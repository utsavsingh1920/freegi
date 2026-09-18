import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_navigation_screen.dart';

class LocationScreen extends StatefulWidget {
  final bool isChangeMode;

  const LocationScreen({
    super.key,
    this.isChangeMode = false,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _landmarkController =
      TextEditingController();

  final Geocoding _geocoding = Geocoding();

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;
  bool _locationDetected = false;

  String? _detectedAddress;
  String? _detectedArea;
  String? _detectedCity;
  String? _detectedState;
  String? _detectedPostalCode;

  double? _latitude;
  double? _longitude;

  String _selectedAddressType = 'Home';

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF7FCFA);
  static const Color primaryColor = Color(0xFF08A884);
  static const Color darkGreen = Color(0xFF076B58);
  static const Color textColor = Color(0xFF172321);
  static const Color subTextColor = Color(0xFF6D7D79);
  static const Color borderColor = Color(0xFFE0ECE9);
  static const Color softMint = Color(0xFFEAF8F5);
  static const Color softMint2 = Color(0xFFF1FBF8);

  // Visual map image.
  // GPS/address detection below is real.
  static const String locationImageUrl =
      'https://images.unsplash.com/photo-1524661135-423995f22d0b'
      '?auto=format&fit=crop&w=1200&q=86';

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void> _useCurrentLocation() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // 1. CHECK LOCATION SERVICE
      // --------------------------------------------------------

      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        _showMessage(
          'Please turn on Location Services first.',
        );

        await Geolocator.openLocationSettings();
        return;
      }

      // --------------------------------------------------------
      // 2. CHECK PERMISSION
      // --------------------------------------------------------

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        _showMessage(
          'Location permission is required to detect your address.',
        );

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        if (!mounted) return;

        _showMessage(
          'Location permission is permanently denied. '
          'Please enable it from App Settings.',
        );

