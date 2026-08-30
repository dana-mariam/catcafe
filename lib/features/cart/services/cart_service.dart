import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart');
  }

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

    return await _firestore.runTransaction<bool>((transaction) async {
      final productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        return false;
      }

      final productData = productSnapshot.data()!;

      final int availableQuantity =
          (productData['quantity'] as num?)?.toInt() ?? 0;

      if (availableQuantity <= 0) {
        return false;
      }

      final cartSnapshot = await transaction.get(cartItemRef);

      if (cartSnapshot.exists) {
        final currentCartQuantity =
            (cartSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;

        // Don't allow cart quantity to exceed stock.
        if (currentCartQuantity >= availableQuantity) {
          return false;
        }

        transaction.update(cartItemRef, {
          'quantity': currentCartQuantity + 1,
        });
      } else {
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
    });
  }

  // ============================================================
  // INCREASE QUANTITY
  // ============================================================

  Future<bool> increaseQuantity({
    required String productId,
  }) async {
    final productRef = _productsCollection.doc(productId);
    final cartItemRef = _cartCollection.doc(productId);

    return await _firestore.runTransaction<bool>((transaction) async {
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

      // Maximum allowed quantity is the product stock.
      if (currentCartQuantity >= availableQuantity) {
        return false;
      }

      transaction.update(cartItemRef, {
        'quantity': currentCartQuantity + 1,
      });

      return true;
    });
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

    final currentQuantity =
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

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
