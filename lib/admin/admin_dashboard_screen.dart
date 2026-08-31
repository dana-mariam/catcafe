import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  final Color backgroundColor = const Color(0xFFF8EBD7);
  final Color brownColor = const Color(0xFF713D27);

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
            color: Color(0xFF713D27),
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
              child: CircularProgressIndicator(),
            );
          }

          final orders = orderSnapshot.data?.docs ?? [];

          final totalOrders = orders.length;

          final pendingOrders = orders.where((order) {
            final data =
            order.data() as Map<String, dynamic>;
            return data['status'] == 'pending';
          }).length;

          final deliveredOrders = orders.where((order) {
            final data =
            order.data() as Map<String, dynamic>;
            return data['status'] == 'delivered';
          }).length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .snapshots(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final totalProducts =
                  productSnapshot.data?.docs.length ?? 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9A684F),
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Welcome, Admin 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF713D27),
                      ),
                    ),

                    const SizedBox(height: 25),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.25,
                      children: [
                        _buildStatCard(
                          icon: Icons.receipt_long,
                          title: 'Total Orders',
                          value: '$totalOrders',
                        ),
                        _buildStatCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Total Products',
                          value: '$totalProducts',
                        ),
                        _buildStatCard(
                          icon: Icons.pending_actions,
                          title: 'Pending Orders',
                          value: '$pendingOrders',
                        ),
                        _buildStatCard(
                          icon: Icons.check_circle_outline,
                          title: 'Delivered',
                          value: '$deliveredOrders',
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            color: Color(0xFF713D27),
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
                                    color:
                                    Color(0xFF713D27),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Manage your products, categories and orders from the navigation bar.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                    Color(0xFF8A6A59),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Color(0xFF713D27),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF713D27),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A6A59),
            ),
          ),
        ],
      ),
    );
  }
}