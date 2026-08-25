import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../signup/signup_screen.dart';
import '../../profile/profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Email or password is incorrect';

      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-credential') {
        message = 'Email or password is incorrect';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
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
        vertical: 17,
      ),
    );
  }

  Widget cafeLogo() {
    return Column(
      children: [
        Image.asset(
          'lib/assets/images/cat_logo.png',
          width: 55,
          height: 55,
        ),

        const SizedBox(height: 4),

        const Text(
          'Cat Cafe',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF713D27),
            fontFamily: 'serif',
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'CAT CAFÉ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A6D58),
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EBD7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const SizedBox(height: 5),

                cafeLogo(),

                const SizedBox(height: 10),

                const Text(
                  'Your cup and a cat are waiting.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9A6D58),
                  ),
                ),

                const SizedBox(height: 5),

                // ------------------------------------------------
                // Cat + form
                // ------------------------------------------------

                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,

                  children: [
                    // Form card
                    Container(
                      width: double.infinity,

                      margin: const EdgeInsets.only(
                        top: 95,
                      ),

                      padding: const EdgeInsets.fromLTRB(
                        22,
                        115,
                        22,
                        20,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF6),
                        borderRadius: BorderRadius.circular(35),
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF713D27),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: emailController,
                            keyboardType:
                            TextInputType.emailAddress,

                            decoration: fieldDecoration(
                              hint: 'you@catcafe.com',
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter your email';
                              }

                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Color(0xFF713D27),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,

                            decoration:
                            fieldDecoration(
                              hint: '••••••••',
                            ).copyWith(
                              suffixIcon: IconButton(
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

                                  color: const Color(
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

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 7),

                          Align(
                            alignment:
                            Alignment.centerRight,

                            child: TextButton(
                              onPressed: () {},

                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color:
                                  Color(0xFF713D27),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: ElevatedButton(
                              onPressed:
                              isLoading ? null : login,

                              style:
                              ElevatedButton.styleFrom(
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
                                  BorderRadius.circular(
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
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const SignupScreen(),
                                  ),
                                );
                              },

                              child: const Text.rich(
                                TextSpan(
                                  text:
                                  'New to the café? ',

                                  style: TextStyle(
                                    color:
                                    Color(0xFF9A6D58),
                                  ),

                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',

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
                    // Cat sitting directly above the form
                    // ------------------------------------------------

                    Positioned(
                      top: 15,

                      child: Image.asset(
                        'lib/assets/images/cat_peek.png',
                        height: 120,
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