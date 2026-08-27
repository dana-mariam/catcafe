import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  final Color backgroundColor =
  const Color(0xFFF8EBD7);

  final Color cardColor =
  const Color(0xFFFFFCF6);

  final Color brown =
  const Color(0xFF713D27);

  final Color lightBrown =
  const Color(0xFF9A6D58);

  final Color softBrown =
  const Color(0xFFEAD5BF);

  Future<DocumentSnapshot<Map<String, dynamic>>>
  getProduct(
      String productId,
      ) async {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Removed from favorites',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not remove favorite',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor:
        backgroundColor,

        body: Center(
          child: Text(
            'Please login first.',
            style: TextStyle(
              color: brown,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final favoritesStream =
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots();

    return Scaffold(
      backgroundColor:
      backgroundColor,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: favoritesStream,

          builder:
              (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child:
                CircularProgressIndicator(
                  color: brown,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError();
            }

            final favorites =
                snapshot.data?.docs ?? [];

            return CustomScrollView(
              physics:
              const BouncingScrollPhysics(),

              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child:
                  _buildHeader(
                    favorites.length,
                  ),
                ),

                // ==================================================
                // EMPTY
                // ==================================================

                if (favorites.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,

                    child:
                    _buildEmptyState(),
                  )

                // ==================================================
                // FAVORITES LIST
                // ==================================================

                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      35,
                    ),

                    sliver: SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final favorite =
                          favorites[index];

                          final data =
                          favorite.data()
                          as Map<String,
                              dynamic>;

                          final productId =
                              data['productId']
                                  ?.toString() ??
                                  favorite.id;

                          return FutureBuilder<
                              DocumentSnapshot<
                                  Map<String,
                                      dynamic>>>(
                            future:
                            getProduct(
                              productId,
                            ),

                            builder:
                                (
                                context,
                                productSnapshot,
                                ) {
                              if (productSnapshot
                                  .connectionState ==
                                  ConnectionState
                                      .waiting) {
                                return _loadingItem();
                              }

                              if (!productSnapshot
                                  .hasData ||
                                  !productSnapshot
                                      .data!
                                      .exists) {
                                return const SizedBox();
                              }

                              final product =
                              productSnapshot
                                  .data!
                                  .data()!;

                              return _buildFavoriteItem(
                                context,
                                user.uid,
                                productId,
                                product,
                              );
                            },
                          );
                        },

                        childCount:
                        favorites.length,
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

  Widget _buildHeader(
      int count,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        17,
        20,
        15,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      'Your Favorites',
                      style: TextStyle(
                        color: brown,
                        fontSize: 25,
                        fontWeight:
                        FontWeight.w900,
                        fontFamily:
                        'serif',
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'COZY PICKS • JUST FOR YOU',
                      style: TextStyle(
                        color:
                        lightBrown,
                        fontSize: 8,
                        letterSpacing:
                        1.8,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 45,
                height: 45,

                decoration:
                BoxDecoration(
                  color: cardColor,
                  shape:
                  BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown
                          .withOpacity(
                        0.06,
                      ),
                      blurRadius: 10,
                      offset:
                      const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),

                child: Icon(
                  Icons
                      .favorite_rounded,
                  color: brown,
                  size: 21,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            width:
            double.infinity,

            padding:
            const EdgeInsets.all(
              17,
            ),

            decoration:
            BoxDecoration(
              color: brown,

              borderRadius:
              BorderRadius.circular(
                24,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.brown
                      .withOpacity(
                    0.12,
                  ),
                  blurRadius: 15,
                  offset:
                  const Offset(
                    0,
                    6,
                  ),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,

                  decoration:
                  BoxDecoration(
                    color: Colors.white
                        .withOpacity(
                      0.13,
                    ),
                    shape:
                    BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons
                        .favorite_border_rounded,
                    color:
                    Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      const Text(
                        'Little things you love',
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize: 14,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        count == 1
                            ? 'You saved 1 favorite from our menu.'
                            : 'You saved $count favorites from our menu.',

                        style:
                        const TextStyle(
                          color:
                          Colors.white70,
                          fontSize:
                          9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          Row(
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
                      'SAVED FOR LATER',
                      style:
                      TextStyle(
                        color: brown,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Your favorite café moments',
                      style:
                      TextStyle(
                        color:
                        lightBrown,
                        fontSize:
                        10,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$count ${count == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color:
                  lightBrown,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAVORITE ITEM
  // ============================================================

  Widget _buildFavoriteItem(
      BuildContext context,
      String userId,
      String productId,
      Map<String, dynamic> product,
      ) {
    final name =
        product['name']
            ?.toString() ??
            'Unnamed Product';

    final imageUrl =
        product['imageUrl']
            ?.toString() ??
            '';

    final description =
        product['description']
            ?.toString() ??
            '';

    final categoryId =
        product['categoryId']
            ?.toString() ??
            '';

    final num price =
        product['price'] ?? 0;

    final num quantity =
        product['quantity'] ?? 0;

    final outOfStock =
        quantity <= 0;

    return GestureDetector(
      onTap: outOfStock
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(
                  productId:
                  productId,
                  product:
                  product,
                ),
          ),
        );
      },

      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 14,
        ),

        decoration:
        BoxDecoration(
          color: cardColor,

          borderRadius:
          BorderRadius.circular(
            25,
          ),

          border: Border.all(
            color:
            const Color(
              0xFFEEDFCF,
            ),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.brown
                  .withOpacity(
                0.045,
              ),
              blurRadius: 12,
              offset:
              const Offset(
                0,
                5,
              ),
            ),
          ],
        ),

        child: Padding(
          padding:
          const EdgeInsets.all(
            10,
          ),

          child: Row(
            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      19,
                    ),

                    child: SizedBox(
                      width: 108,
                      height: 125,

                      child: imageUrl
                          .isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit:
                        BoxFit.cover,

                        color:
                        outOfStock
                            ? Colors
                            .white
                            .withOpacity(
                          0.45,
                        )
                            : null,

                        colorBlendMode:
                        outOfStock
                            ? BlendMode
                            .saturation
                            : null,

                        errorBuilder:
                            (
                            _,
                            __,
                            ___,
                            ) {
                          return _imagePlaceholder();
                        },
                      )
                          : _imagePlaceholder(),
                    ),
                  ),

                  if (outOfStock)
                    Positioned(
                      left: 7,
                      bottom: 7,

                      child:
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          8,
                          vertical:
                          5,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.red
                              .withOpacity(
                            0.88,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            10,
                          ),
                        ),

                        child:
                        const Text(
                          'SOLD OUT',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            7,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // INFO
              // ==================================================

              Expanded(
                child: SizedBox(
                  height: 125,

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      // TOP ROW
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Expanded(
                            child:
                            Text(
                              name,

                              maxLines:
                              2,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              TextStyle(
                                color:
                                brown,
                                fontSize:
                                16,
                                fontWeight:
                                FontWeight
                                    .w900,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          GestureDetector(
                            onTap: () {
                              removeFavorite(
                                context,
                                userId,
                                productId,
                              );
                            },

                            child:
                            Container(
                              width: 34,
                              height: 34,

                              decoration:
                              const BoxDecoration(
                                color:
                                Color(
                                  0xFFF3DFCA,
                                ),
                                shape:
                                BoxShape
                                    .circle,
                              ),

                              child:
                              Icon(
                                Icons
                                    .favorite_rounded,
                                color:
                                brown,
                                size:
                                17,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      // CATEGORY
                      if (categoryId
                          .isNotEmpty)
                        _categoryLabel(
                          categoryId,
                        ),

                      const SizedBox(
                        height: 5,
                      ),

                      // DESCRIPTION
                      Expanded(
                        child: Text(
                          description.isEmpty
                              ? 'A cozy favorite from our menu.'
                              : description,

                          maxLines: 2,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          TextStyle(
                            color:
                            lightBrown,
                            fontSize:
                            9,
                            height:
                            1.35,
                          ),
                        ),
                      ),

                      // BOTTOM
                      Row(
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',

                            style:
                            TextStyle(
                              color:
                              brown,
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),

                          const Spacer(),

                          if (!outOfStock)
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,

                                  decoration:
                                  const BoxDecoration(
                                    color:
                                    Color(
                                      0xFF76945F,
                                    ),
                                    shape:
                                    BoxShape
                                        .circle,
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                  5,
                                ),

                                Text(
                                  '$quantity available',

                                  style:
                                  const TextStyle(
                                    color:
                                    Color(
                                      0xFF6D8B5B,
                                    ),
                                    fontSize:
                                    8,
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _categoryLabel(
      String categoryId,
      ) {
    return FutureBuilder<
        DocumentSnapshot<
            Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .get(),

      builder:
          (context, snapshot) {
        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const SizedBox();
        }

        final data =
        snapshot.data!.data();

        final name =
            data?['name']
                ?.toString() ??
                '';

        if (name.isEmpty) {
          return const SizedBox();
        }

        return Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFFF3E3D1,
            ),

            borderRadius:
            BorderRadius.circular(
              8,
            ),
          ),

          child: Text(
            name,

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

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
  // LOADING ITEM
  // ============================================================

  Widget _loadingItem() {
    return Container(
      height: 145,

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      decoration:
      BoxDecoration(
        color: cardColor,

        borderRadius:
        BorderRadius.circular(
          25,
        ),
      ),

      child: Center(
        child:
        CircularProgressIndicator(
          color: brown,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      color:
      const Color(0xFFF0DFCC),

      child: Icon(
        Icons
            .local_cafe_rounded,
        color: lightBrown,
        size: 34,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 35,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration:
              const BoxDecoration(
                color:
                Color(0xFFF1DECA),
                shape:
                BoxShape.circle,
              ),

              child: Icon(
                Icons
                    .favorite_border_rounded,
                color: brown,
                size: 48,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              'Nothing saved yet',
              textAlign:
              TextAlign.center,

              style: TextStyle(
                color: brown,
                fontSize: 20,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              'When something makes you say\n'
                  '"I need this", tap the heart\n'
                  'and it will live here.',
              textAlign:
              TextAlign.center,

              style: TextStyle(
                color: lightBrown,
                fontSize: 11,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 8,
              ),

              decoration:
              BoxDecoration(
                color: cardColor,

                borderRadius:
                BorderRadius.circular(
                  20,
                ),

                border: Border.all(
                  color: softBrown,
                ),
              ),

              child: Row(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  Icon(
                    Icons
                        .favorite_rounded,
                    color: brown,
                    size: 14,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    'Tap the heart on any product',
                    style: TextStyle(
                      color: brown,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .error_outline_rounded,
              color: brown,
              size: 45,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Unable to load favorites',
              style: TextStyle(
                color: brown,
                fontSize: 16,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              'Please try again later.',
              style: TextStyle(
                color: lightBrown,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}