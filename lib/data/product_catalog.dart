// lib/data/product_catalog.dart
//
// Freegi single source of truth for product data.
// UI code does NOT belong in this file.
//
// Stable identity rule:
//   id is unique for every sellable variant.
//   Same name with a different unit/pack size = different product.

class ProductCatalog {
  ProductCatalog._();

  // ============================================================
  // PUBLIC API
  // ============================================================

  static List<Map<String, dynamic>> productsForCategory(String category) {
    switch (category) {
      case 'Vegetables':
        return _copyList(_vegetables);
      case 'Fruits':
        return _copyList(_fruits);
      case 'Dairy':
      case 'Dairy & Eggs':
        return _copyList(_dairy);
      case 'Bakery':
        return _copyList(_bakery);
      case 'Beverages':
        return _copyList(_beverages);
      case 'Snacks':
        return _copyList(_snacks);
      default:
        return _generatedCategoryProducts(category);
    }
  }

  static List<Map<String, dynamic>> get allProducts {
    final all = <Map<String, dynamic>>[
      ..._vegetables,
      ..._fruits,
      ..._dairy,
      ..._bakery,
      ..._beverages,
      ..._snacks,
      ..._homeOnlyProducts,
    ];

    for (final category in _generatedCatalog.keys) {
      all.addAll(_generatedCategoryProducts(category));
    }

    final unique = <String, Map<String, dynamic>>{};
    for (final product in all) {
      unique[product['id'].toString()] = product;
    }
    return _copyList(unique.values.toList());
  }

  static Map<String, dynamic>? byId(String id) {
    for (final product in allProducts) {
      if (product['id'] == id) {
        return Map<String, dynamic>.from(product);
      }
    }
    return null;
  }

  static String productId(Map<String, dynamic> product) {
    final existing = product['id']?.toString().trim() ?? '';
    if (existing.isNotEmpty) return existing;

    final name = product['name']?.toString() ?? '';
    final unit = product['unit']?.toString() ?? '';
    return _slug('$name-$unit');
  }

  static bool sameProduct(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    return productId(a) == productId(b);
  }

  // ============================================================
  // HOME SECTIONS
  // These return catalog products, not duplicate product maps.
  // ============================================================

  static List<Map<String, dynamic>> get homePopularProducts => _byIds([
        'fruit-fresh-red-apple-1-kg',
        'home-fresh-tomato-500-g',
        'vegetable-red-onion-1-kg',
        'vegetable-fresh-potato-1-kg',
        'home-fresh-banana-6-pcs',
        'dairy-fresh-milk-1-litre',
        'home-sweet-orange-1-kg',
      ]);

  static List<Map<String, dynamic>> get homeDailyEssentials => _byIds([
        'home-fresh-tomato-500-g',
        'vegetable-red-onion-1-kg',
        'vegetable-fresh-potato-1-kg',
        'bakery-brown-bread-400-g',
        'home-fresh-eggs-6-pcs',
        'beverage-orange-juice-1-litre',
        'home-fresh-milk-500-ml',
      ]);

  static List<Map<String, dynamic>> get homeTopPicks => _byIds([
        'home-green-vegetables-1-pack',
        'home-premium-apples-4-pcs',
        'home-fresh-bread-400-g',
        'home-farm-eggs-12-pcs',
        'fruit-fresh-orange-1-kg',
      ]);

  static List<Map<String, dynamic>> get homeBreakfastProducts => _byIds([
        'bakery-whole-wheat-bread-400-g',
        'home-fresh-eggs-12-pcs',
        'home-full-cream-milk-1-litre',
        'beverage-orange-juice-1-litre',
        'home-banana-6-pcs',
      ]);

  // ============================================================
  // VEGETABLES
  // ============================================================

