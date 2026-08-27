import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  // ============================================================
  // COLORS
  // ============================================================

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

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> cancelOrder(
      BuildContext context,
      String orderId,
      Map<String, dynamic> orderData,
      ) async {
    final shouldCancel =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(26),
          ),

          title: const Text(
            'Cancel Order?',
            style: TextStyle(
              color: brown,
              fontSize: 19,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          content: const Text(
            'Are you sure you want to cancel this order? '
                'The product will be returned to stock.',
            style: TextStyle(
              color: lightBrown,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          actionsPadding:
          const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            12,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Keep Order',
                style: TextStyle(
                  color: brown,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Cancel Order',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      final orderRef =
      FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);

      final productId =
      orderData['productId']
          ?.toString();

      if (productId == null ||
          productId.isEmpty) {
        throw Exception(
          'Product information is missing.',
        );
      }

      final productRef =
      FirebaseFirestore.instance
          .collection('products')
          .doc(productId);

      await FirebaseFirestore.instance
          .runTransaction(
            (transaction) async {
          final orderSnapshot =
          await transaction.get(
            orderRef,
          );

          final productSnapshot =
          await transaction.get(
            productRef,
          );

          if (!orderSnapshot.exists) {
            throw Exception(
              'Order no longer exists.',
            );
          }

          final currentOrder =
          orderSnapshot.data();

          if (currentOrder == null) {
            throw Exception(
              'Order data is unavailable.',
            );
          }

          if (currentOrder['status'] ==
              'cancelled') {
            throw Exception(
              'This order is already cancelled.',
            );
          }

          if (!productSnapshot.exists) {
            throw Exception(
              'Product no longer exists.',
            );
          }

          final productData =
          productSnapshot.data();

          final currentQuantity =
          (productData?['quantity']
          as num? ??
              0)
              .toInt();

          // Mark order as cancelled
          transaction.update(
            orderRef,
            {
              'status': 'cancelled',
              'cancelledAt':
              FieldValue
                  .serverTimestamp(),
            },
          );

          // Return product to stock
          transaction.update(
            productRef,
            {
              'quantity':
              currentQuantity + 1,
            },
          );
        },
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order cancelled successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
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

    return Scaffold(
      backgroundColor:
      backgroundColor,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream:
          FirebaseFirestore.instance
              .collection('orders')
              .where(
            'userId',
            isEqualTo: user.uid,
          )
              .snapshots(),

          builder:
              (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
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

            final allOrders =
                snapshot.data?.docs ?? [];

            // Cancelled orders stay in Firestore
            // for Admin Orders.
            //
            // The user only sees active orders.
            final orders =
            allOrders.where((doc) {
              final data =
              doc.data()
              as Map<String, dynamic>;

              return data['status'] !=
                  'cancelled';
            }).toList();

            // Sort newest first
            orders.sort((a, b) {
              final aData =
              a.data()
              as Map<String, dynamic>;

              final bData =
              b.data()
              as Map<String, dynamic>;

              final aTime =
              aData['createdAt'];

              final bTime =
              bData['createdAt'];

              if (aTime is Timestamp &&
                  bTime is Timestamp) {
                return bTime
                    .compareTo(aTime);
              }

              return 0;
            });

            return CustomScrollView(
              physics:
              const BouncingScrollPhysics(),

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
                    child:
                    _buildEmptyState(),
                  )

                // ==================================================
                // ORDERS
                // ==================================================

                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      6,
                      18,
                      35,
                    ),

                    sliver: SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final doc =
                          orders[index];

                          final data =
                          doc.data()
                          as Map<String,
                              dynamic>;

                          return _buildOrderCard(
                            context,
                            doc.id,
                            data,
                          );
                        },

                        childCount:
                        orders.length,
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
      int orderCount,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
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
                  CrossAxisAlignment
                      .start,

                  children: [
                    const Text(
                      'Your Orders',
                      style: TextStyle(
                        color: brown,
                        fontSize: 26,
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
                      'YOUR COFFEE JOURNEY',
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
                width: 48,
                height: 48,

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

                child: const Icon(
                  Icons
                      .receipt_long_rounded,
                  color: brown,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ==================================================
          // HERO
          // ==================================================

          Container(
            width:
            double.infinity,

            padding:
            const EdgeInsets.all(
              18,
            ),

            decoration:
            BoxDecoration(
              color: brown,

              borderRadius:
              BorderRadius.circular(
                25,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.brown
                      .withOpacity(
                    0.12,
                  ),
                  blurRadius: 17,
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
                  width: 48,
                  height: 48,

                  decoration:
                  BoxDecoration(
                    color: Colors.white
                        .withOpacity(
                      0.13,
                    ),
                    shape:
                    BoxShape.circle,
                  ),

                  child:
                  const Icon(
                    Icons
                        .local_cafe_rounded,
                    color:
                    Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      const Text(
                        'Made with a little love',
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
                        height: 4,
                      ),

                      Text(
                        orderCount == 0
                            ? 'Your orders will appear here.'
                            : orderCount == 1
                            ? 'You have 1 active order.'
                            : 'You have $orderCount active orders.',

                        style:
                        const TextStyle(
                          color:
                          Colors.white70,
                          fontSize:
                          9,
                          height:
                          1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
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
                    const Text(
                      'ORDER HISTORY',
                      style:
                      TextStyle(
                        color: brown,
                        fontSize: 14,
                        fontWeight:
                        FontWeight
                            .w900,
                        letterSpacing:
                        0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Track your café favorites',
                      style:
                      TextStyle(
                        color:
                        lightBrown,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$orderCount ${orderCount == 1 ? 'order' : 'orders'}',
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
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard(
      BuildContext context,
      String orderId,
      Map<String, dynamic> data,
      ) {
    final String productName =
        data['productName']
            ?.toString() ??
            'Product';

    final String productId =
        data['productId']
            ?.toString() ??
            '';

    final num price =
        (data['totalPrice'] as num?) ??
            0;

    final int quantity =
    (data['quantity'] as num? ??
        1)
        .toInt();

    final String status =
        data['status']
            ?.toString() ??
            'pending';

    final String date =
    _formatDate(
      data['createdAt'],
    );

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 17,
      ),

      decoration:
      BoxDecoration(
        color: cardColor,

        borderRadius:
        BorderRadius.circular(
          27,
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
              0.055,
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

      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          27,
        ),

        child: Column(
          children: [
            // ==================================================
            // PRODUCT IMAGE
            // ==================================================

            if (productId.isNotEmpty)
              FutureBuilder<
                  DocumentSnapshot<
                      Map<String,
                          dynamic>>>(
                future:
                FirebaseFirestore
                    .instance
                    .collection(
                    'products')
                    .doc(productId)
                    .get(),

                builder: (
                    context,
                    productSnapshot,
                    ) {
                  String imageUrl =
                      '';

                  String category =
                      '';

                  if (productSnapshot
                      .hasData &&
                      productSnapshot
                          .data!
                          .exists) {
                    final product =
                    productSnapshot
                        .data!
                        .data();

                    imageUrl =
                        product?[
                        'imageUrl']
                            ?.toString() ??
                            '';

                    category =
                        product?[
                        'categoryName']
                            ?.toString() ??
                            '';
                  }

                  return _buildProductImage(
                    imageUrl,
                    category,
                  );
                },
              )
            else
              _buildProductImage(
                '',
                '',
              ),

            // ==================================================
            // ORDER INFO
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.all(
                17,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  // TOP
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

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
                                color:
                                brown,
                                fontSize:
                                18,
                                fontWeight:
                                FontWeight
                                    .w900,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              'ORDER #${_shortOrderId(orderId)}',

                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFFB08B75,
                                ),
                                fontSize:
                                9,
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
                        width: 10,
                      ),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFF2E1CE,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            13,
                          ),
                        ),

                        child: Text(
                          '\$${price.toStringAsFixed(2)}',

                          style:
                          const TextStyle(
                            color:
                            brown,
                            fontSize:
                            14,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // DETAILS
                  // ==================================================

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
                            '$quantity',
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 30,
                          color:
                          softBrown,
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
                          color:
                          softBrown,
                        ),

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
                    height: 15,
                  ),

                  // ==================================================
                  // STATUS + CANCEL
                  // ==================================================

                  Row(
                    children: [
                      _buildStatusBadge(
                        status,
                      ),

                      const Spacer(),

                      TextButton.icon(
                        onPressed: () {
                          cancelOrder(
                            context,
                            orderId,
                            data,
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
                            fontSize:
                            10,
                            fontWeight:
                            FontWeight
                                .w800,
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
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage(
      String imageUrl,
      String category,
      ) {
    return Stack(
      children: [
        SizedBox(
          height: 175,
          width:
          double.infinity,

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

        // Gradient-like dark overlay at bottom
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
                      .withOpacity(
                    0.32,
                  ),
                ],
              ),
            ),
          ),
        ),

        if (category.isNotEmpty)
          Positioned(
            left: 13,
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
                    .withOpacity(
                  0.88,
                ),

                borderRadius:
                BorderRadius
                    .circular(
                  10,
                ),
              ),

              child: Text(
                category,
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
      color:
      const Color(0xFFF1DECA),

      child: const Center(
        child: Icon(
          Icons
              .local_cafe_rounded,
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

        const SizedBox(
          width: 6,
        ),

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
                height: 2,
              ),

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
  // STATUS ITEM
  // ============================================================

  Widget _buildStatusItem(
      String status,
      ) {
    final label =
    status == 'pending'
        ? 'Pending'
        : _capitalize(
      status,
    );

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        Icon(
          Icons.timelapse_rounded,
          size: 16,
          color: lightBrown,
        ),

        const SizedBox(
          width: 6,
        ),

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

              const SizedBox(
                height: 2,
              ),

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
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(
      String status,
      ) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case 'completed':
        bgColor =
        const Color(0xFFE4F0DE);
        textColor =
        const Color(0xFF668853);
        icon =
            Icons.check_circle_outline;
        text = 'Completed';
        break;

      case 'cancelled':
        bgColor =
        const Color(0xFFF5DEDA);
        textColor =
        const Color(0xFFB85B4E);
        icon =
            Icons.cancel_outlined;
        text = 'Cancelled';
        break;

      case 'preparing':
        bgColor =
        const Color(0xFFF3E5C9);
        textColor =
        const Color(0xFF9A6D35);
        icon =
            Icons.restaurant_rounded;
        text = 'Preparing';
        break;

      default:
        bgColor =
        const Color(0xFFE4F0DE);
        textColor =
        const Color(0xFF668853);
        icon =
            Icons
                .check_circle_outline;
        text = 'Order received';
    }

    return Container(
      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration:
      BoxDecoration(
        color: bgColor,

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Row(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
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
              width: 105,
              height: 105,

              decoration:
              const BoxDecoration(
                color:
                Color(0xFFF1DECA),
                shape:
                BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .receipt_long_outlined,
                color: brown,
                size: 50,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No orders yet',
              textAlign:
              TextAlign.center,

              style: TextStyle(
                color: brown,
                fontSize: 21,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Your coffee orders will appear here.\n'
                  'Find something delicious on the menu\n'
                  'and make your first order.',
              textAlign:
              TextAlign.center,

              style: TextStyle(
                color: lightBrown,
                fontSize: 10,
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

                  SizedBox(
                    width: 6,
                  ),

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
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              color: brown,
              size: 45,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Unable to load your orders',
              textAlign:
              TextAlign.center,

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
              style:
              const TextStyle(
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
  // HELPERS
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

  String _formatDate(
      dynamic timestamp,
      ) {
    if (timestamp is Timestamp) {
      final date =
      timestamp.toDate();

      final day =
      date.day.toString()
          .padLeft(2, '0');

      final month =
      date.month.toString()
          .padLeft(2, '0');

      final year =
      date.year.toString();

      return '$day/$month/$year';
    }

    return 'Just now';
  }

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