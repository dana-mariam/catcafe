import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();

  File? selectedImage;
  String? selectedCategory;

  bool isSaving = false;

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

  Future<void> addProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a product image'),
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // 1. Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        selectedImage!,
      );

      if (imageUrl == null) {
        throw Exception('Image upload failed');
      }

      // 2. Convert price and quantity
      final double price =
      double.parse(priceController.text.trim());

      final int quantity =
      int.parse(quantityController.text.trim());

      // 3. Save product in Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .add({
        'name': nameController.text.trim(),
        'price': price,
        'description': descriptionController.text.trim(),
        'categoryId': selectedCategory,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Clear form
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      quantityController.clear();

      setState(() {
        selectedImage = null;
        selectedCategory = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product: $e'),
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

  InputDecoration fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFFFCF6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF713D27),
          fontWeight: FontWeight.w600,
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
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Color(0xFF713D27),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            // IMAGE
            GestureDetector(
              onTap: isSaving ? null : pickImage,

              child: Container(
                height: 190,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF6),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: selectedImage != null
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(24),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 50,
                      color: Color(0xFF9A6D58),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Choose Product Image',
                      style: TextStyle(
                        color: Color(0xFF713D27),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to select from gallery',
                      style: TextStyle(
                        color: Color(0xFF9A6D58),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // NAME
            label('Product Name'),

            TextFormField(
              controller: nameController,
              decoration:
              fieldDecoration('Enter product name'),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter product name';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // PRICE
            label('Price'),

            TextFormField(
              controller: priceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration:
              fieldDecoration('Enter price'),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter price';
                }

                final price =
                double.tryParse(value.trim());

                if (price == null || price < 0) {
                  return 'Enter a valid price';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            label('Description'),

            TextFormField(
              controller: descriptionController,
              maxLines: 4,

              decoration:
              fieldDecoration('Enter description'),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter description';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // CATEGORY
            label('Category'),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('name')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF6),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Loading categories...',
                      style: TextStyle(
                        color: Color(0xFF9A6D58),
                      ),
                    ),
                  );
                }

                final categories =
                    snapshot.data?.docs ?? [];

                return DropdownButtonFormField<String>(
                  value: selectedCategory,

                  decoration:
                  fieldDecoration('Select category'),

                  items: categories.map((doc) {
                    final data =
                    doc.data()
                    as Map<String, dynamic>;

                    final name =
                        data['name'] ?? '';

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(name),
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

            const SizedBox(height: 16),

            // QUANTITY
            label('Quantity'),

            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,

              decoration:
              fieldDecoration('Enter quantity'),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter quantity';
                }

                final quantity =
                int.tryParse(value.trim());

                if (quantity == null ||
                    quantity < 0) {
                  return 'Enter a valid quantity';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // ADD BUTTON
            SizedBox(
              height: 56,

              child: ElevatedButton(
                onPressed:
                isSaving ? null : addProduct,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF713D27),
                  foregroundColor: Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}