  static const List<Map<String, dynamic>> _vegetables = [
    {
      'id': 'vegetable-fresh-tomato-1-kg',
      'name': 'Fresh Tomato',
      'category': 'Vegetables',
      'filter': 'Tomato',
      'unit': '1 kg',
      'price': 28,
      'oldPrice': 35,
      'rating': 4.8,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=85',
    },
    {
      'id': 'vegetable-red-onion-1-kg',
      'name': 'Red Onion',
      'category': 'Vegetables',
      'filter': 'Onion',
      'unit': '1 kg',
      'price': 34,
      'oldPrice': 42,
      'rating': 4.7,
      'discount': '19% OFF',
      'image':
          'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&w=600&q=85',
    },
    {
      'id': 'vegetable-fresh-potato-1-kg',
      'name': 'Fresh Potato',
      'category': 'Vegetables',
      'filter': 'Potato',
      'unit': '1 kg',
      'price': 32,
      'oldPrice': 40,
      'rating': 4.8,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-fresh-carrot-500-g',
      'name': 'Fresh Carrot',
      'category': 'Vegetables',
      'filter': 'Root',
      'unit': '500 g',
      'price': 42,
      'oldPrice': 50,
      'rating': 4.6,
      'discount': '16% OFF',
      'image':
          'https://images.unsplash.com/photo-1447175008436-054170c2e979?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-green-capsicum-500-g',
      'name': 'Green Capsicum',
      'category': 'Vegetables',
      'filter': 'Green',
      'unit': '500 g',
      'price': 60,
      'oldPrice': 72,
      'rating': 4.7,
      'discount': '17% OFF',
      'image':
          'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-fresh-broccoli-500-g',
      'name': 'Fresh Broccoli',
      'category': 'Vegetables',
      'filter': 'Green',
      'unit': '500 g',
      'price': 80,
      'oldPrice': 95,
      'rating': 4.9,
      'discount': '16% OFF',
      'image':
          'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-fresh-spinach-1-bunch',
      'name': 'Fresh Spinach',
      'category': 'Vegetables',
      'filter': 'Leafy',
      'unit': '1 bunch',
      'price': 30,
      'oldPrice': 38,
      'rating': 4.7,
      'discount': '21% OFF',
      'image':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-fresh-cabbage-1-pc',
      'name': 'Fresh Cabbage',
      'category': 'Vegetables',
      'filter': 'Leafy',
      'unit': '1 pc',
      'price': 36,
      'oldPrice': 45,
      'rating': 4.6,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1557844352-761f2565b576?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-green-beans-500-g',
      'name': 'Green Beans',
      'category': 'Vegetables',
      'filter': 'Green',
      'unit': '500 g',
      'price': 55,
      'oldPrice': 68,
      'rating': 4.5,
      'discount': '19% OFF',
      'image':
          'https://images.unsplash.com/photo-1567375698348-5d9d5ae99de0?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'vegetable-fresh-beetroot-500-g',
      'name': 'Fresh Beetroot',
      'category': 'Vegetables',
      'filter': 'Root',
      'unit': '500 g',
      'price': 48,
      'oldPrice': 60,
      'rating': 4.6,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1593105544559-ecb03bf76f82?auto=format&fit=crop&w=500&q=85',
    },
  ];

  // ============================================================
  // FRUITS
  // ============================================================

