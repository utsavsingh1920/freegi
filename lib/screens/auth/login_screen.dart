import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_navigation_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoggingIn = false;

  static const Color primaryColor = Color(0xFF00AFA8);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color backgroundColor = Color(0xFFF8FCFA);
  static const Color textColor = Color(0xFF172321);
  static const Color subTextColor = Color(0xFF6D7D79);
  static const Color borderColor = Color(0xFFE1ECEA);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  Future<void> _loadRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe =
        prefs.getBool('freegi_remember_me') ?? false;

    if (!mounted) return;

    setState(() {
      _rememberMe = rememberMe;

      if (rememberMe) {
        _emailController.text =
            prefs.getString('freegi_remembered_login') ?? '';
      }
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // --------------------------------------------------------
      // USER INPUT
      // --------------------------------------------------------

      final String enteredLogin =
          _emailController.text.trim();

      final String normalizedLogin =
          enteredLogin.toLowerCase();

      // --------------------------------------------------------
      // ACCOUNT CREATED FROM SIGNUP
      // --------------------------------------------------------

      final String savedEmail =
          (prefs.getString('freegi_profile_email') ?? '')
              .trim()
              .toLowerCase();

      final String savedPhone =
          (prefs.getString('freegi_profile_phone') ?? '')
              .trim();

      final String savedName =
          (prefs.getString('freegi_profile_name') ?? '')
              .trim();

      // --------------------------------------------------------
      // CHECK IF ACCOUNT EXISTS
      // --------------------------------------------------------

      final bool hasSavedAccount =
          savedEmail.isNotEmpty ||
          savedPhone.isNotEmpty ||
          savedName.isNotEmpty;

      if (!hasSavedAccount) {
        if (!mounted) return;

        setState(() {
          _isLoggingIn = false;
        });

        _showMessage(
          'No Freegi account found. Please create an account first.',
        );

        return;
      }

      // --------------------------------------------------------
      // EMAIL / MOBILE MATCH
      // --------------------------------------------------------

      final bool emailMatches =
          savedEmail.isNotEmpty &&
          normalizedLogin == savedEmail;

      final bool phoneMatches =
          savedPhone.isNotEmpty &&
          enteredLogin == savedPhone;

      if (!emailMatches && !phoneMatches) {
        if (!mounted) return;

        setState(() {
          _isLoggingIn = false;
        });

        _showMessage(
          'No account found with this email or mobile number.',
        );

        return;
      }

      // --------------------------------------------------------
      // LOCAL DEMO PASSWORD AUTHENTICATION
      // --------------------------------------------------------
      final String savedPassword =
          prefs.getString('freegi_local_password') ?? '';

      if (savedPassword.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoggingIn = false;
        });

        _showMessage(
          'Password is not set for this account. Please create the account again.',
        );
        return;
      }

      if (_passwordController.text != savedPassword) {
        if (!mounted) return;

        setState(() {
          _isLoggingIn = false;
        });

        _showMessage('Incorrect password. Please try again.');
        return;
      }

      // --------------------------------------------------------
      // SAVE LOGIN SESSION
      // --------------------------------------------------------

      await prefs.setBool(
        'isLoggedIn',
        true,
      );

      // Onboarding should never repeat after account setup.
      await prefs.setBool(
        'isOnboardingCompleted',
        true,
      );

      // --------------------------------------------------------
      // REMEMBER ME
      // --------------------------------------------------------

      await prefs.setBool(
        'freegi_remember_me',
        _rememberMe,
      );

      if (_rememberMe) {
        await prefs.setString(
          'freegi_remembered_login',
          enteredLogin,
        );
      } else {
        await prefs.remove(
          'freegi_remembered_login',
        );
      }

      if (!mounted) return;

      // --------------------------------------------------------
      // LOGIN SUCCESS → DIRECT HOME
      // --------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(
            initialIndex: 0,
          ),
        ),
        (route) => false,
      );
    } catch (error) {
      debugPrint('LOGIN ERROR: $error');

      if (!mounted) return;

      setState(() {
        _isLoggingIn = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // SIGNUP
  // ============================================================

  void _openSignup() {
    FocusScope.of(context).unfocus();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void _forgotPassword() {
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  void _googleLogin() {
    FocusScope.of(context).unfocus();

    _showMessage(
      'Google Login will be connected later.',
    );
  }

  // ============================================================
  // APPLE LOGIN
  // ============================================================

  void _appleLogin() {
    FocusScope.of(context).unfocus();

    _showMessage(
      'Apple Login will be connected later.',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // Keyboard screen ko resize nahi karega.
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double scale = constraints.maxHeight / 780;

            if (scale > 1.0) {
              scale = 1.0;
            }

            if (scale < 0.78) {
              scale = 0.78;
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ===============================================
                  // BACKGROUND LEAVES
                  // ===============================================

                  _buildBackgroundLeaves(scale),

                  // ===============================================
                  // BOTTOM MINT WAVE
                  // ===============================================

                  Positioned(
                    left: -90,
                    right: -90,
                    bottom: -88 * scale,
                    child: IgnorePointer(
                      child: Container(
                        height: 180 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8F4)
                              .withValues(alpha: 0.65),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.elliptical(
                              280,
                              105,
                            ),
                            topRight: Radius.elliptical(
                              280,
                              105,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===============================================
                  // FIXED LOGIN CONTENT
                  // ===============================================

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      8 * scale,
                      22,
                      12 * scale,
                    ),
                    child: _buildContent(
                      context,
                      scale,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildContent(
    BuildContext context,
    double scale,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // TOP BRAND
          // =====================================================

          _buildTopBrand(
            context,
            scale,
          ),

          // =====================================================
          // SPACE AFTER BRAND
          // =====================================================

          const Spacer(flex: 1),

          // =====================================================
          // WELCOME BACK
          // =====================================================

          Text(
            'Welcome Back',
            style: TextStyle(
              color: textColor,
              fontSize: 29 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.02,
            ),
          ),

          SizedBox(height: 10 * scale),

          Text(
            'Log in to your Freegi account and continue\n'
            'shopping fresh groceries.',
            style: TextStyle(
              color: subTextColor,
              fontSize: 12.5 * scale,
              height: 1.42,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(flex: 2),

          // =====================================================
          // EMAIL / MOBILE
          // =====================================================

          _buildLabel(
            'Email or Mobile Number',
            scale,
          ),

          SizedBox(height: 7 * scale),

          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            enabled: true,
            onFieldSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            style: TextStyle(
              color: textColor,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
            ),
            decoration: _inputDecoration(
              hintText: 'Enter email or mobile number',
              icon: Icons.person_outline_rounded,
              scale: scale,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email or mobile number';
              }

              final input = value.trim();

              // If input contains @, treat as email.
              if (input.contains('@')) {
                final emailRegex = RegExp(
                  r'^[\w\.-]+@[\w\.-]+\.\w+$',
                );

                if (!emailRegex.hasMatch(input)) {
                  return 'Please enter a valid email address';
                }
              } else {
                final phoneRegex = RegExp(
                  r'^[0-9]{10}$',
                );

                if (!phoneRegex.hasMatch(input)) {
                  return 'Enter a valid 10-digit mobile number';
                }
              }

              return null;
            },
          ),

          SizedBox(height: 13 * scale),

          // =====================================================
          // PASSWORD
          // =====================================================

          _buildLabel(
            'Password',
            scale,
          ),

          SizedBox(height: 7 * scale),

          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: true,
            onFieldSubmitted: (_) {
              _login();
            },
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            style: TextStyle(
              color: textColor,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
            ),
            decoration: _inputDecoration(
              hintText: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              scale: scale,
            ).copyWith(
              suffixIcon: IconButton(
                splashRadius: 18,
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20 * scale,
                  color: const Color(0xFF788985),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }

              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }

              return null;
            },
          ),

          SizedBox(height: 9 * scale),

          // =====================================================
          // REMEMBER + FORGOT
          // =====================================================

          _buildRememberForgot(scale),

          const Spacer(flex: 1),

          // =====================================================
          // LOGIN BUTTON
          // =====================================================

          SizedBox(
            width: double.infinity,
            height: 52 * scale,
            child: ElevatedButton(
              onPressed:
                  _isLoggingIn ? null : _login,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: primaryColor,
                disabledBackgroundColor:
                    primaryColor.withValues(
                  alpha: 0.65,
                ),
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16 * scale,
                  ),
                ),
              ),
              child: _isLoggingIn
                  ? SizedBox(
                      width: 21 * scale,
                      height: 21 * scale,
                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 14.5 * scale,
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
          ),

          const Spacer(flex: 1),

          // =====================================================
          // DIVIDER
          // =====================================================

          _buildDivider(scale),

          SizedBox(height: 12 * scale),

          // =====================================================
          // SOCIAL BUTTONS
          // =====================================================

          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  onTap: _googleLogin,
                  type: _SocialType.google,
                  text: 'Google',
                  scale: scale,
                ),
              ),

              SizedBox(width: 11 * scale),

              Expanded(
                child: _buildSocialButton(
                  onTap: _appleLogin,
                  type: _SocialType.apple,
                  text: 'Apple',
                  scale: scale,
                ),
              ),
            ],
          ),

          const Spacer(flex: 2),

          // =====================================================
          // CREATE ACCOUNT
          // =====================================================

          _buildSignupRow(scale),

          const Spacer(flex: 1),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BRAND
  // ============================================================

  Widget _buildTopBrand(
    BuildContext context,
    double scale,
  ) {
    return SizedBox(
      height: 125 * scale,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 5 * scale,
            child: _backButton(
              context,
              scale,
            ),
          ),

          Positioned(
            top: 18 * scale,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/freegi_icon.png',
                  width: 64 * scale,
                  height: 64 * scale,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),

                SizedBox(height: 4 * scale),

                Text(
                  'Freegi',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1,
                  ),
                ),

                SizedBox(height: 4 * scale),

                Text(
                  'Good Food  •  Brighter Days',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 8.5 * scale,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _backButton(
    BuildContext context,
    double scale,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          Navigator.maybePop(context);
        },
        borderRadius: BorderRadius.circular(
          14 * scale,
        ),
        child: Container(
          width: 43 * scale,
          height: 43 * scale,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              14 * scale,
            ),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 9 * scale,
                offset: Offset(
                  0,
                  3 * scale,
                ),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 17 * scale,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND LEAVES
  // ============================================================

  Widget _buildBackgroundLeaves(
    double scale,
  ) {
    return Stack(
      children: [
        Positioned(
          right: -43 * scale,
          top: 3 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.28,
              child: Transform.rotate(
                angle: 0.35,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 115 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: -43 * scale,
          top: 125 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.17,
              child: Transform.rotate(
                angle: -0.70,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 75 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: -38 * scale,
          top: 215 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Transform.rotate(
                angle: 0.48,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 70 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: -47 * scale,
          bottom: -25 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.28,
              child: Transform.rotate(
                angle: -0.45,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 135 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: -46 * scale,
          bottom: -24 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.27,
              child: Transform.rotate(
                angle: 0.70,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 132 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
    String text,
    double scale,
  ) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 12 * scale,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    required double scale,
  }) {
    return InputDecoration(
      hintText: hintText,

      prefixIcon: Icon(
        icon,
        color: primaryColor,
        size: 20 * scale,
      ),

      prefixIconConstraints: BoxConstraints(
        minWidth: 48 * scale,
        minHeight: 48 * scale,
      ),

      filled: true,
      fillColor: Colors.white,

      hintStyle: TextStyle(
        color: const Color(0xFF9AA7A5),
        fontSize: 12 * scale,
        fontWeight: FontWeight.w500,
      ),

      isDense: true,

      contentPadding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 15 * scale,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          15 * scale,
        ),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          15 * scale,
        ),
        borderSide: const BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          15 * scale,
        ),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.4,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          15 * scale,
        ),
        borderSide: const BorderSide(
          color: Color(0xFFE85D5D),
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          15 * scale,
        ),
        borderSide: const BorderSide(
          color: Color(0xFFE85D5D),
          width: 1.4,
        ),
      ),

      errorStyle: TextStyle(
        fontSize: 8.5 * scale,
        height: 0.9,
      ),
    );
  }

  // ============================================================
  // REMEMBER + FORGOT
  // ============================================================

  Widget _buildRememberForgot(
    double scale,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 27 * scale,
          height: 27 * scale,
          child: Transform.scale(
            scale: 0.84 * scale,
            child: Checkbox(
              value: _rememberMe,
              activeColor: primaryColor,
              checkColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFFB8D3CF),
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
          ),
        ),

        SizedBox(width: 5 * scale),

        Text(
          'Remember me',
          style: TextStyle(
            color: subTextColor,
            fontSize: 10.5 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: _forgotPassword,
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: 2 * scale,
              vertical: 2 * scale,
            ),
            minimumSize: Size.zero,
            tapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider(double scale) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: borderColor,
            thickness: 1,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
          ),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Expanded(
          child: Divider(
            color: borderColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SOCIAL BUTTON
  // ============================================================

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required _SocialType type,
    required String text,
    required double scale,
  }) {
    return SizedBox(
      height: 47 * scale,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 8 * scale,
          ),
          side: const BorderSide(
            color: borderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14 * scale,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            if (type == _SocialType.google)
              _googleLogo(scale)
            else
              Icon(
                Icons.apple_rounded,
                color: Colors.black,
                size: 24 * scale,
              ),

            SizedBox(width: 8 * scale),

            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GOOGLE LOGO
  // ============================================================

  Widget _googleLogo(double scale) {
    return Image.asset(
      'assets/icon/google_logo.png',
      width: 22 * scale,
      height: 22 * scale,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons.g_mobiledata_rounded,
          color: const Color(0xFF4285F4),
          size: 27 * scale,
        );
      },
    );
  }

  // ============================================================
  // SIGNUP ROW
  // ============================================================

  Widget _buildSignupRow(
    double scale,
  ) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment:
            WrapCrossAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: subTextColor,
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),

          TextButton(
            onPressed: _openSignup,
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: EdgeInsets.only(
                left: 4 * scale,
              ),
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Create Account',
              style: TextStyle(
                fontSize: 10.5 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SocialType {
  google,
  apple,
}