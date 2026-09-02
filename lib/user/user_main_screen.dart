import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../features/adoption/adoption_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/profile/profile_screen.dart';
import '../screens/home_screen.dart';
import 'favorites_screen.dart';
import 'my_orders_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int currentIndex = 0;

  void _goHome() {
    setState(() => currentIndex = 0);
  }

  void _goProfile() {
    setState(() => currentIndex = 5);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenProfile: _goProfile),
      FavoritesScreen(onExplore: _goHome),
      CartScreen(onShopNow: _goHome),
      const AdoptionScreen(),
      const MyOrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.nav,
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() => currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              selectedIcon: Icon(Icons.pets_rounded),
              label: 'Adopt',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
