import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/edit_product_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_text_styles.dart';
import '../features/cart/services/cart_service.dart';
import '../user/product_details_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/ui_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenProfile});

  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';
  String userRole = 'user';
  bool isLoadingRole = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoadingRole = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        userRole = doc.data()?['role'] ?? 'user';
        isLoadingRole = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        userRole = 'user';
        isLoadingRole = false;
      });
    }
  }

  bool get isAdmin => userRole == 'admin';

  Future<void> deleteProduct(BuildContext context, String productId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.extraLarge),
          title: Text('Delete product?', style: AppTextStyles.section),
          content: Text(
            'This product will be removed from the menu.',
            style: AppTextStyles.secondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await FirebaseFirestore.instance.collection('products').doc(productId).delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
  }

  void openEditProduct(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Navigator.push(
      context,
      cafeRoute(
        EditProductScreen(productId: doc.id, product: data),
      ),
    );
  }

  void openProductDetails(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final num quantity = data['quantity'] ?? 0;

    if (!isAdmin && quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is currently out of stock.')),
      );
      return;
    }

    Navigator.push(
      context,
      cafeRoute(
        ProductDetailsScreen(productId: doc.id, product: data),
      ),
    );
  }

  Future<void> addProductToCart(QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final num quantity = data['quantity'] ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is currently out of stock.')),
      );
      return;
    }

    try {
      final success = await _cartService.addToCart(
        productId: doc.id,
        product: data,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Added to cart' : 'This product is out of stock.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .orderBy('name')
              .snapshots(),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState();
            }

            if (productSnapshot.hasError) {
              return const ErrorState(message: 'We could not load the menu.');
            }

            final products = productSnapshot.data?.docs ?? [];
            final query = searchQuery.trim().toLowerCase();

            final filteredProducts = products.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final matchesCategory = selectedCategoryId == 'all' ||
                  data['categoryId'] == selectedCategoryId;
              final name = data['name']?.toString().toLowerCase() ?? '';
              final matchesSearch = query.isEmpty || name.contains(query);
              return matchesCategory && matchesSearch;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: AppSearchField(
                      controller: searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                  ),
                ),
                if (products.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: _buildHero(products.first),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Explore the menu',
                    subtitle: 'Coffee, treats, and cozy favorites',
                  ),
                ),
                SliverToBoxAdapter(child: _buildCategories()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 14),
                    child: SectionHeader(
                      title: selectedCategoryId == 'all' ? 'Popular today' : 'Menu items',
                      subtitle: query.isEmpty
                          ? 'Fresh from the café'
                          : 'Search results',
                      trailing: Text(
                        '${filteredProducts.length}',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                ),
                if (filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.local_cafe_outlined,
                      title: query.isNotEmpty ? 'No matches' : 'Nothing here yet',
                      message: query.isNotEmpty
                          ? 'Try a different name or category.'
                          : 'Try another category.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width >= 720 ? 3 : 2;
                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildGridProduct(
                                context,
                                filteredProducts[index],
                              );
                            },
                            childCount: filteredProducts.length,
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

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          Image.asset(
            'lib/assets/images/cat_logo.png',
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.local_cafe_rounded,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppTextStyles.caption),
                Text(
                  'Purr & Pour',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.person_outline_rounded,
            onPressed: widget.onOpenProfile ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHero(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name']?.toString() ?? '';
    final description = data['description']?.toString() ?? '';
    final imageUrl = data['imageUrl']?.toString() ?? '';
    final price = (data['price'] as num?) ?? 0;
    final quantity = (data['quantity'] as num?) ?? 0;
    final outOfStock = quantity <= 0;

    return GestureDetector(
      onTap: () => openProductDetails(context, doc),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: AppRadius.extraLarge,
          boxShadow: AppShadows.soft,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.extraLarge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductImage(imageUrl: imageUrl),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    "Today's pick",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.brown,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              if (isAdmin)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildAdminMenu(context, doc, dark: true),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description.isEmpty
                                ? 'A cozy favorite from our menu.'
                                : description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.secondary.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          if (outOfStock) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Out of stock',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 56,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          final categories = snapshot.data?.docs ?? [];
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            children: [
              AppChip(
                label: 'All',
                icon: Icons.grid_view_rounded,
                selected: selectedCategoryId == 'all',
                onTap: () => setState(() => selectedCategoryId = 'all'),
              ),
              ...categories.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = data['name']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: AppChip(
                    label: title,
                    icon: _categoryIcon(title),
                    selected: selectedCategoryId == doc.id,
                    onTap: () => setState(() => selectedCategoryId = doc.id),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('coffee') || value.contains('cafe')) {
      return Icons.coffee_rounded;
    }
    if (value.contains('dessert') || value.contains('cake') || value.contains('sweet')) {
      return Icons.cake_outlined;
    }
    if (value.contains('drink') || value.contains('juice')) {
      return Icons.local_drink_outlined;
    }
    if (value.contains('tea')) {
      return Icons.emoji_food_beverage_outlined;
    }
    return Icons.restaurant_menu_rounded;
  }

  Widget _buildGridProduct(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name']?.toString() ?? '';
    final description = data['description']?.toString() ?? '';
    final imageUrl = data['imageUrl']?.toString() ?? '';
    final price = (data['price'] as num?) ?? 0;
    final quantity = (data['quantity'] as num?) ?? 0;
    final outOfStock = quantity <= 0;

    if (isAdmin) {
      return ProductCard(
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        outOfStock: outOfStock,
        onTap: () => openProductDetails(context, doc),
        adminMenu: _buildAdminMenu(context, doc),
      );
    }

    return FutureBuilder<bool>(
      future: isProductFavorite(doc.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return ProductCard(
          name: name,
          price: price,
          imageUrl: imageUrl,
          description: description,
          outOfStock: outOfStock,
          isFavorite: isFavorite,
          onTap: () => openProductDetails(context, doc),
          onFavorite: () async {
            await toggleFavorite(doc.id);
            if (mounted) setState(() {});
          },
          onAdd: () => addProductToCart(doc),
        );
      },
    );
  }

  Widget _buildAdminMenu(
    BuildContext context,
    QueryDocumentSnapshot doc, {
    bool dark = false,
  }) {
    return Material(
      color: dark ? Colors.white : AppColors.cream,
      shape: const CircleBorder(),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_horiz_rounded, color: AppColors.brown, size: 20),
        onSelected: (value) {
          if (value == 'edit') openEditProduct(context, doc);
          if (value == 'delete') deleteProduct(context, doc.id);
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Future<bool> isProductFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .get();

    return doc.exists;
  }

  Future<void> toggleFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    final existing = await favoriteRef.get();
    if (existing.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
