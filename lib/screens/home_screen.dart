import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/edit_product_screen.dart';
import '../animations/home/home_animations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../features/cart/services/cart_service.dart';
import '../user/product_details_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/ui_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenProfile,
    this.onOpenAdopt,
  });

  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenAdopt;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';
  String userRole = 'user';
  bool isLoadingRole = true;
  String searchQuery = '';

  final TextEditingController searchController =
  TextEditingController();

  final CartService _cartService = CartService();

  static const _residents = [
    {
      'name': 'Milo',
      'note': 'Naps by the pastry case',
      'image':
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
    },
    {
      'name': 'Luna',
      'note': 'Claims the sunny window',
      'image':
      'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
    },
    {
      'name': 'Oliver',
      'note': 'Supervises every pour',
      'image':
      'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=800',
    },
    {
      'name': 'Bella',
      'note': 'Greets the afternoon crowd',
      'image':
      'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=800',
    },
  ];

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

  Future<void> deleteProduct(
      BuildContext context,
      String productId,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.extraLarge,
          ),
          title: Text(
            'Delete product?',
            style: AppTextStyles.section,
          ),
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
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product deleted'),
      ),
    );
  }

  void openEditProduct(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    final data = doc.data() as Map<String, dynamic>;

    Navigator.push(
      context,
      cafeRoute(
        EditProductScreen(
          productId: doc.id,
          product: data,
        ),
      ),
    );
  }

  void openProductDetails(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    final data = doc.data() as Map<String, dynamic>;
    final num quantity = data['quantity'] ?? 0;

    if (!isAdmin && quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This product is currently out of stock.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      cafeRoute(
        ProductDetailsScreen(
          productId: doc.id,
          product: data,
        ),
      ),
    );
  }

  Future<void> addProductToCart(
      QueryDocumentSnapshot doc,
      ) async {
    final data = doc.data() as Map<String, dynamic>;
    final num quantity = data['quantity'] ?? 0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This product is currently out of stock.',
          ),
        ),
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
          content: Text(
            success
                ? 'Added to cart'
                : 'This product is out of stock.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  Map<String, dynamic> _data(
      QueryDocumentSnapshot doc,
      ) {
    return doc.data() as Map<String, dynamic>;
  }

  String? _badgeFor(
      Map<String, dynamic> data,
      ) {
    final quantity = (data['quantity'] as num?) ?? 0;

    if (quantity > 0 && quantity <= 5) {
      return 'Limited';
    }

    final createdAt = data['createdAt'];

    if (createdAt is Timestamp) {
      final age =
      DateTime.now().difference(createdAt.toDate());

      if (age.inDays <= 14) {
        return 'New';
      }
    }

    return null;
  }

  QueryDocumentSnapshot _pickFeatured(
      List<QueryDocumentSnapshot> products,
      ) {
    QueryDocumentSnapshot? withImage;

    for (final doc in products) {
      final data = _data(doc);

      final qty =
          (data['quantity'] as num?) ?? 0;

      final image =
          data['imageUrl']?.toString() ?? '';

      if (qty > 0 && image.isNotEmpty) {
        return doc;
      }

      if (withImage == null && image.isNotEmpty) {
        withImage = doc;
      }
    }

    return withImage ?? products.first;
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
            if (productSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const LoadingState();
            }

            if (productSnapshot.hasError) {
              return const ErrorState(
                message: 'We could not load the menu.',
              );
            }

            final products =
                productSnapshot.data?.docs ?? [];

            final query =
            searchQuery.trim().toLowerCase();

            final browsingAll =
                selectedCategoryId == 'all' &&
                    query.isEmpty;

            final List<QueryDocumentSnapshot>
            filteredProducts;

            if (selectedCategoryId == 'all') {
              filteredProducts = products.where((doc) {
                final data = _data(doc);

                final name =
                    data['name']
                        ?.toString()
                        .toLowerCase() ??
                        '';

                return query.isEmpty ||
                    name.contains(query);
              }).toList();
            } else {
              filteredProducts = products.where((doc) {
                final data = _data(doc);

                final categoryId =
                    data['categoryId']
                        ?.toString() ??
                        '';

                final name =
                    data['name']
                        ?.toString()
                        .toLowerCase() ??
                        '';

                final matchesCategory =
                    categoryId ==
                        selectedCategoryId;

                final matchesSearch =
                    query.isEmpty ||
                        name.contains(query);

                return matchesCategory &&
                    matchesSearch;
              }).toList();
            }

            QueryDocumentSnapshot? featured;

            List<QueryDocumentSnapshot>
            favoritesRail = const [];

            List<QueryDocumentSnapshot>
            menuGrid = filteredProducts;

            if (browsingAll &&
                products.isNotEmpty) {
              featured =
                  _pickFeatured(products);

              final remaining = products
                  .where(
                    (doc) => doc.id != featured!.id,
              )
                  .toList();

              inStockFirst(remaining);

              favoritesRail =
                  remaining.take(6).toList();

              menuGrid = filteredProducts;
            }

            return CustomScrollView(
              physics:
              const BouncingScrollPhysics(),
              slivers: [
                // ==================================================
                // HEADER
                // Animation: Fade + Slide
                // ==================================================

                SliverToBoxAdapter(
                  child: HomeEntranceAnimation(
                    delay:
                    const Duration(milliseconds: 100),
                    child: _buildHeader(),
                  ),
                ),

                // ==================================================
                // SEARCH
                // Animation: Fade + Slide
                // ==================================================

                SliverToBoxAdapter(
                  child: HomeEntranceAnimation(
                    delay:
                    const Duration(milliseconds: 180),
                    offset:
                    const Offset(0, 0.05),
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        AppSpacing.xl,
                      ),
                      child: AppSearchField(
                        controller:
                        searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // HERO
                // Animation:
                // 1. Fade + Slide entrance
                // 2. Subtle breathing image/shadow
                // ==================================================

                if (featured != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xxl,
                      ),
                      child: HomeEntranceAnimation(
                        delay:
                        const Duration(milliseconds: 280),
                        offset:
                        const Offset(0, 0.08),
                        child: HomeHeroAnimation(
                          child:
                          _buildHero(featured),
                        ),
                      ),
                    ),
                  ),

                // ==================================================
                // MENU INTRO
                // Animation: AnimatedSwitcher
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE MENU',
                          style:
                          AppTextStyles.overline,
                        ),

                        const SizedBox(height: 4),

                        AnimatedSwitcher(
                          duration:
                          const Duration(
                            milliseconds: 300,
                          ),
                          transitionBuilder:
                              (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child:
                              SlideTransition(
                                position:
                                Tween<Offset>(
                                  begin:
                                  const Offset(
                                    0,
                                    0.12,
                                  ),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            selectedCategoryId ==
                                'all'
                                ? 'What are you in the mood for?'
                                : 'Explore the menu',
                            key: ValueKey(
                              selectedCategoryId,
                            ),
                            style:
                            AppTextStyles.section,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Coffee, pastries, and quiet little indulgences',
                          style:
                          AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // CATEGORIES
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildCategories(),
                ),

                // ==================================================
                // FROM THE BAR
                // ==================================================

                if (favoritesRail.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.only(
                        top: AppSpacing.section,
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FROM THE BAR',
                              style:
                              AppTextStyles.overline,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cat-approved favorites',
                              style:
                              AppTextStyles.section,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Today's little indulgence",
                              style:
                              AppTextStyles.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 270,
                      child: ListView.separated(
                        padding:
                        const EdgeInsets.fromLTRB(
                          20,
                          16,
                          20,
                          4,
                        ),
                        scrollDirection:
                        Axis.horizontal,
                        physics:
                        const BouncingScrollPhysics(),
                        itemCount:
                        favoritesRail.length,
                        separatorBuilder:
                            (_, __) =>
                        const SizedBox(
                          width: 12,
                        ),
                        itemBuilder:
                            (context, index) {
                          return SizedBox(
                            width: 180,
                            child:
                            _buildRailProduct(
                              context,
                              favoritesRail[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // ==================================================
                // HOUSE MENU
                // Animation: AnimatedSwitcher
                // ==================================================

                if (!browsingAll ||
                    menuGrid.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        14,
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                AnimatedSwitcher(
                                  duration:
                                  const Duration(
                                    milliseconds: 250,
                                  ),
                                  transitionBuilder:
                                      (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    query.isNotEmpty
                                        ? 'SEARCH'
                                        : 'HOUSE MENU',
                                    key: ValueKey(
                                      query.isNotEmpty,
                                    ),
                                    style:
                                    AppTextStyles
                                        .overline,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                AnimatedSwitcher(
                                  duration:
                                  const Duration(
                                    milliseconds: 300,
                                  ),
                                  transitionBuilder:
                                      (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child:
                                      SlideTransition(
                                        position:
                                        Tween<Offset>(
                                          begin:
                                          const Offset(
                                            0,
                                            0.12,
                                          ),
                                          end:
                                          Offset.zero,
                                        ).animate(
                                            animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    selectedCategoryId ==
                                        'all'
                                        ? (query.isEmpty
                                        ? 'Something cozy for you'
                                        : 'Results')
                                        : 'Menu items',
                                    key: ValueKey(
                                      '$selectedCategoryId-$query',
                                    ),
                                    style:
                                    AppTextStyles
                                        .section,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  query.isEmpty
                                      ? 'Made with love, served with purrs'
                                      : 'Matching pours and plates',
                                  style:
                                  AppTextStyles
                                      .secondary,
                                ),
                              ],
                            ),
                          ),

                          AnimatedSwitcher(
                            duration:
                            const Duration(
                              milliseconds: 250,
                            ),
                            transitionBuilder:
                                (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              '${(browsingAll ? menuGrid : filteredProducts).length}',
                              key: ValueKey(
                                (browsingAll
                                    ? menuGrid
                                    : filteredProducts)
                                    .length,
                              ),
                              style:
                              AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ==================================================
                // EMPTY STATE
                // ==================================================

                if (products.isEmpty ||
                    (!browsingAll &&
                        filteredProducts.isEmpty))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        40,
                      ),
                      child: EmptyState(
                        icon:
                        Icons.local_cafe_outlined,
                        assetPath:
                        'lib/assets/images/cat_logo.png',
                        title: query.isNotEmpty
                            ? 'No pour by that name'
                            : products.isEmpty
                            ? 'The kitchen is quiet'
                            : 'Nothing on this shelf yet',
                        message: query.isNotEmpty
                            ? 'Try another name, or browse the full menu.'
                            : products.isEmpty
                            ? 'The menu will appear here when the café is ready.'
                            : 'Another category may have what you are craving.',
                      ),
                    ),
                  )

                // ==================================================
                // PRODUCT GRID
                // ==================================================

                else if ((browsingAll
                    ? menuGrid
                    : filteredProducts)
                    .isNotEmpty)
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      32,
                    ),
                    sliver: SliverLayoutBuilder(
                      builder:
                          (context, constraints) {
                        final width =
                            constraints
                                .crossAxisExtent;

                        final columns =
                        width >= 720 ? 3 : 2;

                        final items = browsingAll
                            ? menuGrid
                            : filteredProducts;

                        return SliverGrid(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                            columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate:
                          SliverChildBuilderDelegate(
                                (context, index) {
                              return _buildGridProduct(
                                context,
                                items[index],
                              );
                            },
                            childCount:
                            items.length,
                          ),
                        );
                      },
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child:
                    SizedBox(height: 32),
                  ),

                // ==================================================
                // THE HOUSE
                // ==================================================

                if (browsingAll)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        32,
                      ),
                      child: _buildCafeStory(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==============================================================
  // STOCK SORT
  // ==============================================================

  void inStockFirst(
      List<QueryDocumentSnapshot> products,
      ) {
    products.sort((a, b) {
      final aQty =
          (_data(a)['quantity'] as num?) ?? 0;

      final bQty =
          (_data(b)['quantity'] as num?) ?? 0;

      final aStock = aQty > 0 ? 0 : 1;
      final bStock = bQty > 0 ? 0 : 1;

      return aStock.compareTo(bStock);
    });
  }

  // ==============================================================
  // HEADER
  // ==============================================================

  Widget _buildHeader() {
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        16,
        16,
        4,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/images/cat_logo.png',
            width: 44,
            height: 44,
            errorBuilder: (_, __, ___) =>
            const Icon(
              Icons.local_cafe_rounded,
              color: AppColors.brown,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting · CAT CAFÉ',
                  style:
                  AppTextStyles.overline,
                ),

                const SizedBox(height: 2),

                Text(
                  'Purr & Pour',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  AppTextStyles.pageTitle
                      .copyWith(
                    fontSize: 24,
                  ),
                ),

                Text(
                  'Your cozy little corner',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  AppTextStyles.caption
                      .copyWith(
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          AppIconButton(
            icon:
            Icons.person_outline_rounded,
            onPressed:
            widget.onOpenProfile ?? () {},
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HERO
  // ==============================================================

  Widget _buildHero(
      QueryDocumentSnapshot doc,
      ) {
    final data = _data(doc);

    final name =
        data['name']?.toString() ?? '';

    final imageUrl =
        data['imageUrl']?.toString() ?? '';

    final price =
        (data['price'] as num?) ?? 0;

    final quantity =
        (data['quantity'] as num?) ?? 0;

    final outOfStock =
        quantity <= 0;

    final screenHeight =
        MediaQuery.sizeOf(context).height;

    final heroHeight =
    screenHeight < 680
        ? 210.0
        : 246.0;

    return GestureDetector(
      onTap: () =>
          openProductDetails(context, doc),
      child: Container(
        height: heroHeight,
        decoration: BoxDecoration(
          borderRadius:
          AppRadius.extraLarge,
          boxShadow:
          AppShadows.soft,
        ),
        child: ClipRRect(
          borderRadius:
          AppRadius.extraLarge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductImage(
                imageUrl: imageUrl,
              ),

              DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment.topCenter,
                    end:
                    Alignment.bottomCenter,
                    colors: [
                      AppColors.espresso
                          .withValues(
                        alpha: 0.12,
                      ),
                      AppColors.espresso
                          .withValues(
                        alpha: 0.28,
                      ),
                      AppColors.espresso
                          .withValues(
                        alpha: 0.78,
                      ),
                    ],
                    stops: const [
                      0,
                      0.42,
                      1,
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.surface
                        .withValues(
                      alpha: 0.94,
                    ),
                    borderRadius:
                    AppRadius.pillRadius,
                  ),
                  child: Text(
                    "TODAY'S PICK",
                    style:
                    AppTextStyles
                        .overline
                        .copyWith(
                      color:
                      AppColors.brown,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

              if (isAdmin)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildAdminMenu(
                    context,
                    doc,
                    dark: true,
                  ),
                ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coffee tastes better with company.',
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      AppTextStyles.display
                          .copyWith(
                        color: Colors.white,
                        fontSize:
                        screenHeight < 680
                            ? 22
                            : 26,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                AppTextStyles
                                    .product
                                    .copyWith(
                                  color:
                                  Colors.white,
                                ),
                              ),

                              Text(
                                outOfStock
                                    ? 'Out of stock'
                                    : '\$${price.toStringAsFixed(2)} · Meet your new favorite brew',
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                AppTextStyles
                                    .secondary
                                    .copyWith(
                                  color:
                                  Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            AppColors.surface,
                            borderRadius:
                            AppRadius
                                .pillRadius,
                          ),
                          child: Text(
                            'Taste it',
                            style:
                            AppTextStyles
                                .button
                                .copyWith(
                              color:
                              AppColors.brown,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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

  // ==============================================================
  // CATEGORIES
  // ==============================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 64,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          final categories =
              snapshot.data?.docs ?? [];

          return ListView(
            scrollDirection:
            Axis.horizontal,
            padding:
            const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              0,
            ),
            children: [
              AppChip(
                label: 'All',
                icon:
                Icons.grid_view_rounded,
                selected:
                selectedCategoryId ==
                    'all',
                onTap: () {
                  setState(() {
                    selectedCategoryId =
                    'all';
                  });
                },
              ),

              ...categories.map((doc) {
                final data =
                doc.data()
                as Map<String, dynamic>;

                final title =
                    data['name']
                        ?.toString() ??
                        '';

                if (title.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    left: 8,
                  ),
                  child: AppChip(
                    label: title,
                    icon:
                    _categoryIcon(title),
                    selected:
                    selectedCategoryId ==
                        doc.id,
                    onTap: () {
                      setState(() {
                        selectedCategoryId =
                            doc.id;
                      });
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  IconData _categoryIcon(
      String category,
      ) {
    final value =
    category.toLowerCase();

    if (value.contains('coffee') ||
        value.contains('cafe')) {
      return Icons.coffee_rounded;
    }

    if (value.contains('dessert') ||
        value.contains('cake') ||
        value.contains('sweet')) {
      return Icons.cake_outlined;
    }

    if (value.contains('pastry') ||
        value.contains('pastries') ||
        value.contains('bakery')) {
      return Icons.bakery_dining_outlined;
    }

    if (value.contains('drink') ||
        value.contains('juice') ||
        value.contains('cold')) {
      return Icons.local_drink_outlined;
    }

    if (value.contains('tea')) {
      return Icons
          .emoji_food_beverage_outlined;
    }

    if (value.contains('cat')) {
      return Icons.pets_rounded;
    }

    return Icons
        .restaurant_menu_rounded;
  }

  // ==============================================================
  // CAFE STORY
  // ==============================================================

  Widget _buildCafeStory() {
    final cat =
    _residents[
    DateTime.now().day %
        _residents.length];

    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius:
        AppRadius.extraLarge,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'THE HOUSE',
            style:
            AppTextStyles.overline,
          ),

          const SizedBox(height: 6),

          Text(
            'Made for coffee lovers & cat people',
            style:
            AppTextStyles.section
                .copyWith(
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'A quiet table, a warm cup, and a few residents who run the place.',
            style:
            AppTextStyles.secondary,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              ClipRRect(
                borderRadius:
                AppRadius.medium,
                child: Image.network(
                  cat['image']!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                      Container(
                        width: 64,
                        height: 64,
                        color:
                        AppColors.soft,
                        child:
                        const Icon(
                          Icons.pets_rounded,
                          color:
                          AppColors.brown,
                        ),
                      ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Cat of the day',
                      style:
                      AppTextStyles
                          .caption,
                    ),

                    Text(
                      cat['name']!,
                      style:
                      AppTextStyles
                          .product,
                    ),

                    Text(
                      cat['note']!,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      AppTextStyles
                          .secondary
                          .copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.onOpenAdopt !=
                  null)
                TextButton(
                  onPressed:
                  widget.onOpenAdopt,
                  child:
                  const Text(
                    'Meet them',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // GRID PRODUCT
  // ==============================================================

  Widget _buildGridProduct(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    return _buildProductCard(
      context,
      doc,
      rail: false,
    );
  }

  // ==============================================================
  // RAIL PRODUCT
  // ==============================================================

  Widget _buildRailProduct(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    return _buildProductCard(
      context,
      doc,
      rail: true,
    );
  }

  // ==============================================================
  // PRODUCT CARD
  // Animation: Press Scale
  // ==============================================================

  Widget _buildProductCard(
      BuildContext context,
      QueryDocumentSnapshot doc, {
        required bool rail,
      }) {
    final data = _data(doc);

    final name =
        data['name']?.toString() ?? '';

    final imageUrl =
        data['imageUrl']?.toString() ?? '';

    final price =
        (data['price'] as num?) ?? 0;

    final quantity =
        (data['quantity'] as num?) ?? 0;

    final outOfStock =
        quantity <= 0;

    final description =
        data['description']
            ?.toString() ??
            '';

    if (isAdmin) {
      return HomePressScale(
        child: ProductCard(
          name: name,
          price: price,
          imageUrl: imageUrl,
          description:
          description.isEmpty
              ? null
              : description,
          outOfStock: outOfStock,
          onTap: () =>
              openProductDetails(
                context,
                doc,
              ),
          adminMenu:
          _buildAdminMenu(
            context,
            doc,
          ),
        ),
      );
    }

    return FutureBuilder<bool>(
      future:
      isProductFavorite(doc.id),
      builder:
          (context, snapshot) {
        final isFavorite =
            snapshot.data ?? false;

        return HomePressScale(
          child: ProductCard(
            name: name,
            price: price,
            imageUrl: imageUrl,
            description:
            description.isEmpty
                ? null
                : description,
            outOfStock:
            outOfStock,
            isFavorite:
            isFavorite,
            onTap: () =>
                openProductDetails(
                  context,
                  doc,
                ),
            onFavorite:
                () async {
              await toggleFavorite(
                doc.id,
              );

              if (mounted) {
                setState(() {});
              }
            },
            onAdd:
                () => addProductToCart(
              doc,
            ),
          ),
        );
      },
    );
  }

  // ==============================================================
  // ADMIN MENU
  // ==============================================================

  Widget _buildAdminMenu(
      BuildContext context,
      QueryDocumentSnapshot doc, {
        bool dark = false,
      }) {
    return Material(
      color: dark
          ? Colors.white
          : AppColors.cream,
      shape:
      const CircleBorder(),
      child:
      PopupMenuButton<String>(
        padding:
        EdgeInsets.zero,
        icon: const Icon(
          Icons.more_horiz_rounded,
          color:
          AppColors.brown,
          size: 20,
        ),
        onSelected: (value) {
          if (value == 'edit') {
            openEditProduct(
              context,
              doc,
            );
          }

          if (value == 'delete') {
            deleteProduct(
              context,
              doc.id,
            );
          }
        },
        itemBuilder:
            (context) => const [
          PopupMenuItem(
            value: 'edit',
            child:
            Text('Edit'),
          ),
          PopupMenuItem(
            value: 'delete',
            child:
            Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // FAVORITES
  // ==============================================================

  Future<bool> isProductFavorite(
      String productId,
      ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final doc =
    await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .get();

    return doc.exists;
  }

  Future<void> toggleFavorite(
      String productId,
      ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final favoriteRef =
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    final existing =
    await favoriteRef.get();

    if (existing.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'productId': productId,
        'createdAt':
        FieldValue.serverTimestamp(),
      });
    }
  }
}