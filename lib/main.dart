import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/screens/onboarding_screen.dart';
import 'firebase_options.dart';
import 'features/auth/login/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  final hasSeenOnboarding =
      prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    CatCafeApp(
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}

class CatCafeApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const CatCafeApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Purr & Pour',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8EBD7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF713D27),
        ),
        fontFamily: 'Arial',
      ),
      home: hasSeenOnboarding
          ? LoginScreen()
          : const OnboardingScreen(),
    );
  }
}