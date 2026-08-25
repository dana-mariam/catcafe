import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5E9D7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 16,
      ),
    );
  }

  Widget cafeLogo() {
    return Column(
      children: [
        Image.asset(
          'lib/assets/images/cat_logo.png',
          width: 52,
          height: 52,
        ),

        const SizedBox(height: 3),

        const Text(
          'Cat Cafe',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: Color(0xFF713D27),
            fontFamily: 'serif',
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'CAT CAFÉ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A6D58),
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'User creation failed',
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'age': '',
        'phone': '',
        'bio': '',
        'photoUrl': '',
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message =
          'Something went wrong';

      if (e.code ==
          'email-already-in-use') {
        message =
        'This email is already registered';
      } else if (e.code ==
          'invalid-email') {
        message =
        'Please enter a valid email';
      } else if (e.code ==
          'weak-password') {
        message =
        'Password is too weak';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EBD7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const SizedBox(height: 2),

                cafeLogo(),

                const SizedBox(height: 5),

                const Text(
                  'One account, endless purrs.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9A6D58),
                  ),
                ),

                const SizedBox(height: 2),

                // ------------------------------------------------
                // Cat + signup form
                // ------------------------------------------------

                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,

                  children: [
                    Container(
                      width: double.infinity,

                      margin: const EdgeInsets.only(
                        top: 92,
                      ),

                      padding: const EdgeInsets.fromLTRB(
                        22,
                        110,
                        22,
                        16,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF6),
                        borderRadius:
                        BorderRadius.circular(35),
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Name',
                            style: TextStyle(
                              color: Color(0xFF713D27),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextFormField(
                            controller:
                            nameController,

                            decoration:
                            fieldDecoration(
                              hint: 'Your name',
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Enter your name';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF713D27),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextFormField(
                            controller:
                            emailController,

                            keyboardType:
                            TextInputType
                                .emailAddress,

                            decoration:
                            fieldDecoration(
                              hint: 'you@catcafe.com',
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Enter your email';
                              }

                              if (!value.contains(
                                '@',
                              )) {
                                return 'Enter a valid email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Color(0xFF713D27),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextFormField(
                            controller:
                            passwordController,

                            obscureText:
                            obscurePassword,

                            decoration:
                            fieldDecoration(
                              hint: '••••••••',
                            ).copyWith(
                              suffixIcon:
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },

                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                      .visibility_off
                                      : Icons.visibility,

                                  color:
                                  const Color(
                                    0xFF795548,
                                  ),
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Enter your password';
                              }

                              if (value.length <
                                  6) {
                                return 'At least 6 characters';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              color: Color(0xFF713D27),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextFormField(
                            controller:
                            confirmPasswordController,

                            obscureText:
                            obscureConfirmPassword,

                            decoration:
                            fieldDecoration(
                              hint: '••••••••',
                            ).copyWith(
                              suffixIcon:
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                    !obscureConfirmPassword;
                                  });
                                },

                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons
                                      .visibility_off
                                      : Icons.visibility,

                                  color:
                                  const Color(
                                    0xFF795548,
                                  ),
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Confirm your password';
                              }

                              if (value !=
                                  passwordController
                                      .text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: ElevatedButton(
                              onPressed:
                              isLoading
                                  ? null
                                  : signup,

                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                const Color(
                                  0xFF713D27,
                                ),

                                foregroundColor:
                                Colors.white,

                                elevation: 3,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    30,
                                  ),
                                ),
                              ),

                              child: isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                CircularProgressIndicator(
                                  color:
                                  Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Sign Up',
                                style:
                                TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const LoginScreen(),
                                  ),
                                );
                              },

                              child: const Text.rich(
                                TextSpan(
                                  text:
                                  'Already a regular? ',

                                  style: TextStyle(
                                    color:
                                    Color(0xFF9A6D58),
                                  ),

                                  children: [
                                    TextSpan(
                                      text: 'Log In',

                                      style: TextStyle(
                                        color:
                                        Color(
                                          0xFF713D27,
                                        ),
                                        fontWeight:
                                        FontWeight.bold,
                                        decoration:
                                        TextDecoration
                                            .underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------
                    // Cat directly above the form
                    // ------------------------------------------------

                    Positioned(
                      top: 10,

                      child: Image.asset(
                        'lib/assets/images/cat_peek.png',
                        height: 118,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}