  static const List<Map<String, dynamic>> _fruits = [
    {
      'id': 'fruit-fresh-red-apple-1-kg',
      'name': 'Fresh Red Apple',
      'category': 'Fruits',
      'filter': 'Apple',
      'unit': '1 kg',
      'price': 140,
      'oldPrice': 175,
      'rating': 4.8,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-fresh-banana-1-kg',
      'name': 'Fresh Banana',
      'category': 'Fruits',
      'filter': 'Banana',
      'unit': '1 kg',
      'price': 60,
      'oldPrice': 75,
      'rating': 4.7,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-fresh-orange-1-kg',
      'name': 'Fresh Orange',
      'category': 'Fruits',
      'filter': 'Citrus',
      'unit': '1 kg',
      'price': 120,
      'oldPrice': 145,
      'rating': 4.6,
      'discount': '17% OFF',
      'image':
          'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-green-grapes-500-g',
      'name': 'Green Grapes',
      'category': 'Fruits',
      'filter': 'Grapes',
      'unit': '500 g',
      'price': 90,
      'oldPrice': 110,
      'rating': 4.5,
      'discount': '18% OFF',
      'image':
          'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-fresh-mango-1-kg',
      'name': 'Fresh Mango',
      'category': 'Fruits',
      'filter': 'Mango',
      'unit': '1 kg',
      'price': 180,
      'oldPrice': 220,
      'rating': 4.9,
      'discount': '18% OFF',
      'image':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-fresh-strawberry-250-g',
      'name': 'Fresh Strawberry',
      'category': 'Fruits',
      'filter': 'Seasonal',
      'unit': '250 g',
      'price': 150,
      'oldPrice': 185,
      'rating': 4.7,
      'discount': '19% OFF',
      'image':
          'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-watermelon-1-pc',
      'name': 'Watermelon',
      'category': 'Fruits',
      'filter': 'Seasonal',
      'unit': '1 pc',
      'price': 85,
      'oldPrice': 100,
      'rating': 4.7,
      'discount': '15% OFF',
      'image':
          'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'fruit-pomegranate-500-g',
      'name': 'Pomegranate',
      'category': 'Fruits',
      'filter': 'Seasonal',
      'unit': '500 g',
      'price': 125,
      'oldPrice': 150,
      'rating': 4.8,
      'discount': '17% OFF',
      'image':
          'https://images.unsplash.com/photo-1541344999736-83eca272f6fc?auto=format&fit=crop&w=500&q=85',
    },
  ];

  // ============================================================
  // DAIRY
  // ============================================================

  static const List<Map<String, dynamic>> _dairy = [
    {
      'id': 'dairy-fresh-milk-1-litre',
      'name': 'Fresh Milk',
      'category': 'Dairy',
      'filter': 'Milk',
      'unit': '1 litre',
      'price': 62,
      'oldPrice': 68,
      'rating': 4.8,
      'discount': '9% OFF',
      'image':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'dairy-fresh-curd-400-g',
      'name': 'Fresh Curd',
      'category': 'Dairy',
      'filter': 'Curd',
      'unit': '400 g',
      'price': 55,
      'oldPrice': 62,
      'rating': 4.7,
      'discount': '11% OFF',
      'image':
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'dairy-fresh-paneer-200-g',
      'name': 'Fresh Paneer',
      'category': 'Dairy',
      'filter': 'Paneer',
      'unit': '200 g',
      'price': 95,
      'oldPrice': 110,
      'rating': 4.8,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'dairy-farm-eggs-6-pcs',
      'name': 'Farm Eggs',
      'category': 'Dairy',
      'filter': 'Eggs',
      'unit': '6 pcs',
      'price': 72,
      'oldPrice': 80,
      'rating': 4.7,
      'discount': '10% OFF',
      'image':
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'dairy-butter-100-g',
      'name': 'Butter',
      'category': 'Dairy',
      'filter': 'Butter',
      'unit': '100 g',
      'price': 58,
      'oldPrice': 65,
      'rating': 4.6,
      'discount': '11% OFF',
      'image':
          'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'dairy-cheese-slices-200-g',
      'name': 'Cheese Slices',
      'category': 'Dairy',
      'filter': 'Cheese',
      'unit': '200 g',
      'price': 125,
      'oldPrice': 145,
      'rating': 4.7,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=500&q=85',
    },
  ];

  // ============================================================
  // BAKERY
  // ============================================================

