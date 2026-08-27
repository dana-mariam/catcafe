import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String selectedFilter = 'All';

  final Color backgroundColor = const Color(0xFFF8EBD7);
  final Color cardColor = const Color(0xFFFFFCF6);
  final Color brown = const Color(0xFF713D27);
  final Color lightBrown = const Color(0xFF9A6D58);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Orders',
          style: TextStyle(
            color: brown,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: brown,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: brown,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          final filteredOrders = orders.where((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            final status =
                data['status']?.toString() ?? 'pending';

            if (selectedFilter == 'All') {
              return true;
            }

            return status ==
                selectedFilter.toLowerCase();
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 4),

              _buildSummary(orders),

              const SizedBox(height: 14),

              _buildFilters(),

              const SizedBox(height: 10),

              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    30,
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final doc =
                    filteredOrders[index];

                    final data =
                    doc.data()
                    as Map<String, dynamic>;

                    return _OrderCard(
                      orderId: doc.id,
                      data: data,
                      backgroundColor:
                      backgroundColor,
                      cardColor: cardColor,
                      brown: brown,
                      lightBrown: lightBrown,
                      onCancel: () {
                        _cancelOrder(
                          context,
                          doc.id,
                          data,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      List<QueryDocumentSnapshot> orders,
      ) {
    int pending = 0;
    int cancelled = 0;

    for (final order in orders) {
      final data =
      order.data() as Map<String, dynamic>;

      final status =
          data['status']?.toString() ?? 'pending';

      if (status == 'cancelled') {
        cancelled++;
      } else {
        pending++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              icon: Icons.receipt_long_outlined,
              title: 'All Orders',
              value: '${orders.length}',
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _summaryCard(
              icon: Icons.pending_actions_outlined,
              title: 'Pending',
              value: '$pending',
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _summaryCard(
              icon: Icons.cancel_outlined,
              title: 'Cancelled',
              value: '$cancelled',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: brown,
            size: 21,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: brown,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: TextStyle(
              color: lightBrown,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 43,

      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        children: [
          _filterButton('All'),
          _filterButton('Pending'),
          _filterButton('Cancelled'),
        ],
      ),
    );
  }

  Widget _filterButton(String filter) {
    final selected =
        selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),

      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },

        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),

          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          decoration: BoxDecoration(
            color: selected
                ? brown
                : cardColor,

            borderRadius:
            BorderRadius.circular(25),

            border: Border.all(
              color: selected
                  ? brown
                  : const Color(0xFFE4D4C3),
            ),
          ),

          child: Center(
            child: Text(
              filter,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : brown,

                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: const BoxDecoration(
                color: Color(0xFFF3DFCA),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.receipt_long_outlined,
                color: brown,
                size: 45,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'No orders found',
              style: TextStyle(
                color: brown,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Customer orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: lightBrown,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> _cancelOrder(
      BuildContext context,
      String orderId,
      Map<String, dynamic> orderData,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),

          title: Text(
            'Cancel Order?',
            style: TextStyle(
              color: brown,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'This order will be marked as cancelled '
                'and the product quantity will be returned to stock.',
            style: TextStyle(
              color: lightBrown,
              height: 1.4,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: Text(
                'Keep Order',
                style: TextStyle(
                  color: brown,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final firestore =
          FirebaseFirestore.instance;

      final orderRef =
      firestore
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
      firestore
          .collection('products')
          .doc(productId);

      await firestore.runTransaction(
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

          if (!productSnapshot.exists) {
            throw Exception(
              'Product no longer exists.',
            );
          }

          final currentOrder =
          orderSnapshot.data();

          final productData =
          productSnapshot.data();

          if (currentOrder == null ||
              productData == null) {
            throw Exception(
              'Unable to read order information.',
            );
          }

          final currentStatus =
              currentOrder['status']
                  ?.toString() ??
                  'pending';

          if (currentStatus == 'cancelled') {
            throw Exception(
              'This order is already cancelled.',
            );
          }

          final currentQuantity =
          (productData['quantity']
          as num? ??
              0)
              .toInt();

          final orderedQuantity =
          (currentOrder['quantity']
          as num? ??
              1)
              .toInt();

          transaction.update(
            orderRef,
            {
              'status': 'cancelled',
              'cancelledAt':
              FieldValue.serverTimestamp(),
            },
          );

          transaction.update(
            productRef,
            {
              'quantity':
              currentQuantity +
                  orderedQuantity,
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
}

// ==================================================================
// ORDER CARD
// ==================================================================

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  final Color backgroundColor;
  final Color cardColor;
  final Color brown;
  final Color lightBrown;

  final VoidCallback onCancel;

  const _OrderCard({
    required this.orderId,
    required this.data,
    required this.backgroundColor,
    required this.cardColor,
    required this.brown,
    required this.lightBrown,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final productName =
        data['productName']
            ?.toString() ??
            'Unknown Product';

    final productId =
        data['productId']
            ?.toString() ??
            '';

    final userName =
        data['userName']
            ?.toString() ??
            'Unknown User';

    final userPhone =
        data['userPhone']
            ?.toString() ??
            'No phone';

    final category =
        data['category']
            ?.toString() ??
            '';

    final imageUrl =
        data['imageUrl']
            ?.toString() ??
            '';

    final quantity =
    (data['quantity'] as num? ?? 1)
        .toInt();

    final price =
    (data['totalPrice'] as num? ?? 0);

    final status =
        data['status']
            ?.toString() ??
            'pending';

    final date =
    _formatDate(data['createdAt']);

    final cancelled =
        status == 'cancelled';

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 18,
      ),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
            Colors.brown.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(28),

        child: Column(
          children: [
            // ======================================================
            // PRODUCT IMAGE
            // ======================================================

            Stack(
              children: [
                _buildImage(
                  imageUrl,
                  productId,
                ),

                Positioned(
                  top: 14,
                  right: 14,

                  child: _statusBadge(
                    cancelled,
                  ),
                ),
              ],
            ),

            // ======================================================
            // CONTENT
            // ======================================================

            Padding(
              padding:
              const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // PRODUCT HEADER
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              productName,

                              maxLines: 2,

                              overflow:
                              TextOverflow.ellipsis,

                              style: TextStyle(
                                color: brown,
                                fontSize: 20,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              'ORDER #${_shortOrderId(orderId)}',

                              style:
                              TextStyle(
                                color:
                                const Color(
                                  0xFFB08B75,
                                ),
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        '\$${price.toStringAsFixed(2)}',

                        style: TextStyle(
                          color: brown,
                          fontSize: 19,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // PRODUCT DETAILS
                  _sectionTitle(
                    'PRODUCT DETAILS',
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  Container(
                    padding:
                    const EdgeInsets.all(
                      14,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFF8EBD7,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: Column(
                      children: [
                        _detailRow(
                          Icons.category_outlined,
                          'Category',
                          category.isEmpty
                              ? 'Uncategorized'
                              : category,
                        ),

                        _divider(),

                        _detailRow(
                          Icons.inventory_2_outlined,
                          'Quantity',
                          '$quantity',
                        ),

                        _divider(),

                        _detailRow(
                          Icons.attach_money,
                          'Unit Price',
                          '\$${price.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // CUSTOMER DETAILS
                  _sectionTitle(
                    'CUSTOMER DETAILS',
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  Container(
                    padding:
                    const EdgeInsets.all(
                      14,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFF8EBD7,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: Column(
                      children: [
                        _detailRow(
                          Icons.person_outline,
                          'Customer',
                          userName,
                        ),

                        _divider(),

                        _detailRow(
                          Icons.phone_outlined,
                          'Phone',
                          userPhone,
                        ),

                        _divider(),

                        _detailRow(
                          Icons.calendar_today_outlined,
                          'Order Date',
                          date,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),

                          decoration:
                          BoxDecoration(
                            color: cancelled
                                ? Colors.red
                                .withOpacity(
                              0.08,
                            )
                                : const Color(
                              0xFFE6F0E0,
                            ),

                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                cancelled
                                    ? Icons
                                    .cancel_outlined
                                    : Icons
                                    .check_circle_outline,

                                size: 18,

                                color: cancelled
                                    ? Colors.red
                                    : const Color(
                                  0xFF6D8B5B,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [
                                  Text(
                                    'Status',
                                    style:
                                    TextStyle(
                                      color:
                                      lightBrown,
                                      fontSize: 9,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 2,
                                  ),

                                  Text(
                                    cancelled
                                        ? 'Cancelled'
                                        : 'Pending',

                                    style:
                                    TextStyle(
                                      color: cancelled
                                          ? Colors.red
                                          : const Color(
                                        0xFF6D8B5B,
                                      ),
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (!cancelled) ...[
                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                          ElevatedButton.icon(
                            onPressed: onCancel,

                            icon: const Icon(
                              Icons.close,
                              size: 17,
                            ),

                            label: const Text(
                              'Cancel',
                            ),

                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              brown,
                              foregroundColor:
                              Colors.white,
                              elevation: 0,

                              minimumSize:
                              const Size(
                                0,
                                48,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
  // IMAGE
  // ============================================================

  Widget _buildImage(
      String imageUrl,
      String productId,
      ) {
    // New orders have imageUrl saved directly.
    if (imageUrl.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 185,

        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,

          errorBuilder:
              (_, __, ___) {
            return _placeholder();
          },
        ),
      );
    }

    // Old orders don't have imageUrl.
    // Fetch it from the product.
    if (productId.isNotEmpty) {
      return FutureBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore
            .instance
            .collection('products')
            .doc(productId)
            .get(),

        builder:
            (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data!.exists) {
            final product =
            snapshot.data!.data();

            final oldImageUrl =
                product?['imageUrl']
                    ?.toString() ??
                    '';

            if (oldImageUrl.isNotEmpty) {
              return SizedBox(
                width: double.infinity,
                height: 185,

                child: Image.network(
                  oldImageUrl,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (_, __, ___) {
                    return _placeholder();
                  },
                ),
              );
            }
          }

          return _placeholder();
        },
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 185,

      color: const Color(0xFFF3DFCA),

      child: Icon(
        Icons.local_cafe_outlined,
        size: 52,
        color: lightBrown,
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
      bool cancelled,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: cancelled
            ? Colors.red
            : const Color(0xFF6D8B5B),

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(
        cancelled
            ? 'CANCELLED'
            : 'PENDING',

        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title,

      style: TextStyle(
        color: lightBrown,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  Widget _detailRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: lightBrown,
        ),

        const SizedBox(
          width: 10,
        ),

        Text(
          title,
          style: TextStyle(
            color: lightBrown,
            fontSize: 11,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            textAlign:
            TextAlign.right,

            style: TextStyle(
              color: brown,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 9,
      ),

      child: Divider(
        height: 1,
        color: const Color(0xFFE5D5C3),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _shortOrderId(
      String id,
      ) {
    if (id.length <= 8) {
      return id.toUpperCase();
    }

    return id
        .substring(0, 8)
        .toUpperCase();
  }

  static String _formatDate(
      dynamic timestamp,
      ) {
    if (timestamp is Timestamp) {
      final date =
      timestamp.toDate();

      final day =
      date.day.toString().padLeft(
        2,
        '0',
      );

      final month =
      date.month.toString().padLeft(
        2,
        '0',
      );

      final year =
      date.year.toString();

      return '$day/$month/$year';
    }

    return 'Just now';
  }
}