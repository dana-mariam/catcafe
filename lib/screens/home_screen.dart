import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/edit_product_screen.dart';
import '../user/product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';

  String userRole = 'user';
  bool isLoadingRole = true;

  final Color backgroundColor = const Color(0xFFF8EBD7);
  final Color cardColor = const Color(0xFFFFFCF6);
  final Color brown = const Color(0xFF713D27);
  final Color lightBrown = const Color(0xFF9A6D58);
  final Color softBrown = const Color(0xFFEAD5BF);

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  // ============================================================
  // USER ROLE
  // ============================================================

  Future<void> loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoadingRole = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (!mounted) return;

      setState(() {
        userRole = data?['role'] ?? 'user';
        isLoadingRole = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        userRole = 'user';
        isLoadingRole = false;
      });
    }
  }

  bool get isAdmin => userRole == 'admin';

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> deleteProduct(
      BuildContext context,
      String productId,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete Product?',
            style: TextStyle(
              color: brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This product will be removed from the menu.',
            style: TextStyle(
              color: lightBrown,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: brown,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
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
        content: Text(
          'Product deleted',
        ),
      ),
    );
  }

  // ============================================================
  // EDIT PRODUCT
  // ============================================================

  void openEditProduct(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          productId: doc.id,
          product: data,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT DETAILS
  // ============================================================

  void openProductDetails(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    final num quantity =
        data['quantity'] ?? 0;

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
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: doc.id,
          product: data,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .orderBy('name')
              .snapshots(),

          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: brown,
                ),
              );
            }

            if (productSnapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong.',
                  style: TextStyle(
                    color: brown,
                  ),
                ),
              );
            }

            final products =
                productSnapshot.data?.docs ?? [];

            final filteredProducts =
            selectedCategoryId == 'all'
                ? products
                : products.where((doc) {
              final data =
              doc.data()
              as Map<String, dynamic>;

              return data['categoryId'] ==
                  selectedCategoryId;
            }).toList();

            return CustomScrollView(
              physics:
              const BouncingScrollPhysics(),

              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // ==================================================
                // HERO
                // ==================================================

                if (products.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        18,
                        4,
                        18,
                        28,
                      ),
                      child:
                      _buildHero(products.first),
                    ),
                  ),

                // ==================================================
                // CATEGORY TITLE
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'EXPLORE OUR MENU',
                    'Find something made for your mood',
                  ),
                ),

                // ==================================================
                // CATEGORIES
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildCategories(),
                ),

                // ==================================================
                // POPULAR TITLE
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      30,
                      18,
                      14,
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCategoryId ==
                                    'all'
                                    ? 'POPULAR TODAY'
                                    : 'MENU ITEMS',
                                style: TextStyle(
                                  color: brown,
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                selectedCategoryId ==
                                    'all'
                                    ? 'Something worth coming back for'
                                    : 'Made fresh for you',
                                style: TextStyle(
                                  color: lightBrown,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${filteredProducts.length} items',
                          style: TextStyle(
                            color: lightBrown,
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // PRODUCT LIST
                // ==================================================

                if (filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyProducts(),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      35,
                    ),

                    sliver: SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final doc =
                          filteredProducts[index];

                          return _buildMenuProduct(
                            context,
                            doc,
                          );
                        },
                        childCount:
                        filteredProducts.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        15,
        16,
        10,
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Cat Cafe',
                  style: TextStyle(
                    color: brown,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'COFFEE • CATS • COZY THINGS',
                  style: TextStyle(
                    color: lightBrown,
                    fontSize: 8,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.brown.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Icon(
              Icons.menu_rounded,
              color: brown,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(
      QueryDocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    final name =
        data['name']?.toString() ?? '';

    final description =
        data['description']?.toString() ?? '';

    final imageUrl =
        data['imageUrl']?.toString() ?? '';

    final price =
        (data['price'] as num?) ?? 0;

    final quantity =
        (data['quantity'] as num?) ?? 0;

    final outOfStock =
        quantity <= 0;

    return GestureDetector(
      onTap: () {
        openProductDetails(
          context,
          doc,
        );
      },

      child: Container(
        height: 245,

        decoration: BoxDecoration(
          color: brown,
          borderRadius:
          BorderRadius.circular(30),

          boxShadow: [
            BoxShadow(
              color:
              Colors.brown.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(30),

          child: Stack(
            children: [
              // IMAGE
              Positioned.fill(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (_, __, ___) {
                    return _heroPlaceholder();
                  },
                )
                    : _heroPlaceholder(),
              ),

              // DARK OVERLAY
              Positioned.fill(
                child: Container(
                  decoration:
                  BoxDecoration(
                    gradient: LinearGradient(
                      begin:
                      Alignment.topCenter,
                      end:
                      Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.03),
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),

              // FEATURED LABEL
              Positioned(
                top: 16,
                left: 16,

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Text(
                    'TODAY\'S PICK',
                    style: TextStyle(
                      color: brown,
                      fontSize: 8,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // ADMIN MENU
              if (isAdmin)
                Positioned(
                  top: 10,
                  right: 10,
                  child:
                  _buildAdminMenu(
                    context,
                    doc,
                    dark: true,
                  ),
                ),

              // BOTTOM CONTENT
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,

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
                          Text(
                            name,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,

                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            description.isEmpty
                                ? 'A cozy favorite from our menu.'
                                : description,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,

                            style:
                            const TextStyle(
                              color:
                              Colors.white70,
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          if (outOfStock)
                            _outOfStockBadge(
                              dark: true,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style:
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w900,
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

  Widget _heroPlaceholder() {
    return Container(
      color: const Color(0xFF8A5A43),
      child: const Center(
        child: Icon(
          Icons.local_cafe_rounded,
          color: Colors.white54,
          size: 55,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
      String title,
      String subtitle,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: TextStyle(
              color: brown,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            subtitle,

            style: TextStyle(
              color: lightBrown,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 91,

      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('name')
            .snapshots(),

        builder:
            (context, snapshot) {
          final categories =
              snapshot.data?.docs ?? [];

          return ListView(
            scrollDirection:
            Axis.horizontal,

            padding:
            const EdgeInsets.fromLTRB(
              18,
              15,
              18,
              0,
            ),

            children: [
              _categoryItem(
                id: 'all',
                title: 'All',
                icon: Icons.apps_rounded,
              ),

              ...categories.map(
                    (doc) {
                  final data =
                  doc.data()
                  as Map<String, dynamic>;

                  final title =
                      data['name']
                          ?.toString() ??
                          '';

                  return _categoryItem(
                    id: doc.id,
                    title: title,
                    icon:
                    _categoryIcon(title),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _categoryItem({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final selected =
        selectedCategoryId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryId = id;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 200,
        ),

        width: 78,

        margin:
        const EdgeInsets.only(
          right: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? brown
              : cardColor,

          borderRadius:
          BorderRadius.circular(22),

          border: Border.all(
            color: selected
                ? brown
                : softBrown,
          ),
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : brown,
              size: 23,
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              title,

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : brown,
                fontSize: 10,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
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

    if (value.contains('drink') ||
        value.contains('juice')) {
      return Icons.local_drink_outlined;
    }

    if (value.contains('tea')) {
      return Icons.emoji_food_beverage_outlined;
    }

    return Icons.restaurant_menu_rounded;
  }

  // ============================================================
  // MENU PRODUCT
  // ============================================================

  Widget _buildMenuProduct(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    final String name =
        data['name']?.toString() ?? '';

    final String description =
        data['description']?.toString() ?? '';

    final String imageUrl =
        data['imageUrl']?.toString() ?? '';

    final String categoryId =
        data['categoryId']?.toString() ?? '';

    final num price =
        (data['price'] as num?) ?? 0;

    final num quantity =
        (data['quantity'] as num?) ?? 0;

    final bool outOfStock =
        quantity <= 0;

    return GestureDetector(
      onTap: () {
        openProductDetails(
          context,
          doc,
        );
      },

      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 13,
        ),

        decoration: BoxDecoration(
          color: cardColor,

          borderRadius:
          BorderRadius.circular(24),

          border: Border.all(
            color:
            const Color(0xFFEEDFCF),
          ),
        ),

        child: Padding(
          padding:
          const EdgeInsets.all(10),

          child: Row(
            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              ClipRRect(
                borderRadius:
                BorderRadius.circular(18),

                child: SizedBox(
                  width: 94,
                  height: 94,

                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,

                    color: outOfStock
                        ? Colors.white
                        .withOpacity(0.35)
                        : null,

                    colorBlendMode:
                    outOfStock
                        ? BlendMode.saturation
                        : null,

                    errorBuilder:
                        (_, __, ___) {
                      return _smallPlaceholder();
                    },
                  )
                      : _smallPlaceholder(),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // INFO
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,

                            maxLines: 1,

                            overflow:
                            TextOverflow.ellipsis,

                            style: TextStyle(
                              color: brown,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ),

                        if (!isAdmin)
                          _favoriteButton(
                            doc.id,
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      description.isEmpty
                          ? 'Freshly prepared for you.'
                          : description,

                      maxLines: 2,

                      overflow:
                      TextOverflow.ellipsis,

                      style: TextStyle(
                        color: lightBrown,
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        _categoryLabel(
                          categoryId,
                        ),

                        const Spacer(),

                        Text(
                          '\$${price.toStringAsFixed(2)}',

                          style: TextStyle(
                            color: brown,
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Row(
                      children: [
                        if (outOfStock)
                          _outOfStockBadge()
                        else
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration:
                                const BoxDecoration(
                                  color:
                                  Color(0xFF76945F),
                                  shape:
                                  BoxShape.circle,
                                ),
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Text(
                                '$quantity available',

                                style:
                                const TextStyle(
                                  color:
                                  Color(0xFF76945F),
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                        const Spacer(),

                        if (isAdmin)
                          _buildAdminMenu(
                            context,
                            doc,
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

  // ============================================================
  // CATEGORY LABEL
  // ============================================================

  Widget _categoryLabel(
      String categoryId,
      ) {
    if (categoryId.isEmpty) {
      return const SizedBox();
    }

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .snapshots(),

      builder:
          (context, snapshot) {
        String name = '';

        if (snapshot.hasData &&
            snapshot.data!.exists) {
          final data =
          snapshot.data!.data();

          name =
              data?['name']
                  ?.toString() ??
                  '';
        }

        if (name.isEmpty) {
          return const SizedBox();
        }

        return Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),

          decoration: BoxDecoration(
            color:
            const Color(0xFFF4E4D2),

            borderRadius:
            BorderRadius.circular(8),
          ),

          child: Text(
            name,

            style: TextStyle(
              color: lightBrown,
              fontSize: 8,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FAVORITE
  // ============================================================

  Widget _favoriteButton(
      String productId,
      ) {
    return FutureBuilder<bool>(
      future: isProductFavorite(
        productId,
      ),

      builder:
          (context, snapshot) {
        final isFavorite =
            snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            await toggleFavorite(
              productId,
            );

            if (mounted) {
              setState(() {});
            }
          },

          child: Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color:
              const Color(0xFFF8EBD7),
              shape: BoxShape.circle,
            ),

            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,

              color: brown,
              size: 17,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ADMIN MENU
  // ============================================================

  Widget _buildAdminMenu(
      BuildContext context,
      QueryDocumentSnapshot doc, {
        bool dark = false,
      }) {
    return Container(
      width: 36,
      height: 36,

      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(0.92)
            : const Color(0xFFF8EBD7),

        shape: BoxShape.circle,
      ),

      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,

        icon: Icon(
          Icons.more_horiz_rounded,
          color: brown,
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

        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'edit',
            child: Text(
              'Edit',
            ),
          ),

          PopupMenuItem(
            value: 'delete',
            child: Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OUT OF STOCK
  // ============================================================

  Widget _outOfStockBadge({
    bool dark = false,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(0.18)
            : const Color(0xFFF2D6D0),

        borderRadius:
        BorderRadius.circular(8),
      ),

      child: Text(
        'OUT OF STOCK',

        style: TextStyle(
          color: dark
              ? Colors.white
              : const Color(0xFFB34C3F),
          fontSize: 8,
          fontWeight:
          FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _smallPlaceholder() {
    return Container(
      color: const Color(0xFFF0DFCC),

      child: Icon(
        Icons.local_cafe_rounded,
        color: lightBrown,
        size: 30,
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyProducts() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Container(
              width: 78,
              height: 78,

              decoration:
              const BoxDecoration(
                color:
                Color(0xFFF1DDC8),
                shape:
                BoxShape.circle,
              ),

              child: Icon(
                Icons.local_cafe_outlined,
                color: brown,
                size: 36,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              'Nothing here yet',
              style: TextStyle(
                color: brown,
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              'Try another category.',
              style: TextStyle(
                color: lightBrown,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FAVORITES FIRESTORE
  // ============================================================

  Future<bool> isProductFavorite(
      String productId,
      ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final doc =
    await FirebaseFirestore.instance
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

    if (user == null) {
      return;
    }

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