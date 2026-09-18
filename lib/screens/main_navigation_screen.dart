import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color mint = Color(0xFFE3F8F5);

  // Same SharedPreferences key used by ProfileScreen.
  static const String _profilePhotoKey = 'freegi_profile_photo';

  late int _currentIndex;
  late final List<Widget> _screens;

  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex.clamp(0, 4);

    _screens = [
      const HomeScreen(
        showBottomNavigation: false,
      ),
      const CategoriesScreen(
        showBottomNavigation: false,
      ),
      CartScreen(
        showBottomNavigation: false,
        onContinueShopping: () {
          _changeTab(0);
        },
      ),
      const OrdersScreen(
        showBottomNavigation: false,
      ),
      ProfileScreen(
        showBottomNavigation: false,
        onProfilePhotoChanged: _handleProfilePhotoChanged,
      ),
    ];

    _loadProfilePhoto();
  }

  void _handleProfilePhotoChanged(String? path) {
    if (!mounted) return;

    setState(() {
      if (path != null &&
          path.trim().isNotEmpty &&
          File(path).existsSync()) {
        _profilePhotoPath = path;
      } else {
        _profilePhotoPath = null;
      }
    });
  }

  Future<void> _loadProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_profilePhotoKey);

    String? validPath;

    if (savedPath != null &&
        savedPath.trim().isNotEmpty &&
        File(savedPath).existsSync()) {
      validPath = savedPath;
    }

    if (!mounted) return;

    setState(() {
      _profilePhotoPath = validPath;
    });
  }

  Future<void> _changeTab(int index) async {
    // Reload photo every time navbar is used.
    // So after changing profile photo, moving between tabs refreshes avatar.
    await _loadProfilePhoto();

    if (!mounted) return;

    // IMPORTANT:
    // OrdersScreen is inside an IndexedStack, so its old State stays alive.
    // Recreate only the Orders screen whenever the Orders tab is tapped.
    // This makes it read the latest saved orders/status from OrderStorage.
    if (index == 3) {
      setState(() {
        _screens[3] = const OrdersScreen(
          showBottomNavigation: false,
        );
        _currentIndex = 3;
      });
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final keyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? const Color(0xFF0B1110)
          : const Color(0xFFF8FCFA),
      body: Column(
        children: [
          // Page content gets its own area and can never paint behind
          // the shared bottom navigation section.
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Hide the shared navbar while keyboard is open.
          if (!keyboardOpen)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _buildBottomNavigation(isDark),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    const navColor = Color(0xFFFFFFFF);

    final borderColor = isDark
        ? const Color(0xFF293432)
        : const Color(0xFFE8EFED);

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: navColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.28 : 0.08,
            ),
            blurRadius: 24,
            spreadRadius: isDark ? 0 : 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // HOME
          Expanded(
            child: _navItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
              isDark: isDark,
            ),
          ),

          // CATEGORIES
          Expanded(
            child: _navItem(
              index: 1,
              icon: Icons.shopping_basket_rounded,
              label: 'Categories',
              isDark: isDark,
            ),
          ),

          // CART
          Expanded(
            child: _cartNavItem(isDark),
          ),

          // ORDERS
          Expanded(
            child: _navItem(
              index: 3,
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
              isDark: isDark,
            ),
          ),

          // PROFILE
          Expanded(
            child: _profileNavItem(isDark),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HOME / CATEGORIES / ORDERS NAV ITEM
  // =========================================================

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final selected = _currentIndex == index;

    final inactiveColor = isDark
        ? const Color(0xFF91A19D)
        : const Color(0xFF747E8B);

    final selectedBackground = isDark
        ? teal.withValues(alpha: 0.15)
        : mint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeTab(index),
          borderRadius: BorderRadius.circular(19),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? selectedBackground
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? teal : inactiveColor,
                  size: selected ? 21 : 20,
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color:
                          selected ? teal : inactiveColor,
                      fontSize: 9.0,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w700,
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

  // =========================================================
  // PROFILE NAV ITEM
  // =========================================================

  Widget _profileNavItem(bool isDark) {
    final selected = _currentIndex == 4;

    final inactiveColor = isDark
        ? const Color(0xFF91A19D)
        : const Color(0xFF747E8B);

    final selectedBackground = isDark
        ? teal.withValues(alpha: 0.15)
        : mint;

    final bool hasPhoto =
        _profilePhotoPath != null &&
        _profilePhotoPath!.isNotEmpty &&
        File(_profilePhotoPath!).existsSync();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeTab(4),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 54,
            decoration: BoxDecoration(
              color: selected
                  ? selectedBackground
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasPhoto
                        ? Colors.transparent
                        : selected
                            ? teal.withValues(alpha: 0.12)
                            : Colors.transparent,
                    border: hasPhoto
                        ? Border.all(
                            color: selected
                                ? teal
                                : isDark
                                    ? const Color(0xFF46514F)
                                    : const Color(0xFFD8DEDD),
                            width: selected ? 2.2 : 1.4,
                          )
                        : null,
                    boxShadow: hasPhoto && selected
                        ? [
                            BoxShadow(
                              color: teal.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasPhoto
                      ? Image.file(
                          File(_profilePhotoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Icon(
                              Icons.person_rounded,
                              color: selected
                                  ? teal
                                  : inactiveColor,
                              size: 21,
                            );
                          },
                        )
                      : Icon(
                          Icons.person_rounded,
                          color:
                              selected ? teal : inactiveColor,
                          size: 21,
                        ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Profile',
                  maxLines: 1,
                  style: TextStyle(
                    color: selected ? teal : inactiveColor,
                    fontSize: 9.0,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CART NAV ITEM
  // =========================================================

  Widget _cartNavItem(bool isDark) {
    final selected = _currentIndex == 2;

    final inactiveText = isDark
        ? const Color(0xFF91A19D)
        : const Color(0xFF747E8B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeTab(2),
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 62,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -12,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: selected ? 54 : 51,
                  height: selected ? 54 : 51,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF12D4C7),
                        Color(0xFF00AFA8),
                        Color(0xFF008E88),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF151C1B)
                          : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: teal.withValues(
                          alpha: selected ? 0.34 : 0.24,
                        ),
                        blurRadius: selected ? 14 : 10,
                        spreadRadius: selected ? 1 : 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),

              Positioned(
                bottom: 3,
                child: Text(
                  'Cart',
                  style: TextStyle(
                    color:
                        selected ? teal : inactiveText,
                    fontSize: 9.0,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}