        await Geolocator.openAppSettings();
        return;
      }

      // --------------------------------------------------------
      // 3. GET CURRENT GPS POSITION
      // --------------------------------------------------------

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // --------------------------------------------------------
      // 4. REVERSE GEOCODING
      // --------------------------------------------------------

      final placemarks =
          await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String finalAddress =
          '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';

      String area = '';
      String city = '';
      String state = '';
      String postalCode = '';

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        area = _firstNonEmpty([
          place.subLocality,
          place.street,
          place.name,
        ]);

        city = _firstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
        ]);

        state =
            place.administrativeArea?.trim() ?? '';

        postalCode =
            place.postalCode?.trim() ?? '';

        final parts = <String>[
          place.name ?? '',
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
          place.subAdministrativeArea ?? '',
          place.administrativeArea ?? '',
          place.postalCode ?? '',
          place.country ?? '',
        ]
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Remove duplicate address parts.
        final deduped = <String>[];

        for (final item in parts) {
          final alreadyExists = deduped.any(
            (existing) =>
                existing.toLowerCase() ==
                item.toLowerCase(),
          );

          if (!alreadyExists) {
            deduped.add(item);
          }
        }

        if (deduped.isNotEmpty) {
          finalAddress = deduped.join(', ');
        }
      }

      if (!mounted) return;

      // --------------------------------------------------------
      // 5. UPDATE UI
      // --------------------------------------------------------

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;

        _detectedAddress = finalAddress;
        _detectedArea = area;
        _detectedCity = city;
        _detectedState = state;
        _detectedPostalCode = postalCode;

        _addressController.text = finalAddress;

        _locationDetected = true;
      });

      _showMessage(
        'Location detected successfully.',
      );
    } catch (error) {
      debugPrint(
        'LOCATION ERROR: $error',
      );

      if (!mounted) return;

      _showMessage(
        'Unable to detect your location. '
        'Please check GPS or enter the address manually.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _firstNonEmpty(
    List<String?> values,
  ) {
    for (final value in values) {
      final text = value?.trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  // ============================================================
  // SAVE LOCATION
  // ============================================================

  Future<void> _saveAndContinue() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final address =
        _addressController.text.trim();

    final landmark =
        _landmarkController.text.trim();

    if (address.isEmpty) {
      _showMessage(
        'Please enter your delivery address.',
      );

      return;
    }

    if (address.length < 8) {
      _showMessage(
        'Please enter a complete delivery address.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      // Login/session
      await prefs.setBool(
        'isLoggedIn',
        true,
      );

      await prefs.setBool(
        'isOnboardingCompleted',
        true,
      );

      // Main address
      await prefs.setString(
        'deliveryAddress',
        address,
      );

      await prefs.setString(
        'deliveryAddressType',
        _selectedAddressType,
      );

      await prefs.setString(
        'deliveryLandmark',
        landmark,
      );

      // Separate address information
      await prefs.setString(
        'deliveryArea',
        (_detectedArea ?? '').trim(),
      );

      await prefs.setString(
        'deliveryCity',
        (_detectedCity ?? '').trim(),
      );

      await prefs.setString(
        'deliveryState',
        (_detectedState ?? '').trim(),
      );

      await prefs.setString(
        'deliveryPostalCode',
        (_detectedPostalCode ?? '').trim(),
      );

      // Coordinates
      if (_latitude != null) {
        await prefs.setDouble(
          'deliveryLatitude',
          _latitude!,
        );
      }

      if (_longitude != null) {
        await prefs.setDouble(
          'deliveryLongitude',
          _longitude!,
        );
      }

      if (!mounted) return;

      // --------------------------------------------------------
      // HOME
      // --------------------------------------------------------

      // When opened from Home to change the saved location,
      // return to the existing Home screen instead of rebuilding
      // the whole navigation stack. Home will reload the saved
      // location when it receives `true`.
      if (widget.isChangeMode) {
        Navigator.of(context).pop(true);
        return;
      }

      // First-time setup keeps the existing behavior.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(
            initialIndex: 0,
          ),
        ),
        (route) => false,
      );
    } catch (error) {
      debugPrint(
        'SAVE LOCATION ERROR: $error',
      );

      if (!mounted) return;

      _showMessage(
        'Could not save your location. '
        'Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SKIP
  // ============================================================

  Future<void> _skipLocation() async {
    if (_isLoading) return;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'isLoggedIn',
      true,
    );

    await prefs.setBool(
      'isOnboardingCompleted',
      true,
    );

    if (!mounted) return;

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            const MainNavigationScreen(
          initialIndex: 0,
        ),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // CHANGE LOCATION
  // ============================================================

  void _changeLocation() {
    FocusScope.of(context).unfocus();

    setState(() {
      _locationDetected = false;

      _detectedAddress = null;
      _detectedArea = null;
      _detectedCity = null;
      _detectedState = null;
      _detectedPostalCode = null;

      _latitude = null;
      _longitude = null;

      _addressController.clear();
    });
  }

  // ============================================================
  // EDIT DETECTED ADDRESS
  // ============================================================

  void _editAddress() {
    FocusScope.of(context).unfocus();

    // Important:
    // Controller is NOT cleared here.
    // Detected address stays available for editing.
    setState(() {
      _locationDetected = false;
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          margin:
              const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
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

      // Location form should move/scroll normally
      // when keyboard is open.
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
              physics:
                  const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                          34,
                ),
                child: _locationDetected
                    ? _buildDetectedView()
                    : _buildChooseLocationView(),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // FIRST VIEW
  // ============================================================

  Widget _buildChooseLocationView() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildInitialHeader(),

        const SizedBox(height: 16),

        const Text(
          'Select Location',
          style: TextStyle(
            color: textColor,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.05,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Delivering happiness near you.',
          style: TextStyle(
            color: subTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 18),

        _buildChooseMapCard(),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: softMint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCFEAE4)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use your current location',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find nearby stores and faster delivery',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // CURRENT LOCATION BUTTON
        // ------------------------------------------------------

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : _useCurrentLocation,
            style:
                ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  primaryColor,
              disabledBackgroundColor:
                  primaryColor.withValues(
                alpha: 0.55,
              ),
              foregroundColor:
                  Colors.white,
              shadowColor:
                  Colors.transparent,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 200,
              ),
              child: _isLoading
                  ? const Row(
                      key: ValueKey(
                        'loading',
                      ),
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        SizedBox(
                          width: 19,
                          height: 19,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.2,
                            color:
                                Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Detecting Location...',
                          style:
                              TextStyle(
                            fontSize:
                                14,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      key: ValueKey(
                        'location',
                      ),
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .my_location_rounded,
                          size: 20,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Use Current Location',
                          style:
                              TextStyle(
                            fontSize:
                                14.5,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        _buildDividerText(
          'OR',
        ),

        const SizedBox(height: 17),

        _buildSectionTitle(
          'Search Location',
        ),

        const SizedBox(height: 8),

        _buildAddressTextField(),

        const SizedBox(height: 15),

        _buildSectionTitle(
          'Save as',
        ),

        const SizedBox(height: 9),

        _buildAddressTypeSelector(),

        const SizedBox(height: 18),

        _buildSaveButton(
          outlined: true,
        ),
      ],
    );
  }

  // ============================================================
  // DETECTED VIEW
  // ============================================================

  Widget _buildDetectedView() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        _buildDetectedHeader(),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // SUCCESS
        // ------------------------------------------------------

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFF22C882),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Location Detected!',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          -0.45,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'We found your current location.',
                    style: TextStyle(
                      color:
                          subTextColor,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // MAP
        // ------------------------------------------------------

        _buildDetectedMap(),

        const SizedBox(height: 14),

        // ------------------------------------------------------
        // ADDRESS
        // ------------------------------------------------------

        _buildDetectedAddressCard(),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // SAVE AS
        // ------------------------------------------------------

        _buildSectionTitle(
          'Save as',
        ),

        const SizedBox(height: 9),

        _buildAddressTypeSelector(),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // OPTIONAL DETAILS
        // ------------------------------------------------------

        _buildSectionTitle(
          'Add more details (Optional)',
        ),

        const SizedBox(height: 8),

        _buildLandmarkField(),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // SAVE
        // ------------------------------------------------------

        _buildSaveButton(),
      ],
    );
  }

  // ============================================================
  // INITIAL HEADER
  // ============================================================

  Widget _buildInitialHeader() {
    return Row(
      children: [
        Expanded(
          child: _buildBrand(),
        ),

        const SizedBox(width: 10),

        if (!widget.isChangeMode)
          TextButton(
          onPressed:
              _isLoading
                  ? null
                  : _skipLocation,
          style: TextButton.styleFrom(
            foregroundColor: darkGreen,
            backgroundColor: softMint,
            minimumSize:
                const Size(68, 42),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                21,
              ),
            ),
          ),
          child: const Text(
            'Skip',
            style: TextStyle(
              fontWeight:
                  FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETECTED HEADER
  //
  // THIS FIXES RIGHT OVERFLOW
  // ============================================================

  Widget _buildDetectedHeader() {
    return Row(
      children: [
        _smallSquareButton(
          icon:
              Icons.arrow_back_ios_new_rounded,
          onTap: () {
            Navigator.maybePop(context);
          },
        ),

        const SizedBox(width: 10),

        // Brand receives ONLY available width.
        Expanded(
          child: _buildBrand(),
        ),

        const SizedBox(width: 8),

        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : _changeLocation,
          style: TextButton.styleFrom(
            foregroundColor: darkGreen,
            backgroundColor: softMint,
            minimumSize:
                const Size(72, 42),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                21,
              ),
            ),
          ),
          child: const Text(
            'Change',
            style: TextStyle(
              fontWeight:
                  FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BRAND
  // ============================================================

  Widget _buildBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          padding:
              const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            child: Image.asset(
              'assets/icon/freegi_icon.png',
              fit: BoxFit.contain,
              filterQuality:
                  FilterQuality.high,
              errorBuilder:
                  (_, _, _) {
                return Container(
                  decoration:
                      BoxDecoration(
                    color:
                        primaryColor,
                    borderRadius:
                        BorderRadius
                            .circular(
                      11,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .shopping_cart_rounded,
                    color:
                        Colors.white,
                    size: 23,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 9),

        // Flexible prevents brand text overflow.
        Flexible(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Freegi',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'Fresh Groceries, Happier You',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: subTextColor
                      .withValues(
                    alpha: 0.92,
                  ),
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SMALL BUTTON
  // ============================================================

  Widget _smallSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.035,
                ),
                blurRadius: 10,
                offset:
                    const Offset(
                  0,
                  3,
                ),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: textColor,
            size: 18,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHOOSE LOCATION MAP
  // ============================================================

  Widget _buildChooseMapCard() {
    return Container(
      width: double.infinity,
      height: 205,
      decoration: BoxDecoration(
        color: softMint2,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.045,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMapImage(),

            Positioned.fill(
              child: Container(
                color: Colors.white
                    .withValues(
                  alpha: 0.16,
                ),
              ),
            ),

            // --------------------------------------------------
            // TOP LABEL
            // --------------------------------------------------

            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.96,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons
                            .near_me_rounded,
                        color:
                            primaryColor,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Flexible(
                        child: Text(
                          _isLoading
                              ? 'Detecting your location...'
                              : 'Your delivery area',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                textColor,
                            fontSize:
                                11.5,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // PIN
            // --------------------------------------------------

            Center(
              child: Container(
                width: 86,
                height: 86,
                decoration:
                    BoxDecoration(
                  color: primaryColor
                      .withValues(
                    alpha: 0.13,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                alignment:
                    Alignment.center,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    shape:
                        BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black
                                .withValues(
                          alpha: 0.10,
                        ),
                        blurRadius: 12,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons
                        .location_on_rounded,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // BOTTOM
            // --------------------------------------------------

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  15,
                  11,
                  15,
                  11,
                ),
                color: Colors.white
                    .withValues(
                  alpha: 0.94,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons
                          .delivery_dining_rounded,
                      color:
                          primaryColor,
                      size: 21,
                    ),
                    SizedBox(
                      width: 9,
                    ),
                    Expanded(
                      child: Text(
                        'Find nearby stores and get faster delivery',
                        style:
                            TextStyle(
                          color:
                              subTextColor,
                          fontSize:
                              11.2,
                          fontWeight:
                              FontWeight
                                  .w600,
                          height: 1.25,
                        ),
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
  // DETECTED MAP
  // ============================================================

  Widget _buildDetectedMap() {
    final area =
        (_detectedArea?.isNotEmpty ??
                false)
            ? _detectedArea!
            : 'Your Location';

    final secondLine = [
      _detectedCity,
      _detectedState,
    ]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');

    return Container(
      width: double.infinity,

      // Compact compared with old 285.
      height: 250,

      decoration: BoxDecoration(
        color: softMint,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(21),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMapImage(),

            Positioned.fill(
              child: Container(
                color: Colors.white
                    .withValues(
                  alpha: 0.13,
                ),
              ),
            ),

            // --------------------------------------------------
            // DETECTED ADDRESS ON MAP
            // --------------------------------------------------

            Positioned(
              top: 15,
              left: 18,
              right: 18,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.96,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.07,
                      ),
                      blurRadius: 13,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration:
                          const BoxDecoration(
                        color: softMint,
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          const Icon(
                        Icons
                            .location_on_rounded,
                        color:
                            primaryColor,
                        size: 18,
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Your Location',
                            style:
                                TextStyle(
                              color:
                                  textColor,
                              fontSize:
                                  12,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            secondLine
                                    .isEmpty
                                ? area
                                : '$area, $secondLine',
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  subTextColor,
                              fontSize:
                                  10.5,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              height:
                                  1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --------------------------------------------------
            // CENTER PIN
            // --------------------------------------------------

            Center(
              child: Stack(
                alignment:
                    Alignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration:
                        BoxDecoration(
                      color: primaryColor
                          .withValues(
                        alpha: 0.14,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                  ),

                  const Icon(
                    Icons
                        .location_on_rounded,
                    color: primaryColor,
                    size: 52,
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // RE-DETECT BUTTON
            // --------------------------------------------------

            Positioned(
              right: 14,
              bottom: 14,
              child: Material(
                color:
                    Colors.transparent,
                child: InkWell(
                  onTap: _isLoading
                      ? null
                      : _useCurrentLocation,
                  customBorder:
                      const CircleBorder(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      shape:
                          BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black
                                  .withValues(
                            alpha: 0.09,
                          ),
                          blurRadius:
                              13,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons
                          .my_location_rounded,
                      color: darkGreen,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAP IMAGE
  // ============================================================

  Widget _buildMapImage() {
    return Image.network(
      locationImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          color: softMint,
          child: const Center(
            child: Icon(
              Icons.map_rounded,
              color: primaryColor,
              size: 70,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETECTED ADDRESS CARD
  // ============================================================

  Widget _buildDetectedAddressCard() {
    final title = [
      _detectedArea,
      _detectedCity,
    ]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');

    final subtitle = [
      _detectedState,
      _detectedPostalCode,
    ]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' ');

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.025,
            ),
            blurRadius: 12,
            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                const BoxDecoration(
              color: softMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_outlined,
              color: primaryColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title.isEmpty
                      ? 'Detected Address'
                      : title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle.isEmpty
                      ? (_detectedAddress ??
                          'Current location')
                      : subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        subTextColor,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          TextButton.icon(
            onPressed: _editAddress,
            style: TextButton.styleFrom(
              foregroundColor: darkGreen,
              backgroundColor: softMint,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  13,
                ),
              ),
            ),
            icon: const Icon(
              Icons.edit_outlined,
              size: 16,
            ),
            label: const Text(
              'Edit',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MANUAL ADDRESS
  // ============================================================

  Widget _buildAddressTextField() {
    return TextField(
      controller:
          _addressController,
      keyboardType:
          TextInputType.streetAddress,
      textCapitalization:
          TextCapitalization.sentences,
      minLines: 2,
      maxLines: 4,
      style: const TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      decoration: InputDecoration(
        hintText:
            'Search area, street or landmark...',
        hintStyle:
            const TextStyle(
          color: Color(0xFF9AA7A5),
          fontSize: 12.5,
          fontWeight:
              FontWeight.w500,
          height: 1.35,
        ),
        prefixIcon:
            const Icon(
          Icons.home_outlined,
          color: primaryColor,
          size: 21,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              const BorderSide(
            color: primaryColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LANDMARK
  // ============================================================

  Widget _buildLandmarkField() {
    return TextField(
      controller:
          _landmarkController,
      textCapitalization:
          TextCapitalization.sentences,
      textInputAction:
          TextInputAction.done,
      onSubmitted: (_) {
        FocusScope.of(context)
            .unfocus();
      },
      style: const TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText:
            'Flat no., landmark, society name...',
        hintStyle:
            const TextStyle(
          color: Color(0xFF9AA7A5),
          fontSize: 12.5,
          fontWeight:
              FontWeight.w500,
        ),
        prefixIcon:
            const Icon(
          Icons.apartment_rounded,
          color: primaryColor,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color: primaryColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADDRESS TYPE
  // ============================================================

  Widget _buildAddressTypeSelector() {
    return Row(
      children: [
        Expanded(
          child:
              _addressTypeButton(
            type: 'Home',
            icon:
                Icons.home_outlined,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child:
              _addressTypeButton(
            type: 'Work',
            icon: Icons
                .work_outline_rounded,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child:
              _addressTypeButton(
            type: 'Other',
            icon: Icons
                .location_on_outlined,
          ),
        ),
      ],
    );
  }

  Widget _addressTypeButton({
    required String type,
    required IconData icon,
  }) {
    final bool selected =
        _selectedAddressType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAddressType =
              type;
        });
      },
      borderRadius:
          BorderRadius.circular(16),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),

        // More compact.
        height: 56,

        decoration: BoxDecoration(
          color: selected
              ? softMint
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: selected
                ? primaryColor
                : borderColor,
            width:
                selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? primaryColor
                  : const Color(
                      0xFF748681,
                    ),
              size: 20,
            ),

            const SizedBox(width: 6),

            Flexible(
              child: Text(
                type,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style: TextStyle(
                  color: selected
                      ? darkGreen
                      : const Color(
                          0xFF748681,
                        ),
                  fontSize: 12,
                  fontWeight:
                      selected
                          ? FontWeight
                              .w800
                          : FontWeight
                              .w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton({
    bool outlined = false,
  }) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _isLoading
              ? null
              : _saveAndContinue,
          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                darkGreen,
            backgroundColor:
                softMint2,
            side: const BorderSide(
              color:
                  Color(0xFFB7DDD8),
              width: 1.3,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                Icons
                    .location_on_outlined,
                color: primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Save & Continue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons
                    .arrow_forward_rounded,
                size: 19,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _saveAndContinue,
        style:
            ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              primaryColor,
          disabledBackgroundColor:
              primaryColor.withValues(
            alpha: 0.55,
          ),
          foregroundColor:
              Colors.white,
          shadowColor:
              Colors.transparent,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Text(
                    'Save & Continue',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 21,
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String text,
  ) {
    return Text(
      text,
      style: const TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDividerText(
    String text,
  ) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: borderColor,
            thickness: 1,
          ),
        ),

        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 12,
          ),
          child: Text(
            text,
            style:
                const TextStyle(
              color: subTextColor,
              fontSize: 11.5,
              fontWeight:
                  FontWeight.w500,
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
}