  static const List<Map<String, dynamic>> _bakery = [
    {
      'id': 'bakery-brown-bread-400-g',
      'name': 'Brown Bread',
      'category': 'Bakery',
      'filter': 'Bread',
      'unit': '400 g',
      'price': 48,
      'oldPrice': 55,
      'rating': 4.7,
      'discount': '13% OFF',
      'image':
          'https://loremflickr.com/600/600/brown,bread,bakery?lock=11001',
    },
    {
      'id': 'bakery-whole-wheat-bread-400-g',
      'name': 'Whole Wheat Bread',
      'category': 'Bakery',
      'filter': 'Bread',
      'unit': '400 g',
      'price': 52,
      'oldPrice': 60,
      'rating': 4.8,
      'discount': '13% OFF',
      'image':
          'https://loremflickr.com/600/600/whole,wheat,bread?lock=11002',
    },
    {
      'id': 'bakery-fresh-buns-4-pcs',
      'name': 'Fresh Buns',
      'category': 'Bakery',
      'filter': 'Buns',
      'unit': '4 pcs',
      'price': 45,
      'oldPrice': 52,
      'rating': 4.6,
      'discount': '13% OFF',
      'image':
          'https://loremflickr.com/600/600/fresh,buns,bakery?lock=11003',
    },
    {
      'id': 'bakery-chocolate-cake-500-g',
      'name': 'Chocolate Cake',
      'category': 'Bakery',
      'filter': 'Cakes',
      'unit': '500 g',
      'price': 299,
      'oldPrice': 349,
      'rating': 4.8,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'bakery-butter-cookies-200-g',
      'name': 'Butter Cookies',
      'category': 'Bakery',
      'filter': 'Cookies',
      'unit': '200 g',
      'price': 85,
      'oldPrice': 99,
      'rating': 4.7,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'bakery-crispy-rusk-300-g',
      'name': 'Crispy Rusk',
      'category': 'Bakery',
      'filter': 'Rusk',
      'unit': '300 g',
      'price': 75,
      'oldPrice': 88,
      'rating': 4.6,
      'discount': '15% OFF',
      'image':
          'https://loremflickr.com/600/600/crispy,rusk,bakery?lock=11004',
    },
  ];

  // ============================================================
  // BEVERAGES
  // ============================================================

  static const List<Map<String, dynamic>> _beverages = [
    {
      'id': 'beverage-orange-juice-1-litre',
      'name': 'Orange Juice',
      'category': 'Beverages',
      'filter': 'Juice',
      'unit': '1 litre',
      'price': 110,
      'oldPrice': 130,
      'rating': 4.7,
      'discount': '15% OFF',
      'image':
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'beverage-apple-juice-1-litre',
      'name': 'Apple Juice',
      'category': 'Beverages',
      'filter': 'Juice',
      'unit': '1 litre',
      'price': 115,
      'oldPrice': 135,
      'rating': 4.6,
      'discount': '15% OFF',
      'image':
          'https://loremflickr.com/600/600/apple,juice,drink?lock=12002',
    },
    {
      'id': 'beverage-premium-tea-250-g',
      'name': 'Premium Tea',
      'category': 'Beverages',
      'filter': 'Tea',
      'unit': '250 g',
      'price': 145,
      'oldPrice': 165,
      'rating': 4.8,
      'discount': '12% OFF',
      'image':
          'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'beverage-classic-coffee-100-g',
      'name': 'Classic Coffee',
      'category': 'Beverages',
      'filter': 'Coffee',
      'unit': '100 g',
      'price': 175,
      'oldPrice': 199,
      'rating': 4.8,
      'discount': '12% OFF',
      'image':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'beverage-soft-drink-750-ml',
      'name': 'Soft Drink',
      'category': 'Beverages',
      'filter': 'Soft Drinks',
      'unit': '750 ml',
      'price': 45,
      'oldPrice': 50,
      'rating': 4.5,
      'discount': '10% OFF',
      'image':
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'beverage-energy-drink-250-ml',
      'name': 'Energy Drink',
      'category': 'Beverages',
      'filter': 'Energy',
      'unit': '250 ml',
      'price': 99,
      'oldPrice': 115,
      'rating': 4.5,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?auto=format&fit=crop&w=500&q=85',
    },
  ];

  // ============================================================
  // SNACKS
  // ============================================================

