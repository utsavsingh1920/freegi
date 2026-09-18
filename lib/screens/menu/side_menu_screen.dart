import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../categories/categories_screen.dart';
import '../orders/orders_screen.dart';
import '../wallet/wallet_screen.dart';
import '../offers/offers_screen.dart';
import '../notifications/notifications_screen.dart';
import '../support/help_support_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

class SideMenuScreen extends StatelessWidget {
  const SideMenuScreen({super.key});

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color borderColor = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE8F8F4);
  static const Color orange = Color(0xFFFFA928);

  void _openScreen(
    BuildContext context,
    Widget screen,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Log Out?',
            style: TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out from Freegi?',
            style: TextStyle(
              color: subText,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: subText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _showMessage(
                  context,
                  'Logout will be connected with Login screen later.',
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFFEEEE),
                foregroundColor: const Color(0xFFD64C4C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  30,
                ),
                child: Column(
                  children: [
                    _buildProfileCard(context),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Explore'),

                    const SizedBox(height: 10),

                    _buildMenuCard(
                      children: [
                        _MenuItem(
                          icon: Icons.home_rounded,
                          title: 'Home',
                          subtitle: 'Back to Freegi home',
                          iconColor: teal,
                          iconBg: lightMint,
                          onTap: () {
                            _goHome(context);
                          },
                        ),

                        _divider(),

                        _MenuItem(
                          icon: Icons.grid_view_rounded,
                          title: 'Categories',
                          subtitle: 'Browse grocery categories',
                          iconColor: const Color(0xFF3B82F6),
                          iconBg: const Color(0xFFEAF2FF),
                          onTap: () {
                            _openScreen(
                              context,
                              const CategoriesScreen(),
                            );
                          },
                        ),

                        _divider(),

                        _MenuItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'My Orders',
                          subtitle: 'Track and manage orders',
                          iconColor: teal,
                          iconBg: lightMint,
                          onTap: () {
                            _openScreen(
                              context,
                              const OrdersScreen(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Payments & Offers'),

                    const SizedBox(height: 10),

                    _buildMenuCard(
                      children: [
                        _MenuItem(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Freegi Wallet',
                          subtitle: 'Balance and transactions',
                          iconColor: const Color(0xFF7A5AF8),
                          iconBg: const Color(0xFFF0ECFF),
                          trailingText: '₹0',
                          onTap: () {
                            _openScreen(
                              context,
                              const WalletScreen(),
                            );
                          },
                        ),

                        _divider(),

                        _MenuItem(
                          icon: Icons.local_offer_rounded,
                          title: 'Offers & Coupons',
                          subtitle: 'Save more on your orders',
                          iconColor: orange,
                          iconBg: const Color(0xFFFFF4DE),
                          onTap: () {
                            _openScreen(
                              context,
                              const OffersScreen(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Account'),

                    const SizedBox(height: 10),

                    _buildMenuCard(
                      children: [
                        _MenuItem(
                          icon: Icons.person_rounded,
                          title: 'My Profile',
                          subtitle: 'Manage your account',
                          iconColor: teal,
                          iconBg: lightMint,
                          onTap: () {
                            _openScreen(
                              context,
                              const ProfileScreen(),
                            );
                          },
                        ),

                        _divider(),

                        _MenuItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          subtitle: 'Orders, offers and updates',
                          iconColor: const Color(0xFFE96A3E),
                          iconBg: const Color(0xFFFFEEE8),
                          badge: '3',
                          onTap: () {
                            _openScreen(
                              context,
                              const NotificationsScreen(),
                            );
                          },
                        ),

                        _divider(),

                        _MenuItem(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          subtitle: 'Theme and preferences',
                          iconColor: darkTeal,
                          iconBg: lightMint,
                          onTap: () {
                            _openScreen(
                              context,
                              const SettingsScreen(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Support'),

                    const SizedBox(height: 10),

                    _buildMenuCard(
                      children: [
                        _MenuItem(
                          icon: Icons.headset_mic_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get help with Freegi',
                          iconColor: const Color(0xFF2B8A66),
                          iconBg: const Color(0xFFE7F7EF),
                          onTap: () {
                            _openScreen(
                              context,
                              const HelpSupportScreen(),
                            );
                          },
                        ),

                        _divider(),

                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          title: 'About Freegi',
                          subtitle: 'App information and version',
                          iconColor: const Color(0xFF667085),
                          iconBg: const Color(0xFFF1F3F5),
                          onTap: () {
                            _showMessage(
                              context,
                              'About Freegi screen will be connected later.',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildLogoutButton(context),

                    const SizedBox(height: 22),

                    const Text(
                      'Freegi • Version 1.0.0',
                      style: TextStyle(
                        color: Color(0xFF9AA5A3),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Fresh groceries, faster to you.',
                      style: TextStyle(
                        color: Color(0xFFB0BAB8),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.maybePop(context);
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkText,
                size: 18,
              ),
            ),
          ),

          const Spacer(),

          const Column(
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Explore Freegi',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: teal,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return InkWell(
      onTap: () {
        _openScreen(
          context,
          const ProfileScreen(),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              darkGreen,
              darkTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: darkTeal.withValues(
                alpha: 0.16,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.70,
                  ),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: teal,
                size: 34,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Freegi User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'user@freegi.app',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.72,
                      ),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.14,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: darkText,
          fontSize: 15.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 55,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFEDF2F1),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          _showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD64C4C),
          side: const BorderSide(
            color: Color(0xFFFFDCDC),
          ),
          backgroundColor: const Color(0xFFFFF7F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
  final String? trailingText;
  final String? badge;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.trailingText,
    this.badge,
  });

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9.3,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (badge != null)
              Container(
                constraints: const BoxConstraints(
                  minWidth: 23,
                  minHeight: 23,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(
                  color: teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
            ],

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFAAB5B2),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}