import 'package:flutter/material.dart';

import '../features/cart/services/cart_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  final CartService _cartService = CartService();

  bool isFavorite = false;
  bool isAddingToCart = false;

  static const Color backgroundColor =
  Color(0xFFF8EBD7);

  static const Color cardColor =
  Color(0xFFFFFCF6);

  static const Color brown =
  Color(0xFF713D27);

  static const Color lightBrown =
  Color(0xFF9A6D58);

  static const Color softBrown =
  Color(0xFFEAD5BF);

  @override
  Widget build(BuildContext context) {
    final String name =
        widget.product['name']?.toString() ?? '';

    final String description =
        widget.product['description']?.toString() ?? '';

    final String imageUrl =
        widget.product['imageUrl']?.toString() ?? '';

    final String categoryName =
        widget.product['categoryName']?.toString() ??
            widget.product['category']?.toString() ??
            '';

    final num price =
        (widget.product['price'] as num?) ?? 0;

    final num quantity =
        (widget.product['quantity'] as num?) ?? 0;

    final bool outOfStock = quantity <= 0;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // BOTTOM ADD TO CART BAR
      // ============================================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            14,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRICE',
                      style: TextStyle(
                        color: lightBrown,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: brown,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    outOfStock || isAddingToCart
                        ? null
                        : addToCart,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      disabledBackgroundColor:
                      const Color(0xFFD6C8B8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(19),
                      ),
                    ),

                    child: isAddingToCart
                        ? const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 19,
                          height: 19,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 9),
                        Text(
                          'ADDING...',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          outOfStock
                              ? Icons
                              .remove_shopping_cart_outlined
                              : Icons
                              .shopping_bag_outlined,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          outOfStock
                              ? 'OUT OF STOCK'
                              : 'ADD TO CART',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: CustomScrollView(
          physics:
          const BouncingScrollPhysics(),
          slivers: [
            // ========================================================
            // APP BAR
            // ========================================================

            SliverAppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              pinned: true,
              expandedHeight: 0,

              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration:
                  const BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons
                          .arrow_back_ios_new_rounded,
                      color: brown,
                      size: 17,
                    ),
                  ),
                ),
              ),

              centerTitle: true,

              title: const Text(
                'Product Details',
                style: TextStyle(
                  color: brown,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),

              actions: [
                Padding(
                  padding:
                  const EdgeInsets.only(
                    right: 8,
                  ),
                  child: Container(
                    decoration:
                    const BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite =
                          !isFavorite;
                        });
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons
                            .favorite_border_rounded,
                        color: brown,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ========================================================
            // CONTENT
            // ========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PRODUCT IMAGE
                    // ==================================================

                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 315,
                          decoration:
                          BoxDecoration(
                            color: cardColor,
                            borderRadius:
                            BorderRadius
                                .circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown
                                    .withOpacity(
                                  0.08,
                                ),
                                blurRadius: 18,
                                offset:
                                const Offset(
                                  0,
                                  7,
                                ),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius
                                .circular(30),
                            child:
                            imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
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

                        // OUT OF STOCK
                        if (outOfStock)
                          Positioned(
                            left: 14,
                            top: 14,
                            child: Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration:
                              BoxDecoration(
                                color: Colors.black
                                    .withOpacity(
                                  0.68,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .inventory_2_outlined,
                                    color:
                                    Colors.white,
                                    size: 13,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'OUT OF STOCK',
                                    style:
                                    TextStyle(
                                      color:
                                      Colors
                                          .white,
                                      fontSize: 9,
                                      fontWeight:
                                      FontWeight
                                          .w900,
                                      letterSpacing:
                                      0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // CATEGORY
                        if (categoryName.isNotEmpty)
                          Positioned(
                            left: 14,
                            bottom: 14,
                            child: Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration:
                              BoxDecoration(
                                color: Colors.white
                                    .withOpacity(
                                  0.92,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  15,
                                ),
                              ),
                              child: Text(
                                categoryName,
                                style:
                                const TextStyle(
                                  color: brown,
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // NAME + PRICE
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                name,
                                style:
                                const TextStyle(
                                  color: brown,
                                  fontSize: 28,
                                  fontWeight:
                                  FontWeight
                                      .w900,
                                  fontFamily:
                                  'serif',
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                categoryName
                                    .isNotEmpty
                                    ? categoryName
                                    : 'CAT CAFE SPECIAL',
                                style:
                                const TextStyle(
                                  color:
                                  lightBrown,
                                  fontSize: 8,
                                  letterSpacing:
                                  1.5,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFFF1DFC9,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),
                          child: Text(
                            '\$${price.toStringAsFixed(2)}',
                            style:
                            const TextStyle(
                              color: brown,
                              fontSize: 17,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 23),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================

                    _sectionCard(
                      icon: Icons
                          .description_outlined,
                      title:
                      'ABOUT THIS PRODUCT',
                      child: Text(
                        description.isEmpty
                            ? 'A delicious choice from our Cat Cafe menu, prepared with care for your cozy café moment.'
                            : description,
                        style:
                        const TextStyle(
                          color:
                          Color(0xFF795548),
                          fontSize: 11,
                          height: 1.55,
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // PRODUCT INFORMATION
                    // ==================================================

                    _sectionCard(
                      icon: Icons
                          .auto_awesome_outlined,
                      title:
                      'PRODUCT INFORMATION',
                      child: Row(
                        children: [
                          Expanded(
                            child: _infoBox(
                              Icons
                                  .inventory_2_outlined,
                              'Available',
                              outOfStock
                                  ? 'Sold out'
                                  : '$quantity items',
                            ),
                          ),

                          const SizedBox(width: 9),

                          Expanded(
                            child: _infoBox(
                              Icons
                                  .shopping_bag_outlined,
                              'Cart',
                              outOfStock
                                  ? 'Unavailable'
                                  : 'Available',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // COZY NOTE
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(
                        17,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF0DDC8,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          22,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration:
                            const BoxDecoration(
                              color: cardColor,
                              shape:
                              BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons
                                  .local_cafe_rounded,
                              color: brown,
                              size: 19,
                            ),
                          ),

                          const SizedBox(
                            width: 11,
                          ),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  'A cozy little choice',
                                  style:
                                  TextStyle(
                                    color: brown,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight
                                        .w900,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Add your favorite to the cart and enjoy your Cat Cafe moment.',
                                  style:
                                  TextStyle(
                                    color:
                                    lightBrown,
                                    fontSize: 9,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(23),
        border: Border.all(
          color: softBrown,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                const BoxDecoration(
                  color: Color(0xFFF2E0CC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: brown,
                  size: 17,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  color: brown,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _infoBox(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: brown,
            size: 18,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: lightBrown,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: brown,
              fontSize: 10,
              fontWeight:
              FontWeight.w800,
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
    return Container(
      color: const Color(0xFFF0DFCC),
      child: const Center(
        child: Icon(
          Icons.local_cafe_rounded,
          color: lightBrown,
          size: 55,
        ),
      ),
    );
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> addToCart() async {
    if (isAddingToCart) {
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      final bool success =
      await _cartService.addToCart(
        productId: widget.productId,
        product: widget.product,
      );

      if (!mounted) return;

      if (success) {
        _showMessage(
          context,
          'Added to your cart ☕',
        );
      } else {
        _showMessage(
          context,
          'This product is out of stock.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        context,
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
        backgroundColor: brown,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }
}