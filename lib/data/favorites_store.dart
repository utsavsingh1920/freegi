import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore {
  FavoritesStore._();

  // Old key is kept so existing saved favorites are not lost.
  static const String _oldStorageKey = 'freegi_favorites';

  // New key stores complete product information.
  static const String _productsStorageKey =
      'freegi_favorite_products';

  // ============================================================
  // COMPATIBILITY FAVORITE NAMES
  // ============================================================
  //
  // IMPORTANT:
  // Existing Home / Product Details code can continue listening
  // to FavoritesStore.favorites without any changes.

  static final ValueNotifier<Set<String>> favorites =
      ValueNotifier<Set<String>>(<String>{});

  // ============================================================
  // COMPLETE FAVORITE PRODUCTS
  // ============================================================

  static final ValueNotifier<List<Map<String, dynamic>>>
      favoriteProducts =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // ============================================================
  // LOAD FAVORITES
  // ============================================================

  static Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // --------------------------------------------------------
      // Load old saved names
      // --------------------------------------------------------

      final List<String> savedNames =
          prefs.getStringList(_oldStorageKey) ??
              <String>[];

      // --------------------------------------------------------
      // Load complete saved products
      // --------------------------------------------------------

      final String? savedProducts =
          prefs.getString(_productsStorageKey);

      final List<Map<String, dynamic>> loadedProducts =
          <Map<String, dynamic>>[];

      if (savedProducts != null &&
          savedProducts.isNotEmpty) {
        final dynamic decoded =
            jsonDecode(savedProducts);

        if (decoded is List) {
          for (final dynamic item in decoded) {
            if (item is Map) {
              loadedProducts.add(
                Map<String, dynamic>.from(item),
              );
            }
          }
        }
      }

      favoriteProducts.value = loadedProducts;

      // --------------------------------------------------------
      // Build names from both old + new data
      // --------------------------------------------------------

      final Set<String> allNames =
          savedNames
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .toSet();

      for (final product in loadedProducts) {
        final String productName =
            key(product);

        if (productName.isNotEmpty) {
          allNames.add(productName);
        }
      }

      favorites.value = allNames;

      await _saveNames();
    } catch (e) {
      debugPrint(
        'Favorites load error: $e',
      );

      favorites.value = <String>{};
      favoriteProducts.value =
          <Map<String, dynamic>>[];
    }
  }

  // ============================================================
  // PRODUCT KEY
  // ============================================================

  static String key(
    Map<String, dynamic> product,
  ) {
    return product['name']
            ?.toString()
            .trim() ??
        '';
  }

  // ============================================================
  // CHECK FAVORITE
  // ============================================================

  static bool contains(
    Map<String, dynamic> product,
  ) {
    return favorites.value.contains(
      key(product),
    );
  }

  static bool containsName(
    String productName,
  ) {
    return favorites.value.contains(
      productName.trim(),
    );
  }

  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================

  static void toggle(
    Map<String, dynamic> product,
  ) {
    final String productKey =
        key(product);

    if (productKey.isEmpty) {
      return;
    }

    if (contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  // ============================================================
  // ADD FAVORITE
  // ============================================================

  static void add(
    Map<String, dynamic> product,
  ) {
    final String productKey =
        key(product);

    if (productKey.isEmpty) {
      return;
    }

    // --------------------------------------------------------
    // Update favorite names
    // --------------------------------------------------------

    final Set<String> updatedNames =
        Set<String>.from(
      favorites.value,
    );

    updatedNames.add(productKey);

    favorites.value = updatedNames;

    // --------------------------------------------------------
    // Update complete products
    // --------------------------------------------------------

    final List<Map<String, dynamic>>
        updatedProducts =
        favoriteProducts.value
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item,
              ),
            )
            .toList();

    final int existingIndex =
        updatedProducts.indexWhere(
      (item) =>
          key(item) == productKey,
    );

    final Map<String, dynamic>
        completeProduct =
        _normalizeProduct(product);

    if (existingIndex >= 0) {
      updatedProducts[existingIndex] =
          completeProduct;
    } else {
      updatedProducts.add(
        completeProduct,
      );
    }

    favoriteProducts.value =
        updatedProducts;

    _saveAll();
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  static void remove(
    Map<String, dynamic> product,
  ) {
    removeByName(
      key(product),
    );
  }

  // ============================================================
  // REMOVE FAVORITE BY NAME
  // ============================================================

  static void removeByName(
    String productName,
  ) {
    final String cleanedName =
        productName.trim();

    if (cleanedName.isEmpty) {
      return;
    }

    final Set<String> updatedNames =
        Set<String>.from(
      favorites.value,
    );

    updatedNames.remove(
      cleanedName,
    );

    favorites.value =
        updatedNames;

    final List<Map<String, dynamic>>
        updatedProducts =
        favoriteProducts.value
            .where(
              (product) =>
                  key(product) !=
                  cleanedName,
            )
            .map(
              (product) =>
                  Map<String, dynamic>.from(
                product,
              ),
            )
            .toList();

    favoriteProducts.value =
        updatedProducts;

    _saveAll();
  }

  // ============================================================
  // GET PRODUCT BY NAME
  // ============================================================

  static Map<String, dynamic>?
      productByName(
    String productName,
  ) {
    final String cleanedName =
        productName.trim();

    for (final product
        in favoriteProducts.value) {
      if (key(product) ==
          cleanedName) {
        return Map<String, dynamic>.from(
          product,
        );
      }
    }

    return null;
  }

  // ============================================================
  // COUNT
  // ============================================================

  static int get count =>
      favorites.value.length;

  static bool get isEmpty =>
      favorites.value.isEmpty;

  static bool get isNotEmpty =>
      favorites.value.isNotEmpty;

  // ============================================================
  // CLEAR FAVORITES
  // ============================================================

  static void clear() {
    favorites.value =
        <String>{};

    favoriteProducts.value =
        <Map<String, dynamic>>[];

    _saveAll();
  }

  // ============================================================
  // NORMALIZE PRODUCT
  // ============================================================

  static Map<String, dynamic>
      _normalizeProduct(
    Map<String, dynamic> product,
  ) {
    return <String, dynamic>{
      'name':
          product['name']?.toString() ??
              '',
      'unit':
          product['unit']?.toString() ??
              '',
      'price':
          _jsonSafeValue(
        product['price'],
      ),
      'image':
          product['image']?.toString() ??
              '',
      'oldPrice':
          _jsonSafeValue(
        product['oldPrice'],
      ),
      'discount':
          _jsonSafeValue(
        product['discount'],
      ),
      'rating':
          _jsonSafeValue(
        product['rating'],
      ),
    };
  }

  // ============================================================
  // JSON SAFE VALUE
  // ============================================================

  static dynamic _jsonSafeValue(
    dynamic value,
  ) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool) {
      return value;
    }

    return value.toString();
  }

  // ============================================================
  // SAVE EVERYTHING
  // ============================================================

  static Future<void> _saveAll() async {
    await _saveNames();
    await _saveProducts();
  }

  // ============================================================
  // SAVE NAMES
  // ============================================================

  static Future<void> _saveNames() async {
    try {
      final prefs =
          await SharedPreferences
              .getInstance();

      await prefs.setStringList(
        _oldStorageKey,
        favorites.value.toList(),
      );
    } catch (e) {
      debugPrint(
        'Favorite names save error: $e',
      );
    }
  }

  // ============================================================
  // SAVE COMPLETE PRODUCTS
  // ============================================================

  static Future<void>
      _saveProducts() async {
    try {
      final prefs =
          await SharedPreferences
              .getInstance();

      final String encoded =
          jsonEncode(
        favoriteProducts.value,
      );

      await prefs.setString(
        _productsStorageKey,
        encoded,
      );
    } catch (e) {
      debugPrint(
        'Favorite products save error: $e',
      );
    }
  }
}