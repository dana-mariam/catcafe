import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cart/models/cart_item_model.dart';
import 'checkout_model.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // CHECKOUT
  // ============================================================

  Future<String> checkout({
    required String address,
    required List<CartItemModel> cartItems,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in before placing an order.');
    }

    if (address.trim().isEmpty) {
      throw Exception('Please enter your delivery address.');
    }

    if (cartItems.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final orderItems = cartItems
        .map(
          (item) => CheckoutItemModel(
        productId: item.productId,
        name: item.name,
        image: item.image,
        price: item.price,
        quantity: item.quantity,
      ),
    )
        .toList();

    final totalAmount = orderItems.fold<double>(
      0,
          (sum, item) => sum + item.totalPrice,
    );

    final orderReference = _firestore.collection('orders').doc();

    final order = CheckoutOrderModel(
      orderId: orderReference.id,
      userId: user.uid,
      address: address.trim(),
      items: orderItems,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      status: 'pending',
    );

    // ==========================================================
    // STEP 1 + STEP 2
    // Create Order + Update Stock
    // ==========================================================

    await _firestore.runTransaction((transaction) async {
      final productSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final item in cartItems) {
        final productReference = _firestore
            .collection('products')
            .doc(item.productId);

        final productSnapshot = await transaction.get(
          productReference,
        );

        if (!productSnapshot.exists) {
          throw Exception(
            'Product "${item.name}" is no longer available.',
          );
        }

        productSnapshots.add(productSnapshot);
      }

      // --------------------------------------------------------
      // Check stock first
      // --------------------------------------------------------

      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];

        final productData =
        productSnapshots[i].data();

        if (productData == null) {
          throw Exception(
            'Could not load product "${item.name}".',
          );
        }

        final currentStock =
        (productData['quantity'] ?? 0) as int;

        if (currentStock < item.quantity) {
          throw Exception(
            'Not enough stock for "${item.name}".',
          );
        }
      }

      // --------------------------------------------------------
      // STEP 1: Create Order
      // --------------------------------------------------------

      transaction.set(
        orderReference,
        order.toMap(),
      );

      // --------------------------------------------------------
      // STEP 2: Decrease Product Stock
      // --------------------------------------------------------

      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];

        final productReference = _firestore
            .collection('products')
            .doc(item.productId);

        final productData =
        productSnapshots[i].data()!;

        final currentStock =
        (productData['quantity'] ?? 0) as int;

        final newStock =
            currentStock - item.quantity;

        transaction.update(
          productReference,
          {
            'quantity': newStock,
          },
        );
      }
    });

    // ============================================================
    // STEP 3: CLEAR CART
    // ============================================================

    final cartSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    final batch = _firestore.batch();

    for (final document in cartSnapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();

    return orderReference.id;
  }
}