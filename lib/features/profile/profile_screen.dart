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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  bool isLoading = true;
  bool isSaving = false;

  String? photoUrl;
  File? selectedImage;

  User? get currentUser => FirebaseAuth.instance.currentUser;

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

  // ------------------------------------------------------------
  // Load profile from Firestore
  // ------------------------------------------------------------

  Future<void> loadProfile() async {
    final user = currentUser;

    if (user == null) {
      return;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (document.exists) {
        final data = document.data()!;

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load profile'),
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

  // ------------------------------------------------------------
  // Pick image from phone
  // ------------------------------------------------------------

  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select image'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // Save profile + upload image
  // ------------------------------------------------------------

  Future<void> saveProfile() async {
    final user = currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? newPhotoUrl = photoUrl;

      // If user selected a new image,
      // upload it to Cloudinary first.
      if (selectedImage != null) {
        newPhotoUrl =
        await CloudinaryService.uploadImage(
          selectedImage!,
        );

        if (newPhotoUrl == null) {
          throw Exception(
            'Image upload failed',
          );
        }
      }

      // Save all profile data in Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': nameController.text.trim(),
          'age': ageController.text.trim(),
          'phone': phoneController.text.trim(),
          'bio': bioController.text.trim(),
          'photoUrl': newPhotoUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      setState(() {
        photoUrl = newPhotoUrl;
        selectedImage = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile saved successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
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

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // ------------------------------------------------------------
  // Input decoration
  // ------------------------------------------------------------

  InputDecoration decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5E9D7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }

  // ------------------------------------------------------------
  // Profile image
  // ------------------------------------------------------------

  Widget buildProfileImage() {
    if (selectedImage != null) {
      return CircleAvatar(
        radius: 58,
        backgroundImage: FileImage(
          selectedImage!,
        ),
      );
    }

    if (photoUrl != null &&
        photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 58,
        backgroundImage: NetworkImage(
          photoUrl!,
        ),
      );
    }

    return const CircleAvatar(
      radius: 58,
      backgroundColor: Color(0xFFF1E1CA),
      backgroundImage: AssetImage(
        'lib/assets/images/cat_avatar.png',
      ),
    );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8EBD7),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF713D27),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF713D27),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            // --------------------------------------------------
            // Profile header
            // --------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(35),
              ),

              child: Column(
                children: [
                  Stack(
                    children: [
                      buildProfileImage(),

                      Positioned(
                        bottom: 0,
                        right: 0,

                        child: GestureDetector(
                          onTap: pickImage,

                          child: Container(
                            width: 38,
                            height: 38,

                            decoration: const BoxDecoration(
                              color: Color(0xFF713D27),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    nameController.text.isEmpty
                        ? 'Your Name'
                        : nameController.text,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF713D27),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    currentUser?.email ?? '',

                    style: const TextStyle(
                      color: Color(0xFF9A6D58),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(
                      Icons.photo_camera,
                      size: 18,
                    ),
                    label: const Text(
                      'Change Photo',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // Profile fields
            // --------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(35),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF713D27),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: nameController,
                    decoration: decoration(
                      'Enter your name',
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Age',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF713D27),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: ageController,
                    keyboardType:
                    TextInputType.number,
                    decoration: decoration(
                      'Enter your age',
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Phone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF713D27),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: phoneController,
                    keyboardType:
                    TextInputType.phone,
                    decoration: decoration(
                      'Enter your phone',
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Bio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF713D27),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: bioController,
                    maxLines: 4,
                    decoration: decoration(
                      'Tell us about yourself',
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // Save button
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 56,

                    child: ElevatedButton(
                      onPressed:
                      isSaving ? null : saveProfile,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF713D27),
                        foregroundColor:
                        Colors.white,

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
                        'Save',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}