  static const List<Map<String, dynamic>> _snacks = [
    {
      'id': 'snack-classic-potato-chips-100-g',
      'name': 'Classic Potato Chips',
      'category': 'Snacks',
      'filter': 'Chips',
      'unit': '100 g',
      'price': 40,
      'oldPrice': 50,
      'rating': 4.6,
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'snack-masala-namkeen-200-g',
      'name': 'Masala Namkeen',
      'category': 'Snacks',
      'filter': 'Namkeen',
      'unit': '200 g',
      'price': 65,
      'oldPrice': 75,
      'rating': 4.7,
      'discount': '13% OFF',
      'image':
          'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'snack-cream-biscuits-150-g',
      'name': 'Cream Biscuits',
      'category': 'Snacks',
      'filter': 'Biscuits',
      'unit': '150 g',
      'price': 35,
      'oldPrice': 40,
      'rating': 4.6,
      'discount': '13% OFF',
      'image':
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'snack-dark-chocolate-100-g',
      'name': 'Dark Chocolate',
      'category': 'Snacks',
      'filter': 'Chocolate',
      'unit': '100 g',
      'price': 120,
      'oldPrice': 140,
      'rating': 4.8,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1575377427642-087cf684f29d?auto=format&fit=crop&w=500&q=85',
    },
    {
      'id': 'snack-instant-noodles-280-g',
      'name': 'Instant Noodles',
      'category': 'Snacks',
      'filter': 'Noodles',
      'unit': '280 g',
      'price': 60,
      'oldPrice': 70,
      'rating': 4.7,
      'discount': '14% OFF',
      'image':
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=500&q=85',
    },
  ];

  // ============================================================
  // HOME-ONLY VARIANTS / CARDS
  // ============================================================

  static const List<Map<String, dynamic>> _homeOnlyProducts = [
    {
      'id': 'home-fresh-tomato-500-g',
      'name': 'Fresh Tomato',
      'category': 'Vegetables',
      'filter': 'Tomato',
      'unit': '500 g',
      'price': 42,
      'oldPrice': 55,
      'discount': '24% OFF',
      'rating': 4.6,
      'image':
          'https://images.unsplash.com/photo-1561136594-7f68413baa99?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-fresh-banana-6-pcs',
      'name': 'Fresh Banana',
      'category': 'Fruits',
      'filter': 'Banana',
      'unit': '6 pcs',
      'price': 60,
      'oldPrice': 75,
      'discount': '20% OFF',
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-sweet-orange-1-kg',
      'name': 'Sweet Orange',
      'category': 'Fruits',
      'filter': 'Citrus',
      'unit': '1 kg',
      'price': 105,
      'oldPrice': 130,
      'discount': '19% OFF',
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-fresh-eggs-6-pcs',
      'name': 'Fresh Eggs',
      'category': 'Dairy',
      'filter': 'Eggs',
      'unit': '6 pcs',
      'price': 72,
      'oldPrice': 80,
      'discount': '10% OFF',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-fresh-milk-500-ml',
      'name': 'Fresh Milk',
      'category': 'Dairy',
      'filter': 'Milk',
      'unit': '500 ml',
      'price': 32,
      'oldPrice': 36,
      'discount': '11% OFF',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-green-vegetables-1-pack',
      'name': 'Green Vegetables',
      'category': 'Vegetables',
      'filter': 'Green',
      'unit': '1 pack',
      'price': 89,
      'oldPrice': 110,
      'discount': '19% OFF',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-premium-apples-4-pcs',
      'name': 'Premium Apples',
      'category': 'Fruits',
      'filter': 'Apple',
      'unit': '4 pcs',
      'price': 120,
      'oldPrice': 150,
      'discount': '20% OFF',
      'rating': 4.9,
      'image':
          'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-fresh-bread-400-g',
      'name': 'Fresh Bread',
      'category': 'Bakery',
      'filter': 'Bread',
      'unit': '400 g',
      'price': 45,
      'oldPrice': 55,
      'discount': '18% OFF',
      'rating': 4.6,
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-farm-eggs-12-pcs',
      'name': 'Farm Eggs',
      'category': 'Dairy',
      'filter': 'Eggs',
      'unit': '12 pcs',
      'price': 135,
      'oldPrice': 155,
      'discount': '13% OFF',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-fresh-eggs-12-pcs',
      'name': 'Fresh Eggs',
      'category': 'Dairy',
      'filter': 'Eggs',
      'unit': '12 pcs',
      'price': 138,
      'oldPrice': 155,
      'discount': '11% OFF',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-full-cream-milk-1-litre',
      'name': 'Full Cream Milk',
      'category': 'Dairy',
      'filter': 'Milk',
      'unit': '1 litre',
      'price': 68,
      'oldPrice': 75,
      'discount': '9% OFF',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=700&q=90',
    },
    {
      'id': 'home-banana-6-pcs',
      'name': 'Banana',
      'category': 'Fruits',
      'filter': 'Banana',
      'unit': '6 pcs',
      'price': 60,
      'oldPrice': 75,
      'discount': '20% OFF',
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?auto=format&fit=crop&w=700&q=90',
    },
  ];

