import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../location/location_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // ============================================================
  // STATE
  // ============================================================

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showValidation = false;
  bool _isCreatingAccount = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFF00AFA8);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color backgroundColor = Color(0xFFF8FCFA);
  static const Color textColor = Color(0xFF172321);
  static const Color subTextColor = Color(0xFF6D7D79);
  static const Color borderColor = Color(0xFFE1ECEA);
  static const Color errorColor = Color(0xFFE05A5A);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _nameError() {
    final value = _nameController.text.trim();

    if (value.isEmpty) {
      return 'Please enter your full name';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  String? _emailError() {
    final value = _emailController.text.trim();

    if (value.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _phoneError() {
    final value = _phoneController.text.trim();

    if (value.isEmpty) {
      return 'Please enter your mobile number';
    }

    final phoneRegex = RegExp(
      r'^[0-9]{10}$',
    );

    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  String? _passwordError() {
    final value = _passwordController.text;

    if (value.isEmpty) {
      return 'Please create a password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _confirmPasswordError() {
    final value = _confirmPasswordController.text;

    if (value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  bool _isFormValid() {
    return _nameError() == null &&
        _emailError() == null &&
        _phoneError() == null &&
        _passwordError() == null &&
        _confirmPasswordError() == null;
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    if (_isCreatingAccount) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _showValidation = true;
    });

    if (!_isFormValid()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Please accept the Terms & Conditions',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: darkGreen,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      return;
    }

    setState(() {
      _isCreatingAccount = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // ========================================================
      // SAVE PROFILE DETAILS
      // ========================================================

      await prefs.setString(
        'freegi_profile_name',
        _nameController.text.trim(),
      );

      await prefs.setString(
        'freegi_profile_email',
        _emailController.text.trim().toLowerCase(),
      );

      await prefs.setString(
        'freegi_profile_phone',
        _phoneController.text.trim(),
      );

      // ========================================================
      // LOCAL DEMO AUTHENTICATION
      // ========================================================
      // Freegi currently uses a local prototype authentication flow.
      // This keeps Signup, Login, Forgot/Change Password consistent
      // for the portfolio/demo build. Production apps should use
      // Firebase / Supabase / a secure backend instead.
      await prefs.setString(
        'freegi_local_password',
        _passwordController.text,
      );

      // Account/session metadata used by the rest of the app.
      await prefs.setBool('freegi_account_created', true);
      await prefs.setBool('isOnboardingCompleted', false);
      await prefs.setBool('isLoggedIn', false);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LocationScreen(),
        ),
      );
    } catch (error) {
      debugPrint('SIGNUP SAVE ERROR: $error');

      if (!mounted) return;

      setState(() {
        _isCreatingAccount = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Could not create your account. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: darkGreen,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void _openLogin() {
    FocusScope.of(context).unfocus();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // ============================================================
  // SOCIAL SIGNUP
  // ============================================================

  void _socialSignup(String provider) {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$provider sign up will be connected next.',
          ),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // Keyboard overlays the page instead of resizing it.
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double scale = constraints.maxHeight / 780;

            if (scale > 1.0) {
              scale = 1.0;
            }

            if (scale < 0.76) {
              scale = 0.76;
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // =================================================
                  // BACKGROUND LEAVES
                  // =================================================

                  _buildBackgroundLeaves(scale),

                  // =================================================
                  // BOTTOM MINT BACKGROUND
                  // =================================================

                  Positioned(
                    left: -80,
                    right: -80,
                    bottom: -92 * scale,
                    child: IgnorePointer(
                      child: Container(
                        height: 150 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8F4).withValues(
                            alpha: 0.62,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.elliptical(
                              260,
                              90,
                            ),
                            topRight: Radius.elliptical(
                              260,
                              90,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // FIXED CONTENT
                  // =================================================

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      6 * scale,
                      22,
                      8 * scale,
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
  // CONTENT
  // ============================================================

  Widget _buildContent(
    BuildContext context,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // TOP BRAND
        // ======================================================

        _buildTopBar(
          context,
          scale,
        ),

        SizedBox(height: 5 * scale),

        // ======================================================
        // TITLE
        // ======================================================

        Text(
          'Create Account',
          style: TextStyle(
            color: textColor,
            fontSize: 27 * scale,
            fontWeight: FontWeight.w900,
            height: 1.02,
            letterSpacing: -0.75,
          ),
        ),

        SizedBox(height: 5 * scale),

        Text(
          'Join Freegi and start shopping fresh groceries.\n'
          "It's quick, easy and free!",
          style: TextStyle(
            color: subTextColor,
            fontSize: 10.8 * scale,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 9 * scale),

        // ======================================================
        // FULL NAME
        // ======================================================

        _buildFieldBlock(
          label: 'Full Name',
          controller: _nameController,
          focusNode: _nameFocus,
          scale: scale,
          hintText: 'Enter your full name',
          icon: Icons.person_outline_rounded,
          errorText: _nameError(),
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) {
            _emailFocus.requestFocus();
          },
        ),

        SizedBox(height: 3 * scale),

        // ======================================================
        // EMAIL
        // ======================================================

        _buildFieldBlock(
          label: 'Email Address',
          controller: _emailController,
          focusNode: _emailFocus,
          scale: scale,
          hintText: 'Enter your email address',
          icon: Icons.mail_outline_rounded,
          errorText: _emailError(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          onFieldSubmitted: (_) {
            _phoneFocus.requestFocus();
          },
        ),

        SizedBox(height: 3 * scale),

        // ======================================================
        // MOBILE
        // ======================================================

        _buildFieldBlock(
          label: 'Mobile Number',
          controller: _phoneController,
          focusNode: _phoneFocus,
          scale: scale,
          hintText: 'Enter mobile number',
          icon: Icons.phone_outlined,
          errorText: _phoneError(),
          prefixText: '+91  ',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 10,
          onFieldSubmitted: (_) {
            _passwordFocus.requestFocus();
          },
        ),

        SizedBox(height: 3 * scale),

        // ======================================================
        // PASSWORD
        // ======================================================

        _buildFieldBlock(
          label: 'Password',
          controller: _passwordController,
          focusNode: _passwordFocus,
          scale: scale,
          hintText: 'Create password',
          icon: Icons.lock_outline_rounded,
          errorText: _passwordError(),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _confirmPasswordFocus.requestFocus();
          },
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18 * scale,
              color: const Color(0xFF788985),
            ),
          ),
        ),

        SizedBox(height: 3 * scale),

        // ======================================================
        // CONFIRM PASSWORD
        // ======================================================

        _buildFieldBlock(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          scale: scale,
          hintText: 'Confirm password',
          icon: Icons.lock_reset_rounded,
          errorText: _confirmPasswordError(),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            _createAccount();
          },
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                    !_obscureConfirmPassword;
              });
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18 * scale,
              color: const Color(0xFF788985),
            ),
          ),
        ),

        SizedBox(height: 2 * scale),

        // ======================================================
        // TERMS
        // ======================================================

        _buildTerms(scale),

        SizedBox(height: 7 * scale),

        // ======================================================
        // CREATE ACCOUNT BUTTON
        // ======================================================

        SizedBox(
          width: double.infinity,
          height: 47 * scale,
          child: ElevatedButton(
            onPressed:
                _isCreatingAccount ? null : _createAccount,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: primaryColor,
              disabledBackgroundColor:
                  primaryColor.withValues(alpha: 0.60),
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  15 * scale,
                ),
              ),
            ),
            child: _isCreatingAccount
                ? SizedBox(
                    width: 20 * scale,
                    height: 20 * scale,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 11 * scale),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20 * scale,
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 6 * scale),

        // ======================================================
        // DIVIDER
        // ======================================================

        _buildDivider(scale),

        SizedBox(height: 6 * scale),

        // ======================================================
        // GOOGLE + APPLE
        // ======================================================

        Row(
          children: [
            Expanded(
              child: _socialButton(
                provider: 'Google',
                scale: scale,
                child: _googleLogo(scale),
              ),
            ),

            SizedBox(width: 10 * scale),

            Expanded(
              child: _socialButton(
                provider: 'Apple',
                scale: scale,
                child: Icon(
                  Icons.apple_rounded,
                  color: Colors.black,
                  size: 23 * scale,
                ),
              ),
            ),
          ],
        ),

        // Compact bottom spacing.
        SizedBox(height: 10 * scale),

        // ======================================================
        // LOGIN
        // ======================================================

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10.5 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(width: 4 * scale),

              GestureDetector(
                onTap: _openLogin,
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10.5 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8 * scale),
      ],
    );
  }

  // ============================================================
  // TOP BRAND
  // ============================================================

  Widget _buildTopBar(
    BuildContext context,
    double scale,
  ) {
    return SizedBox(
      height: 125 * scale,
      width: double.infinity,
      child: Stack(
        children: [
          // ====================================================
          // BACK BUTTON
          // ====================================================

          Positioned(
            left: 0,
            top: 5 * scale,
            child: _backButton(
              context,
              scale,
            ),
          ),

          // ====================================================
          // BRAND
          // ====================================================

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
                    height: 1,
                    letterSpacing: -0.6,
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
                    height: 1,
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
        // TOP RIGHT
        Positioned(
          right: -43 * scale,
          top: 4 * scale,
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

        // LEFT UPPER
        Positioned(
          left: -43 * scale,
          top: 130 * scale,
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

        // BOTTOM LEFT
        Positioned(
          left: -47 * scale,
          bottom: -30 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.23,
              child: Transform.rotate(
                angle: -0.45,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 125 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // BOTTOM RIGHT
        Positioned(
          right: -46 * scale,
          bottom: -30 * scale,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.22,
              child: Transform.rotate(
                angle: 0.70,
                child: Image.asset(
                  'assets/images/splash_leaves.png',
                  width: 120 * scale,
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
  // FIELD BLOCK
  // ============================================================

  Widget _buildFieldBlock({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required double scale,
    required String hintText,
    required IconData icon,
    required String? errorText,
    String? prefixText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    bool autocorrect = true,
    int? maxLength,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    final bool hasError =
        _showValidation && errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11.5 * scale,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),

        SizedBox(height: 4 * scale),

        SizedBox(
          height: 45 * scale,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: true,
            readOnly: false,
            enableInteractiveSelection: true,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autocorrect: autocorrect,
            maxLength: maxLength,
            onSubmitted: onFieldSubmitted,
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (_) {
              if (_showValidation) {
                setState(() {});
              }
            },
            style: TextStyle(
              color: textColor,
              fontSize: 11.8 * scale,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: prefixText,
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                icon,
                color: primaryColor,
                size: 18.5 * scale,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 45 * scale,
                minHeight: 45 * scale,
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(
                        right: 12 * scale,
                      ),
                      child: suffixIcon,
                    ),
              suffixIconConstraints: BoxConstraints(
                minWidth: 38 * scale,
                minHeight: 38 * scale,
              ),
              hintStyle: TextStyle(
                color: const Color(0xFF9AA7A5),
                fontSize: 11.5 * scale,
                fontWeight: FontWeight.w500,
              ),
              prefixStyle: TextStyle(
                color: textColor,
                fontSize: 11.8 * scale,
                fontWeight: FontWeight.w700,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 13 * scale,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: const BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: BorderSide(
                  color: hasError ? errorColor : borderColor,
                  width: hasError ? 1.25 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: BorderSide(
                  color: hasError ? errorColor : primaryColor,
                  width: 1.35,
                ),
              ),
            ),
          ),
        ),

        // Fixed error area prevents form jumping.
        SizedBox(
          height: 10 * scale,
          child: Padding(
            padding: EdgeInsets.only(
              left: 15 * scale,
              top: 1.5 * scale,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                hasError ? errorText : '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: errorColor,
                  fontSize: 7.8 * scale,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTerms(double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 26 * scale,
          height: 26 * scale,
          child: Transform.scale(
            scale: 0.82 * scale,
            child: Checkbox(
              value: _agreeToTerms,
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
                  _agreeToTerms = value ?? false;
                });
              },
            ),
          ),
        ),

        SizedBox(width: 5 * scale),

        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: subTextColor,
                fontSize: 9.2 * scale,
                height: 1.15,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: 'I agree to the ',
                ),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
            color: Color(0xFFDDE8E6),
            thickness: 1,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 11 * scale,
          ),
          child: Text(
            'or sign up with',
            style: TextStyle(
              color: subTextColor.withValues(
                alpha: 0.85,
              ),
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Expanded(
          child: Divider(
            color: Color(0xFFDDE8E6),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SOCIAL BUTTON
  // ============================================================

  Widget _socialButton({
    required String provider,
    required Widget child,
    required double scale,
  }) {
    return SizedBox(
      height: 43 * scale,
      child: OutlinedButton(
        onPressed: () {
          _socialSignup(provider);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 8 * scale,
          ),
          side: const BorderSide(
            color: Color(0xFFDDE8E6),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14 * scale,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,

            SizedBox(width: 8 * scale),

            Text(
              provider,
              style: TextStyle(
                color: textColor,
                fontSize: 11.8 * scale,
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
      width: 21 * scale,
      height: 21 * scale,
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
          size: 26 * scale,
        );
      },
    );
  }
}