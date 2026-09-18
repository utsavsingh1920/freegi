import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const teal = Color(0xFF00AFA8);
  static const darkTeal = Color(0xFF08756E);
  static const bg = Color(0xFFF7FCFA);
  static const text = Color(0xFF172321);
  static const subText = Color(0xFF71807D);
  static const border = Color(0xFFE1EBE9);
  static const mint = Color(0xFFE8F8F4);
  static const danger = Color(0xFFD64C4C);

  // Keeps compatibility with the address values already used in ProfileScreen.
  static const _legacyTypeKey = 'deliveryAddressType';
  static const _legacyAddressKey = 'deliveryAddress';

  // Local multi-address storage.
  static const _countKey = 'freegi_saved_address_count';
  static const _selectedKey = 'freegi_selected_address_index';

  bool _loading = true;
  int _selectedIndex = 0;
  List<_AddressData> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_countKey) ?? 0;
    final loaded = <_AddressData>[];

    for (int i = 0; i < count; i++) {
      final address = _AddressData(
        label: prefs.getString('freegi_address_${i}_label') ?? 'Home',
        name: prefs.getString('freegi_address_${i}_name') ?? '',
        phone: prefs.getString('freegi_address_${i}_phone') ?? '',
        house: prefs.getString('freegi_address_${i}_house') ?? '',
        area: prefs.getString('freegi_address_${i}_area') ?? '',
        landmark: prefs.getString('freegi_address_${i}_landmark') ?? '',
        city: prefs.getString('freegi_address_${i}_city') ?? '',
        state: prefs.getString('freegi_address_${i}_state') ?? '',
        pincode: prefs.getString('freegi_address_${i}_pincode') ?? '',
      );

      if (address.fullAddress.trim().isNotEmpty) loaded.add(address);
    }

    // Import old single address once, if it exists.
    if (loaded.isEmpty) {
      final oldAddress = prefs.getString(_legacyAddressKey)?.trim() ?? '';
      final oldType = prefs.getString(_legacyTypeKey)?.trim() ?? 'Home';

      if (oldAddress.isNotEmpty) {
        loaded.add(
          _AddressData(
            label: oldType.isEmpty ? 'Home' : oldType,
            name: '',
            phone: '',
            house: oldAddress,
            area: '',
            landmark: '',
            city: '',
            state: '',
            pincode: '',
          ),
        );
      }
    }

    var selected = prefs.getInt(_selectedKey) ?? 0;
    if (loaded.isEmpty) {
      selected = 0;
    } else if (selected < 0 || selected >= loaded.length) {
      selected = 0;
    }

    if (!mounted) return;
    setState(() {
      _addresses = loaded;
      _selectedIndex = selected;
      _loading = false;
    });

    if (loaded.isNotEmpty) {
      await _saveAll();
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();

    final oldCount = prefs.getInt(_countKey) ?? 0;
    for (int i = 0; i < oldCount; i++) {
      await prefs.remove('freegi_address_${i}_label');
      await prefs.remove('freegi_address_${i}_name');
      await prefs.remove('freegi_address_${i}_phone');
      await prefs.remove('freegi_address_${i}_house');
      await prefs.remove('freegi_address_${i}_area');
      await prefs.remove('freegi_address_${i}_landmark');
      await prefs.remove('freegi_address_${i}_city');
      await prefs.remove('freegi_address_${i}_state');
      await prefs.remove('freegi_address_${i}_pincode');
    }

    await prefs.setInt(_countKey, _addresses.length);
    await prefs.setInt(_selectedKey, _selectedIndex);

    for (int i = 0; i < _addresses.length; i++) {
      final a = _addresses[i];
      await prefs.setString('freegi_address_${i}_label', a.label);
      await prefs.setString('freegi_address_${i}_name', a.name);
      await prefs.setString('freegi_address_${i}_phone', a.phone);
      await prefs.setString('freegi_address_${i}_house', a.house);
      await prefs.setString('freegi_address_${i}_area', a.area);
      await prefs.setString('freegi_address_${i}_landmark', a.landmark);
      await prefs.setString('freegi_address_${i}_city', a.city);
      await prefs.setString('freegi_address_${i}_state', a.state);
      await prefs.setString('freegi_address_${i}_pincode', a.pincode);
    }

    if (_addresses.isEmpty) {
      await prefs.remove(_legacyTypeKey);
      await prefs.remove(_legacyAddressKey);
      await prefs.remove('deliveryLandmark');
      await prefs.remove('deliveryArea');
      await prefs.remove('deliveryCity');
      await prefs.remove('deliveryState');
      await prefs.remove('deliveryPostalCode');
      await prefs.remove('deliveryLatitude');
      await prefs.remove('deliveryLongitude');
    } else {
      final selected = _addresses[_selectedIndex];

      // Keep one selected/default address as the source used by
      // Home, checkout and the legacy delivery flow.
      await prefs.setString(_legacyTypeKey, selected.label);
      await prefs.setString(_legacyAddressKey, selected.fullAddress);
      await prefs.setString('deliveryLandmark', selected.landmark);
      await prefs.setString('deliveryArea', selected.area);
      await prefs.setString('deliveryCity', selected.city);
      await prefs.setString('deliveryState', selected.state);
      await prefs.setString('deliveryPostalCode', selected.pincode);

      // A manually edited/saved address does not necessarily represent
      // the previous GPS coordinates, so do not leave stale coordinates.
      await prefs.remove('deliveryLatitude');
      await prefs.remove('deliveryLongitude');
    }
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? danger : darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _openAddressForm({_AddressData? address, int? index}) async {
    final result = await showModalBottomSheet<_AddressData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(initial: address),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        _addresses.add(result);
        if (_addresses.length == 1) _selectedIndex = 0;
      } else {
        _addresses[index] = result;
      }
    });

    await _saveAll();
    if (mounted) {
      _message(index == null ? 'Address added successfully.' : 'Address updated.');
    }
  }

  Future<void> _selectAddress(int index) async {
    setState(() => _selectedIndex = index);
    await _saveAll();
    if (mounted) _message('Default delivery address updated.');
  }

  Future<void> _deleteAddress(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Delete address?',
          style: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'This saved delivery address will be removed from Freegi.',
          style: TextStyle(color: subText, fontSize: 11, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFFEEEE),
              foregroundColor: danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _addresses.removeAt(index);
      if (_addresses.isEmpty) {
        _selectedIndex = 0;
      } else if (_selectedIndex >= _addresses.length) {
        _selectedIndex = _addresses.length - 1;
      } else if (index < _selectedIndex) {
        _selectedIndex--;
      }
    });

    await _saveAll();
    if (mounted) _message('Address removed.');
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'other':
        return Icons.location_on_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: teal))
                  : _addresses.isEmpty
                      ? _emptyState()
                      : _addressList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openAddressForm(),
              backgroundColor: teal,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text(
                'Add Address',
                style: TextStyle(fontWeight: FontWeight.w900),
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
            onTap: () => Navigator.pop(context, true),
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
                color: text,
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Saved Addresses',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your saved delivery locations',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: teal,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressHero() {
    return Container(
      width: double.infinity,
      height: 172,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F8F4),
            Color(0xFFF5FCF9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCFEAE4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -35,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: .06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -55,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: .045),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Positioned(
              left: 18,
              top: 22,
              child: SizedBox(
                width: 165,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your delivery,\nyour place.',
                      style: TextStyle(
                        color: text,
                        fontSize: 22,
                        height: 1.08,
                        letterSpacing: -.45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Save your favorite locations for a faster checkout.',
                      style: TextStyle(
                        color: subText,
                        fontSize: 9.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: _homeLocationArtwork(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeLocationArtwork() {
    return SizedBox(
      width: 132,
      height: 130,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: 124,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFBFE9D8),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 18,
            child: Container(
              width: 83,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD7E9E4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .07),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 33,
                    bottom: 0,
                    child: Container(
                      width: 23,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Color(0xFF08756E),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 19,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF6F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 78,
            child: Transform.rotate(
              angle: -.06,
              child: Container(
                width: 99,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF00AFA8),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  Icons.roofing_rounded,
                  color: Color(0xFF075C50),
                  size: 42,
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 9,
            child: Container(
              width: 53,
              height: 53,
              decoration: BoxDecoration(
                color: teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: teal.withValues(alpha: .24),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const Positioned(
            right: 8,
            bottom: 10,
            child: Icon(
              Icons.park_rounded,
              color: Color(0xFF56B98A),
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_location_alt_outlined,
                color: teal,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No saved addresses yet',
              style: TextStyle(
                color: text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Add your home, work or another delivery address for faster checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openAddressForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Your First Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressList() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: [
        _addressHero(),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mint,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFCDEEE8)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: teal, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Select one address as your default delivery location.',
                  style: TextStyle(
                    color: darkTeal,
                    fontSize: 9.8,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          _addresses.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: _addressCard(index),
          ),
        ),
      ],
    );
  }

  Widget _addressCard(int index) {
    final address = _addresses[index];
    final selected = index == _selectedIndex;

    return InkWell(
      onTap: () => _selectAddress(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? teal : border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: selected ? mint : const Color(0xFFF5F8F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _labelIcon(address.label),
                color: selected ? teal : subText,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          color: text,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: mint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: teal,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (address.name.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      address.name,
                      style: const TextStyle(
                        color: text,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9.7,
                      height: 1.45,
                    ),
                  ),
                  if (address.phone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+91 ${address.phone}',
                      style: const TextStyle(
                        color: subText,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      _smallAction(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: () => _openAddressForm(
                          address: address,
                          index: index,
                        ),
                      ),
                      const SizedBox(width: 9),
                      _smallAction(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        dangerAction: true,
                        onTap: () => _deleteAddress(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? teal : const Color(0xFFC4CFCC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool dangerAction = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: dangerAction
              ? const Color(0xFFFFF4F4)
              : const Color(0xFFF2FAF8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: dangerAction ? danger : teal,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: dangerAction ? danger : darkTeal,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressData {
  final String label;
  final String name;
  final String phone;
  final String house;
  final String area;
  final String landmark;
  final String city;
  final String state;
  final String pincode;

  const _AddressData({
    required this.label,
    required this.name,
    required this.phone,
    required this.house,
    required this.area,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
  });

  String get fullAddress {
    return [
      house,
      area,
      landmark,
      city,
      state,
      pincode,
    ].where((e) => e.trim().isNotEmpty).join(', ');
  }
}

class _AddressFormSheet extends StatefulWidget {
  final _AddressData? initial;

  const _AddressFormSheet({this.initial});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  static const teal = Color(0xFF00AFA8);
  static const text = Color(0xFF172321);
  static const subText = Color(0xFF71807D);
  static const border = Color(0xFFE1EBE9);
  static const mint = Color(0xFFE8F8F4);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _house;
  late final TextEditingController _area;
  late final TextEditingController _landmark;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;

  String _label = 'Home';

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _label = a?.label ?? 'Home';
    _name = TextEditingController(text: a?.name ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _house = TextEditingController(text: a?.house ?? '');
    _area = TextEditingController(text: a?.area ?? '');
    _landmark = TextEditingController(text: a?.landmark ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _state = TextEditingController(text: a?.state ?? 'Maharashtra');
    _pincode = TextEditingController(text: a?.pincode ?? '');
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      _AddressData(
        label: _label,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        house: _house.text.trim(),
        area: _area.text.trim(),
        landmark: _landmark.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 11),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 17, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initial == null
                            ? 'Add New Address'
                            : 'Edit Address',
                        style: const TextStyle(
                          color: text,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Save address as',
                          style: TextStyle(
                            color: text,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            _labelChip('Home', Icons.home_outlined),
                            const SizedBox(width: 8),
                            _labelChip('Work', Icons.work_outline_rounded),
                            const SizedBox(width: 8),
                            _labelChip('Other', Icons.location_on_outlined),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _field(
                          _name,
                          'Full Name',
                          'Receiver name',
                          Icons.person_outline_rounded,
                          requiredField: true,
                        ),
                        _field(
                          _phone,
                          'Mobile Number',
                          '10-digit mobile number',
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (v) {
                            if (!RegExp(r'^[6-9]\d{9}$')
                                .hasMatch(v?.trim() ?? '')) {
                              return 'Enter a valid 10-digit mobile number.';
                            }
                            return null;
                          },
                        ),
                        _field(
                          _house,
                          'House / Flat / Building',
                          'Flat no., building or house',
                          Icons.home_work_outlined,
                          requiredField: true,
                        ),
                        _field(
                          _area,
                          'Area / Street',
                          'Road, area or locality',
                          Icons.signpost_outlined,
                          requiredField: true,
                        ),
                        _field(
                          _landmark,
                          'Landmark (Optional)',
                          'Nearby landmark',
                          Icons.flag_outlined,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                _city,
                                'City',
                                'City',
                                Icons.location_city_outlined,
                                requiredField: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _field(
                                _pincode,
                                'Pincode',
                                '6 digits',
                                Icons.pin_drop_outlined,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                validator: (v) {
                                  if (!RegExp(r'^\d{6}$')
                                      .hasMatch(v?.trim() ?? '')) {
                                    return 'Enter 6 digits.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        _field(
                          _state,
                          'State',
                          'State',
                          Icons.map_outlined,
                          requiredField: true,
                        ),
                        const SizedBox(height: 7),
                        SizedBox(
                          width: double.infinity,
                          height: 53,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              widget.initial == null
                                  ? 'Save Address'
                                  : 'Update Address',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelChip(String label, IconData icon) {
    final selected = _label == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _label = label),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? mint : const Color(0xFFF8FBFA),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: selected ? teal : border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? teal : subText),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? teal : text,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool requiredField = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
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
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            validator: validator ??
                (requiredField
                    ? (value) => (value?.trim().isEmpty ?? true)
                        ? 'This field is required.'
                        : null
                    : null),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              prefixIcon: Icon(icon, color: teal, size: 19),
              filled: true,
              fillColor: const Color(0xFFF8FBFA),
              hintStyle: const TextStyle(color: Color(0xFFA6B0AE), fontSize: 10.5),
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
                borderSide: const BorderSide(color: teal, width: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _house.dispose();
    _area.dispose();
    _landmark.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    super.dispose();
  }
}
