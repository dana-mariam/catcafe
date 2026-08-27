import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
//1
  static Future<void> createOrder({
    required String productId,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final userRef = _firestore
        .collection('users')
        .doc(user.uid);

    final productRef = _firestore
        .collection('products')
        .doc(productId);

    final orderRef = _firestore
        .collection('orders')
        .doc();
//2
    await _firestore.runTransaction(
          (transaction) async {
        // ==========================================
        // GET PRODUCT
        // ==========================================

        final productSnapshot =
        await transaction.get(
          productRef,
        );

        if (!productSnapshot.exists) {
          throw Exception(
            'Product no longer exists.',
          );
        }

        final productData =
        productSnapshot.data();

        if (productData == null) {
          throw Exception(
            'Product data is unavailable.',
          );
        }
//3
        final int quantity =
        (productData['quantity'] as num? ?? 0)
            .toInt();

        if (quantity <= 0) {
          throw Exception(
            'This product is out of stock.',
          );
        }

        // ==========================================
        // GET USER
        // ==========================================
//4
        final userSnapshot =
        await transaction.get(
          userRef,
        );

        if (!userSnapshot.exists) {
          throw Exception(
            'User profile not found.',
          );
        }

        final userData =
        userSnapshot.data();

        if (userData == null) {
          throw Exception(
            'User data is unavailable.',
          );
        }

        // ==========================================
        // PRODUCT DATA
        // ==========================================

        final String productName =
            productData['name']
                ?.toString() ??
                '';

        final num price =
            (productData['price'] as num?) ??
                0;

        final String imageUrl =
            productData['imageUrl']
                ?.toString() ??
                '';

        final String categoryId =
            productData['categoryId']
                ?.toString() ??
                '';

        // ==========================================
        // GET CATEGORY NAME
        // ==========================================

        String categoryName =
            'Uncategorized';

        if (categoryId.isNotEmpty) {
          final categoryRef =
          _firestore
              .collection('categories')
              .doc(categoryId);

          final categorySnapshot =
          await transaction.get(
            categoryRef,
          );

          if (categorySnapshot.exists) {
            final categoryData =
            categorySnapshot.data();

            if (categoryData != null) {
              categoryName =
                  categoryData['name']
                      ?.toString() ??
                      'Uncategorized';
            }
          }
        }

        // ==========================================
        // USER DATA
        // ==========================================

        final String userName =
            userData['name']
                ?.toString() ??
                'Unknown User';

        final String userPhone =
            userData['phone']
                ?.toString() ??
                'No phone';

        // ==========================================
        // CREATE ORDER
        // ==========================================
//5
        transaction.set(
          orderRef,
          {
            'userId': user.uid,

            'productId': productId,

            'productName': productName,

            'categoryId': categoryId,

            'category': categoryName,

            'imageUrl': imageUrl,

            'userName': userName,

            'userPhone': userPhone,

            'quantity': 1,

            'totalPrice': price,

            'status': 'pending',

            'createdAt':
            FieldValue.serverTimestamp(),
          },
        );

        // ==========================================
        // DECREASE PRODUCT QUANTITY
        // ==========================================
//6
        transaction.update(
          productRef,
          {
            'quantity': quantity - 1,
          },
        );
      },
    );
  }
}