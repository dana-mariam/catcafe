import 'package:flutter/material.dart';

import '../checkout/checkout_address_screen.dart';
import 'models/cart_item_model.dart';
import 'services/cart_service.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartService _cartService = CartService();

  static const Color backgroundColor = Color(0xFFF8EBD7);
  static const Color cardColor = Color(0xFFFFFCF6);
  static const Color brown = Color(0xFF713D27);
  static const Color lightBrown = Color(0xFF9A6D58);
  static const Color softBrown = Color(0xFFEAD5BF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,

        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: brown,
                size: 17,
              ),
            ),
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR CART',
              style: TextStyle(
                color: lightBrown,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'My Cozy Picks',
              style: TextStyle(
                color: brown,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),

        actions: [
          StreamBuilder<List<CartItemModel>>(
            stream: _cartService.getCartItems(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: IconButton(
                  tooltip: 'Clear cart',
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: lightBrown,
                    size: 23,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.getCartItems(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: brown,
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return _errorState(
              'Something went wrong while loading your cart.',
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _emptyCart();
          }

          final double subtotal = items.fold(
            0,
                (sum, item) => sum + item.totalPrice,
          );

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    8,
                    18,
                    20,
                  ),
                  children: [
                    _cartHeader(items.length),

                    const SizedBox(height: 16),

                    ...items.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: _cartItemCard(
                          context,
                          item,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    _cozyNote(),
                  ],
                ),
              ),

              _bottomSummary(
                context,
                subtotal,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // CART HEADER
  // ============================================================

  Widget _cartHeader(int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DDC8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: brown,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A little something for you',
                  style: TextStyle(
                    color: brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'} in your cart',
                  style: const TextStyle(
                    color: lightBrown,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFD49A68),
            size: 18,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _cartItemCard(
      BuildContext context,
      CartItemModel item,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: softBrown,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PRODUCT IMAGE
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFF1DFC9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: item.image.isNotEmpty
                  ? Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _imagePlaceholder();
                },
              )
                  : _imagePlaceholder(),
            ),
          ),

          const SizedBox(width: 13),

          // PRODUCT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: brown,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '\$${item.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    color: lightBrown,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 11),

                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove_rounded,
                      onPressed: () async {
                        try {
                          await _cartService.decreaseQuantity(
                            productId: item.productId,
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          _showMessage(
                            context,
                            e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                          );
                        }
                      },
                    ),

                    Container(
                      width: 38,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: brown,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    _quantityButton(
                      icon: Icons.add_rounded,
                      onPressed: () async {
                        final success =
                        await _cartService.increaseQuantity(
                          productId: item.productId,
                        );

                        if (!success && context.mounted) {
                          _showMessage(
                            context,
                            'You reached the available stock.',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // TOTAL + DELETE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  await _cartService.removeFromCart(
                    productId: item.productId,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFB49A87),
                  size: 18,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: brown,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUANTITY BUTTON
  // ============================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: const Color(0xFFF0DDC8),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Icon(
            icon,
            color: brown,
            size: 16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SUMMARY
  // ============================================================

  Widget _bottomSummary(
      BuildContext context,
      double subtotal,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        15,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUBTOTAL',
                style: TextStyle(
                  color: lightBrown,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: brown,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutAddressScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: const BoxDecoration(
                color: Color(0xFFF0DDC8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: brown,
                size: 42,
              ),
            ),

            const SizedBox(height: 23),

            const Text(
              'Your cart is cozy... and empty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: brown,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'Pick something delicious from our menu and make your cart a little happier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: lightBrown,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COZY NOTE
  // ============================================================

  Widget _cozyNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DDC8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: brown,
              size: 17,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Made for your cozy moment',
                  style: TextStyle(
                    color: brown,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your selected items will stay safely in your cart.',
                  style: TextStyle(
                    color: lightBrown,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.local_cafe_rounded,
        color: lightBrown,
        size: 35,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: lightBrown,
              size: 45,
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: brown,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLEAR CART DIALOG
  // ============================================================

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Clear your cart?',
            style: TextStyle(
              color: brown,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
          content: const Text(
            'All selected products will be removed from your cart.',
            style: TextStyle(
              color: lightBrown,
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: lightBrown,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _cartService.clearCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: brown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}