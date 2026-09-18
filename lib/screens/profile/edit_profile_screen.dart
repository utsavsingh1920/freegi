import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const teal = Color(0xFF00AFA8);
  static const darkTeal = Color(0xFF08756E);
  static const bg = Color(0xFFF8FCFA);
  static const text = Color(0xFF172321);
  static const subText = Color(0xFF71807D);
  static const border = Color(0xFFE1EBE9);
  static const mint = Color(0xFFE8F8F4);

  static const _nameKey = 'freegi_profile_name';
  static const _phoneKey = 'freegi_profile_phone';
  static const _emailKey = 'freegi_profile_email';
  static const _photoKey = 'freegi_profile_photo';

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _picker = ImagePicker();

  String? _photoPath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name.text = prefs.getString(_nameKey) ?? '';
    _phone.text = prefs.getString(_phoneKey) ?? '';
    _email.text = prefs.getString(_emailKey) ?? '';
    _photoPath = prefs.getString(_photoKey);
    if (mounted) setState(() => _loading = false);
  }

  void _message(String value, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(value),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFD64C4C) : darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _choosePhoto() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                'Profile Photo',
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _photoOption(
                      Icons.photo_camera_rounded,
                      'Camera',
                      () {
                        Navigator.pop(sheetContext);
                        _pick(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _photoOption(
                      Icons.photo_library_rounded,
                      'Gallery',
                      () {
                        Navigator.pop(sheetContext);
                        _pick(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              if (_photoPath != null && _photoPath!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      setState(() => _photoPath = null);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD64C4C),
                      side: const BorderSide(color: Color(0xFFFFD7D7)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFA),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: mint,
              child: Icon(icon, color: teal),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1400,
        maxHeight: 1400,
      );
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: teal,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: teal,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );
      if (cropped != null && mounted) {
        setState(() => _photoPath = cropped.path);
      }
    } catch (_) {
      if (mounted) _message('Could not select photo.', error: true);
    }
  }

  Future<String?> _savePhoto(String? path) async {
    if (path == null || path.isEmpty) return null;
    final source = File(path);
    if (!await source.exists()) return null;

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/profile');
    if (!await dir.exists()) await dir.create(recursive: true);
    if (path.startsWith(dir.path)) return path;

    final saved = await source.copy(
      '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    return saved.path;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _saving) return;

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhoto = await _savePhoto(_photoPath);

      await prefs.setString(_nameKey, _name.text.trim());
      await prefs.setString(_phoneKey, _phone.text.trim());
      await prefs.setString(_emailKey, _email.text.trim().toLowerCase());

      if (savedPhoto == null) {
        await prefs.remove(_photoKey);
      } else {
        await prefs.setString(_photoKey, savedPhoto);
      }

      if (!mounted) return;
      setState(() => _saving = false);
      _message('Profile updated successfully.');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message('Could not save profile.', error: true);
    }
  }

  String? _nameValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your full name.';
    if (v.length < 2) return 'Enter a valid name.';
    return null;
  }

  String? _phoneValidator(String? value) {
    final v = value?.replaceAll(' ', '') ?? '';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
      return 'Enter a valid 10-digit mobile number.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    if (!RegExp(r'^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$').hasMatch(v)) {
      return 'Enter a valid email address.';
    }
    if (!(v.endsWith('@gmail.com') ||
        v.endsWith('@outlook.com') ||
        v.endsWith('@hotmail.com'))) {
      return 'Use Gmail, Outlook or Hotmail email.';
    }
    return null;
  }

  ImageProvider? get _image {
    if (_photoPath == null || _photoPath!.isEmpty) return null;
    final file = File(_photoPath!);
    return file.existsSync() ? FileImage(file) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: teal))
            : Column(
                children: [
                  _header(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _photoCard(),
                            const SizedBox(height: 18),
                            _formCard(),
                            const SizedBox(height: 18),
                            _privacyCard(),
                            const SizedBox(height: 22),
                            _saveButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: text,
              ),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Update your personal information',
                  style: TextStyle(color: subText, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _photoCard() {
    final image = _image;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBDEBE4), width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: mint,
                  backgroundImage: image,
                  child: image == null
                      ? const Icon(Icons.person_rounded, color: teal, size: 48)
                      : null,
                ),
              ),
              Positioned(
                right: -3,
                bottom: 3,
                child: InkWell(
                  onTap: _choosePhoto,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Profile Photo',
            style: TextStyle(
              color: text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap camera icon to update your photo',
            style: TextStyle(color: subText, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              color: text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),
          _field(
            controller: _name,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            validator: _nameValidator,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _phone,
            label: 'Mobile Number',
            hint: '10-digit mobile number',
            icon: Icons.phone_outlined,
            validator: _phoneValidator,
            type: TextInputType.phone,
            prefix: '+91  ',
            maxLength: 10,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _email,
            label: 'Email Address',
            hint: 'example@gmail.com',
            icon: Icons.mail_outline_rounded,
            validator: _emailValidator,
            type: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? type,
    TextCapitalization capitalization = TextCapitalization.none,
    String? prefix,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: text,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: type,
          textCapitalization: capitalization,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            prefixText: prefix,
            prefixIcon: Icon(icon, color: teal, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FBFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: teal, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _privacyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: teal, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your profile information is stored securely on your device.',
              style: TextStyle(
                color: darkTeal,
                fontSize: 9.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.3,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }
}
