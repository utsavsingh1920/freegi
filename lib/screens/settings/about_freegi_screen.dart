import 'package:flutter/material.dart';

class AboutFreegiScreen extends StatelessWidget {
  const AboutFreegiScreen({super.key});

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
                    _brandCard(),
                    const SizedBox(height: 20),
                    _sectionTitle('App Information'),
                    const SizedBox(height: 10),
                    _card(
                      children: [
                        _infoRow(
                          icon: Icons.apps_rounded,
                          title: 'App Name',
                          value: 'Freegi',
                        ),
                        _line(),
                        _infoRow(
                          icon: Icons.shopping_basket_rounded,
                          title: 'Category',
                          value: 'Grocery Shopping',
                        ),
                        _line(),
                        _infoRow(
                          icon: Icons.info_outline_rounded,
                          title: 'Version',
                          value: '1.0.0',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Information'),
                    const SizedBox(height: 10),
                    _card(
                      children: [
                        _actionRow(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Learn how Freegi handles your information',
                          onTap: () => _showInfo(
                            context,
                            'Privacy Policy',
                            'This Freegi project currently uses local app storage for selected preferences and account information. A final published privacy policy should be added before a public production release.',
                          ),
                        ),
                        _line(),
                        _actionRow(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          subtitle: 'Read the terms for using Freegi',
                          onTap: () => _showInfo(
                            context,
                            'Terms & Conditions',
                            'These terms are currently provided as project information. Final legal terms should be reviewed and published before a public production release.',
                          ),
                        ),
                        _line(),
                        _actionRow(
                          context,
                          icon: Icons.code_rounded,
                          title: 'Developer Information',
                          subtitle: 'About the Freegi project',
                          onTap: () => _showInfo(
                            context,
                            'Developer Information',
                            'Freegi is a grocery shopping application project designed to provide a simple, clean and convenient shopping experience.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Freegi • Version 1.0.0',
                      style: TextStyle(
                        color: Color(0xFF9AA5A3),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
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
                'About Freegi',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'App information & details',
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

  Widget _brandCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal, teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: .17),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .14),
                  blurRadius: 15,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Image.asset(
                'assets/icon/freegi_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    color: teal,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'FREEGI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Fresh groceries, faster to you.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .80),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VERSION 1.0.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                letterSpacing: .5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
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

  Widget _card({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: border),
        ),
        child: Column(children: children),
      );

  Widget _line() => const Padding(
        padding: EdgeInsets.only(left: 55),
        child: Divider(height: 1, color: divider),
      );

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
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
            child: Text(
              title,
              style: const TextStyle(
                color: text,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: darkTeal,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(
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
      builder: (sheetContext) => Container(
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
            const Icon(Icons.info_outline_rounded, color: teal, size: 35),
            const SizedBox(height: 10),
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
                fontSize: 10.5,
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
      ),
    );
  }
}
