class CartItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromFirestore(
      Map<String, dynamic> data,
      String documentId,
      ) {
    return CartItemModel(
      productId: data['productId'] ?? documentId,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? productId,
    String? name,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}