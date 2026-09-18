import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color background = Color(0xFFF8FCFA);
  static const Color subText = Color(0xFF667875);

  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<OnboardingData> pages = const [
    OnboardingData(
      image: 'assets/images/onboarding_fresh_groceries.png',
      title: 'Fresh Groceries',
      subtitle:
          'Fresh groceries and daily essentials,\ndelivered right to your doorstep.',
      accent: Color(0xFF00AFA8),
    ),
    OnboardingData(
      image: 'assets/images/onboarding_fast_delivery.png',
      title: 'Fast & Reliable Delivery',
      subtitle:
          'Get your essentials delivered quickly,\nsafely, and on time.',
      accent: Color(0xFF00AFA8),
    ),
    OnboardingData(
      image: 'assets/images/onboarding_best_deals.png',
      title: 'Best Deals Everyday',
      subtitle:
          'Save more with exclusive offers,\ndiscounts, and special deals.',
      accent: Color(0xFFFFA928),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToWelcome() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'isOnboardingCompleted',
      true,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }

  void _nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToWelcome();
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const Color(0xFF0B1110)
        : background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDark),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(
                    pages[index],
                    isDark,
                  );
                },
              ),
            ),

            _buildBottomSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    final textColor =
        isDark ? Colors.white : darkGreen;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        6,
      ),
      child: Row(
        children: [
          if (currentPage > 0)
            InkWell(
              onTap: _previousPage,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF151C1B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF293432)
                        : const Color(0xFFE2ECEA),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 17,
                  color: textColor,
                ),
              ),
            )
          else
            const SizedBox(width: 40),

          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/icon/freegi_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Freegi',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToWelcome,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: teal,
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    OnboardingData page,
    bool isDark,
  ) {
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF15201E);

    final descriptionColor = isDark
        ? const Color(0xFF9EAEAA)
        : subText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            compact ? 6 : 14,
            22,
            4,
          ),
          child: Column(
            children: [
              const Spacer(),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: compact ? 250 : 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            page.accent.withValues(alpha: 0.12),
                            const Color(0xFF131B19),
                          ]
                        : [
                            page.accent.withValues(alpha: 0.08),
                            const Color(0xFFF7FFFD),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF263532)
                        : const Color(0xFFDDF1EC),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.18 : 0.05,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 18,
                        left: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                color: page.accent,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Freegi Fresh',
                                style: TextStyle(
                                  color: page.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          16,
                          12,
                          6,
                        ),
                        child: Image.asset(
                          page.image,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 52,
                                color: page.accent,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: compact ? 22 : 30),

              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: compact ? 25 : 29,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: descriptionColor,
                  fontSize: compact ? 13 : 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(bool isDark) {
    final lastPage =
        currentPage == pages.length - 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        8,
        22,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) {
                final active =
                    currentPage == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  width: active ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? teal
                        : isDark
                            ? const Color(0xFF344440)
                            : const Color(0xFFCFE7E2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: teal,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Row(
                  key: ValueKey(lastPage),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lastPage
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      lastPage
                          ? Icons.check_circle_outline_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${currentPage + 1} of ${pages.length}',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF6F817D)
                  : const Color(0xFF9AA8A5),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final Color accent;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}
