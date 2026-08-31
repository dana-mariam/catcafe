import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutAddressScreen extends StatefulWidget {
  const CheckoutAddressScreen({super.key});

  @override
  State<CheckoutAddressScreen> createState() =>
      _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState
    extends State<CheckoutAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController =
  TextEditingController();

  bool _isSaving = false;

  static const Color backgroundColor = Color(0xFFF8EBD7);
  static const Color cardColor = Color(0xFFFFFCF6);
  static const Color brown = Color(0xFF713D27);
  static const Color lightBrown = Color(0xFF9A6D58);
  static const Color softBrown = Color(0xFFEAD5BF);

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  // ============================================================
  // LOAD SAVED ADDRESS
  // ============================================================

  Future<void> _loadAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!document.exists) {
        return;
      }

      final data = document.data();

      final savedAddress = data?['address'];

      if (savedAddress is String && savedAddress.isNotEmpty) {
        _addressController.text = savedAddress;
      }
    } catch (_) {
      // We don't show an error here because the user can
      // still enter the address manually.
    }
  }

  // ============================================================
  // SAVE ADDRESS
  // ============================================================

  Future<void> _saveAddressAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in before continuing.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final address = _addressController.text.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'address': address,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // For now we return the saved address.
      // The actual Checkout process will be connected next.
      Navigator.pop(
        context,
        address,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not save your address. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: brown,
                size: 17,
              ),
            ),
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHECKOUT',
              style: TextStyle(
                color: lightBrown,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Delivery Details',
              style: TextStyle(
                color: brown,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            25,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0DDC8),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: brown,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Where should we deliver?',
                              style: TextStyle(
                                color: brown,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Enter your delivery address before placing your order.',
                              style: TextStyle(
                                color: lightBrown,
                                fontSize: 9,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // ADDRESS TITLE
                // ==================================================

                const Text(
                  'DELIVERY ADDRESS',
                  style: TextStyle(
                    color: lightBrown,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 9),

                // ==================================================
                // ADDRESS FIELD
                // ==================================================

                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: softBrown,
                    ),
                  ),
                  child: TextFormField(
                    controller: _addressController,
                    maxLines: 4,
                    minLines: 3,
                    textInputAction: TextInputAction.done,

                    style: const TextStyle(
                      color: brown,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),

                    decoration: InputDecoration(
                      hintText:
                      'Example: Jenin, Al-Jawhara Street, Building 12',
                      hintStyle: const TextStyle(
                        color: Color(0xFFB99C88),
                        fontSize: 11,
                      ),

                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 8,
                          top: 14,
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: lightBrown,
                          size: 20,
                        ),
                      ),

                      prefixIconConstraints:
                      const BoxConstraints(
                        minWidth: 45,
                      ),

                      border: InputBorder.none,

                      contentPadding:
                      const EdgeInsets.all(16),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your delivery address.';
                      }

                      if (value.trim().length < 5) {
                        return 'Please enter a more complete address.';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // INFO NOTE
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: softBrown,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: lightBrown,
                        size: 19,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Your address will be saved to your account so you can use it again for future orders.',
                          style: TextStyle(
                            color: lightBrown,
                            fontSize: 9,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // CONTINUE BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : _saveAddressAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      disabledBackgroundColor:
                      lightBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      width: 21,
                      height: 21,
                      child:
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          'CONTINUE TO CHECKOUT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),

                        SizedBox(width: 8),

                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
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
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: brown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}