  // ============================================================
  // GENERATED CATEGORY CATALOG
  // ============================================================

  static const Map<String, Map<String, List<String>>> _generatedCatalog = {
    'Personal Care': {
      'Hair Care': ['Herbal Shampoo', 'Hair Conditioner', 'Hair Oil'],
      'Skin Care': ['Face Wash', 'Moisturizing Lotion', 'Aloe Vera Gel'],
      'Bath': ['Bathing Soap', 'Body Wash', 'Shower Gel'],
      'Oral Care': ['Fresh Toothpaste', 'Soft Toothbrush', 'Mouth Wash'],
    },
    'Household': {
      'Cleaning': ['Multi Surface Cleaner', 'Glass Cleaner', 'Cleaning Spray'],
      'Laundry': ['Laundry Detergent', 'Fabric Conditioner', 'Stain Remover'],
      'Kitchen': ['Kitchen Cleaner', 'Dishwash Liquid', 'Scrub Pads'],
      'Home Care': ['Air Freshener', 'Garbage Bags', 'Tissue Roll'],
    },
    'Atta, Rice & Dal': {
      'Atta': ['Whole Wheat Atta', 'Multigrain Atta', 'Premium Atta'],
      'Rice': ['Basmati Rice', 'Sona Masoori Rice', 'Brown Rice'],
      'Dal': ['Toor Dal', 'Moong Dal', 'Masoor Dal'],
      'Pulses': ['Kabuli Chana', 'Rajma', 'Black Chana'],
      'Flour': ['Besan Flour', 'Rice Flour', 'Maida'],
    },
    'Masala & Spices': {
      'Masala': ['Garam Masala', 'Chaat Masala', 'Kitchen King Masala'],
      'Spices': ['Turmeric Powder', 'Red Chilli Powder', 'Coriander Powder'],
      'Salt': ['Iodized Salt', 'Rock Salt', 'Pink Salt'],
      'Sugar': ['Fine Sugar', 'Brown Sugar', 'Mishri'],
      'Seasoning': ['Oregano Seasoning', 'Chilli Flakes', 'Mixed Herbs'],
    },
    'Instant Food': {
      'Noodles': ['Masala Noodles', 'Hakka Noodles', 'Cup Noodles'],
      'Pasta': ['Penne Pasta', 'Macaroni Pasta', 'Fusilli Pasta'],
      'Soup': ['Tomato Soup', 'Sweet Corn Soup', 'Hot & Sour Soup'],
      'Ready Meal': ['Veg Pulao', 'Dal Khichdi', 'Paneer Rice Bowl'],
    },
    'Baby Care': {
      'Diapers': ['Baby Diapers Small', 'Baby Diapers Medium', 'Baby Diapers Large'],
      'Baby Food': ['Baby Cereal', 'Fruit Puree', 'Baby Oats'],
      'Bath': ['Baby Soap', 'Baby Shampoo', 'Baby Body Wash'],
      'Skin Care': ['Baby Lotion', 'Baby Cream', 'Baby Powder'],
    },
    'Pet Care': {
      'Dog Food': ['Chicken Dog Food', 'Adult Dog Food', 'Puppy Food'],
      'Cat Food': ['Tuna Cat Food', 'Adult Cat Food', 'Kitten Food'],
      'Treats': ['Dog Treats', 'Cat Treats', 'Dental Treats'],
      'Care': ['Pet Shampoo', 'Pet Wipes', 'Pet Grooming Brush'],
    },
    'Organic': {
      'Fruits': ['Organic Apple', 'Organic Banana', 'Organic Orange'],
      'Vegetables': ['Organic Tomato', 'Organic Potato', 'Organic Spinach'],
      'Grains': ['Organic Brown Rice', 'Organic Quinoa', 'Organic Millet'],
      'Staples': ['Organic Atta', 'Organic Dal', 'Organic Jaggery'],
    },
    'Frozen Food': {
      'Veg': ['Frozen Green Peas', 'Frozen Sweet Corn', 'Frozen Mixed Veg'],
      'Snacks': ['Frozen Samosa', 'Frozen Spring Roll', 'Frozen French Fries'],
      'Desserts': ['Vanilla Ice Cream', 'Chocolate Ice Cream', 'Frozen Kulfi'],
      'Ready Meal': ['Frozen Paratha', 'Frozen Veg Biryani', 'Frozen Pasta'],
    },
    'Dry Fruits': {
      'Almond': ['California Almonds', 'Roasted Almonds', 'Premium Almonds'],
      'Cashew': ['Whole Cashews', 'Roasted Cashews', 'Premium Cashews'],
      'Raisin': ['Golden Raisins', 'Black Raisins', 'Seedless Raisins'],
      'Walnut': ['Walnut Kernels', 'Premium Walnuts', 'California Walnuts'],
    },
    'Breakfast': {
      'Cereal': ['Corn Flakes', 'Choco Cereal', 'Fruit Muesli'],
      'Oats': ['Rolled Oats', 'Masala Oats', 'Instant Oats'],
      'Bread': ['Brown Bread', 'Multigrain Bread', 'Milk Bread'],
      'Spread': ['Peanut Butter', 'Chocolate Spread', 'Mixed Fruit Jam'],
      'Eggs': ['Farm Eggs 6 pcs', 'Farm Eggs 12 pcs', 'Brown Eggs'],
    },
    'Tea & Coffee': {
      'Tea': ['Premium Tea', 'Assam Tea', 'Masala Tea'],
      'Coffee': ['Classic Coffee', 'Instant Coffee', 'Filter Coffee'],
      'Green Tea': ['Lemon Green Tea', 'Tulsi Green Tea', 'Honey Green Tea'],
      'Premix': ['Coffee Premix', 'Tea Premix', 'Masala Chai Premix'],
    },
    'Biscuits': {
      'Cookies': ['Butter Cookies', 'Choco Chip Cookies', 'Coconut Cookies'],
      'Cream': ['Chocolate Cream Biscuits', 'Vanilla Cream Biscuits', 'Orange Cream Biscuits'],
      'Digestive': ['Digestive Biscuits', 'Oats Digestive', 'Multigrain Digestive'],
      'Crackers': ['Salted Crackers', 'Jeera Crackers', 'Cheese Crackers'],
    },
    'Cooking Oil': {
      'Sunflower': ['Sunflower Oil 1L', 'Sunflower Oil 2L', 'Sunflower Oil 5L'],
      'Mustard': ['Mustard Oil 1L', 'Cold Pressed Mustard Oil', 'Mustard Oil 5L'],
      'Soybean': ['Soybean Oil 1L', 'Soybean Oil 2L', 'Soybean Oil 5L'],
      'Olive': ['Extra Virgin Olive Oil', 'Light Olive Oil', 'Olive Pomace Oil'],
    },
    'Cleaning': {
      'Floor': ['Floor Cleaner Lemon', 'Floor Cleaner Floral', 'Disinfectant Floor Cleaner'],
      'Dishwash': ['Dishwash Liquid', 'Dishwash Bar', 'Dishwasher Tablets'],
      'Bathroom': ['Bathroom Cleaner', 'Toilet Cleaner', 'Tile Cleaner'],
      'Laundry': ['Detergent Powder', 'Liquid Detergent', 'Fabric Softener'],
    },
    'Beauty': {
      'Face': ['Face Wash', 'Face Cream', 'Face Serum'],
      'Hair': ['Beauty Shampoo', 'Hair Serum', 'Hair Mask'],
      'Body': ['Body Lotion', 'Body Wash', 'Body Scrub'],
      'Makeup': ['Lipstick', 'Kajal', 'Compact Powder'],
    },
    'Health': {
      'Nutrition': ['Protein Drink', 'Health Drink', 'Nutrition Bar'],
      'Wellness': ['Herbal Tea', 'Honey', 'Chyawanprash'],
      'Hygiene': ['Hand Wash', 'Hand Sanitizer', 'Wet Wipes'],
      'Daily Care': ['Cotton Pads', 'Bandage Pack', 'Daily Care Kit'],
    },
    'More': {
      'Popular': ['Freegi Popular Pack', 'Daily Grocery Combo', 'Family Essentials'],
      'New': ['New Arrival Pack', 'Fresh Discovery Box', 'New Grocery Combo'],
      'Best Seller': ['Best Seller Combo', 'Customer Choice Pack', 'Top Rated Essentials'],
      'Offers': ['Super Saver Pack', 'Value Deal Combo', 'Mega Offer Box'],
    },
  };

