import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String selectedFilter = 'All';

  final Color backgroundColor = const Color(0xFFF8EBD7);
  final Color cardColor = const Color(0xFFFFFCF6);
  final Color brown = const Color(0xFF713D27);
  final Color lightBrown = const Color(0xFF9A6D58);

  final List<String> statuses = [
    'pending',
    'processing',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

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

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
            final data = doc.data();

            final status =
                data['status']?.toString().toLowerCase() ?? 'pending';

            if (selectedFilter == 'All') {
              return true;
            }

            return status == selectedFilter.toLowerCase();
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
                    final doc = filteredOrders[index];

                    return _OrderCard(
                      orderId: doc.id,
                      data: doc.data(),
                      backgroundColor: backgroundColor,
                      cardColor: cardColor,
                      brown: brown,
                      lightBrown: lightBrown,
                      statuses: statuses,
                      onStatusChanged: (newStatus) {
                        _updateOrderStatus(
                          context,
                          doc.id,
                          newStatus,
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
      List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
      ) {
    int pending = 0;
    int processing = 0;
    int outForDelivery = 0;
    int delivered = 0;

    for (final order in orders) {
      final data = order.data();

      final status =
          data['status']?.toString().toLowerCase() ?? 'pending';

      switch (status) {
        case 'pending':
          pending++;
          break;

        case 'processing':
          processing++;
          break;

        case 'out_for_delivery':
          outForDelivery++;
          break;

        case 'delivered':
          delivered++;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _summaryCard(
              icon: Icons.receipt_long_outlined,
              title: 'All Orders',
              value: '${orders.length}',
            ),

            const SizedBox(width: 10),

            _summaryCard(
              icon: Icons.pending_actions_outlined,
              title: 'Pending',
              value: '$pending',
            ),

            const SizedBox(width: 10),

            _summaryCard(
              icon: Icons.sync_outlined,
              title: 'Processing',
              value: '$processing',
            ),

            const SizedBox(width: 10),

            _summaryCard(
              icon: Icons.delivery_dining_outlined,
              title: 'Delivery',
              value: '$outForDelivery',
            ),

            const SizedBox(width: 10),

            _summaryCard(
              icon: Icons.check_circle_outline,
              title: 'Delivered',
              value: '$delivered',
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: 105,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          _filterButton('Processing'),
          _filterButton('Out for Delivery'),
          _filterButton('Delivered'),
          _filterButton('Cancelled'),
        ],
      ),
    );
  }

  Widget _filterButton(String filter) {
    final selected = selectedFilter == filter;

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
          duration: const Duration(
            milliseconds: 200,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          decoration: BoxDecoration(
            color: selected
                ? brown
                : cardColor,

            borderRadius: BorderRadius.circular(
              25,
            ),

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
  // UPDATE ORDER STATUS
  // ============================================================

  Future<void> _updateOrderStatus(
      BuildContext context,
      String orderId,
      String newStatus,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order status updated to ${_getDisplayStatus(newStatus)}.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update order status.',
          ),
        ),
      );
    }
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'processing':
        return 'Processing';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      default:
        return 'Pending';
    }
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

  final List<String> statuses;

  final Function(String) onStatusChanged;

  const _OrderCard({
    required this.orderId,
    required this.data,
    required this.backgroundColor,
    required this.cardColor,
    required this.brown,
    required this.lightBrown,
    required this.statuses,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final userId =
        data['userId']?.toString() ?? '';

    final address =
        data['address']?.toString() ?? 'No address';

    final totalAmount =
    (data['totalAmount'] as num? ?? 0).toDouble();

    final status =
        data['status']?.toString().toLowerCase() ?? 'pending';

    final date =
    _formatDate(data['createdAt']);

    final items =
    _getItems(data['items']);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(
          28,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          28,
        ),

        child: Column(
          children: [
            // ======================================================
            // ORDER HEADER
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              color: const Color(0xFFF3DFCA),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius:
                      BorderRadius.circular(15),
                    ),

                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: brown,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          'ORDER #${_shortOrderId(orderId)}',
                          style: TextStyle(
                            color: brown,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          date,
                          style: TextStyle(
                            color: lightBrown,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _statusBadge(status),
                ],
              ),
            ),

            // ======================================================
            // ORDER CONTENT
            // ======================================================

            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // PRODUCTS
                  // ==================================================

                  _sectionTitle(
                    'ORDER ITEMS',
                  ),

                  const SizedBox(height: 10),

                  if (items.isEmpty)
                    Text(
                      'No items found.',
                      style: TextStyle(
                        color: lightBrown,
                        fontSize: 12,
                      ),
                    )
                  else
                    ...items.map(
                          (item) => _buildItemRow(item),
                    ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // DELIVERY ADDRESS
                  // ==================================================

                  _sectionTitle(
                    'DELIVERY ADDRESS',
                  ),

                  const SizedBox(height: 9),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EBD7),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 19,
                          color: lightBrown,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              color: brown,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // USER ID
                  // ==================================================

                  if (userId.isNotEmpty) ...[
                    _detailRow(
                      Icons.person_outline,
                      'User ID',
                      _shortOrderId(userId),
                    ),

                    const SizedBox(height: 12),
                  ],

                  // ==================================================
                  // TOTAL
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF3DFCA),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: brown,
                          size: 20,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          'Total',
                          style: TextStyle(
                            color: lightBrown,
                            fontSize: 12,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: brown,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // CHANGE STATUS
                  // ==================================================

                  _sectionTitle(
                    'UPDATE ORDER STATUS',
                  ),

                  const SizedBox(height: 9),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EBD7),

                      borderRadius:
                      BorderRadius.circular(18),

                      border: Border.all(
                        color: const Color(0xFFE5D5C3),
                      ),
                    ),

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: statuses.contains(status)
                            ? status
                            : 'pending',

                        isExpanded: true,

                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: brown,
                        ),

                        dropdownColor: cardColor,

                        style: TextStyle(
                          color: brown,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),

                        items: statuses.map(
                              (statusValue) {
                            return DropdownMenuItem<String>(
                              value: statusValue,

                              child: Row(
                                children: [
                                  Icon(
                                    _statusIcon(
                                      statusValue,
                                    ),
                                    size: 18,
                                    color: _statusColor(
                                      statusValue,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    _displayStatus(
                                      statusValue,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),

                        onChanged: (value) {
                          if (value == null) return;

                          if (value == status) return;

                          onStatusChanged(value);
                        },
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
  // ITEM ROW
  // ============================================================

  Widget _buildItemRow(
      Map<String, dynamic> item,
      ) {
    final name =
        item['name']?.toString() ?? 'Product';

    final image =
        item['image']?.toString() ?? '';

    final price =
    (item['price'] as num? ?? 0).toDouble();

    final quantity =
    (item['quantity'] as num? ?? 1).toInt();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: const Color(0xFFF8EBD7),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: image.isNotEmpty
                ? Image.network(
              image,
              width: 58,
              height: 58,
              fit: BoxFit.cover,

              errorBuilder: (_, __, ___) {
                return _itemPlaceholder();
              },
            )
                : _itemPlaceholder(),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: brown,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Quantity: $quantity',
                  style: TextStyle(
                    color: lightBrown,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              color: brown,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemPlaceholder() {
    return Container(
      width: 58,
      height: 58,

      color: const Color(0xFFE8D4BE),

      child: Icon(
        Icons.local_cafe_outlined,
        color: lightBrown,
        size: 25,
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
      String status,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        _displayStatus(status).toUpperCase(),

        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
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

  // ============================================================
  // DETAIL ROW
  // ============================================================

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

        const SizedBox(width: 10),

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
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,

            style: TextStyle(
              color: brown,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  String _displayStatus(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'processing':
        return 'Processing';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      default:
        return 'Pending';
    }
  }

  Color _statusColor(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return const Color(0xFFB78342);

      case 'processing':
        return const Color(0xFF7C6AA6);

      case 'out_for_delivery':
        return const Color(0xFF557A8A);

      case 'delivered':
        return const Color(0xFF6D8B5B);

      case 'cancelled':
        return Colors.red;

      default:
        return const Color(0xFFB78342);
    }
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions_outlined;

      case 'processing':
        return Icons.sync_outlined;

      case 'out_for_delivery':
        return Icons.delivery_dining_outlined;

      case 'delivered':
        return Icons.check_circle_outline;

      case 'cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.pending_actions_outlined;
    }
  }

  // ============================================================
  // ITEMS
  // ============================================================

  List<Map<String, dynamic>> _getItems(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
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
      final date = timestamp.toDate();

      final day =
      date.day.toString().padLeft(2, '0');

      final month =
      date.month.toString().padLeft(2, '0');

      final year =
      date.year.toString();

      return '$day/$month/$year';
    }

    return 'Just now';
  }
}