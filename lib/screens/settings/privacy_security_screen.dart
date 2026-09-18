import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color background = Color(0xFFF7FCFA);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color border = Color(0xFFE1EBE9);
  static const Color divider = Color(0xFFEDF2F1);
  static const Color mint = Color(0xFFE8F8F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                child: Column(
                  children: [
                    _hero(),
                    const SizedBox(height: 20),
                    _sectionTitle('Security'),
                    const SizedBox(height: 10),
                    _card(
                      children: [
                        _item(
                          context,
                          icon: Icons.shield_rounded,
                          title: 'Account Security',
                          subtitle: 'Password and account protection',
                          onTap: () => _showInfo(
                            context,
                            'Account Security',
                            'Keep your Freegi account secure by using a strong password and keeping your account information private.',
                          ),
                        ),
                        _line(),
                        _item(
                          context,
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'App Permissions',
                          subtitle: 'Review permissions used by Freegi',
                          onTap: () => _showInfo(
                            context,
                            'App Permissions',
                            'Freegi may request device permissions only when a feature needs them. You can review or change permissions from your device settings.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Legal & Privacy'),
                    const SizedBox(height: 10),
                    _card(
                      children: [
                        _item(
                          context,
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'How Freegi handles your information',
                          onTap: () => _showInfo(
                            context,
                            'Privacy Policy',
                            'This project stores basic app preferences and locally saved account information used by Freegi features. A production release should provide the final published privacy policy here.',
                          ),
                        ),
                        _line(),
                        _item(
                          context,
                          icon: Icons.description_rounded,
                          title: 'Terms & Conditions',
                          subtitle: 'Rules for using the Freegi app',
                          onTap: () => _showInfo(
                            context,
                            'Terms & Conditions',
                            'These terms are currently a placeholder for the Freegi project. Final legal terms should be added before a public production release.',
                          ),
                        ),
                        _line(),
                        _item(
                          context,
                          icon: Icons.storage_rounded,
                          title: 'Data & Privacy',
                          subtitle: 'Understand locally stored app data',
                          onTap: () => _showInfo(
                            context,
                            'Data & Privacy',
                            'Freegi uses locally stored data for app preferences and selected account features. You can clear relevant app data through available controls or your device settings.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Freegi • Privacy & Security',
                      style: TextStyle(
                        color: Color(0xFF9AA5A3),
                        fontSize: 9.5,
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

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
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
                'Privacy & Security',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage privacy and account safety',
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

  Widget _hero() {
    return Container(
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
            color: darkTeal.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FREEGI PRIVACY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your privacy matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Review security, permissions and privacy information.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }

  Widget _line() {
    return const Padding(
      padding: EdgeInsets.only(left: 55),
      child: Divider(height: 1, color: divider),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
                color: mint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: darkTeal, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(width: 8),
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

  void _showInfo(BuildContext context, String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
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
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: darkTeal,
                  size: 27,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: subText,
                  fontSize: 11,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
