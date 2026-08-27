import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController =
  TextEditingController();

  final priceController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  final quantityController =
  TextEditingController();

  File? selectedImage;

  String? selectedCategory;

  bool isSaving = false;

  // ============================================================
  // CATEGORIES
  // ============================================================

  List<QueryDocumentSnapshot> categories = [];

  bool isLoadingCategories = true;

  // ============================================================
  // COLORS
  // ============================================================

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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    quantityController.text = '0';

    loadCategories();
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

  Future<void> loadCategories() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();

      if (!mounted) return;

      setState(() {
        categories = snapshot.docs;
        isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingCategories = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load categories: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    quantityController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    if (isSaving) return;

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    if (!mounted) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> addProduct() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose a product image',
          ),
        ),
      );

      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a category',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // ========================================================
      // 1. UPLOAD IMAGE TO CLOUDINARY
      // ========================================================

      final imageUrl =
      await CloudinaryService.uploadImage(
        selectedImage!,
      );

      if (imageUrl == null) {
        throw Exception(
          'Image upload failed',
        );
      }

      // ========================================================
      // 2. CONVERT PRICE & QUANTITY
      // ========================================================

      final double price =
      double.parse(
        priceController.text.trim(),
      );

      final int quantity =
      int.parse(
        quantityController.text.trim(),
      );

      // ========================================================
      // 3. GET CATEGORY NAME
      // ========================================================

      String categoryName = '';

      try {
        final categoryDoc =
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(selectedCategory)
            .get();

        if (categoryDoc.exists) {
          final categoryData =
          categoryDoc.data();

          categoryName =
              categoryData?['name']
                  ?.toString() ??
                  '';
        }
      } catch (_) {
        // Keep categoryName empty if
        // category name cannot be loaded.
      }

      // ========================================================
      // 4. SAVE PRODUCT TO FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection('products')
          .add({
        'name':
        nameController.text.trim(),

        'price': price,

        'description':
        descriptionController.text.trim(),

        'categoryId':
        selectedCategory,

        'categoryName':
        categoryName,

        'quantity': quantity,

        'imageUrl': imageUrl,

        'createdAt':
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ========================================================
      // 5. CLEAR FORM
      // ========================================================

      nameController.clear();

      priceController.clear();

      descriptionController.clear();

      quantityController.text = '0';

      setState(() {
        selectedImage = null;

        selectedCategory = null;
      });

      // ========================================================
      // 6. RESET FORM VALIDATION
      // ========================================================

      formKey.currentState?.reset();

      // Important:
      // Keep quantity at 0 after reset.
      quantityController.text = '0';

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Product added successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add product: $e',
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

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration fieldDecoration({
    required String hint,
    IconData? icon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color: lightBrown,
        size: 20,
      ),

      prefixText: prefixText,

      prefixStyle: TextStyle(
        color: brown,
        fontWeight: FontWeight.w800,
      ),

      filled: true,

      fillColor: cardColor,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),

      hintStyle: TextStyle(
        color:
        lightBrown.withOpacity(0.65),
        fontSize: 12,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide: BorderSide(
          color:
          brown.withOpacity(0.35),
          width: 1.2,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(
      String title,
      String subtitle,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(
              color: brown,
              fontSize: 16,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            subtitle,
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
  // FIELD LABEL
  // ============================================================

  Widget fieldLabel(
      String text,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        left: 3,
        bottom: 7,
      ),

      child: Text(
        text,
        style: TextStyle(
          color: brown,
          fontSize: 11,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
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

        leading: IconButton(
          onPressed: isSaving
              ? null
              : () {
            Navigator.pop(
              context,
            );
          },

          icon: Icon(
            Icons
                .arrow_back_ios_new_rounded,
            color: brown,
            size: 19,
          ),
        ),

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Create New Item',
              style: TextStyle(
                color: brown,
                fontSize: 20,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'Add something special to the menu',
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

      body: Form(
        key: formKey,

        child: ListView(
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
            // INTRO
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(
                color: brown,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),
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
                        0.14,
                      ),

                      shape:
                      BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons
                          .local_cafe_rounded,
                      color:
                      Colors.white,
                      size: 25,
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

                      children: const [
                        Text(
                          'A new café favorite?',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),

                        SizedBox(
                          height: 4,
                        ),

                        Text(
                          'Create a beautiful menu item for your customers.',
                          style:
                          TextStyle(
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
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // PRODUCT IMAGE
            // ==================================================

            sectionTitle(
              'PRODUCT PHOTO',
              'Give your item a photo worth craving.',
            ),

            GestureDetector(
              onTap:
              isSaving
                  ? null
                  : pickImage,

              child: AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 250,
                ),

                height: 220,

                decoration:
                BoxDecoration(
                  color: cardColor,

                  borderRadius:
                  BorderRadius.circular(
                    28,
                  ),

                  border: Border.all(
                    color:
                    selectedImage ==
                        null
                        ? softBrown
                        : Colors
                        .transparent,

                    width: 1.2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown
                          .withOpacity(
                        0.05,
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

                child:
                selectedImage !=
                    null
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                      BorderRadius
                          .circular(
                        28,
                      ),

                      child:
                      Image.file(
                        selectedImage!,
                        width:
                        double.infinity,
                        height:
                        double.infinity,
                        fit: BoxFit
                            .cover,
                      ),
                    ),

                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,

                      child:
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          14,
                          vertical:
                          10,
                        ),

                        decoration:
                        BoxDecoration(
                          color: Colors
                              .black
                              .withOpacity(
                            0.55,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .photo_camera_outlined,
                              color:
                              Colors.white,
                              size: 18,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            const Expanded(
                              child:
                              Text(
                                'Change product photo',
                                style:
                                TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize:
                                  11,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons
                                  .chevron_right_rounded,
                              color:
                              Colors.white,
                              size: 19,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    Container(
                      width: 68,
                      height: 68,

                      decoration:
                      const BoxDecoration(
                        color:
                        Color(
                          0xFFF3DFCA,
                        ),
                        shape:
                        BoxShape
                            .circle,
                      ),

                      child:
                      Icon(
                        Icons
                            .add_photo_alternate_outlined,
                        color:
                        brown,
                        size:
                        32,
                      ),
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    Text(
                      'Add Product Photo',
                      style:
                      TextStyle(
                        color:
                        brown,
                        fontSize:
                        15,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Tap to choose an image from your gallery',
                      style:
                      TextStyle(
                        color:
                        lightBrown,
                        fontSize:
                        10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // PRODUCT INFORMATION
            // ==================================================

            sectionTitle(
              'PRODUCT INFORMATION',
              'Tell customers what makes this item special.',
            ),

            // NAME

            fieldLabel(
              'Product Name',
            ),

            TextFormField(
              controller:
              nameController,

              textInputAction:
              TextInputAction.next,

              decoration:
              fieldDecoration(
                hint:
                'e.g. Caffe Latte',
                icon:
                Icons
                    .local_cafe_outlined,
              ),

              validator:
                  (value) {
                if (value ==
                    null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Enter product name';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 15,
            ),

            // PRICE + CATEGORY

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                // ==================================================
                // PRICE
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      fieldLabel(
                        'Price',
                      ),

                      TextFormField(
                        controller:
                        priceController,

                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal:
                          true,
                        ),

                        decoration:
                        fieldDecoration(
                          hint:
                          '20.00',
                          prefixText:
                          '\$  ',
                        ),

                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Enter price';
                          }

                          final price =
                          double.tryParse(
                            value.trim(),
                          );

                          if (price ==
                              null ||
                              price <
                                  0) {
                            return 'Invalid price';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // ==================================================
                // CATEGORY
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      fieldLabel(
                        'Category',
                      ),

                      if (isLoadingCategories)
                        Container(
                          height: 56,

                          decoration:
                          BoxDecoration(
                            color:
                            cardColor,

                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),

                          child:
                          Center(
                            child:
                            SizedBox(
                              width: 19,
                              height: 19,

                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2,
                                color:
                                brown,
                              ),
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<
                            String>(
                          // This key is important.
                          //
                          // When selectedCategory becomes null
                          // after adding a product, Flutter creates
                          // a fresh DropdownButtonFormField state.
                          key: ValueKey(
                            selectedCategory,
                          ),

                          value:
                          selectedCategory,

                          isExpanded:
                          true,

                          icon:
                          Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            color:
                            lightBrown,
                          ),

                          decoration:
                          fieldDecoration(
                            hint:
                            'Select',
                            icon:
                            Icons
                                .category_outlined,
                          ),

                          items:
                          categories
                              .map(
                                (
                                doc,
                                ) {
                              final data =
                              doc.data()
                              as Map<String,
                                  dynamic>;

                              final name =
                                  data['name']
                                      ?.toString() ??
                                      '';

                              return DropdownMenuItem<
                                  String>(
                                value:
                                doc.id,

                                child:
                                Text(
                                  name,

                                  overflow:
                                  TextOverflow
                                      .ellipsis,

                                  style:
                                  TextStyle(
                                    color:
                                    brown,
                                    fontSize:
                                    11,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),
                              );
                            },
                          ).toList(),

                          onChanged:
                          isSaving
                              ? null
                              : (
                              value,
                              ) {
                            setState(
                                  () {
                                selectedCategory =
                                    value;
                              },
                            );
                          },

                          validator:
                              (value) {
                            if (value ==
                                null) {
                              return 'Select category';
                            }

                            return null;
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            fieldLabel(
              'Description',
            ),

            TextFormField(
              controller:
              descriptionController,

              maxLines: 4,

              textCapitalization:
              TextCapitalization
                  .sentences,

              decoration:
              fieldDecoration(
                hint:
                'Describe the taste, ingredients or experience...',
                icon:
                Icons
                    .description_outlined,
              ),

              validator:
                  (value) {
                if (value ==
                    null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Enter description';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // INVENTORY
            // ==================================================

            sectionTitle(
              'INVENTORY',
              'Set how many items are currently available.',
            ),

            Container(
              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color: cardColor,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),

                border: Border.all(
                  color: softBrown,
                ),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,

                        decoration:
                        const BoxDecoration(
                          color:
                          Color(
                            0xFFF3DFCA,
                          ),
                          shape:
                          BoxShape.circle,
                        ),

                        child: Icon(
                          Icons
                              .inventory_2_outlined,
                          color: brown,
                          size: 22,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            Text(
                              'Available Quantity',
                              style:
                              TextStyle(
                                color:
                                brown,
                                fontSize:
                                13,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              'Customers can order until stock reaches zero.',
                              style:
                              TextStyle(
                                color:
                                lightBrown,
                                fontSize:
                                9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // QUANTITY CONTROL
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                    children: [
                      _quantityButton(
                        icon:
                        Icons
                            .remove_rounded,

                        onTap: () {
                          int value =
                              int.tryParse(
                                quantityController
                                    .text,
                              ) ??
                                  0;

                          if (value >
                              0) {
                            value--;
                          }

                          quantityController
                              .text =
                              value
                                  .toString();

                          setState(
                                () {},
                          );
                        },
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Container(
                        width: 100,
                        height: 55,

                        alignment:
                        Alignment.center,

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

                        child:
                        TextFormField(
                          controller:
                          quantityController,

                          textAlign:
                          TextAlign.center,

                          keyboardType:
                          TextInputType
                              .number,

                          style:
                          TextStyle(
                            color:
                            brown,
                            fontSize:
                            20,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),

                          decoration:
                          const InputDecoration(
                            border:
                            InputBorder
                                .none,

                            contentPadding:
                            EdgeInsets
                                .zero,
                          ),

                          validator:
                              (value) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Enter quantity';
                            }

                            final quantity =
                            int.tryParse(
                              value.trim(),
                            );

                            if (quantity ==
                                null ||
                                quantity <
                                    0) {
                              return 'Invalid';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      _quantityButton(
                        icon:
                        Icons
                            .add_rounded,

                        onTap: () {
                          int value =
                              int.tryParse(
                                quantityController
                                    .text,
                              ) ??
                                  0;

                          value++;

                          quantityController
                              .text =
                              value
                                  .toString();

                          setState(
                                () {},
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // STOCK STATUS
                  // ==================================================

                  Builder(
                    builder:
                        (context) {
                      final quantity =
                          int.tryParse(
                            quantityController
                                .text,
                          ) ??
                              0;

                      final isOutOfStock =
                          quantity ==
                              0;

                      return AnimatedContainer(
                        duration:
                        const Duration(
                          milliseconds:
                          200,
                        ),

                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          12,
                          vertical:
                          7,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          isOutOfStock
                              ? const Color(
                            0xFFF3D6D1,
                          )
                              : const Color(
                            0xFFE6F0E0,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),
                        ),

                        child: Row(
                          mainAxisSize:
                          MainAxisSize
                              .min,

                          children: [
                            Container(
                              width: 7,
                              height: 7,

                              decoration:
                              BoxDecoration(
                                color:
                                isOutOfStock
                                    ? Colors
                                    .red
                                    : const Color(
                                  0xFF76945F,
                                ),

                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),

                            const SizedBox(
                              width: 7,
                            ),

                            Text(
                              isOutOfStock
                                  ? 'Currently out of stock'
                                  : 'In stock • $quantity available',

                              style:
                              TextStyle(
                                color:
                                isOutOfStock
                                    ? Colors
                                    .red
                                    : const Color(
                                  0xFF64804F,
                                ),

                                fontSize:
                                9,

                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // ADD BUTTON
            // ==================================================

            SizedBox(
              height: 58,

              child:
              ElevatedButton(
                onPressed:
                isSaving
                    ? null
                    : addProduct,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  brown,

                  disabledBackgroundColor:
                  brown.withOpacity(
                    0.55,
                  ),

                  foregroundColor:
                  Colors.white,

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),
                  ),
                ),

                child:
                isSaving
                    ? Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children:
                  const [
                    SizedBox(
                      width: 21,
                      height: 21,

                      child:
                      CircularProgressIndicator(
                        color:
                        Colors
                            .white,
                        strokeWidth:
                        2,
                      ),
                    ),

                    SizedBox(
                      width: 11,
                    ),

                    Text(
                      'Adding to menu...',
                      style:
                      TextStyle(
                        fontSize:
                        13,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children:
                  const [
                    Icon(
                      Icons
                          .add_rounded,
                      size:
                      22,
                    ),

                    SizedBox(
                      width: 7,
                    ),

                    Text(
                      'ADD TO MENU',
                      style:
                      TextStyle(
                        fontSize:
                        14,
                        fontWeight:
                        FontWeight
                            .w900,
                        letterSpacing:
                        0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Center(
              child: Text(
                'The product will be saved to the Cat Cafe menu.',
                style: TextStyle(
                  color: lightBrown,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUANTITY BUTTON
  // ============================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap:
      isSaving
          ? null
          : onTap,

      child: Container(
        width: 45,
        height: 45,

        decoration:
        BoxDecoration(
          color: brown,

          shape:
          BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: Colors.brown
                  .withOpacity(
                0.12,
              ),

              blurRadius: 8,

              offset:
              const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: Icon(
          icon,
          color:
          Colors.white,
          size: 21,
        ),
      ),
    );
  }
}