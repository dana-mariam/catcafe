import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  final TextEditingController categoryController =
  TextEditingController();

  bool isAdding = false;

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

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> addCategory() async {
    final name =
    categoryController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a category name',
          ),
        ),
      );

      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      // Prevent duplicate categories
      final existing =
      await FirebaseFirestore.instance
          .collection('categories')
          .where(
        'name',
        isEqualTo: name,
      )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'This category already exists',
            ),
          ),
        );

        return;
      }

      await FirebaseFirestore.instance
          .collection('categories')
          .add({
        'name': name,
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      categoryController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Category added successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add category: $e',
          ),
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

  // ============================================================
  // DELETE CATEGORY
  // ============================================================

  Future<void> deleteCategory(
      String categoryId,
      ) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Category deleted',
        ),
      ),
    );
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  Future<void> confirmDelete(
      String categoryId,
      String categoryName,
      ) async {
    final shouldDelete =
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
            'Remove Category?',
            style: TextStyle(
              color: brown,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          content: Text(
            'Are you sure you want to remove "$categoryName" from the menu categories?',
            style: TextStyle(
              color: lightBrown,
              height: 1.4,
              fontSize: 13,
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
                'Keep',
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
                'Remove',
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

    if (shouldDelete == true) {
      try {
        await deleteCategory(
          categoryId,
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete category: $e',
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        backgroundColor,

        elevation: 0,

        centerTitle: false,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Categories',
              style: TextStyle(
                color: brown,
                fontSize: 22,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'Organize your café menu',
              style: TextStyle(
                color: lightBrown,
                fontSize: 9,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('name')
            .snapshots(),

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

          final categories =
              snapshot.data?.docs ?? [];

          return ListView(
            physics:
            const BouncingScrollPhysics(),

            padding:
            const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              35,
            ),

            children: [
              // ==================================================
              // INTRO CARD
              // ==================================================

              _buildIntroCard(
                categories.length,
              ),

              const SizedBox(
                height: 22,
              ),

              // ==================================================
              // ADD CATEGORY
              // ==================================================

              _buildAddSection(),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // CATEGORY TITLE
              // ==================================================

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
                          'YOUR MENU CATEGORIES',
                          style:
                          TextStyle(
                            color: brown,
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            0.7,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          'Keep your menu easy to explore.',
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

                  if (categories.isNotEmpty)
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF0DDC8,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        '${categories.length}',
                        style:
                        TextStyle(
                          color: brown,
                          fontSize: 11,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              // ==================================================
              // EMPTY
              // ==================================================

              if (categories.isEmpty)
                _buildEmptyState()

              // ==================================================
              // CATEGORY LIST
              // ==================================================

              else
                ...categories.map(
                      (doc) {
                    final data =
                    doc.data()
                    as Map<String,
                        dynamic>;

                    final name =
                        data['name']
                            ?.toString() ??
                            '';

                    return _buildCategoryTile(
                      doc.id,
                      name,
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // INTRO CARD
  // ============================================================

  Widget _buildIntroCard(
      int count,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(20),

      decoration:
      BoxDecoration(
        color: brown,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
            Colors.brown
                .withOpacity(0.13),
            blurRadius: 18,
            offset:
            const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration:
            BoxDecoration(
              color:
              Colors.white
                  .withOpacity(
                0.13,
              ),
              shape:
              BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .restaurant_menu_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Text(
                  'Build your menu',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  count == 0
                      ? 'Start by adding your first category.'
                      : '$count categories are currently available to customers.',

                  style:
                  const TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD SECTION
  // ============================================================

  Widget _buildAddSection() {
    return Container(
      padding:
      const EdgeInsets.all(18),

      decoration:
      BoxDecoration(
        color: cardColor,

        borderRadius:
        BorderRadius.circular(25),

        border: Border.all(
          color: softBrown,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.brown
                .withOpacity(0.04),
            blurRadius: 12,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFF2E0CC,
                  ),
                  shape:
                  BoxShape.circle,
                ),

                child: Icon(
                  Icons.add_rounded,
                  color: brown,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    'Add a category',
                    style:
                    TextStyle(
                      color: brown,
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    'Create a new menu section',
                    style:
                    TextStyle(
                      color:
                      lightBrown,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                  categoryController,

                  textInputAction:
                  TextInputAction.done,

                  onSubmitted:
                      (_) {
                    if (!isAdding) {
                      addCategory();
                    }
                  },

                  decoration:
                  InputDecoration(
                    hintText:
                    'e.g. Coffee',

                    prefixIcon:
                    Icon(
                      Icons
                          .category_outlined,
                      color:
                      lightBrown,
                      size: 20,
                    ),

                    filled: true,

                    fillColor:
                    backgroundColor,

                    hintStyle:
                    TextStyle(
                      color: lightBrown
                          .withOpacity(
                        0.65,
                      ),
                      fontSize: 11,
                    ),

                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),

                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),

                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                      borderSide:
                      BorderSide(
                        color: brown
                            .withOpacity(
                          0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              GestureDetector(
                onTap:
                isAdding
                    ? null
                    : addCategory,

                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 200,
                  ),

                  width: 54,
                  height: 54,

                  decoration:
                  BoxDecoration(
                    color: isAdding
                        ? brown.withOpacity(
                      0.55,
                    )
                        : brown,

                    borderRadius:
                    BorderRadius.circular(
                      17,
                    ),
                  ),

                  child: isAdding
                      ? const Padding(
                    padding:
                    EdgeInsets.all(
                      17,
                    ),
                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth:
                      2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .add_rounded,
                    color:
                    Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY TILE
  // ============================================================

  Widget _buildCategoryTile(
      String categoryId,
      String name,
      ) {
    return Dismissible(
      key: ValueKey(categoryId),

      direction:
      DismissDirection.endToStart,

      confirmDismiss:
          (_) async {
        await confirmDelete(
          categoryId,
          name,
        );

        return false;
      },

      background: Container(
        margin:
        const EdgeInsets.only(
          bottom: 11,
        ),

        padding:
        const EdgeInsets.only(
          right: 22,
        ),

        alignment:
        Alignment.centerRight,

        decoration:
        BoxDecoration(
          color:
          const Color(0xFFF3D8D3),
          borderRadius:
          BorderRadius.circular(
            21,
          ),
        ),

        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 24,
        ),
      ),

      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 11,
        ),

        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),

        decoration:
        BoxDecoration(
          color: cardColor,

          borderRadius:
          BorderRadius.circular(
            21,
          ),

          border: Border.all(
            color:
            const Color(
              0xFFEEDFCF,
            ),
          ),

          boxShadow: [
            BoxShadow(
              color:
              Colors.brown
                  .withOpacity(
                0.035,
              ),
              blurRadius: 10,
              offset:
              const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // ICON
            Container(
              width: 49,
              height: 49,

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF2E0CC,
                ),
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),

              child: Icon(
                _categoryIcon(name),
                color: brown,
                size: 23,
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            // NAME
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    TextStyle(
                      color: brown,
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'Menu category',
                    style:
                    TextStyle(
                      color:
                      lightBrown,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // DELETE
            Container(
              width: 38,
              height: 38,

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF8EBD7,
                ),
                shape:
                BoxShape.circle,
              ),

              child:
              IconButton(
                padding:
                EdgeInsets.zero,

                icon: const Icon(
                  Icons
                      .delete_outline_rounded,
                  color:
                  Color(0xFFB85B4E),
                  size: 19,
                ),

                onPressed: () {
                  confirmDelete(
                    categoryId,
                    name,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _categoryIcon(
      String category,
      ) {
    final value =
    category.toLowerCase();

    if (value.contains('coffee') ||
        value.contains('cafe')) {
      return Icons.coffee_rounded;
    }

    if (value.contains('dessert') ||
        value.contains('cake') ||
        value.contains('sweet')) {
      return Icons.cake_outlined;
    }

    if (value.contains('drink') ||
        value.contains('juice')) {
      return Icons.local_drink_outlined;
    }

    if (value.contains('tea')) {
      return Icons
          .emoji_food_beverage_outlined;
    }

    if (value.contains('breakfast')) {
      return Icons
          .free_breakfast_outlined;
    }

    return Icons
        .restaurant_menu_rounded;
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      margin:
      const EdgeInsets.only(
        top: 8,
      ),

      padding:
      const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 35,
      ),

      decoration:
      BoxDecoration(
        color: cardColor,

        borderRadius:
        BorderRadius.circular(
          25,
        ),

        border: Border.all(
          color: softBrown,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,

            decoration:
            const BoxDecoration(
              color:
              Color(0xFFF2E0CC),
              shape:
              BoxShape.circle,
            ),

            child: Icon(
              Icons
                  .restaurant_menu_outlined,
              color: brown,
              size: 34,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            'No categories yet',
            style: TextStyle(
              color: brown,
              fontSize: 17,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Add your first category above\nto start organizing the menu.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: lightBrown,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
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
            Icon(
              Icons.error_outline_rounded,
              color: brown,
              size: 45,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Unable to load categories',
              style: TextStyle(
                color: brown,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}