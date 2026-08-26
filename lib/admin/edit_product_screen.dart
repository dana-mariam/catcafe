import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController descriptionController;
  late final TextEditingController quantityController;

  String? selectedCategory;
  String currentImageUrl = '';

  File? selectedImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product['name']?.toString() ?? '',
    );

    priceController = TextEditingController(
      text: widget.product['price']?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.product['description']?.toString() ?? '',
    );

    quantityController = TextEditingController(
      text: widget.product['quantity']?.toString() ?? '',
    );

    selectedCategory =
        widget.product['categoryId']?.toString();

    currentImageUrl =
        widget.product['imageUrl']?.toString() ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String imageUrl = currentImageUrl;

      // Upload a new image only if the admin selected one.
      if (selectedImage != null) {
        final uploadedUrl =
        await CloudinaryService.uploadImage(
          selectedImage!,
        );

        if (uploadedUrl == null) {
          throw Exception(
            'Could not upload the new image.',
          );
        }

        imageUrl = uploadedUrl;
      }

      final double price =
      double.parse(priceController.text.trim());

      final int quantity =
      int.parse(quantityController.text.trim());

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': nameController.text.trim(),
        'price': price,
        'description':
        descriptionController.text.trim(),
        'categoryId': selectedCategory,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update product: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  InputDecoration fieldDecoration(
      String hint, {
        Widget? prefixIcon,
      }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFCF6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF9A6D58),
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
    );
  }

  Widget sectionTitle(
      String title,
      String subtitle,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF713D27),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF9A6D58),
              fontSize: 12,
            ),
          ),
        ],
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
        leading: IconButton(
          onPressed: isSaving
              ? null
              : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF713D27),
            size: 20,
          ),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(
            color: Color(0xFF713D27),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Form(
        key: formKey,

        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),

          children: [
            // ------------------------------------------------
            // PRODUCT IMAGE
            // ------------------------------------------------

            GestureDetector(
              onTap: isSaving ? null : pickImage,

              child: Container(
                height: 245,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF6),
                  borderRadius:
                  BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown
                          .withOpacity(0.07),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(28),

                  child: Stack(
                    fit: StackFit.expand,

                    children: [
                      if (selectedImage != null)
                        Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        )
                      else if (currentImageUrl.isNotEmpty)
                        Image.network(
                          currentImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stack) {
                            return const Center(
                              child: Icon(
                                Icons
                                    .image_not_supported_outlined,
                                size: 55,
                                color:
                                Color(0xFF9A6D58),
                              ),
                            );
                          },
                        )
                      else
                        const Center(
                          child: Icon(
                            Icons
                                .image_outlined,
                            size: 55,
                            color:
                            Color(0xFF9A6D58),
                          ),
                        ),

                      // Bottom overlay
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,

                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),

                          decoration:
                          BoxDecoration(
                            gradient:
                            LinearGradient(
                              begin: Alignment
                                  .topCenter,
                              end: Alignment
                                  .bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black
                                    .withOpacity(
                                  0.65,
                                ),
                              ],
                            ),
                          ),

                          child: Row(
                            children: [
                              Container(
                                padding:
                                const EdgeInsets
                                    .all(9),
                                decoration:
                                BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(
                                    0.92,
                                  ),
                                  shape:
                                  BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons
                                      .photo_camera_outlined,
                                  color:
                                  Color(0xFF713D27),
                                  size: 20,
                                ),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Change product photo',
                                      style: TextStyle(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Tap to choose a new image',
                                      style: TextStyle(
                                        color:
                                        Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ------------------------------------------------
            // BASIC INFO
            // ------------------------------------------------

            sectionTitle(
              'Product Details',
              'Keep your menu information fresh.',
            ),

            TextFormField(
              controller: nameController,
              textCapitalization:
              TextCapitalization.words,

              decoration: fieldDecoration(
                'Product name',
                prefixIcon: const Icon(
                  Icons.local_cafe_outlined,
                  color: Color(0xFF9A6D58),
                ),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter product name';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: descriptionController,
              maxLines: 4,

              decoration: fieldDecoration(
                'Describe your coffee or product',
                prefixIcon: const Icon(
                  Icons.notes_outlined,
                  color: Color(0xFF9A6D58),
                ),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter description';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // ------------------------------------------------
            // PRICE + QUANTITY
            // ------------------------------------------------

            sectionTitle(
              'Pricing & Stock',
              'Manage the price and available quantity.',
            ),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType:
                    const TextInputType
                        .numberWithOptions(
                      decimal: true,
                    ),

                    decoration: fieldDecoration(
                      'Price',
                      prefixIcon:
                      const Icon(
                        Icons
                            .payments_outlined,
                        color:
                        Color(0xFF9A6D58),
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Required';
                      }

                      final price =
                      double.tryParse(
                        value.trim(),
                      );

                      if (price == null ||
                          price < 0) {
                        return 'Invalid';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    controller:
                    quantityController,
                    keyboardType:
                    TextInputType.number,

                    decoration: fieldDecoration(
                      'Quantity',
                      prefixIcon:
                      const Icon(
                        Icons.inventory_2_outlined,
                        color:
                        Color(0xFF9A6D58),
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Required';
                      }

                      final quantity =
                      int.tryParse(
                        value.trim(),
                      );

                      if (quantity == null ||
                          quantity < 0) {
                        return 'Invalid';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ------------------------------------------------
            // CATEGORY
            // ------------------------------------------------

            sectionTitle(
              'Category',
              'Choose where this product belongs.',
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('name')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    padding:
                    const EdgeInsets.all(18),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(0xFFFFFCF6),
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child:
                    const LinearProgressIndicator(
                      color:
                      Color(0xFF713D27),
                      backgroundColor:
                      Color(0xFFF5E9D7),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding:
                    const EdgeInsets.all(18),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(0xFFFFFCF6),
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: const Text(
                      'Could not load categories.',
                      style: TextStyle(
                        color:
                        Color(0xFF9A6D58),
                      ),
                    ),
                  );
                }

                final categories =
                    snapshot.data?.docs ?? [];

                return DropdownButtonFormField<
                    String>(
                  value: categories.any(
                        (doc) =>
                    doc.id ==
                        selectedCategory,
                  )
                      ? selectedCategory
                      : null,

                  decoration:
                  fieldDecoration(
                    'Select category',
                    prefixIcon:
                    const Icon(
                      Icons.category_outlined,
                      color:
                      Color(0xFF9A6D58),
                    ),
                  ),

                  items: categories.map((doc) {
                    final data =
                    doc.data()
                    as Map<String,
                        dynamic>;

                    final name =
                        data['name'] ?? '';

                    return DropdownMenuItem<
                        String>(
                      value: doc.id,
                      child: Text(
                        name,
                        style:
                        const TextStyle(
                          color:
                          Color(0xFF713D27),
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: isSaving
                      ? null
                      : (value) {
                    setState(() {
                      selectedCategory =
                          value;
                    });
                  },

                  validator: (value) {
                    if (value == null) {
                      return 'Select a category';
                    }

                    return null;
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // ------------------------------------------------
            // SAVE
            // ------------------------------------------------

            SizedBox(
              height: 58,

              child: ElevatedButton(
                onPressed:
                isSaving ? null : saveProduct,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF713D27),
                  foregroundColor: Colors.white,

                  elevation: 3,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                  width: 23,
                  height: 23,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Icon(
                      Icons
                          .check_circle_outline,
                      size: 21,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Changes will be saved to your Cat Cafe menu.',
                style: TextStyle(
                  color: Color(0xFF9A6D58),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}