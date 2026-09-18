import 'package:flutter/material.dart';

import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primaryColor = Color(0xFF00AFA8);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color backgroundColor = Color(0xFFF8FCFA);
  static const Color textColor = Color(0xFF172321);
  static const Color subTextColor = Color(0xFF6D7D79);
  static const Color borderColor = Color(0xFFD7EAE6);

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openSignup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double h = constraints.maxHeight;

            double scale = h / 875;

            if (scale > 1.0) {
              scale = 1.0;
            }

            if (scale < 0.82) {
              scale = 0.82;
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                // =================================================
                // BACKGROUND DECORATION
                // =================================================

                _buildBackgroundLeaves(scale),

                // =================================================
                // BOTTOM SOFT MINT BACKGROUND
                // =================================================

                Positioned(
                  left: -90,
                  right: -90,
                  bottom: -90 * scale,
                  child: IgnorePointer(
                    child: Container(
                      height: 160 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F4)
                            .withValues(alpha: 0.60),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.elliptical(290, 100),
                          topRight: Radius.elliptical(290, 100),
                        ),
                      ),
                    ),
                  ),
                ),

                // =================================================
                // MAIN PAGE
                // =================================================

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    26 * scale,
                    16,
                    8 * scale,
                  ),
                  child: Column(
                    children: [
                      // =============================================
                      // BRAND
                      // =============================================

                      _buildHeader(scale),

                      // Only this gap is reduced: logo stays fixed,
                       // all content below moves slightly upward.
                       SizedBox(height: 25 * scale),

                      // =============================================
                      // MAIN TITLE
                      // =============================================

                      _buildHeading(scale),

                      SizedBox(height: 16 * scale),

                      // =============================================
                      // HERO
                      // =============================================

                      _buildHeroSection(scale),

                      SizedBox(height: 14 * scale),

                      // =============================================
                      // BENEFITS
                      // =============================================

                      _buildBenefitsRow(scale),

                      SizedBox(height: 13 * scale),

                      // =============================================
                      // CREATE ACCOUNT
                      // =============================================

                      _buildCreateAccountButton(
                        context,
                        scale,
                      ),

                      SizedBox(height: 10 * scale),

                      // =============================================
                      // LOGIN
                      // =============================================

                      _buildLoginButton(
                        context,
                        scale,
                      ),

                      const Spacer(),

                      // =============================================
                      // FOOTER
                      // =============================================

                      _buildBottomSection(scale),

                      SizedBox(height: 3 * scale),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND LEAVES
  // ============================================================

  Widget _buildBackgroundLeaves(double scale) {
    return Stack(
      children: [
        // TOP LEFT
        Positioned(
          left: -45 * scale,
          top: 8 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.72,
              child: Transform.rotate(
                angle: -0.35,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 108 * scale,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),

        // TOP RIGHT
        Positioned(
          right: -45 * scale,
          top: 6 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.72,
              child: Transform.rotate(
                angle: 0.60,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 108 * scale,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),

        // LEFT MIDDLE
        Positioned(
          left: -27 * scale,
          top: 285 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: -0.45,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 64 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // RIGHT MIDDLE
        Positioned(
          right: -28 * scale,
          top: 360 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 0.48,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 62 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // BOTTOM LEFT
        Positioned(
          left: -55 * scale,
          bottom: -34 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.62,
              child: Transform.rotate(
                angle: 0.28,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 118 * scale,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),

        // BOTTOM RIGHT
        Positioned(
          right: -55 * scale,
          bottom: -34 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.62,
              child: Transform.rotate(
                angle: -0.48,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 118 * scale,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --------------------------------------------------------
        // LOGO
        // --------------------------------------------------------

        Image.asset(
          'assets/icon/freegi_icon.png',
          width: 88 * scale,
          height: 88 * scale,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),

        SizedBox(height: 6 * scale),

        // --------------------------------------------------------
        // FREEGI
        // --------------------------------------------------------

        Text(
          'Freegi',
          style: TextStyle(
            color: darkGreen,
            fontSize: 36 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
            height: 1,
          ),
        ),

        SizedBox(height: 7 * scale),

        // --------------------------------------------------------
        // SMALL TAGLINE
        // --------------------------------------------------------

        Text(
          'Good Food  •  Brighter Days',
          style: TextStyle(
            color: subTextColor,
            fontSize: 10.4 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.10,
            height: 1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN HEADING
  // ============================================================

  Widget _buildHeading(double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Fresh groceries,\n',
              ),
              TextSpan(
                text: 'right at your doorstep',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 29 * scale,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.75,
          ),
        ),

        SizedBox(height: 10 * scale),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
          ),
          child: Text(
            'Shop fresh fruits, vegetables and everyday\n'
            'essentials with fast and reliable delivery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subTextColor,
              fontSize: 11.0 * scale,
              height: 1.38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO SECTION
  // ============================================================

  Widget _buildHeroSection(double scale) {
    return SizedBox(
      width: double.infinity,
      height: 252 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // =====================================================
          // BACK MINT HALO
          // =====================================================

          Positioned(
            top: 21 * scale,
            child: Container(
              width: 286 * scale,
              height: 210 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F9F3),
                borderRadius: BorderRadius.circular(
                  145 * scale,
                ),
              ),
            ),
          ),

          // =====================================================
          // MAIN GROCERY BASKET
          // =====================================================

          Positioned(
            left: -40 * scale,
            right: -40 * scale,
            top: -2 * scale,
            bottom: -46 * scale,
            child: Image.asset(
              'assets/images/onboarding_fresh_groceries.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
          ),

          // =====================================================
          // LEFT FRESH QUALITY CARD
          // =====================================================

          Positioned(
            left: 1 * scale,
            top: 55 * scale,
            child: Container(
              width: 67 * scale,
              padding: EdgeInsets.symmetric(
                vertical: 8 * scale,
                horizontal: 4 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.97,
                ),
                borderRadius: BorderRadius.circular(
                  19 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(
                      alpha: 0.09,
                    ),
                    blurRadius: 14 * scale,
                    offset: Offset(
                      0,
                      4 * scale,
                    ),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 31 * scale,
                    height: 31 * scale,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F8E8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: const Color(0xFF32B65C),
                      size: 18 * scale,
                    ),
                  ),

                  SizedBox(height: 6 * scale),

                  Text(
                    'Fresh\nQuality',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 8.7 * scale,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // RIGHT HEALTHY CHOICES
          // =====================================================

          Positioned(
            right: 0,
            top: 50 * scale,
            child: Transform.rotate(
              angle: -0.04,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Healthy\nChoices\nHappier\nYou ♡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 9 * scale,
                      height: 1.03,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4 * scale),

                  Container(
                    width: 40 * scale,
                    height: 1.7 * scale,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // TOP DECORATIVE LEAF
          // =====================================================

          Positioned(
            left: 58 * scale,
            top: 3 * scale,
            child: Transform.rotate(
              angle: -0.55,
              child: Image.asset(
                'assets/images/splash_leaves.png',
                width: 43 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // =====================================================
          // LOWER LEFT LEAF
          // =====================================================

          Positioned(
            left: 49 * scale,
            bottom: 14 * scale,
            child: Transform.rotate(
              angle: -0.70,
              child: Image.asset(
                'assets/images/splash_leaves.png',
                width: 39 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // =====================================================
          // LOWER RIGHT LEAF
          // =====================================================

          Positioned(
            right: 48 * scale,
            bottom: 17 * scale,
            child: Transform.rotate(
              angle: 0.55,
              child: Image.asset(
                'assets/images/splash_leaves.png',
                width: 39 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // =====================================================
          // BETTER FOOD CIRCLE
          // =====================================================

          Positioned(
            right: 0,
            bottom: 5 * scale,
            child: Container(
              width: 59 * scale,
              height: 59 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF2FFF9)
                    .withValues(alpha: 0.96),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBDEFD4),
                  width: 1.5,
                ),
              ),
              child: Text(
                'Better\nFood\nBrighter\nDays',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 6.6 * scale,
                  height: 1.02,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BENEFITS ROW
  // ============================================================

  Widget _buildBenefitsRow(double scale) {
    return Container(
      width: double.infinity,
      height: 100 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 3 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.98,
        ),
        borderRadius: BorderRadius.circular(
          22 * scale,
        ),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 14 * scale,
            offset: Offset(
              0,
              5 * scale,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _benefitItem(
              icon: Icons.eco_rounded,
              title: 'Fresh\nQuality',
              color: const Color(0xFF36B95C),
              scale: scale,
            ),
          ),

          _benefitDivider(scale),

          Expanded(
            child: _benefitItem(
              icon: Icons.local_shipping_rounded,
              title: 'Fast\nDelivery',
              color: primaryColor,
              scale: scale,
            ),
          ),

          _benefitDivider(scale),

          Expanded(
            child: _benefitItem(
              icon: Icons.verified_user_rounded,
              title: 'Safe &\nHygienic',
              color: const Color(0xFF2CA77C),
              scale: scale,
            ),
          ),

          _benefitDivider(scale),

          Expanded(
            child: _benefitItem(
              icon: Icons.percent_rounded,
              title: 'Best\nDeals',
              color: primaryColor,
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BENEFIT ITEM
  // ============================================================

  Widget _benefitItem({
    required IconData icon,
    required String title,
    required Color color,
    required double scale,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 45 * scale,
          height: 45 * scale,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.10,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22 * scale,
          ),
        ),

        SizedBox(height: 6 * scale),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkGreen,
            fontSize: 9.0 * scale,
            height: 1.04,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BENEFIT DIVIDER
  // ============================================================

  Widget _benefitDivider(double scale) {
    return Container(
      width: 1,
      height: 50 * scale,
      color: const Color(0xFFDCEBE8),
    );
  }

  // ============================================================
  // CREATE ACCOUNT BUTTON
  // ============================================================

  Widget _buildCreateAccountButton(
    BuildContext context,
    double scale,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55 * scale,
      child: ElevatedButton(
        onPressed: () => _openSignup(context),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              17 * scale,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 15.5 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(width: 12 * scale),

            Icon(
              Icons.arrow_forward_rounded,
              size: 21 * scale,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton(
    BuildContext context,
    double scale,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55 * scale,
      child: OutlinedButton(
        onPressed: () => _openLogin(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGreen,
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: Color(0xFF9BDDD4),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              17 * scale,
            ),
          ),
        ),
        child: Text(
          'Log In',
          style: TextStyle(
            fontSize: 15.5 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SECTION
  // ============================================================

  Widget _buildBottomSection(double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Good Food  •  Brighter Days',
          style: TextStyle(
            color: darkGreen.withValues(
              alpha: 0.72,
            ),
            fontSize: 8.8 * scale,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 4 * scale),

        Container(
          width: 36 * scale,
          height: 1.3,
          decoration: BoxDecoration(
            color: primaryColor.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
        ),

        SizedBox(height: 5 * scale),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4 * scale,
          ),
          child: Text.rich(
            TextSpan(
              children: const [
                TextSpan(
                  text:
                      'By continuing, you agree to our ',
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                ),
                TextSpan(
                  text: 'Privacy Policy.',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8A9996),
              fontSize: 7.6 * scale,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}