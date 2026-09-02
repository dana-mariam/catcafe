import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';
import '../checkout/checkout_address_screen.dart';
import 'models/cart_item_model.dart';
import 'services/cart_service.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key, this.onShopNow});

  final VoidCallback? onShopNow;
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your cart', style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
            Text('Ready when you are', style: AppTextStyles.caption),
          ],
        ),
        actions: [
          StreamBuilder<List<CartItemModel>>(
            stream: _cartService.getCartItems(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear cart',
                onPressed: () => _showClearCartDialog(context),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          if (snapshot.hasError) {
            return const ErrorState(
              message: 'Something went wrong while loading your cart.',
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              assetPath: 'lib/assets/images/cat_logo.png',
              title: 'Your cart is empty',
              message: 'Add something delicious to get started.',
              actionLabel: onShopNow == null ? null : 'Shop now',
              onAction: onShopNow,
            );
          }

          final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _cartItem(context, items[index]);
                  },
                ),
              ),
              _summary(context, subtotal, items.length),
            ],
          );
        },
      ),
    );
  }

  Widget _cartItem(BuildContext context, CartItemModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.large,
            child: SizedBox(
              width: 84,
              height: 84,
              child: ProductImage(imageUrl: item.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.product),
                const SizedBox(height: 4),
                Text('\$${item.price.toStringAsFixed(2)} each', style: AppTextStyles.caption),
                const SizedBox(height: 10),
                QuantitySelector(
                  quantity: item.quantity,
                  onDecrease: () async {
                    try {
                      await _cartService.decreaseQuantity(productId: item.productId);
                    } catch (e) {
                      if (!context.mounted) return;
                      _showMessage(context, e.toString().replaceFirst('Exception: ', ''));
                    }
                  },
                  onIncrease: () async {
                    final success = await _cartService.increaseQuantity(
                      productId: item.productId,
                    );
                    if (!success && context.mounted) {
                      _showMessage(context, 'You reached the available stock.');
                    }
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _cartService.removeFromCart(productId: item.productId),
                icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 20),
              ),
              Text('\$${item.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.price),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, double subtotal, int count) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.nav,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('$count ${count == 1 ? 'item' : 'items'}', style: AppTextStyles.secondary),
                const Spacer(),
                Text('\$${subtotal.toStringAsFixed(2)}', style: AppTextStyles.price.copyWith(fontSize: 22)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Checkout',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  cafeRoute(const CheckoutAddressScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.extraLarge),
          title: Text('Clear your cart?', style: AppTextStyles.section),
          content: Text(
            'All selected products will be removed from your cart.',
            style: AppTextStyles.secondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _cartService.clearCart();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
