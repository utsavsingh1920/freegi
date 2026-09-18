import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding/onboarding_screen.dart';
import 'auth/welcome_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF075C50);


  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // First Home viewport images only.
  // These start loading while the 1.5-second splash is visible.
  static const List<String> _homePreloadUrls = [
    // First hero banner
    'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1600&q=92',

    // First 4 categories
    'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=600&q=90',
    'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=90',
    'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=90',
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=90',

    // First 4 Today's Best Deals
    'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=700&q=90',
    'https://images.unsplash.com/photo-1561136594-7f68413baa99?auto=format&fit=crop&w=700&q=90',
    'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=700&q=90',
    'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=700&q=90',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Start session reading immediately.
    _checkAppStatus();

    // Start network image preloading as soon as the first frame is ready.
    // Navigation does NOT wait for this, so slow internet cannot trap
    // the user on the splash screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheHomeNetworkImages();
    });
  }

  Future<void> _precacheHomeNetworkImages() async {
    if (!mounted) return;

    // Load the important first-screen images in parallel.
    // We intentionally do not await this method from navigation logic.
    await Future.wait(
      _homePreloadUrls.map((url) async {
        if (!mounted) return;

        try {
          await precacheImage(
            NetworkImage(url),
            context,
          );
        } catch (_) {
          // Ignore individual network/cache failures. HomeScreen already
          // has loading/error UI, so startup should never be blocked.
        }
      }),
    );
  }

  Future<void> _checkAppStatus() async {
    // Start BOTH tasks immediately so SharedPreferences is read during
    // the splash instead of after the 1.5-second delay.
    final prefsFuture = SharedPreferences.getInstance();
    final splashDelay = Future<void>.delayed(
      const Duration(milliseconds: 1500),
    );

    final prefs = await prefsFuture;
    await splashDelay;

    final bool isLoggedIn =
        prefs.getBool('isLoggedIn') ?? false;

    final bool isOnboardingCompleted =
        prefs.getBool('isOnboardingCompleted') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) =>
              const MainNavigationScreen(initialIndex: 0),
          transitionDuration: const Duration(milliseconds: 180),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
      return;
    }

    if (!isOnboardingCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFFF8FFFC),
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FFFC),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final compact = height < 720;

            final logoSize = compact ? 108.0 : 132.0;
            final titleSize = compact ? 44.0 : 54.0;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Soft white-to-mint background.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF8FFFC),
                        Color(0xFFEAF9F3),
                      ],
                      stops: [0.0, 0.52, 1.0],
                    ),
                  ),
                ),

                // Three layered mint waves matching the final reference.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * 0.075,
                  height: height * 0.255,
                  child: ClipPath(
                    clipper: const _LayeredWaveClipper(
                      startY: 0.22,
                      middleY: 0.58,
                      endY: 0.16,
                    ),
                    child: const ColoredBox(
                      color: Color(0xFFE4F8F1),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * 0.055,
                  height: height * 0.225,
                  child: ClipPath(
                    clipper: const _LayeredWaveClipper(
                      startY: 0.30,
                      middleY: 0.72,
                      endY: 0.26,
                    ),
                    child: const ColoredBox(
                      color: Color(0xFFC8F0E4),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * 0.035,
                  height: height * 0.195,
                  child: ClipPath(
                    clipper: const _LayeredWaveClipper(
                      startY: 0.42,
                      middleY: 0.82,
                      endY: 0.36,
                    ),
                    child: const ColoredBox(
                      color: Color(0xFFAEE8D7),
                    ),
                  ),
                ),

                // Decorative leaves at top-left.
                Positioned(
                  left: compact ? -38 : -46,
                  top: compact ? -8 : -4,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.95,
                      child: Transform.rotate(
                        angle: -0.20,
                        child: Image.asset(
                          'assets/images/splash_leaves.png',
                          width: compact ? 180 : 215,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-right message like reference design.
                Positioned(
                  right: compact ? 18 : 24,
                  top: compact ? 64 : 82,
                  child: Transform.rotate(
                    angle: -0.035,
                    child: Column(
                      children: [
                        Text(
                          'Good Food\nBrighter Days',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF5F8E87),
                            fontSize: compact ? 15 : 18,
                            height: 1.12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          width: compact ? 58 : 72,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8ACB26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Small floating decorative leaves.
                Positioned(
                  left: width * 0.06,
                  top: height * 0.22,
                  child: const _FloatingLeaf(
                    size: 23,
                    angle: -0.7,
                    opacity: 0.28,
                  ),
                ),
                Positioned(
                  right: width * 0.08,
                  top: height * 0.35,
                  child: const _FloatingLeaf(
                    size: 27,
                    angle: 0.65,
                    opacity: 0.58,
                  ),
                ),
                Positioned(
                  left: width * 0.07,
                  top: height * 0.43,
                  child: const _FloatingLeaf(
                    size: 25,
                    angle: -0.55,
                    opacity: 0.48,
                  ),
                ),

                // Main logo/title/benefits.
                SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            height: compact
                                ? height * 0.160
                                : height * 0.185,
                          ),

                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                compact ? 25 : 29,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: teal.withValues(alpha: 0.17),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                compact ? 25 : 29,
                              ),
                              child: Image.asset(
                                'assets/icon/freegi_icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(height: compact ? 14 : 18),

                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                'Freegi',
                                style: TextStyle(
                                  color: darkTeal,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                  height: 1,
                                ),
                              ),
                              Positioned(
                                right: compact ? -5 : -7,
                                top: compact ? -5 : -8,
                                child: Transform.rotate(
                                  angle: 0.65,
                                  child: Icon(
                                    Icons.eco_rounded,
                                    color: const Color(0xFF8ACB26),
                                    size: compact ? 21 : 24,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: compact ? 7 : 9),

                          Text(
                            'Fresh Groceries, Faster to You.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: darkTeal,
                              fontSize: compact ? 13.5 : 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.05,
                            ),
                          ),

                          SizedBox(height: compact ? 18 : 22),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 42 : 52,
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: _BenefitItem(
                                    icon: Icons.eco_rounded,
                                    label: 'Fresh\nProducts',
                                  ),
                                ),
                                _BenefitDivider(),
                                Expanded(
                                  child: _BenefitItem(
                                    icon: Icons.local_shipping_rounded,
                                    label: 'Fast\nDelivery',
                                  ),
                                ),
                                _BenefitDivider(),
                                Expanded(
                                  child: _BenefitItem(
                                    icon: Icons.verified_user_rounded,
                                    label: 'Trusted\nQuality',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Center freshness message above the mint waves.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: compact ? 125 : 150,
                  child: Transform.rotate(
                    angle: -0.035,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Fresh\nHealthier\nHappier You ♥',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkTeal.withValues(alpha: 0.95),
                            fontSize: compact ? 17 : 20,
                            height: 1.04,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          width: compact ? 82 : 98,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF74B91E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom-only seamless blend.
                // IMPORTANT: this is painted BEFORE all lower leaves,
                // so none of the decorative leaves are faded/covered.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: compact ? 58 : 72,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFAEE8D7),
                            const Color(0xFFCBEFE4),
                            const Color(0xFFEAF9F4),
                            const Color(0xFFF8FFFC),
                          ],
                          stops: const [0.0, 0.34, 0.70, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Lower natural leaf decorations like the reference.
                Positioned(
                  left: compact ? -38 : -48,
                  bottom: height * 0.105,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.72,
                      child: Transform.rotate(
                        angle: -0.45,
                        child: Image.asset(
                          'assets/images/splash_leaves.png',
                          width: compact ? 105 : 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: compact ? -48 : -58,
                  bottom: height * 0.085,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.58,
                      child: Transform.rotate(
                        angle: 2.55,
                        child: Image.asset(
                          'assets/images/splash_leaves.png',
                          width: compact ? 115 : 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.13,
                  bottom: height * 0.055,
                  child: const _FloatingLeaf(
                    size: 34,
                    angle: -0.55,
                    opacity: 0.72,
                  ),
                ),
                Positioned(
                  right: width * 0.12,
                  bottom: height * 0.19,
                  child: const _FloatingLeaf(
                    size: 29,
                    angle: 0.65,
                    opacity: 0.70,
                  ),
                ),

                // Bottom caption.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'GROCERIES  •  DAILY NEEDS  •  A BETTER TOMORROW',
                          style: TextStyle(
                            color: darkTeal.withValues(alpha: 0.78),
                            fontSize: 8.8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFE0F5EE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Color(0xFF08725F),
            size: 22,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF075C50),
            fontSize: 11.5,
            height: 1.02,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: const Color(0xFFCFE5DF),
    );
  }
}

class _FloatingLeaf extends StatelessWidget {
  final double size;
  final double angle;
  final double opacity;

  const _FloatingLeaf({
    required this.size,
    required this.angle,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            Icons.eco_rounded,
            size: size,
            color: const Color(0xFF72B92D),
          ),
        ),
      ),
    );
  }
}

class _LayeredWaveClipper extends CustomClipper<Path> {
  final double startY;
  final double middleY;
  final double endY;

  const _LayeredWaveClipper({
    required this.startY,
    required this.middleY,
    required this.endY,
  });

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height * startY)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.02,
        size.width * 0.46,
        size.height * middleY,
        size.width * 0.66,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.34,
        size.width * 0.92,
        size.height * 0.20,
        size.width,
        size.height * endY,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _LayeredWaveClipper oldClipper) {
    return oldClipper.startY != startY ||
        oldClipper.middleY != middleY ||
        oldClipper.endY != endY;
  }
}
    