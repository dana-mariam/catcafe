import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/ui_kit.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onExplore});

  final VoidCallback? onExplore;

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(String productId) {
    return FirebaseFirestore.instance.collection('products').doc(productId).get();
  }

  Future<void> removeFavorite(
    BuildContext context,
    String userId,
    String productId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Please log in',
          message: 'Sign in to see the drinks you love.',
        ),
      );
    }

    final favoritesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: favoritesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState();
            }
            if (snapshot.hasError) {
              return const ErrorState(message: 'Unable to load favorites.');
            }

            final favorites = snapshot.data?.docs ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Favorites', style: AppTextStyles.display),
                        const SizedBox(height: 4),
                        Text(
                          favorites.isEmpty
                              ? 'Saved for later'
                              : '${favorites.length} saved ${favorites.length == 1 ? 'item' : 'items'}',
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (favorites.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.favorite_border_rounded,
                      assetPath: 'lib/assets/images/cat_logo.png',
                      title: 'Your favorites are waiting',
                      message: 'Tap the heart on a drink you love and it will live here.',
                      actionLabel: onExplore == null ? null : 'Explore products',
                      onAction: onExplore,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent >= 720 ? 3 : 2;
                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final favorite = favorites[index];
                              final data = favorite.data() as Map<String, dynamic>;
                              final productId =
                                  data['productId']?.toString() ?? favorite.id;

                              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                future: getProduct(productId),
                                builder: (context, productSnapshot) {
                                  if (productSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const ColoredBox(
                                      color: AppColors.surface,
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }

                                  if (!productSnapshot.hasData ||
                                      !productSnapshot.data!.exists) {
                                    return const SizedBox.shrink();
                                  }

                                  final product = productSnapshot.data!.data()!;
                                  final name = product['name']?.toString() ?? 'Unnamed Product';
                                  final imageUrl = product['imageUrl']?.toString() ?? '';
                                  final description = product['description']?.toString() ?? '';
                                  final price = product['price'] ?? 0;
                                  final quantity = product['quantity'] ?? 0;
                                  final outOfStock = quantity <= 0;

                                  return ProductCard(
                                    name: name,
                                    price: price is num ? price : 0,
                                    imageUrl: imageUrl,
                                    description: description,
                                    outOfStock: outOfStock,
                                    isFavorite: true,
                                    onFavorite: () =>
                                        removeFavorite(context, user.uid, productId),
                                    onTap: outOfStock
                                        ? () {}
                                        : () {
                                            Navigator.push(
                                              context,
                                              cafeRoute(
                                                ProductDetailsScreen(
                                                  productId: productId,
                                                  product: product,
                                                ),
                                              ),
                                            );
                                          },
                                  );
                                },
                              );
                            },
                            childCount: favorites.length,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