  // ============================================================
  // GENERATED PRODUCT HELPERS
  // Same formulas as the current CategoryItemsScreen.
  // ============================================================

  static List<Map<String, dynamic>> _generatedCategoryProducts(
    String category,
  ) {
    final groups = _generatedCatalog[category];
    if (groups == null || groups.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final result = <Map<String, dynamic>>[];
    int index = 0;

    for (final entry in groups.entries) {
      for (final name in entry.value) {
        final unit = _unitFor(category, entry.key, index);

        result.add({
          'id': '${_slug(category)}-${_slug(name)}-${_slug(unit)}',
          'name': name,
          'category': category,
          'filter': entry.key,
          'unit': unit,
          'price': 49 + ((index * 17 + category.length * 3) % 251),
          'oldPrice': 69 + ((index * 19 + category.length * 4) % 281),
          'rating': 4.5 + ((index % 5) * 0.1),
          'reviews': 520 + ((index * 137 + category.length * 29) % 980),
          'discount': '${10 + ((index * 3) % 16)}% OFF',
          'image': _imageFor(category, entry.key, name),
        });

        index++;
      }
    }

    return result;
  }

  static String _imageFor(
    String category,
    String filter,
    String name,
  ) {
    // Stable product-specific image. Using the complete product identity as the
    // seed prevents generated catalogue items from accidentally sharing the
    // same image between products or categories.
    final seed = _slug('$category-$filter-$name');
    return 'https://picsum.photos/seed/freegi-$seed/600/600';
  }

  static String _unitFor(
    String category,
    String filter,
    int index,
  ) {
    if (category == 'Cooking Oil') {
      return index % 3 == 0 ? '1 litre' : '500 ml';
    }

    if (category == 'Baby Care' && filter == 'Diapers') {
      return '1 pack';
    }

    if (category == 'Pet Care') {
      return index.isEven ? '1 kg' : '500 g';
    }

    if (category == 'Beauty' ||
        category == 'Personal Care' ||
        category == 'Cleaning') {
      return index.isEven ? '250 ml' : '1 pack';
    }

    return index.isEven ? '500 g' : '1 pack';
  }

  // ============================================================
  // INTERNAL HELPERS
  // ============================================================

  static List<Map<String, dynamic>> _byIds(List<String> ids) {
    final lookup = <String, Map<String, dynamic>>{};

    for (final product in [
      ..._vegetables,
      ..._fruits,
      ..._dairy,
      ..._bakery,
      ..._beverages,
      ..._snacks,
      ..._homeOnlyProducts,
    ]) {
      lookup[product['id'].toString()] = product;
    }

    return ids
        .where(lookup.containsKey)
        .map((id) => Map<String, dynamic>.from(lookup[id]!))
        .toList();
  }

  static List<Map<String, dynamic>> _copyList(
    List<Map<String, dynamic>> source,
  ) {
    return source
        .map((product) => Map<String, dynamic>.from(product))
        .toList();
  }

  static String _slug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
