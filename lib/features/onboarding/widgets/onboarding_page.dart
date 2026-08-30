import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String tag;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.tag,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                image,
                height: 500,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 28),

            // Tag
            Text(
              tag.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 3,
                color: Color(0xFF765746),
              ),
            ),

            const SizedBox(height: 14),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Color(0xFF42251A),
                height: 1.15,
              ),
            ),

            const SizedBox(height: 14),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF765746),
              ),
            ),
          ],
        ),
      ),
    );
  }
}