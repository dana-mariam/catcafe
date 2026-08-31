import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color backgroundColor = Color(0xFFF8EBD7);
  static const Color cardColor = Color(0xFFFFFCF6);
  static const Color brownColor = Color(0xFF713D27);
  static const Color lightBrownColor = Color(0xFF9A684F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: brownColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .snapshots(),

        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: brownColor,
              ),
            );
          }

          if (orderSnapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load orders.',
                style: TextStyle(
                  color: brownColor,
                ),
              ),
            );
          }

          final orders = orderSnapshot.data?.docs ?? [];

          // =====================================================
          // ORDER STATISTICS
          // =====================================================

          int pendingOrders = 0;
          int processingOrders = 0;
          int outForDeliveryOrders = 0;
          int deliveredOrders = 0;

          for (final order in orders) {
            final data =
            order.data() as Map<String, dynamic>;

            final status =
                data['status']?.toString().toLowerCase() ??
                    'pending';

            switch (status) {
              case 'pending':
                pendingOrders++;
                break;

              case 'processing':
                processingOrders++;
                break;

              case 'out_for_delivery':
                outForDeliveryOrders++;
                break;

              case 'delivered':
                deliveredOrders++;
                break;
            }
          }

          // =====================================================
          // PRODUCTS
          // =====================================================

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .snapshots(),

            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: brownColor,
                  ),
                );
              }

              if (productSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Unable to load products.',
                    style: TextStyle(
                      color: brownColor,
                    ),
                  ),
                );
              }

              final products =
                  productSnapshot.data?.docs ?? [];

              final totalOrders = orders.length;
              final totalProducts = products.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  30,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // HEADER
                    // =================================================

                    const Text(
                      'OVERVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        color: lightBrownColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Welcome, Admin 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: brownColor,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =================================================
                    // MAIN STATISTICS
                    // =================================================

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,

                      children: [
                        _buildStatCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Total Orders',
                          value: '$totalOrders',
                        ),

                        _buildStatCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Total Products',
                          value: '$totalProducts',
                        ),

                        _buildStatCard(
                          icon: Icons.pending_actions_outlined,
                          title: 'Pending',
                          value: '$pendingOrders',
                        ),

                        _buildStatCard(
                          icon: Icons.autorenew_outlined,
                          title: 'Processing',
                          value: '$processingOrders',
                        ),

                        _buildStatCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Out for Delivery',
                          value: '$outForDeliveryOrders',
                        ),

                        _buildStatCard(
                          icon: Icons.check_circle_outline,
                          title: 'Delivered',
                          value: '$deliveredOrders',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // ORDER LIFECYCLE
                    // =================================================

                    const Text(
                      'ORDER LIFECYCLE',
                      style: TextStyle(
                        fontSize: 11,
                        color: lightBrownColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                        BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.brown.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          _buildStatusRow(
                            icon:
                            Icons.pending_actions_outlined,
                            title: 'Pending',
                            value: pendingOrders,
                          ),

                          _buildDivider(),

                          _buildStatusRow(
                            icon:
                            Icons.autorenew_outlined,
                            title: 'Processing',
                            value: processingOrders,
                          ),

                          _buildDivider(),

                          _buildStatusRow(
                            icon:
                            Icons.local_shipping_outlined,
                            title: 'Out for Delivery',
                            value: outForDeliveryOrders,
                          ),

                          _buildDivider(),

                          _buildStatusRow(
                            icon:
                            Icons.check_circle_outline,
                            title: 'Delivered',
                            value: deliveredOrders,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // STORE OVERVIEW
                    // =================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                        BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.brown.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            color: brownColor,
                            size: 30,
                          ),

                          SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [
                                Text(
                                  'Store Overview',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: brownColor,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  'Manage products, categories and customer orders from the navigation bar.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                    lightBrownColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===============================================================
  // STAT CARD
  // ===============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

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

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: brownColor,
            size: 27,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: brownColor,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: lightBrownColor,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STATUS ROW
  // ===============================================================

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required int value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: const Color(0xFFF3E2CF),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: brownColor,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: brownColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          '$value',
          style: const TextStyle(
            color: brownColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // DIVIDER
  // ===============================================================

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Color(0xFFE8D9C8),
      ),
    );
  }
}