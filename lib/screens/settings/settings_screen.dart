import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'account_settings_screen.dart';
import 'privacy_security_screen.dart';
import 'about_freegi_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color orange = Color(0xFFFFA928);

  static const Color background = Color(0xFFF7FCFA);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color border = Color(0xFFE1EBE9);
  static const Color divider = Color(0xFFEDF2F1);
  static const Color mint = Color(0xFFE8F8F4);

  static const String _pushKey = 'freegi_push_notifications';
  static const String _orderKey = 'freegi_order_updates';
  static const String _offersKey = 'freegi_offers_updates';
  static const String _languageKey = 'freegi_language';

  bool pushNotifications = true;
  bool orderUpdates = true;
  bool offersUpdates = true;
  String selectedLanguage = 'English';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      pushNotifications = prefs.getBool(_pushKey) ?? true;
      orderUpdates = prefs.getBool(_orderKey) ?? true;
      offersUpdates = prefs.getBool(_offersKey) ?? true;
      selectedLanguage = prefs.getString(_languageKey) ?? 'English';
      _loading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  void _showMessage(String message) {
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

  void _showLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Choose Language',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Select your preferred app language.',
                      style: TextStyle(
                        color: subText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _languageOption(
                      sheetContext: sheetContext,
                      language: 'English',
                      subtitle: 'English',
                      setSheetState: setSheetState,
                    ),
                    const SizedBox(height: 9),
                    _languageOption(
                      sheetContext: sheetContext,
                      language: 'Hindi',
                      subtitle: 'हिन्दी',
                      setSheetState: setSheetState,
                    ),
                    const SizedBox(height: 9),
                    _languageOption(
                      sheetContext: sheetContext,
                      language: 'Marathi',
                      subtitle: 'मराठी',
                      setSheetState: setSheetState,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _languageOption({
    required BuildContext sheetContext,
    required String language,
    required String subtitle,
    required StateSetter setSheetState,
  }) {
    final selected = selectedLanguage == language;

    return InkWell(
      onTap: () async {
        setState(() {
          selectedLanguage = language;
        });

        setSheetState(() {});
        await _saveLanguage(language);

        if (!mounted) return;
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }

        _showMessage('$language selected.');
      },
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? mint : const Color(0xFFF9FCFB),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected ? teal : border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? teal.withValues(alpha: 0.10) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language_rounded,
                color: selected ? teal : subText,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      color: selected ? teal : text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: teal, size: 21),
          ],
        ),
      ),
    );
  }

  void _clearSearchHistory() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Clear Search History?',
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Your recent product searches will be removed.',
            style: TextStyle(
              color: subText,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('freegi_recent_searches');

                if (!mounted) return;
                _showMessage('Search history cleared.');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(90, 42),
                elevation: 0,
                backgroundColor: teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetSettings() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Reset Settings?',
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Language and notification preferences will return to default. '
            'Your account and login will not be removed.',
            style: TextStyle(color: subText, fontSize: 11, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(_pushKey);
                await prefs.remove(_orderKey);
                await prefs.remove(_offersKey);
                await prefs.remove(_languageKey);

                if (!mounted) return;

                setState(() {
                  pushNotifications = true;
                  orderUpdates = true;
                  offersUpdates = true;
                  selectedLanguage = 'English';
                });

                _showMessage('Settings reset to default.');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(90, 42),
                elevation: 0,
                backgroundColor: const Color(0xFFFFEEEE),
                foregroundColor: const Color(0xFFD64C4C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareFreegi() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out Freegi — a simple and convenient grocery shopping app. '
              'Fresh groceries, faster to you.',
          subject: 'Freegi Grocery App',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to open sharing options right now.');
    }
  }


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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                child: Column(
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Account'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.manage_accounts_rounded,
                          title: 'Account Settings',
                          subtitle: 'Profile, email, phone and security',
                          iconColor: teal,
                          iconBg: mint,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('General'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          subtitle: 'Choose your preferred app language',
                          iconColor: const Color(0xFF3B82F6),
                          iconBg: const Color(0xFFEAF2FF),
                          trailingText: selectedLanguage,
                          onTap: _showLanguageSheet,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(
                      children: [
                        _SettingsSwitchItem(
                          icon: Icons.notifications_rounded,
                          title: 'Push Notifications',
                          subtitle: 'Receive important Freegi notifications',
                          iconColor: orange,
                          iconBg: const Color(0xFFFFF4DE),
                          value: pushNotifications,
                          onChanged: (value) async {
                            setState(() {
                              pushNotifications = value;
                              if (!value) {
                                orderUpdates = false;
                                offersUpdates = false;
                              }
                            });

                            await _saveBool(_pushKey, value);

                            if (!value) {
                              await _saveBool(_orderKey, false);
                              await _saveBool(_offersKey, false);
                            }
                          },
                        ),
                        _divider(),
                        _SettingsSwitchItem(
                          icon: Icons.local_shipping_rounded,
                          title: 'Order Updates',
                          subtitle: 'Delivery, status and order alerts',
                          iconColor: teal,
                          iconBg: mint,
                          value: orderUpdates,
                          enabled: pushNotifications,
                          onChanged: (value) async {
                            setState(() {
                              orderUpdates = value;
                            });
                            await _saveBool(_orderKey, value);
                          },
                        ),
                        _divider(),
                        _SettingsSwitchItem(
                          icon: Icons.local_offer_rounded,
                          title: 'Offers & Deals',
                          subtitle: 'Coupons, promotions and discount alerts',
                          iconColor: const Color(0xFFE96A3E),
                          iconBg: const Color(0xFFFFEEE8),
                          value: offersUpdates,
                          enabled: pushNotifications,
                          onChanged: (value) async {
                            setState(() {
                              offersUpdates = value;
                            });
                            await _saveBool(_offersKey, value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('Privacy & Security'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.shield_outlined,
                          title: 'Privacy & Security',
                          subtitle: 'Learn how to protect your account',
                          iconColor: const Color(0xFF2B8A66),
                          iconBg: const Color(0xFFE7F7EF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacySecurityScreen(),
                              ),
                            );
                          },
                        ),
                        _divider(),
                        _SettingsItem(
                          icon: Icons.delete_sweep_rounded,
                          title: 'Clear Search History',
                          subtitle: 'Remove your recent product searches',
                          iconColor: const Color(0xFFD64C4C),
                          iconBg: const Color(0xFFFFEEEE),
                          onTap: _clearSearchHistory,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle('App'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.share_rounded,
                          title: 'Share Freegi',
                          subtitle: 'Invite friends and family',
                          iconColor: const Color(0xFF7A5AF8),
                          iconBg: const Color(0xFFF0ECFF),
                          onTap: _shareFreegi,
                        ),
                        _divider(),
                        _SettingsItem(
                          icon: Icons.info_outline_rounded,
                          title: 'About Freegi',
                          subtitle: 'App information and version',
                          iconColor: const Color(0xFF667085),
                          iconBg: const Color(0xFFF1F3F5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutFreegiScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSettingsCard(
                      children: [
                        _SettingsItem(
                          icon: Icons.restart_alt_rounded,
                          title: 'Reset Settings',
                          subtitle:
                              'Restore notification and language defaults',
                          iconColor: const Color(0xFFD64C4C),
                          iconBg: const Color(0xFFFFEEEE),
                          onTap: _resetSettings,
                        ),
                      ],
                    ),

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
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
                color: surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: text,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          const Column(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage your Freegi preferences',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 184,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal, teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -38,
              top: -48,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -45,
              bottom: -75,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(right: 15, top: 28, child: _settingsArtwork()),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 21, 148, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FREEGI SETTINGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        letterSpacing: .65,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Settings made\nsimple.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.07,
                      letterSpacing: -.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Control your Freegi experience in one place.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .76),
                      fontSize: 9,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsArtwork() {
    return SizedBox(
      width: 125,
      height: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 103,
            height: 103,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: -.14,
            child: Container(
              width: 79,
              height: 79,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.settings_rounded, color: teal, size: 48),
            ),
          ),
          Positioned(
            right: 3,
            top: 10,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD66B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF8A6500),
                size: 18,
              ),
            ),
          ),
          const Positioned(
            left: 3,
            bottom: 14,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFB7F0DA),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .018),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 55),
      child: Divider(height: 1, color: divider),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
  final String? trailingText;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF172321);
    const subTextColor = Color(0xFF71807D);
    const arrowColor = Color(0xFFAAB5B2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
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
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: subTextColor,
                      fontSize: 9.3,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(
                  color: Color(0xFF00AFA8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
            ],
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: arrowColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF172321);
    const subTextColor = Color(0xFF71807D);

    return Opacity(
      opacity: enabled ? 1 : 0.52,
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
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: subTextColor,
                      fontSize: 9.3,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.82,
              child: Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF00AFA8),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFDCE4E2),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
