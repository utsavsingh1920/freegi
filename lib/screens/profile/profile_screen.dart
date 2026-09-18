import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freegi/data/favorites_store.dart';
import 'package:freegi/data/notification_store.dart';
import 'package:freegi/services/order_storage.dart';

import '../auth/welcome_screen.dart';
import '../favorites_screen.dart';
import '../notifications/notifications_screen.dart';
import '../offers/offers_screen.dart';
import '../orders/orders_screen.dart';
import '../settings/settings_screen.dart';
import '../support/help_support_screen.dart';
import '../wallet/wallet_screen.dart';

import 'edit_profile_screen.dart';
import 'refer_earn_screen.dart';
import 'saved_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNavigation;
  final ValueChanged<String?>? onProfilePhotoChanged;

  const ProfileScreen({
    super.key,
    this.showBottomNavigation = true,
    this.onProfilePhotoChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const teal = Color(0xFF00AFA8);
  static const darkTeal = Color(0xFF08756E);
  static const darkGreen = Color(0xFF075C50);
  static const orange = Color(0xFFFFA928);
  static const purple = Color(0xFF7A5AF8);
  static const danger = Color(0xFFD64C4C);

  static const background = Color(0xFFF8FCFA);
  static const text = Color(0xFF172321);
  static const subText = Color(0xFF71807D);
  static const border = Color(0xFFE1EBE9);
  static const mint = Color(0xFFE8F8F4);

  static const _nameKey = 'freegi_profile_name';
  static const _phoneKey = 'freegi_profile_phone';
  static const _emailKey = 'freegi_profile_email';
  static const _photoKey = 'freegi_profile_photo';

  String _name = 'Freegi User';
  String _phone = '+91 XXXXX XXXXX';
  String _email = 'user@freegi.app';
  String? _photoPath;

  bool _loading = true;
  bool _openingEditor = false;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadProfile(),
      _loadOrderCount(),
    ]);
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString(_nameKey)?.trim();
      final phone = prefs.getString(_phoneKey)?.trim();
      final email = prefs.getString(_emailKey)?.trim();
      final photo = prefs.getString(_photoKey)?.trim();

      if (!mounted) return;

      setState(() {
        _name = (name != null && name.isNotEmpty) ? name : 'Freegi User';
        _phone =
            (phone != null && phone.isNotEmpty) ? phone : '+91 XXXXX XXXXX';
        _email =
            (email != null && email.isNotEmpty) ? email : 'user@freegi.app';
        _photoPath = (photo != null && photo.isNotEmpty) ? photo : null;
        _loading = false;
      });

      widget.onProfilePhotoChanged?.call(_photoPath);
    } catch (e) {
      debugPrint('PROFILE LOAD ERROR: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOrderCount() async {
    try {
      final count = await OrderStorage.getTotalOrderCount();
      if (!mounted) return;
      setState(() => _orderCount = count);
    } catch (e) {
      debugPrint('ORDER COUNT ERROR: $e');
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _openEditProfile() async {
    if (_openingEditor || !mounted) return;
    _openingEditor = true;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    _openingEditor = false;
    if (!mounted) return;

    if (changed == true) {
      await _loadProfile();
    }
  }

  Future<void> _openOrders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
    await _loadOrderCount();
  }

  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openWallet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openOffers() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OffersScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSavedAddresses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openReferEarn() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReferEarnScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (!mounted) return;
    await _loadProfile();
    setState(() {});
  }

  Future<void> _openHelpSupport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFFFEEEE),
              child: Icon(Icons.logout_rounded, color: danger, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Log Out?',
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your Freegi account?',
          style: TextStyle(color: subText, fontSize: 11, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFFEEEE),
              foregroundColor: danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: teal)),
      );
    }

    return Scaffold(
      backgroundColor: background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                color: teal,
                onRefresh: _refreshAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    18,
                    4,
                    18,
                    widget.showBottomNavigation ? 32 : 112,
                  ),
                  child: Column(
                    children: [
                      _profileCard(),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: FavoritesStore.favorites,
                        builder: (context, favorites, _) => _quickStats(),
                      ),
                      const SizedBox(height: 14),

                      _profileShortcuts(),

                      const SizedBox(height: 18),

                      _sectionTitle('My Account'),
                      const SizedBox(height: 9),
                      _menuCard([
                        _ProfileMenuItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'My Orders',
                          subtitle: 'Track and manage your orders',
                          iconColor: teal,
                          iconBg: mint,
                          onTap: _openOrders,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.favorite_rounded,
                          title: 'Favorites',
                          subtitle: 'View your saved products',
                          iconColor: const Color(0xFFE85E65),
                          iconBg: const Color(0xFFFFECEF),
                          trailingText: '${FavoritesStore.count}',
                          onTap: _openFavorites,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Freegi Wallet',
                          subtitle: 'Balance and transactions',
                          iconColor: purple,
                          iconBg: const Color(0xFFF0ECFF),
                          trailingText: '₹0',
                          onTap: _openWallet,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.local_offer_rounded,
                          title: 'Offers & Coupons',
                          subtitle: 'View available deals and coupons',
                          iconColor: orange,
                          iconBg: const Color(0xFFFFF4DE),
                          onTap: _openOffers,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.location_on_rounded,
                          title: 'Saved Addresses',
                          subtitle: 'Manage your delivery addresses',
                          iconColor: const Color(0xFF3B82F6),
                          iconBg: const Color(0xFFEAF2FF),
                          onTap: _openSavedAddresses,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.card_giftcard_rounded,
                          title: 'Refer & Earn',
                          subtitle: 'Invite friends and earn rewards',
                          iconColor: const Color(0xFFE85E65),
                          iconBg: const Color(0xFFFFECEF),
                          onTap: _openReferEarn,
                        ),
                      ]),

                      const SizedBox(height: 18),
                      _sectionTitle('Preferences & Support'),
                      const SizedBox(height: 9),
                      _menuCard([
                        _ProfileMenuItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          subtitle: 'Offers and order updates',
                          iconColor: const Color(0xFFE96A3E),
                          iconBg: const Color(0xFFFFEEE8),
                          badge: NotificationStore.unreadCount > 0
                              ? '${NotificationStore.unreadCount}'
                              : null,
                          onTap: _openNotifications,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          subtitle: 'Account, language and preferences',
                          iconColor: darkTeal,
                          iconBg: mint,
                          onTap: _openSettings,
                        ),
                        _divider(),
                        _ProfileMenuItem(
                          icon: Icons.headset_mic_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get help with account and orders',
                          iconColor: const Color(0xFF2B8A66),
                          iconBg: const Color(0xFFE7F7EF),
                          onTap: _openHelpSupport,
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _logoutButton(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your Freegi account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _profileCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openEditProfile,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [darkGreen, darkTeal, teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: darkTeal.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  _avatar(_photoPath, 70, 3),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: darkTeal, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: teal,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.65),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? path, double size, double borderWidth) {
    final valid =
        path != null && path.isNotEmpty && File(path).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
      ),
      child: ClipOval(
        child: valid
            ? Image.file(
                File(path),
                key: ValueKey(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.person_rounded,
                  color: teal,
                  size: size * 0.55,
                ),
              )
            : Icon(
                Icons.person_rounded,
                color: teal,
                size: size * 0.55,
              ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _quickStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _stat(
              icon: Icons.shopping_bag_rounded,
              value: '$_orderCount',
              label: 'Orders',
              iconColor: teal,
              iconBg: mint,
              onTap: _openOrders,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _stat(
              icon: Icons.favorite_rounded,
              value: '${FavoritesStore.count}',
              label: 'Favorites',
              iconColor: const Color(0xFFE85E65),
              iconBg: const Color(0xFFFFECEF),
              onTap: _openFavorites,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _stat(
              icon: Icons.local_offer_rounded,
              value: '6',
              label: 'Coupons',
              iconColor: orange,
              iconBg: const Color(0xFFFFF1D9),
              onTap: _openOffers,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: text,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: subText,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 50,
      color: const Color(0xFFEAF0EF),
    );
  }

  // ============================================================
  // PROFILE SHORTCUTS
  // Offers • Help • Settings • Refer & Earn
  // ============================================================

  Widget _profileShortcuts() {
    return Row(
      children: [
        Expanded(
          child: _shortcutTile(
            icon: Icons.local_offer_rounded,
            label: 'Offers',
            iconColor: orange,
            backgroundColor: const Color(0xFFFFF8E8),
            borderColor: const Color(0xFFF5E6BD),
            onTap: _openOffers,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _shortcutTile(
            icon: Icons.headset_mic_rounded,
            label: 'Help',
            iconColor: const Color(0xFF2B8A66),
            backgroundColor: const Color(0xFFEDF9F4),
            borderColor: const Color(0xFFD7ECE3),
            onTap: _openHelpSupport,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _shortcutTile(
            icon: Icons.settings_rounded,
            label: 'Settings',
            iconColor: purple,
            backgroundColor: const Color(0xFFF2F0FF),
            borderColor: const Color(0xFFE0DBFA),
            onTap: _openSettings,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _shortcutTile(
            icon: Icons.group_add_rounded,
            label: 'Refer & Earn',
            iconColor: const Color(0xFFE85E65),
            backgroundColor: const Color(0xFFFFF0F2),
            borderColor: const Color(0xFFF4DDE1),
            onTap: _openReferEarn,
          ),
        ),
      ],
    );
  }

  Widget _shortcutTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: text,
                  fontSize: 9.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MENU HELPERS
  // ============================================================

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: text,
          fontSize: 15.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 55),
      child: Divider(height: 1, color: Color(0xFFEDF2F1)),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: danger,
          backgroundColor: const Color(0xFFFFF7F7),
          side: const BorderSide(color: Color(0xFFFFDCDC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
  final String? trailingText;
  final String? badge;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.trailingText,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ProfileScreenState.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _ProfileScreenState.subText,
                      fontSize: 9.3,
                      height: 1.3,
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
                  color: _ProfileScreenState.teal,
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
                  color: _ProfileScreenState.teal,
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
