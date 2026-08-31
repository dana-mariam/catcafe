import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER ID
  // ============================================================

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // CART COLLECTION
  // users/{userId}/cart
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart');
  }

  // ============================================================
  // PRODUCTS COLLECTION
  // products
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _productsCollection {
    return _firestore.collection('products');
  }

  // ============================================================
  // GET CART ITEMS
  // ============================================================

  Stream<List<CartItemModel>> getCartItems() {
    return _cartCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItemModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // ============================================================
  // ADD PRODUCT TO CART
  // ============================================================

  Future<bool> addToCart({
    required String productId,
    required Map<String, dynamic> product,
  }) async {
    final productRef = _productsCollection.doc(productId);
    final cartItemRef = _cartCollection.doc(productId);

    return await _firestore.runTransaction<bool>(
          (transaction) async {
        // Get product stock
        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          return false;
        }

        final productData = productSnapshot.data()!;

        final int availableQuantity =
            (productData['quantity'] as num?)?.toInt() ?? 0;

        // Product is out of stock
        if (availableQuantity <= 0) {
          return false;
        }

        // Check if product already exists in cart
        final cartSnapshot = await transaction.get(cartItemRef);

        if (cartSnapshot.exists) {
          final int currentCartQuantity =
              (cartSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;

          // Don't allow cart quantity to exceed stock
          if (currentCartQuantity >= availableQuantity) {
            return false;
          }

          transaction.update(cartItemRef, {
            'quantity': currentCartQuantity + 1,
          });
        } else {
          // Add new product to cart
          final cartItem = CartItemModel(
            productId: productId,
            name: product['name'] ?? '',
            image: product['imageUrl'] ?? '',
            price: (product['price'] as num?)?.toDouble() ?? 0.0,
            quantity: 1,
          );

          transaction.set(
            cartItemRef,
            cartItem.toFirestore(),
          );
        }

        return true;
      },
    );
  }

  // ============================================================
  // INCREASE QUANTITY
  // ============================================================

  Future<bool> increaseQuantity({
    required String productId,
  }) async {
    final productRef = _productsCollection.doc(productId);
    final cartItemRef = _cartCollection.doc(productId);

    return await _firestore.runTransaction<bool>(
          (transaction) async {
        final productSnapshot = await transaction.get(productRef);
        final cartSnapshot = await transaction.get(cartItemRef);

        if (!productSnapshot.exists || !cartSnapshot.exists) {
          return false;
        }

        final productData = productSnapshot.data()!;
        final cartData = cartSnapshot.data()!;

        final int availableQuantity =
            (productData['quantity'] as num?)?.toInt() ?? 0;

        final int currentCartQuantity =
            (cartData['quantity'] as num?)?.toInt() ?? 0;

        // Maximum allowed quantity is the product stock
        if (currentCartQuantity >= availableQuantity) {
          return false;
        }

        transaction.update(cartItemRef, {
          'quantity': currentCartQuantity + 1,
        });

        return true;
      },
    );
  }

  // ============================================================
  // DECREASE QUANTITY
  // ============================================================

  Future<void> decreaseQuantity({
    required String productId,
  }) async {
    final cartItemRef = _cartCollection.doc(productId);

    final snapshot = await cartItemRef.get();

    if (!snapshot.exists) {
      return;
    }

    final int currentQuantity =
        (snapshot.data()?['quantity'] as num?)?.toInt() ?? 1;

    if (currentQuantity > 1) {
      await cartItemRef.update({
        'quantity': currentQuantity - 1,
      });
    } else {
      await cartItemRef.delete();
    }
  }

  // ============================================================
  // REMOVE PRODUCT FROM CART
  // ============================================================

  Future<void> removeFromCart({
    required String productId,
  }) async {
    await _cartCollection.doc(productId).delete();
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<void> clearCart() async {
    final snapshot = await _cartCollection.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============================================================
  // CHECKOUT
  //
  // 1. Create Order
  // 2. Update Product Stock
  // 3. Clear Cart
  // ============================================================

  Future<void> checkout({
    required String address,
  }) async {
    final userId = _userId;

    // ------------------------------------------------------------
    // GET CART
    // ------------------------------------------------------------

    final cartSnapshot = await _cartCollection.get();

    if (cartSnapshot.docs.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    // ------------------------------------------------------------
    // GET USER INFORMATION
    // ------------------------------------------------------------

    final userSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!userSnapshot.exists) {
      throw Exception('User information not found.');
    }

    final userData = userSnapshot.data() ?? {};

    // ------------------------------------------------------------
    // PREPARE ORDER ITEMS
    // ------------------------------------------------------------

    final List<Map<String, dynamic>> orderItems = [];

    double totalAmount = 0.0;

    for (final cartDoc in cartSnapshot.docs) {
      final cartItem = CartItemModel.fromFirestore(
        cartDoc.data(),
        cartDoc.id,
      );

      orderItems.add({
        'productId': cartItem.productId,
        'name': cartItem.name,
        'image': cartItem.image,
        'price': cartItem.price,
        'quantity': cartItem.quantity,
        'totalPrice': cartItem.totalPrice,
      });

      totalAmount += cartItem.totalPrice;
    }

    // ------------------------------------------------------------
    // CREATE ORDER REFERENCE
    // ------------------------------------------------------------

    final orderRef = _firestore.collection('orders').doc();

    // ------------------------------------------------------------
    // CHECK STOCK FIRST
    // ------------------------------------------------------------

    final List<Map<String, dynamic>> productsToUpdate = [];

    for (final cartDoc in cartSnapshot.docs) {
      final cartItem = CartItemModel.fromFirestore(
        cartDoc.data(),
        cartDoc.id,
      );

      final productRef =
      _productsCollection.doc(cartItem.productId);

      final productSnapshot = await productRef.get();

      if (!productSnapshot.exists) {
        throw Exception(
          'Product "${cartItem.name}" is no longer available.',
        );
      }

      final productData = productSnapshot.data() ?? {};

      final int currentStock =
          (productData['quantity'] as num?)?.toInt() ?? 0;

      // Check if enough stock is available
      if (currentStock < cartItem.quantity) {
        throw Exception(
          'Not enough stock for ${cartItem.name}. '
              'Only $currentStock available.',
        );
      }

      productsToUpdate.add({
        'reference': productRef,
        'newQuantity': currentStock - cartItem.quantity,
      });
    }

    // ------------------------------------------------------------
    // FIRESTORE BATCH
    // ------------------------------------------------------------

    final batch = _firestore.batch();

    // ============================================================
    // STEP 1: CREATE ORDER
    // ============================================================

    batch.set(orderRef, {
      'userId': userId,
      'userName': userData['name'] ??
          userData['username'] ??
          '',

      'userEmail': userData['email'] ??
          _auth.currentUser?.email ??
          '',

      'address': address,

      'items': orderItems,

      'totalAmount': totalAmount,

      'createdAt': FieldValue.serverTimestamp(),

      'status': 'pending',
    });

    // ============================================================
    // STEP 2: UPDATE PRODUCT STOCK
    // ============================================================

    for (final product in productsToUpdate) {
      final productRef =
      product['reference']
      as DocumentReference<Map<String, dynamic>>;

      final int newQuantity =
      product['newQuantity'] as int;

      batch.update(productRef, {
        'quantity': newQuantity,
      });
    }

    // ============================================================
    // STEP 3: CLEAR CART
    // ============================================================

    for (final cartDoc in cartSnapshot.docs) {
      batch.delete(cartDoc.reference);
    }

    // ------------------------------------------------------------
    // EXECUTE ALL OPERATIONS
    // ------------------------------------------------------------

    await batch.commit();
  }
}