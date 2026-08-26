import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EBD7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8EBD7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Color(0xFF713D27),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Orders management coming soon',
          style: TextStyle(
            color: Color(0xFF9A6D58),
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}