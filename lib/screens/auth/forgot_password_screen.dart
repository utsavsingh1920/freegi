import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isResetting = false;

  static const Color primary = Color(0xFF00AFA8);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color text = Color(0xFF172321);
  static const Color subText = Color(0xFF6D7D79);
  static const Color border = Color(0xFFE1ECEA);
  static const Color mint = Color(0xFFE8F8F4);

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _message(String message) {
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

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _isResetting) return;

    setState(() => _isResetting = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedEmail =
          (prefs.getString('freegi_profile_email') ?? '').trim().toLowerCase();
      final savedPhone =
          (prefs.getString('freegi_profile_phone') ?? '').trim();

      final entered = _loginController.text.trim();
      final normalized = entered.toLowerCase();

      final accountExists = savedEmail.isNotEmpty || savedPhone.isNotEmpty;
      if (!accountExists) {
        if (mounted) setState(() => _isResetting = false);
        _message('No Freegi account found. Please create an account first.');
        return;
      }

      final emailMatches =
          savedEmail.isNotEmpty && normalized == savedEmail;
      final phoneMatches =
          savedPhone.isNotEmpty && entered == savedPhone;

      if (!emailMatches && !phoneMatches) {
        if (mounted) setState(() => _isResetting = false);
        _message('This email or mobile number is not linked to your account.');
        return;
      }

      await prefs.setString(
        'freegi_local_password',
        _passwordController.text,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: mint,
                  child: Icon(Icons.check_rounded, color: darkGreen),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Password Reset')),
              ],
            ),
            content: const Text(
              'Your Freegi password has been updated. You can now log in with your new password.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Continue to Login',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) setState(() => _isResetting = false);
      _message('Could not reset password. Please try again.');
    }
  }

  String? _validateLogin(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter your email or mobile number';

    if (input.contains('@')) {
      final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
      if (!regex.hasMatch(input)) return 'Enter a valid email address';
    } else {
      if (!RegExp(r'^[0-9]{10}$').hasMatch(input)) {
        return 'Enter a valid 10-digit mobile number';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter a new password';
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm your new password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -70,
              top: -50,
              child: Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  color: mint,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -90,
              bottom: -80,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  color: mint.withValues(alpha: .7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _backButton(),
                        const Spacer(),
                        Image.asset(
                          'assets/icon/freegi_icon.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.shopping_basket_rounded,
                            color: primary,
                            size: 42,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Freegi',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 42),
                    Center(
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [darkGreen, primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: .18),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.lock_reset_rounded,
                              color: Colors.white,
                              size: 58,
                            ),
                            Positioned(
                              right: 17,
                              top: 18,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: Color(0xFFFFD166),
                                child: Icon(
                                  Icons.key_rounded,
                                  size: 13,
                                  color: darkGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: text,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verify your Freegi account and create a new password.',
                      style: TextStyle(
                        color: subText,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _field(
                      controller: _loginController,
                      label: 'Email or Mobile Number',
                      hint: 'Enter registered email or mobile',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateLogin,
                    ),
                    const SizedBox(height: 17),
                    _field(
                      controller: _passwordController,
                      label: 'New Password',
                      hint: 'Create new password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      validator: _validatePassword,
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: subText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    _field(
                      controller: _confirmController,
                      label: 'Confirm New Password',
                      hint: 'Re-enter new password',
                      icon: Icons.verified_user_outlined,
                      obscure: _obscureConfirm,
                      validator: _validateConfirm,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _resetPassword(),
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: subText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isResetting ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primary,
                          disabledBackgroundColor:
                              primary.withValues(alpha: .55),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: _isResetting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.3,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: mint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primary.withValues(alpha: .12),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: darkGreen,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'For this portfolio/demo build, password recovery verifies the email or mobile stored on this device.',
                              style: TextStyle(
                                color: subText,
                                fontSize: 11.5,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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

  Widget _backButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.maybePop(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 17,
            color: text,
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffix,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            color: text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9AA7A5),
              fontSize: 12,
            ),
            prefixIcon: const SizedBox.shrink(),
            prefix: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, color: primary, size: 20),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE05A5A)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFFE05A5A), width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
