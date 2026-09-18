import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/welcome_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState
    extends State<AccountSettingsScreen> {
  // ============================================================
  // FREEGI COLORS
  // ============================================================

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);

  static const Color background = Color(0xFFF8FCFA);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color border = Color(0xFFE1EBE9);
  static const Color divider = Color(0xFFEDF2F1);
  static const Color mint = Color(0xFFE8F8F4);

  static const Color danger = Color(0xFFD64C4C);
  static const Color dangerBg = Color(0xFFFFEEEE);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueBg = Color(0xFFEAF2FF);
  static const Color purple = Color(0xFF7A5AF8);
  static const Color purpleBg = Color(0xFFF0ECFF);

  // ============================================================
  // SAME PROFILE KEYS USED BY PROFILE SCREEN
  // ============================================================

  static const String _nameKey = 'freegi_profile_name';
  static const String _phoneKey = 'freegi_profile_phone';
  static const String _emailKey = 'freegi_profile_email';

  String _name = 'Freegi User';
  String _phone = '+91 XXXXX XXXXX';
  String _email = 'user@freegi.app';

  bool _loading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedName = prefs.getString(_nameKey)?.trim();
      final savedPhone = prefs.getString(_phoneKey)?.trim();
      final savedEmail = prefs.getString(_emailKey)?.trim();

      if (!mounted) return;

      setState(() {
        _name = savedName != null && savedName.isNotEmpty
            ? savedName
            : 'Freegi User';

        _phone = savedPhone != null && savedPhone.isNotEmpty
            ? savedPhone
            : '+91 XXXXX XXXXX';

        _email = savedEmail != null && savedEmail.isNotEmpty
            ? savedEmail
            : 'user@freegi.app';

        _loading = false;
      });
    } catch (e) {
      debugPrint('ACCOUNT SETTINGS LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    Color color = darkTeal,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _showEditProfile() async {
    final nameController = TextEditingController(
      text: _name == 'Freegi User' ? '' : _name,
    );

    final emailController = TextEditingController(
      text: _email == 'user@freegi.app' ? '' : _email,
    );

    final phoneController = TextEditingController(
      text: _phone == '+91 XXXXX XXXXX' ? '' : _phone,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 18),

                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: text,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Update your basic Freegi account information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subText,
                      fontSize: 10,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _inputField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'Enter your name',
                    icon: Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 12),

                  _inputField(
                    controller: emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 12),

                  _inputField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email =
                            emailController.text.trim().toLowerCase();
                        final phone = phoneController.text.trim();

                        if (name.length < 2) {
                          _showMessage(
                            'Please enter a valid name.',
                            color: danger,
                          );
                          return;
                        }

                        if (!_isValidEmail(email)) {
                          _showMessage(
                            'Please enter a valid email address.',
                            color: danger,
                          );
                          return;
                        }

                        if (!_isValidPhone(phone)) {
                          _showMessage(
                            'Please enter a valid phone number.',
                            color: danger,
                          );
                          return;
                        }

                        final prefs =
                            await SharedPreferences.getInstance();

                        await prefs.setString(_nameKey, name);
                        await prefs.setString(_emailKey, email);
                        await prefs.setString(_phoneKey, phone);

                        if (!mounted) return;

                        setState(() {
                          _name = name;
                          _email = email;
                          _phone = phone;
                        });

                        FocusManager.instance.primaryFocus?.unfocus();

                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (mounted) {
      _showMessage('Profile updated successfully.');
    }

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  // ============================================================
  // MANAGE EMAIL
  // ============================================================

  Future<void> _manageEmail() async {
    final controller = TextEditingController(
      text: _email == 'user@freegi.app' ? '' : _email,
    );

    await _showSingleFieldSheet(
      title: 'Email Address',
      subtitle: 'Update the email linked with your Freegi account.',
      controller: controller,
      label: 'Email Address',
      hint: 'Enter new email address',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      buttonText: 'Update Email',
      onSave: (value) async {
        final email = value.trim().toLowerCase();

        if (!_isValidEmail(email)) {
          _showMessage(
            'Please enter a valid email address.',
            color: danger,
          );
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_emailKey, email);

        if (!mounted) return false;

        setState(() {
          _email = email;
        });

        return true;
      },
      successMessage: 'Email updated successfully.',
    );

    controller.dispose();
  }

  // ============================================================
  // MANAGE PHONE
  // ============================================================

  Future<void> _managePhone() async {
    final controller = TextEditingController(
      text: _phone == '+91 XXXXX XXXXX' ? '' : _phone,
    );

    await _showSingleFieldSheet(
      title: 'Phone Number',
      subtitle: 'Update the mobile number linked with your account.',
      controller: controller,
      label: 'Phone Number',
      hint: 'Enter phone number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      buttonText: 'Update Number',
      onSave: (value) async {
        final phone = value.trim();

        if (!_isValidPhone(phone)) {
          _showMessage(
            'Please enter a valid phone number.',
            color: danger,
          );
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_phoneKey, phone);

        if (!mounted) return false;

        setState(() {
          _phone = phone;
        });

        return true;
      },
      successMessage: 'Phone number updated successfully.',
    );

    controller.dispose();
  }

  Future<void> _showSingleFieldSheet({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required String buttonText,
    required Future<bool> Function(String value) onSave,
    required String successMessage,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),

                const SizedBox(height: 18),

                Text(
                  title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: subText,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                _inputField(
                  controller: controller,
                  label: label,
                  hint: hint,
                  icon: icon,
                  keyboardType: keyboardType,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success =
                          await onSave(controller.text);

                      if (!success) return;

                      FocusManager.instance.primaryFocus?.unfocus();

                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) {
      _showMessage(successMessage);
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _showChangePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool saving = false;

    final passwordChanged = await showDialog<bool>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> savePassword() async {
              if (saving) return;

              final current = currentController.text;
              final newPassword = newController.text;
              final confirm = confirmController.text;

              if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
                _showMessage('Please fill all password fields.', color: danger);
                return;
              }

              if (newPassword.length < 6) {
                _showMessage(
                  'New password must be at least 6 characters.',
                  color: danger,
                );
                return;
              }

              if (newPassword != confirm) {
                _showMessage('New passwords do not match.', color: danger);
                return;
              }

              if (current == newPassword) {
                _showMessage(
                  'New password must be different from current password.',
                  color: danger,
                );
                return;
              }

              setDialogState(() => saving = true);

              try {
                final prefs = await SharedPreferences.getInstance();
                final savedPassword =
                    prefs.getString('freegi_local_password') ?? '';

                if (savedPassword.isEmpty) {
                  setDialogState(() => saving = false);
                  _showMessage(
                    'No password is set for this account.',
                    color: danger,
                  );
                  return;
                }

                if (current != savedPassword) {
                  setDialogState(() => saving = false);
                  _showMessage('Current password is incorrect.', color: danger);
                  return;
                }

                await prefs.setString(
                  'freegi_local_password',
                  newPassword,
                );

                if (!mounted) return;

                FocusManager.instance.primaryFocus?.unfocus();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              } catch (e) {
                setDialogState(() => saving = false);
                _showMessage(
                  'Could not change password. Please try again.',
                  color: danger,
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Change Password',
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter your current password and choose a new password for your Freegi account.',
                      style: TextStyle(
                        color: subText,
                        fontSize: 10,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _passwordField(
                      controller: currentController,
                      hint: 'Current password',
                      obscure: obscureCurrent,
                      onToggle: () {
                        setDialogState(() {
                          obscureCurrent = !obscureCurrent;
                        });
                      },
                    ),
                    const SizedBox(height: 11),
                    _passwordField(
                      controller: newController,
                      hint: 'New password',
                      obscure: obscureNew,
                      onToggle: () {
                        setDialogState(() {
                          obscureNew = !obscureNew;
                        });
                      },
                    ),
                    const SizedBox(height: 11),
                    _passwordField(
                      controller: confirmController,
                      hint: 'Confirm new password',
                      obscure: obscureConfirm,
                      onToggle: () {
                        setDialogState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : savePassword,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (passwordChanged == true && mounted) {
      _showMessage('Password changed successfully.');
    }

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _showDeleteAccount() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool deleting = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> deleteAccount() async {
              if (deleting) return;

              final enteredPassword = passwordController.text;
              if (enteredPassword.isEmpty) {
                _showMessage(
                  'Enter your password to delete the account.',
                  color: danger,
                );
                return;
              }

              setDialogState(() => deleting = true);

              try {
                final prefs = await SharedPreferences.getInstance();
                final savedPassword =
                    prefs.getString('freegi_local_password') ?? '';

                if (savedPassword.isEmpty ||
                    enteredPassword != savedPassword) {
                  setDialogState(() => deleting = false);
                  _showMessage('Incorrect password.', color: danger);
                  return;
                }

                FocusManager.instance.primaryFocus?.unfocus();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              } catch (e) {
                setDialogState(() => deleting = false);
                _showMessage(
                  'Could not verify your account.',
                  color: danger,
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              icon: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: dangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: danger,
                  size: 29,
                ),
              ),
              title: const Text(
                'Delete Account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This will remove your local Freegi account and app data from this device. This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subText,
                      fontSize: 10.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _passwordField(
                    controller: passwordController,
                    hint: 'Confirm your password',
                    obscure: obscurePassword,
                    onToggle: () {
                      setDialogState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: deleting
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(dialogContext, false);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: deleting ? null : deleteAccount,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Delete Account',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();

    if (confirmed != true || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Preserve only non-account app preferences that do not represent
      // the signed-in user's data. Account/session and user-owned local
      // data are removed below.
      final keysToRemove = prefs
          .getKeys()
          .where(
            (key) =>
                key.startsWith('freegi_') ||
                key.startsWith('delivery') ||
                key == 'isLoggedIn' ||
                key == 'isOnboardingCompleted',
          )
          .toList();

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      _showMessage(
        'Could not delete account. Please try again.',
        color: danger,
      );
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    return regex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return digits.length >= 10 && digits.length <= 13;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(
            color: teal,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  30,
                ),
                child: Column(
                  children: [
                    _accountCard(),

                    const SizedBox(height: 20),

                    _sectionTitle('Profile'),

                    const SizedBox(height: 10),

                    _settingsCard(
                      children: [
                        _AccountItem(
                          icon: Icons.person_rounded,
                          title: 'Edit Profile',
                          subtitle:
                              'Update your name, email and phone number',
                          iconColor: teal,
                          iconBg: mint,
                          onTap: _showEditProfile,
                        ),

                        _divider(),

                        _AccountItem(
                          icon: Icons.email_rounded,
                          title: 'Email Address',
                          subtitle: _email,
                          iconColor: blue,
                          iconBg: blueBg,
                          onTap: _manageEmail,
                        ),

                        _divider(),

                        _AccountItem(
                          icon: Icons.phone_rounded,
                          title: 'Phone Number',
                          subtitle: _phone,
                          iconColor: purple,
                          iconBg: purpleBg,
                          onTap: _managePhone,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle('Security'),

                    const SizedBox(height: 10),

                    _settingsCard(
                      children: [
                        _AccountItem(
                          icon: Icons.lock_rounded,
                          title: 'Change Password',
                          subtitle:
                              'Update your Freegi account password',
                          iconColor: const Color(0xFF667085),
                          iconBg: const Color(0xFFF1F3F5),
                          onTap: _showChangePassword,
                        ),


                      ],
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle('Account'),

                    const SizedBox(height: 10),

                    _settingsCard(
                      children: [
                        _AccountItem(
                          icon: Icons.delete_forever_rounded,
                          title: 'Delete Account',
                          subtitle:
                              'Permanently remove your Freegi account',
                          iconColor: danger,
                          iconBg: dangerBg,
                          titleColor: danger,
                          onTap: _showDeleteAccount,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Freegi • Account Settings',
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        12,
      ),
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
                'Account Settings',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage your Freegi account',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          const SizedBox(
            width: 42,
            height: 42,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT HERO CARD
  // ============================================================

  Widget _accountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkGreen,
            darkTeal,
            teal,
          ],
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: Center(
              child: Text(
                _initials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _initials() {
    final cleanName = _name.trim();

    if (cleanName.isEmpty || cleanName == 'Freegi User') {
      return 'FU';
    }

    final parts = cleanName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'FU';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ============================================================
  // UI HELPERS
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

  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 55),
      child: Divider(
        height: 1,
        color: divider,
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: text,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFA0AAA8),
              fontSize: 11,
            ),
            prefixIcon: Icon(
              icon,
              color: teal,
              size: 19,
            ),
            filled: true,
            fillColor: const Color(0xFFF7FAF9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: teal,
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: text,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7FAF9),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: teal,
          size: 19,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: subText,
            size: 19,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: teal,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACCOUNT ITEM
// ============================================================

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
  final Color? titleColor;

  const _AccountItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF172321);
    const subText = Color(0xFF71807D);
    const arrow = Color(0xFFAAB5B2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? text,
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
              color: arrow,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}