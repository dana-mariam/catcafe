import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/auth/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CatCafeApp());
}

class CatCafeApp extends StatelessWidget {
  const CatCafeApp({super.key});

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
      home: LoginScreen(),
    );
  }
}