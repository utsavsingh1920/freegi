import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartStore {
  CartStore._();

  static const String _storageKey = 'freegi_cart_items';

  // ============================================================
  // CART ITEMS
  // ============================================================

  static final ValueNotifier<List<Map<String, dynamic>>> cartItems =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // ============================================================
  // LOAD CART
  // ============================================================

  static Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? savedCart = prefs.getString(_storageKey);

      if (savedCart == null || savedCart.isEmpty) {
        cartItems.value = [];
        return;
      }

      final dynamic decoded = jsonDecode(savedCart);

      if (decoded is! List) {
        cartItems.value = [];
        return;
      }

      final List<Map<String, dynamic>> loadedItems = [];

      for (final item in decoded) {
        if (item is Map) {
          loadedItems.add(
            Map<String, dynamic>.from(item),
          );
        }
      }

      cartItems.value = loadedItems;
    } catch (e) {
      debugPrint('Cart load error: $e');
      cartItems.value = [];
    }
  }

  // ============================================================
  // SAVE CART
  // ============================================================

  static Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String encoded = jsonEncode(
        cartItems.value,
      );

      await prefs.setString(
        _storageKey,
        encoded,
      );
    } catch (e) {
      debugPrint('Cart save error: $e');
    }
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  static void addProduct(
    Map<String, dynamic> product, {
    int quantity = 1,
  }) {
    if (quantity <= 0) {
      return;
    }

    final List<Map<String, dynamic>> updated =
        cartItems.value
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    final String name =
        product['name']?.toString().trim() ?? '';

    final String unit =
        product['unit']?.toString().trim() ?? '';

    if (name.isEmpty) {
      return;
    }

    final int existingIndex = updated.indexWhere(
      (item) =>
          item['name']?.toString().trim() == name &&
          item['unit']?.toString().trim() == unit,
    );

    if (existingIndex >= 0) {
      final int currentQuantity =
          _toInt(
            updated[existingIndex]['quantity'],
            fallback: 1,
          );

      updated[existingIndex]['quantity'] =
          currentQuantity + quantity;
    } else {
      updated.add({
        'name': name,
        'unit': unit,
        'price': _toInt(product['price']),
        'quantity': quantity,
        'image': product['image']?.toString() ?? '',
        'oldPrice': product['oldPrice'],
        'discount': product['discount'],
        'rating': product['rating'],
      });
    }

    cartItems.value = updated;

    _saveCart();
  }

  // ============================================================
  // INCREASE QUANTITY
  // ============================================================

  static void increaseQuantity(int index) {
    if (index < 0 || index >= cartItems.value.length) {
      return;
    }

    final List<Map<String, dynamic>> updated =
        cartItems.value
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    final int currentQuantity =
        _toInt(
          updated[index]['quantity'],
          fallback: 1,
        );

    updated[index]['quantity'] =
        currentQuantity + 1;

    cartItems.value = updated;

    _saveCart();
  }

  // ============================================================
  // DECREASE QUANTITY
  // ============================================================

  static void decreaseQuantity(int index) {
    if (index < 0 || index >= cartItems.value.length) {
      return;
    }

    final List<Map<String, dynamic>> updated =
        cartItems.value
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    final int currentQuantity =
        _toInt(
          updated[index]['quantity'],
          fallback: 1,
        );

    if (currentQuantity <= 1) {
      return;
    }

    updated[index]['quantity'] =
        currentQuantity - 1;

    cartItems.value = updated;

    _saveCart();
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  static void removeAt(int index) {
    if (index < 0 || index >= cartItems.value.length) {
      return;
    }

    final List<Map<String, dynamic>> updated =
        cartItems.value
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    updated.removeAt(index);

    cartItems.value = updated;

    _saveCart();
  }

  // ============================================================
  // REMOVE PRODUCT BY NAME + UNIT
  // ============================================================

  static void removeProduct(
    Map<String, dynamic> product,
  ) {
    final String name =
        product['name']?.toString().trim() ?? '';

    final String unit =
        product['unit']?.toString().trim() ?? '';

    final List<Map<String, dynamic>> updated =
        cartItems.value
            .where(
              (item) =>
                  !(item['name']?.toString().trim() ==
                          name &&
                      item['unit']
                              ?.toString()
                              .trim() ==
                          unit),
            )
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    cartItems.value = updated;

    _saveCart();
  }

  // ============================================================
  // CHECK PRODUCT
  // ============================================================

  static bool contains(
    Map<String, dynamic> product,
  ) {
    final String name =
        product['name']?.toString().trim() ?? '';

    final String unit =
        product['unit']?.toString().trim() ?? '';

    return cartItems.value.any(
      (item) =>
          item['name']?.toString().trim() == name &&
          item['unit']?.toString().trim() == unit,
    );
  }

  // ============================================================
  // PRODUCT QUANTITY
  // ============================================================

  static int quantityOf(
    Map<String, dynamic> product,
  ) {
    final String name =
        product['name']?.toString().trim() ?? '';

    final String unit =
        product['unit']?.toString().trim() ?? '';

    final int index = cartItems.value.indexWhere(
      (item) =>
          item['name']?.toString().trim() == name &&
          item['unit']?.toString().trim() == unit,
    );

    if (index < 0) {
      return 0;
    }

    return _toInt(
      cartItems.value[index]['quantity'],
    );
  }

  // ============================================================
  // COUNTS
  // ============================================================

  static int get uniqueItemCount {
    return cartItems.value.length;
  }

  static int get totalQuantity {
    int total = 0;

    for (final item in cartItems.value) {
      total += _toInt(
        item['quantity'],
      );
    }

    return total;
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  static int get subtotal {
    int total = 0;

    for (final item in cartItems.value) {
      final int price =
          _toInt(item['price']);

      final int quantity =
          _toInt(item['quantity']);

      total += price * quantity;
    }

    return total;
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  static void clear() {
    cartItems.value = [];

    _saveCart();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toInt();
    }

    final String cleaned = value
        .toString()
        .replaceAll(
          RegExp(r'[^0-9.]'),
          '',
        );

    final double? parsed =
        double.tryParse(cleaned);

    return parsed?.toInt() ?? fallback;
  }
}