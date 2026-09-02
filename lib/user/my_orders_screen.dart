import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF8EBD7);
  static const Color cardColor = Color(0xFFFFFCF6);
  static const Color brown = Color(0xFF713D27);
  static const Color lightBrown = Color(0xFF9A6D58);
  static const Color softBrown = Color(0xFFEAD5BF);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Please login first.',
            style: TextStyle(
              color: brown,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          // ======================================================
          // REAL-TIME ORDERS
          // ======================================================

          stream: FirebaseFirestore.instance
              .collection('orders')
              .where(
            'userId',
            isEqualTo: user.uid,
          )
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: brown,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError();
            }

            final allOrders = snapshot.data?.docs ?? [];

            // ==================================================
            // SHOW ACTIVE ORDERS
            // ==================================================

            final orders = allOrders.where((doc) {
              final data =
              doc.data() as Map<String, dynamic>;

              return data['status'] != 'cancelled';
            }).toList();

            // ==================================================
            // NEWEST ORDERS FIRST
            // ==================================================

            orders.sort((a, b) {
              final aData =
              a.data() as Map<String, dynamic>;

              final bData =
              b.data() as Map<String, dynamic>;

              final aTime = aData['createdAt'];
              final bTime = bData['createdAt'];

              if (aTime is Timestamp &&
                  bTime is Timestamp) {
                return bTime.compareTo(aTime);
              }

              return 0;
            });

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildHeader(
                    orders.length,
                  ),
                ),

                // ==================================================
                // EMPTY
                // ==================================================

                if (orders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )

                // ==================================================
                // ORDERS
                // ==================================================

                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      6,
                      18,
                      35,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final doc = orders[index];

                          final data =
                          doc.data()
                          as Map<String, dynamic>;

                          return _buildOrderCard(
                            context,
                            doc.id,
                            data,
                          );
                        },
                        childCount: orders.length,
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

  Widget _buildHeader(int orderCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        17,
        20,
        14,
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
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Orders',
                      style: TextStyle(
                        color: brown,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'YOUR COFFEE JOURNEY',
                      style: TextStyle(
                        color: lightBrown,
                        fontSize: 8,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
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
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: brown,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ======================================================
          // HERO
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: brown,
              borderRadius:
              BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.brown.withOpacity(0.12),
                  blurRadius: 17,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                    Colors.white.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_cafe_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Made with a little love',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        orderCount == 0
                            ? 'Your orders will appear here.'
                            : orderCount == 1
                            ? 'You have 1 active order.'
                            : 'You have $orderCount active orders.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // ORDER HISTORY TITLE
          // ======================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER HISTORY',
                      style: TextStyle(
                        color: brown,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Track your café favorites',
                      style: TextStyle(
                        color: lightBrown,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$orderCount '
                    '${orderCount == 1 ? 'order' : 'orders'}',
                style: TextStyle(
                  color: lightBrown,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard(
      BuildContext context,
      String orderId,
      Map<String, dynamic> data,
      ) {
    // ==========================================================
    // ORDER DATA
    // ==========================================================

    final List<dynamic> items =
    data['items'] is List
        ? data['items'] as List
        : [];

    final double totalAmount =
        (data['totalAmount'] as num?)
            ?.toDouble() ??
            0.0;

    // This status comes directly from Firestore.
    // Because the screen uses snapshots(),
    // it updates automatically in real-time.
    final String status =
        data['status']?.toString() ?? 'pending';

    final String address =
        data['address']?.toString() ??
            'No address';

    final String date =
    _formatDate(data['createdAt']);

    // ==========================================================
    // FIRST PRODUCT
    // ==========================================================

    Map<String, dynamic> firstItem = {};

    if (items.isNotEmpty &&
        items.first is Map) {
      firstItem =
      Map<String, dynamic>.from(
        items.first as Map,
      );
    }

    final String productName =
        firstItem['name']?.toString() ??
            'Product';

    final String imageUrl =
        firstItem['image']?.toString() ?? '';

    // ==========================================================
    // TOTAL QUANTITY
    // ==========================================================

    int totalQuantity = 0;

    for (final item in items) {
      if (item is Map) {
        totalQuantity +=
            (item['quantity'] as num?)
                ?.toInt() ??
                0;
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 17,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(27),
        border: Border.all(
          color: const Color(0xFFEEDFCF),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.brown.withOpacity(0.055),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(27),
        child: Column(
          children: [
            // ==================================================
            // PRODUCT IMAGE
            // ==================================================

            _buildProductImage(
              imageUrl,
              items.length,
            ),

            // ==================================================
            // ORDER INFO
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // PRODUCT NAME + TOTAL
                  // =================================================

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
                              productName,
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color: brown,
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .w900,
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              'ORDER #${_shortOrderId(orderId)}',
                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFFB08B75,
                                ),
                                fontSize: 9,
                                letterSpacing:
                                0.7,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration:
                        BoxDecoration(
                          color: const Color(
                              0xFFF2E1CE),
                          borderRadius:
                          BorderRadius
                              .circular(
                            13,
                          ),
                        ),
                        child: Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style:
                          const TextStyle(
                            color: brown,
                            fontSize: 14,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 16),

                  // =================================================
                  // DETAILS
                  // =================================================

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      backgroundColor,
                      borderRadius:
                      BorderRadius
                          .circular(
                        18,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                          _buildInfoItem(
                            Icons
                                .shopping_bag_outlined,
                            'Quantity',
                            '$totalQuantity',
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 30,
                          color: softBrown,
                        ),

                        Expanded(
                          child:
                          _buildInfoItem(
                            Icons
                                .calendar_today_outlined,
                            'Date',
                            date,
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 30,
                          color: softBrown,
                        ),

                        // =================================================
                        // REAL-TIME STATUS
                        // =================================================

                        Expanded(
                          child:
                          _buildStatusItem(
                            status,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  // =================================================
                  // PRODUCTS COUNT
                  // =================================================

                  if (items.length > 1)
                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration:
                      BoxDecoration(
                        color: const Color(
                            0xFFF2E1CE),
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .inventory_2_outlined,
                            color:
                            lightBrown,
                            size: 16,
                          ),
                          const SizedBox(
                              width: 8),
                          Text(
                            '${items.length} different products in this order',
                            style:
                            const TextStyle(
                              color: brown,
                              fontSize: 10,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (items.length > 1)
                    const SizedBox(
                        height: 12),

                  // =================================================
                  // DELIVERY ADDRESS
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      backgroundColor,
                      borderRadius:
                      BorderRadius
                          .circular(
                        15,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Icon(
                          Icons
                              .location_on_outlined,
                          color:
                          lightBrown,
                          size: 17,
                        ),

                        const SizedBox(
                            width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              const Text(
                                'Delivery Address',
                                style:
                                TextStyle(
                                  color:
                                  Color(
                                    0xFFB08B75,
                                  ),
                                  fontSize: 8,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                  height: 3),

                              Text(
                                address,
                                maxLines: 2,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                const TextStyle(
                                  color: brown,
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // CANCEL ORDER
                  // =================================================
                  //
                  // The old static Pending badge was removed.
                  // Status is already displayed above and is real-time.
                  //

                  if (status == 'pending')
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        top: 10,
                      ),
                      child: Align(
                        alignment:
                        Alignment
                            .centerRight,
                        child:
                        TextButton.icon(
                          onPressed: () {
                            _showCancelNotAvailableMessage(
                              context,
                            );
                          },
                          style:
                          TextButton
                              .styleFrom(
                            foregroundColor:
                            const Color(
                              0xFFB85B4E,
                            ),
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                          ),
                          icon:
                          const Icon(
                            Icons
                                .close_rounded,
                            size: 15,
                          ),
                          label:
                          const Text(
                            'Cancel Order',
                            style:
                            TextStyle(
                              fontSize: 10,
                              fontWeight:
                              FontWeight
                                  .w800,
                            ),
                          ),
                        ),
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
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage(
      String imageUrl,
      int itemCount,
      ) {
    return Stack(
      children: [
        SizedBox(
          height: 175,
          width: double.infinity,
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) {
              return _buildImagePlaceholder();
            },
          )
              : _buildImagePlaceholder(),
        ),

        // ========================================================
        // GRADIENT
        // ========================================================

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 65,
            decoration:
            BoxDecoration(
              gradient:
              LinearGradient(
                begin:
                Alignment.topCenter,
                end:
                Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black
                      .withOpacity(0.32),
                ],
              ),
            ),
          ),
        ),

        // ========================================================
        // ITEMS BADGE
        // ========================================================

        Positioned(
          right: 13,
          bottom: 12,
          child: Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration:
            BoxDecoration(
              color: Colors.white
                  .withOpacity(0.88),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              itemCount == 1
                  ? '1 item'
                  : '$itemCount items',
              style:
              const TextStyle(
                color: brown,
                fontSize: 8,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF1DECA),
      child: const Center(
        child: Icon(
          Icons.local_cafe_rounded,
          size: 50,
          color: lightBrown,
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _buildInfoItem(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: lightBrown,
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Color(0xFFB08B75),
                  fontSize: 8,
                ),
              ),

              const SizedBox(
                  height: 2),

              Text(
                value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color: brown,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REAL-TIME STATUS ITEM
  // ============================================================

  Widget _buildStatusItem(
      String status,
      ) {
    final String label =
    _displayStatus(status);

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          status == 'pending'
              ? Icons.timelapse_rounded
              : Icons.info_outline_rounded,
          size: 16,
          color: lightBrown,
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style:
                TextStyle(
                  color:
                  Color(0xFFB08B75),
                  fontSize: 8,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color: brown,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPLAY STATUS
  // ============================================================

  String _displayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';

      case 'processing':
        return 'Processing';

      case 'out for delivery':
      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      case 'completed':
        return 'Completed';

      case 'preparing':
        return 'Preparing';

      default:
        return _capitalize(status);
    }
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
              width: 105,
              height: 105,
              decoration:
              const BoxDecoration(
                color:
                Color(0xFFF1DECA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .receipt_long_outlined,
                color: brown,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No orders yet',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color: brown,
                fontSize: 21,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your coffee orders will appear here.\n'
                  'Find something delicious on the menu\n'
                  'and make your first order.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color: lightBrown,
                fontSize: 10,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 9,
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
              child: const Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .local_cafe_outlined,
                    color: brown,
                    size: 15,
                  ),

                  SizedBox(width: 6),

                  Text(
                    'Your next favorite is waiting',
                    style:
                    TextStyle(
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
        const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: brown,
              size: 45,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load your orders',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color: brown,
                fontSize: 16,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Please try again later.',
              style:
              TextStyle(
                color: lightBrown,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL MESSAGE
  // ============================================================

  void _showCancelNotAvailableMessage(
      BuildContext context,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Order cancellation will be available soon.',
        ),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SHORT ORDER ID
  // ============================================================

  String _shortOrderId(
      String id,
      ) {
    if (id.length <= 8) {
      return id.toUpperCase();
    }

    return id
        .substring(0, 8)
        .toUpperCase();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
      dynamic timestamp,
      ) {
    if (timestamp is Timestamp) {
      final date =
      timestamp.toDate();

      final day = date.day
          .toString()
          .padLeft(2, '0');

      final month = date.month
          .toString()
          .padLeft(2, '0');

      final year =
      date.year.toString();

      return '$day/$month/$year';
    }

    return 'Just now';
  }

  // ============================================================
  // CAPITALIZE
  // ============================================================

  String _capitalize(
      String value,
      ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}