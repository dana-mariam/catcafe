import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController categoryController =
  TextEditingController();

  bool isAdding = false;

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  Future<void> addCategory() async {
    final name = categoryController.text.trim();

    if (name.isEmpty) {
      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      categoryController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category added successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add category: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category deleted'),
      ),
    );
  }

  Future<void> confirmDelete(
      String categoryId,
      String categoryName,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Delete "$categoryName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteCategory(categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EBD7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8EBD7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Color(0xFF713D27),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // Add category
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      hintText: 'New category',
                      filled: true,
                      fillColor: const Color(0xFFFFFCF6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  height: 52,
                  width: 52,
                  child: ElevatedButton(
                    onPressed: isAdding ? null : addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF713D27),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: isAdding
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),

          // Categories list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
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
                      'Something went wrong',
                    ),
                  );
                }

                final categories =
                    snapshot.data?.docs ?? [];

                if (categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories yet',
                      style: TextStyle(
                        color: Color(0xFF9A6D58),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final doc = categories[index];

                    final data =
                    doc.data() as Map<String, dynamic>;

                    final name = data['name'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF6),
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor:
                          Color(0xFFF5E9D7),
                          child: Icon(
                            Icons.category_outlined,
                            color: Color(0xFF713D27),
                          ),
                        ),

                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF713D27),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            confirmDelete(
                              doc.id,
                              name,
                            );
                          },
                        ),
                      ),
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
}