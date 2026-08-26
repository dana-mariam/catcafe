import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/edit_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';

  String userRole = 'user';
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

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

      setState(() {
        userRole = data?['role'] ?? 'user';
        isLoadingRole = false;
      });
    } catch (e) {
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
          backgroundColor: const Color(0xFFFFFCF6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              color: Color(0xFF713D27),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This product will be removed from the menu.',
            style: TextStyle(
              color: Color(0xFF9A6D58),
            ),
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
                style: TextStyle(color: Colors.red),
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
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          productId: doc.id,
          product: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EBD7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8EBD7),
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'Cat Cafe',
              style: TextStyle(
                color: Color(0xFF713D27),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1,
              ),
            ),
            Text(
              'Coffee • Cats • Cozy Things',
              style: TextStyle(
                color: Color(0xFF9A6D58),
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          // Categories
          SizedBox(
            height: 48,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('name')
                  .snapshots(),

              builder: (context, snapshot) {
                final categories =
                    snapshot.data?.docs ?? [];

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  children: [
                    categoryChip(
                      id: 'all',
                      title: 'All',
                    ),
                    ...categories.map((doc) {
                      final data =
                      doc.data()
                      as Map<String, dynamic>;

                      return categoryChip(
                        id: doc.id,
                        title: data['name'] ?? '',
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Products
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('name')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF713D27),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Something went wrong.',
                      style: TextStyle(
                        color: Color(0xFF713D27),
                      ),
                    ),
                  );
                }

                final products =
                    snapshot.data?.docs ?? [];

                final filteredProducts =
                selectedCategoryId == 'all'
                    ? products
                    : products.where((doc) {
                  final data =
                  doc.data()
                  as Map<String,
                      dynamic>;

                  return data['categoryId'] ==
                      selectedCategoryId;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products in this category yet.',
                      style: TextStyle(
                        color: Color(0xFF9A6D58),
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    20,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.69,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final doc =
                    filteredProducts[index];

                    return buildProductCard(
                      context,
                      doc,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryChip({
    required String id,
    required String title,
  }) {
    final bool selected =
        selectedCategoryId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF713D27)
              : const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : const Color(0xFF713D27),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildProductCard(
      BuildContext context,
      QueryDocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    final String name = data['name'] ?? '';
    final String description =
        data['description'] ?? '';
    final String imageUrl =
        data['imageUrl'] ?? '';

    final num price = data['price'] ?? 0;
    final num quantity =
        data['quantity'] ?? 0;

    final bool outOfStock = quantity <= 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    )
                        : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 45,
                        color:
                        Color(0xFF9A6D58),
                      ),
                    ),
                  ),
                ),

                if (outOfStock)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                        Colors.black.withOpacity(
                          0.65,
                        ),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'OUT OF STOCK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (isAdmin)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.93),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Color(0xFF713D27),
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
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              10,
              12,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF713D27),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9A6D58),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 9),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF713D27),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    if (!isAdmin)
                      IconButton(
                        onPressed: () {
                          // Favorites will be connected next.
                        },
                        padding: EdgeInsets.zero,
                        constraints:
                        const BoxConstraints(),
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Color(0xFF713D27),
                          size: 22,
                        ),
                      )
                    else
                      Text(
                        'Qty $quantity',
                        style: const TextStyle(
                          color: Color(0xFF9A6D58),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}