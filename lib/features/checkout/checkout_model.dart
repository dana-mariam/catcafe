import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  CheckoutItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory CheckoutItemModel.fromMap(Map<String, dynamic> map) {
    return CheckoutItemModel(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }
}

class CheckoutOrderModel {
  final String orderId;
  final String userId;
  final String address;
  final List<CheckoutItemModel> items;
  final double totalAmount;
  final DateTime createdAt;
  final String status;

  CheckoutOrderModel({
    required this.orderId,
    required this.userId,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'address': address,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory CheckoutOrderModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    final itemsData = map['items'] as List<dynamic>? ?? [];

    return CheckoutOrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      address: map['address'] ?? '',
      items: itemsData
          .map(
            (item) => CheckoutItemModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }
}