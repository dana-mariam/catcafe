import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';
import '../auth/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final nameController =
  TextEditingController();

  final ageController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final bioController =
  TextEditingController();

  final ImagePicker imagePicker =
  ImagePicker();

  bool isLoading = true;
  bool isSaving = false;

  String? photoUrl;
  File? selectedImage;

  User? get currentUser =>
      FirebaseAuth.instance.currentUser;

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
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    final user = currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final document =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (document.exists) {
        final data =
        document.data()!;

        nameController.text =
            data['name']?.toString() ?? '';

        ageController.text =
            data['age']?.toString() ?? '';

        phoneController.text =
            data['phone']?.toString() ?? '';

        bioController.text =
            data['bio']?.toString() ?? '';

        photoUrl =
            data['photoUrl']?.toString();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load profile',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    if (isSaving) return;

    try {
      final XFile? image =
      await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage =
            File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to select image',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> saveProfile() async {
    final user = currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? newPhotoUrl =
          photoUrl;

      // Upload new image
      if (selectedImage != null) {
        newPhotoUrl =
        await CloudinaryService
            .uploadImage(
          selectedImage!,
        );

        if (newPhotoUrl == null) {
          throw Exception(
            'Image upload failed',
          );
        }
      }

      // Save profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name':
          nameController.text.trim(),

          'age':
          ageController.text.trim(),

          'phone':
          phoneController.text.trim(),

          'bio':
          bioController.text.trim(),

          'photoUrl':
          newPhotoUrl ?? '',

          'updatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        photoUrl =
            newPhotoUrl;

        selectedImage =
        null;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile saved successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save profile: $e',
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
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
          cardColor,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              24,
            ),
          ),

          title: Text(
            'Logout?',
            style: TextStyle(
              color: brown,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          content: Text(
            'Are you sure you want to leave Cat Cafe?',
            style: TextStyle(
              color: lightBrown,
              height: 1.4,
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
                'Stay',
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
                'Logout',
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

    if (shouldLogout != true) {
      return;
    }

    await FirebaseAuth.instance
        .signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),

          (route) => false,
    );
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: lightBrown,
        size: 19,
      ),

      filled: true,

      fillColor:
      const Color(0xFFF8EBD7),

      hintStyle: TextStyle(
        color:
        lightBrown.withOpacity(
          0.6,
        ),
        fontSize: 11,
      ),

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        borderSide:
        BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        borderSide:
        BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        borderSide:
        BorderSide(
          color:
          brown.withOpacity(
            0.3,
          ),
          width: 1.2,
        ),
      ),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget buildProfileImage() {
    if (selectedImage != null) {
      return Container(
        width: 118,
        height: 118,

        decoration:
        BoxDecoration(
          shape: BoxShape.circle,

          border: Border.all(
            color: Colors.white,
            width: 5,
          ),

          image:
          DecorationImage(
            image:
            FileImage(
              selectedImage!,
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (photoUrl != null &&
        photoUrl!.isNotEmpty) {
      return Container(
        width: 118,
        height: 118,

        decoration:
        BoxDecoration(
          shape: BoxShape.circle,

          border: Border.all(
            color: Colors.white,
            width: 5,
          ),

          image:
          DecorationImage(
            image:
            NetworkImage(
              photoUrl!,
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 118,
      height: 118,

      decoration:
      BoxDecoration(
        color:
        const Color(0xFFF1E1CA),

        shape: BoxShape.circle,

        border: Border.all(
          color: Colors.white,
          width: 5,
        ),

        image:
        const DecorationImage(
          image: AssetImage(
            'lib/assets/images/cat_avatar.png',
          ),
          fit: BoxFit.cover,
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
              fontSize: 15,
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
              fontSize: 9,
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
          fontSize: 10,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor:
        backgroundColor,

        body: Center(
          child:
          CircularProgressIndicator(
            color: brown,
          ),
        ),
      );
    }

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
              'My Profile',
              style: TextStyle(
                color: brown,
                fontSize: 21,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'Your little corner at Cat Cafe',
              style: TextStyle(
                color: lightBrown,
                fontSize: 9,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding:
            const EdgeInsets.only(
              right: 10,
            ),

            child: IconButton(
              onPressed:
              isSaving
                  ? null
                  : logout,

              icon: Icon(
                Icons.logout_rounded,
                color: brown,
                size: 21,
              ),
            ),
          ),
        ],
      ),

      body:
      SingleChildScrollView(
        physics:
        const BouncingScrollPhysics(),

        padding:
        const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          35,
        ),

        child: Column(
          children: [
            // ==================================================
            // PROFILE HERO
            // ==================================================

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.fromLTRB(
                20,
                25,
                20,
                20,
              ),

              decoration:
              BoxDecoration(
                color: brown,

                borderRadius:
                BorderRadius.circular(
                  30,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.brown
                        .withOpacity(
                      0.14,
                    ),
                    blurRadius: 18,
                    offset:
                    const Offset(
                      0,
                      7,
                    ),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Stack(
                    clipBehavior:
                    Clip.none,

                    children: [
                      buildProfileImage(),

                      Positioned(
                        right: -2,
                        bottom: -2,

                        child:
                        GestureDetector(
                          onTap:
                          pickImage,

                          child:
                          Container(
                            width: 40,
                            height: 40,

                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFE4C09F,
                              ),

                              shape:
                              BoxShape
                                  .circle,

                              border:
                              Border.all(
                                color:
                                brown,
                                width:
                                3,
                              ),
                            ),

                            child:
                            Icon(
                              Icons
                                  .camera_alt_rounded,
                              color:
                              brown,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Text(
                    nameController
                        .text
                        .trim()
                        .isEmpty
                        ? 'Welcome'
                        : nameController
                        .text
                        .trim(),

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 22,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    currentUser?.email ??
                        '',

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      Colors.white70,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  GestureDetector(
                    onTap:
                    pickImage,

                    child:
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),

                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),

                      child:
                      const Row(
                        mainAxisSize:
                        MainAxisSize
                            .min,

                        children: [
                          Icon(
                            Icons
                                .photo_camera_outlined,
                            color:
                            Colors.white,
                            size: 15,
                          ),

                          SizedBox(
                            width: 6,
                          ),

                          Text(
                            'Change Photo',
                            style:
                            TextStyle(
                              color:
                              Colors.white,
                              fontSize:
                              9,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // PERSONAL INFORMATION
            // ==================================================

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                19,
              ),

              decoration:
              BoxDecoration(
                color: cardColor,

                borderRadius:
                BorderRadius.circular(
                  27,
                ),

                border: Border.all(
                  color: softBrown,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  sectionTitle(
                    'PERSONAL INFORMATION',
                    'Keep your details up to date.',
                  ),

                  // NAME
                  fieldLabel(
                    'Name',
                  ),

                  TextField(
                    controller:
                    nameController,

                    textInputAction:
                    TextInputAction
                        .next,

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration:
                    decoration(
                      hint:
                      'Enter your name',
                      icon:
                      Icons.person_outline_rounded,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // AGE + PHONE
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            fieldLabel(
                              'Age',
                            ),

                            TextField(
                              controller:
                              ageController,

                              keyboardType:
                              TextInputType
                                  .number,

                              decoration:
                              decoration(
                                hint:
                                'Your age',
                                icon:
                                Icons
                                    .cake_outlined,
                              ),
                            ),
                          ],
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
                            fieldLabel(
                              'Phone',
                            ),

                            TextField(
                              controller:
                              phoneController,

                              keyboardType:
                              TextInputType
                                  .phone,

                              decoration:
                              decoration(
                                hint:
                                'Phone number',
                                icon:
                                Icons
                                    .phone_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // BIO
                  fieldLabel(
                    'Bio',
                  ),

                  TextField(
                    controller:
                    bioController,

                    maxLines: 4,

                    textCapitalization:
                    TextCapitalization
                        .sentences,

                    decoration:
                    decoration(
                      hint:
                      'Tell us a little about yourself...',
                      icon:
                      Icons
                          .edit_note_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // ACCOUNT CARD
            // ==================================================

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                17,
              ),

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF1DFC9,
                ),

                borderRadius:
                BorderRadius.circular(
                  22,
                ),
              ),

              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,

                    decoration:
                    BoxDecoration(
                      color: cardColor,
                      shape:
                      BoxShape.circle,
                    ),

                    child: Icon(
                      Icons
                          .verified_user_outlined,
                      color: brown,
                      size: 21,
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
                          'Account email',
                          style:
                          TextStyle(
                            color:
                            lightBrown,
                            fontSize:
                            9,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          currentUser?.email ??
                              'No email',
                          maxLines: 1,
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
                                .w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              width:
              double.infinity,

              height: 57,

              child:
              ElevatedButton(
                onPressed:
                isSaving
                    ? null
                    : saveProfile,

                style:
                ElevatedButton
                    .styleFrom(
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
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                child: isSaving
                    ? const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        color:
                        Colors.white,
                        strokeWidth:
                        2,
                      ),
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Text(
                      'Saving changes...',
                      style:
                      TextStyle(
                        fontSize:
                        12,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ],
                )
                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    Icon(
                      Icons
                          .check_rounded,
                      size: 21,
                    ),

                    SizedBox(
                      width: 7,
                    ),

                    Text(
                      'SAVE CHANGES',
                      style:
                      TextStyle(
                        fontSize:
                        13,
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
              height: 11,
            ),

            Text(
              'Your profile is saved securely with your account.',
              textAlign:
              TextAlign.center,

              style: TextStyle(
                color: lightBrown,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}