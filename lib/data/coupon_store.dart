import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponStore {
  CouponStore._();

  // ============================================================
  // STORAGE
  // ============================================================

  static const String _selectedCouponKey =
      'freegi_selected_coupon';

  // ============================================================
  // SELECTED COUPON
  // ============================================================

  static final ValueNotifier<Map<String, dynamic>?> selectedCoupon =
      ValueNotifier<Map<String, dynamic>?>(null);

  // ============================================================
  // ALL FREEGI COUPONS
  // ============================================================

  static const List<Map<String, dynamic>> coupons = [
    {
      'id': 'freegi50',
      'code': 'FREEGI50',
      'title': '₹50 OFF',
      'description': 'Save ₹50 on your grocery order.',
      'type': 'flat',
      'value': 50,
      'minOrder': 399,
      'maxDiscount': 50,
      'isActive': true,
    },
    {
      'id': 'fresh20',
      'code': 'FRESH20',
      'title': '20% OFF',
      'description': 'Get 20% off on eligible grocery orders.',
      'type': 'percentage',
      'value': 20,
      'minOrder': 499,
      'maxDiscount': 100,
      'isActive': true,
    },
    {
      'id': 'welcome100',
      'code': 'WELCOME100',
      'title': '₹100 OFF',
      'description': 'Special welcome offer from Freegi.',
      'type': 'flat',
      'value': 100,
      'minOrder': 699,
      'maxDiscount': 100,
      'isActive': true,
    },
    {
      'id': 'freedel',
      'code': 'FREEDEL',
      'title': 'Free Delivery',
      'description': 'Get free delivery on eligible orders.',
      'type': 'free_delivery',
      'value': 0,
      'minOrder': 299,
      'maxDiscount': 0,
      'isActive': true,
    },
  ];

  // ============================================================
  // LOAD SAVED COUPON
  // ============================================================

  static Future<void> loadCoupon() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCoupon =
        prefs.getString(_selectedCouponKey);

    if (savedCoupon == null ||
        savedCoupon.trim().isEmpty) {
      selectedCoupon.value = null;
      return;
    }

    try {
      final decoded = jsonDecode(savedCoupon);

      if (decoded is Map) {
        final coupon =
            Map<String, dynamic>.from(decoded);

        final code =
            coupon['code']?.toString() ?? '';

        final currentCoupon = findByCode(code);

        if (currentCoupon != null &&
            currentCoupon['isActive'] == true) {
          selectedCoupon.value =
              Map<String, dynamic>.from(
            currentCoupon,
          );
        } else {
          selectedCoupon.value = null;
          await prefs.remove(_selectedCouponKey);
        }
      }
    } catch (_) {
      selectedCoupon.value = null;
      await prefs.remove(_selectedCouponKey);
    }
  }

  // ============================================================
  // FIND COUPON
  // ============================================================

  static Map<String, dynamic>? findByCode(
    String code,
  ) {
    final normalized =
        code.trim().toUpperCase();

    for (final coupon in coupons) {
      final couponCode =
          coupon['code']?.toString().toUpperCase();

      if (couponCode == normalized) {
        return Map<String, dynamic>.from(
          coupon,
        );
      }
    }

    return null;
  }

  // ============================================================
  // APPLY / SELECT COUPON
  // ============================================================

  static Future<void> selectCoupon(
    Map<String, dynamic> coupon,
  ) async {
    final code =
        coupon['code']?.toString() ?? '';

    final realCoupon = findByCode(code);

    if (realCoupon == null ||
        realCoupon['isActive'] != true) {
      return;
    }

    selectedCoupon.value =
        Map<String, dynamic>.from(
      realCoupon,
    );

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _selectedCouponKey,
      jsonEncode(realCoupon),
    );
  }

  // ============================================================
  // APPLY BY CODE
  // ============================================================

  static Future<bool> selectCouponByCode(
    String code,
  ) async {
    final coupon = findByCode(code);

    if (coupon == null ||
        coupon['isActive'] != true) {
      return false;
    }

    await selectCoupon(coupon);

    return true;
  }

  // ============================================================
  // REMOVE COUPON
  // ============================================================

  static Future<void> clearSelectedCoupon() async {
    selectedCoupon.value = null;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _selectedCouponKey,
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  static String? validationMessage({
    required Map<String, dynamic> coupon,
    required int itemTotal,
  }) {
    if (coupon['isActive'] != true) {
      return 'This coupon is currently unavailable.';
    }

    final minOrder =
        _toInt(coupon['minOrder']);

    if (itemTotal < minOrder) {
      final remaining =
          minOrder - itemTotal;

      return 'Add ₹$remaining more to use ${coupon['code']}.';
    }

    return null;
  }

  static bool isValidForAmount({
    required Map<String, dynamic> coupon,
    required int itemTotal,
  }) {
    return validationMessage(
          coupon: coupon,
          itemTotal: itemTotal,
        ) ==
        null;
  }

  // ============================================================
  // CALCULATE DISCOUNT
  // ============================================================

  static int calculateDiscount({
    required Map<String, dynamic> coupon,
    required int itemTotal,
  }) {
    if (!isValidForAmount(
      coupon: coupon,
      itemTotal: itemTotal,
    )) {
      return 0;
    }

    final type =
        coupon['type']?.toString() ?? '';

    final value =
        _toInt(coupon['value']);

    final maxDiscount =
        _toInt(coupon['maxDiscount']);

    if (type == 'flat') {
      return value > itemTotal
          ? itemTotal
          : value;
    }

    if (type == 'percentage') {
      int discount =
          ((itemTotal * value) / 100).round();

      if (maxDiscount > 0 &&
          discount > maxDiscount) {
        discount = maxDiscount;
      }

      if (discount > itemTotal) {
        discount = itemTotal;
      }

      return discount;
    }

    // Free-delivery coupon does not reduce item price.
    // Delivery fee will be handled separately in Checkout.
    if (type == 'free_delivery') {
      return 0;
    }

    return 0;
  }

  // ============================================================
  // DELIVERY DISCOUNT
  // ============================================================

  static int calculateDeliveryFee({
    required Map<String, dynamic>? coupon,
    required int itemTotal,
    required int normalDeliveryFee,
  }) {
    if (coupon == null) {
      return normalDeliveryFee;
    }

    if (!isValidForAmount(
      coupon: coupon,
      itemTotal: itemTotal,
    )) {
      return normalDeliveryFee;
    }

    if (coupon['type'] == 'free_delivery') {
      return 0;
    }

    return normalDeliveryFee;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static bool get hasSelectedCoupon =>
      selectedCoupon.value != null;

  static String get selectedCode =>
      selectedCoupon.value?['code']
          ?.toString() ??
      '';

  static int get availableCouponCount {
    return coupons
        .where(
          (coupon) =>
              coupon['isActive'] == true,
        )
        .length;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}