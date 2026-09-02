import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../features/cart/services/cart_service.dart';
import '../widgets/app_button.dart';
import '../widgets/product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  final String productId;
  final Map<String, dynamic> product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartService _cartService = CartService();
  bool isFavorite = false;
  bool isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.product['name']?.toString() ?? '';
    final description = widget.product['description']?.toString() ?? '';
    final imageUrl = widget.product['imageUrl']?.toString() ?? '';
    final categoryName = widget.product['categoryName']?.toString() ??
        widget.product['category']?.toString() ??
        '';
    final price = (widget.product['price'] as num?) ?? 0;
    final quantity = (widget.product['quantity'] as num?) ?? 0;
    final outOfStock = quantity <= 0;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: AppShadows.nav,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: AppTextStyles.caption),
                    Text('\$${price.toStringAsFixed(2)}', style: AppTextStyles.price.copyWith(fontSize: 22)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: outOfStock ? 'Out of stock' : 'Add to cart',
                  loading: isAddingToCart,
                  icon: outOfStock
                      ? Icons.remove_shopping_cart_outlined
                      : Icons.shopping_bag_outlined,
                  onPressed: outOfStock ? null : addToCart,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Text('Product details', style: AppTextStyles.section.copyWith(fontSize: 16)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppIconButton(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onPressed: () => setState(() => isFavorite = !isFavorite),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.05,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: AppRadius.extraLarge,
                              child: ProductImage(imageUrl: imageUrl),
                            ),
                          ),
                          if (outOfStock)
                            Positioned(
                              left: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: AppRadius.pillRadius,
                                ),
                                child: Text(
                                  'Out of stock',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          if (categoryName.isNotEmpty)
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.94),
                                  borderRadius: AppRadius.pillRadius,
                                ),
                                child: Text(categoryName, style: AppTextStyles.caption),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(name, style: AppTextStyles.display),
                    const SizedBox(height: 6),
                    Text(
                      categoryName.isNotEmpty ? categoryName : 'Café special',
                      style: AppTextStyles.overline,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.extraLarge,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About this product', style: AppTextStyles.section.copyWith(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            description.isEmpty
                                ? 'A delicious choice from our Cat Cafe menu, prepared with care for your cozy café moment.'
                                : description,
                            style: AppTextStyles.secondary.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            'Available',
                            outOfStock ? 'Sold out' : '$quantity in stock',
                            Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            'Cart',
                            outOfStock ? 'Unavailable' : 'Ready to add',
                            Icons.shopping_bag_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brown, size: 20),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.product),
        ],
      ),
    );
  }

  Future<void> addToCart() async {
    if (isAddingToCart) return;
    setState(() => isAddingToCart = true);

    try {
      final success = await _cartService.addToCart(
        productId: widget.productId,
        product: widget.product,
      );
      if (!mounted) return;
      _showMessage(success ? 'Added to your cart' : 'This product is out of stock.');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
