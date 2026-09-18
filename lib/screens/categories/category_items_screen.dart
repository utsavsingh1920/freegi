import 'package:flutter/material.dart';
import 'package:freegi/data/cart_store.dart';
import 'package:freegi/data/favorites_store.dart';
import 'package:freegi/data/product_catalog.dart';

import '../product/product_details_screen.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryItemsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryItemsScreen> createState() =>
      _CategoryItemsScreenState();
}

class _CategoryItemsScreenState
    extends State<CategoryItemsScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF73817E);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color border = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE5F8F4);

  final TextEditingController _searchController =
      TextEditingController();

  String selectedFilter = 'All';

  void _toggleFavorite(
    Map<String, dynamic> product,
  ) {
    FavoritesStore.toggle(product);
  }

  // ============================================================
  // FILTERS
  // ============================================================

  List<String> get filters {
    switch (widget.categoryName) {
      case 'Vegetables':
        return [
          'All',
          'Leafy',
          'Tomato',
          'Onion',
          'Potato',
          'Root',
          'Green',
        ];

      case 'Fruits':
        return [
          'All',
          'Apple',
          'Banana',
          'Citrus',
          'Mango',
          'Grapes',
          'Seasonal',
        ];

      case 'Dairy':
      case 'Dairy & Eggs':
        return [
          'All',
          'Milk',
          'Curd',
          'Paneer',
          'Butter',
          'Cheese',
          'Eggs',
        ];

      case 'Bakery':
        return [
          'All',
          'Bread',
          'Buns',
          'Cakes',
          'Cookies',
          'Rusk',
        ];

      case 'Beverages':
        return [
          'All',
          'Juice',
          'Tea',
          'Coffee',
          'Soft Drinks',
          'Energy',
        ];

      case 'Snacks':
        return [
          'All',
          'Chips',
          'Namkeen',
          'Biscuits',
          'Chocolate',
          'Noodles',
        ];

      case 'Personal Care':
        return [
          'All',
          'Hair Care',
          'Skin Care',
          'Bath',
          'Oral Care',
        ];

      case 'Household':
        return [
          'All',
          'Cleaning',
          'Laundry',
          'Kitchen',
          'Home Care',
        ];

      case 'Atta, Rice & Dal':
        return [
          'All',
          'Atta',
          'Rice',
          'Dal',
          'Pulses',
          'Flour',
        ];

      case 'Masala & Spices':
        return [
          'All',
          'Masala',
          'Spices',
          'Salt',
          'Sugar',
          'Seasoning',
        ];

      case 'Instant Food':
        return [
          'All',
          'Noodles',
          'Pasta',
          'Soup',
          'Ready Meal',
        ];

      case 'Baby Care':
        return [
          'All',
          'Diapers',
          'Baby Food',
          'Bath',
          'Skin Care',
        ];

      case 'Pet Care':
        return [
          'All',
          'Dog Food',
          'Cat Food',
          'Treats',
          'Care',
        ];

      case 'Organic':
        return [
          'All',
          'Fruits',
          'Vegetables',
          'Grains',
          'Staples',
        ];

      case 'Frozen Food':
        return [
          'All',
          'Veg',
          'Snacks',
          'Desserts',
          'Ready Meal',
        ];

      case 'Dry Fruits':
        return [
          'All',
          'Almond',
          'Cashew',
          'Raisin',
          'Walnut',
        ];

      case 'Breakfast':
        return [
          'All',
          'Cereal',
          'Oats',
          'Bread',
          'Spread',
          'Eggs',
        ];

      case 'Tea & Coffee':
        return [
          'All',
          'Tea',
          'Coffee',
          'Green Tea',
          'Premix',
        ];

      case 'Biscuits':
        return [
          'All',
          'Cookies',
          'Cream',
          'Digestive',
          'Crackers',
        ];

      case 'Cooking Oil':
        return [
          'All',
          'Sunflower',
          'Mustard',
          'Soybean',
          'Olive',
        ];

      case 'Cleaning':
        return [
          'All',
          'Floor',
          'Dishwash',
          'Bathroom',
          'Laundry',
        ];

      case 'Beauty':
        return [
          'All',
          'Face',
          'Hair',
          'Body',
          'Makeup',
        ];

      case 'Health':
        return [
          'All',
          'Nutrition',
          'Wellness',
          'Hygiene',
          'Daily Care',
        ];

      default:
        return [
          'All',
          'Popular',
          'New',
          'Best Seller',
          'Offers',
        ];
    }
  }

  // ============================================================
  // PRODUCT DATA - SINGLE SOURCE OF TRUTH
  // ============================================================

  List<Map<String, dynamic>> get products {
    return ProductCatalog.productsForCategory(
      widget.categoryName,
    );
  }


  // ============================================================
  // FILTERED PRODUCTS
  // ============================================================

  List<Map<String, dynamic>> get filteredProducts {
    final query =
        _searchController.text.trim().toLowerCase();

    return products.where((product) {
      final name =
          product['name'].toString().toLowerCase();

      final matchesSearch =
          query.isEmpty || name.contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
              product['filter'] == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  void _addProduct(Map<String, dynamic> product) {
    CartStore.addProduct(product);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${product['name']} added to cart',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesStore.favorites,
      builder: (context, _, _) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: CartStore.cartItems,
          builder: (context, _, _) {
            final visibleProducts = filteredProducts;

            return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              visibleProducts.length,
            ),

            const SizedBox(height: 14),

            _buildSearch(),

            const SizedBox(height: 14),

            _buildFilterChips(),

            const SizedBox(height: 12),

            Expanded(
              child: visibleProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics:
                          const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        28,
                      ),
                      itemCount:
                          visibleProducts.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder:
                          (context, index) {
                        final product =
                            visibleProducts[index];

                        return _buildProductRow(
                          product,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        0,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(13),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkText,
                size: 17,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count products available',
                  style: const TextStyle(
                    color: subText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: lightMint,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: teal,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Fresh',
                  style: TextStyle(
                    color: darkTeal,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
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
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        height: 49,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: border,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) {
            setState(() {});
          },
          style: const TextStyle(
            color: darkText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText:
                'Search in ${widget.categoryName}...',
            hintStyle: const TextStyle(
              color: Color(0xFF98A5A3),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: teal,
              size: 21,
            ),
            suffixIcon:
                _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: subText,
                          size: 18,
                        ),
                      ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  String _filterEmoji(String filter) {
    const emojis = <String, String>{
      'Leafy': '🥬', 'Tomato': '🍅', 'Onion': '🧅', 'Potato': '🥔',
      'Root': '🥕', 'Green': '🫑',
      'Apple': '🍎', 'Banana': '🍌', 'Citrus': '🍊', 'Mango': '🥭',
      'Grapes': '🍇', 'Seasonal': '🍉',
      'Milk': '🥛', 'Curd': '🥣', 'Paneer': '🧀', 'Butter': '🧈',
      'Cheese': '🧀', 'Eggs': '🥚',
      'Bread': '🍞', 'Buns': '🥯', 'Cakes': '🍰', 'Cookies': '🍪',
      'Rusk': '🥖', 'Juice': '🧃', 'Tea': '🍵', 'Coffee': '☕',
      'Soft Drinks': '🥤', 'Energy': '⚡',
      'Chips': '🍟', 'Namkeen': '🥨', 'Biscuits': '🍪',
      'Chocolate': '🍫', 'Noodles': '🍜',
      'Hair Care': '🧴', 'Skin Care': '✨', 'Bath': '🧼',
      'Oral Care': '🪥', 'Cleaning': '🧹', 'Laundry': '🧺',
      'Kitchen': '🍽️', 'Home Care': '🏠',
      'Atta': '🌾', 'Rice': '🍚', 'Dal': '🫘', 'Pulses': '🫘',
      'Flour': '🌾', 'Masala': '🌶️', 'Spices': '🌶️', 'Salt': '🧂',
      'Sugar': '🍬', 'Seasoning': '🌿', 'Pasta': '🍝', 'Soup': '🥣',
      'Ready Meal': '🍱', 'Diapers': '👶', 'Baby Food': '🍼',
      'Dog Food': '🐶', 'Cat Food': '🐱', 'Treats': '🦴', 'Care': '🐾',
      'Fruits': '🍎', 'Vegetables': '🥬', 'Grains': '🌾',
      'Staples': '🛒', 'Veg': '🥦', 'Snacks': '🍟', 'Desserts': '🍨',
      'Almond': '🌰', 'Cashew': '🥜', 'Raisin': '🍇', 'Walnut': '🌰',
      'Cereal': '🥣', 'Oats': '🥣', 'Spread': '🥜',
      'Green Tea': '🍵', 'Premix': '☕', 'Cream': '🍪',
      'Digestive': '🍪', 'Crackers': '🥨',
      'Sunflower': '🌻', 'Mustard': '🌼', 'Soybean': '🫘', 'Olive': '🫒',
      'Floor': '🧹', 'Dishwash': '🍽️', 'Bathroom': '🧽',
      'Face': '✨', 'Hair': '💇', 'Body': '🧴', 'Makeup': '💄',
      'Nutrition': '🥗', 'Wellness': '🌿', 'Hygiene': '🧼',
      'Daily Care': '💚', 'Popular': '🔥', 'New': '✨',
      'Best Seller': '⭐', 'Offers': '🏷️',
    };
    return emojis[filter] ?? '•';
  }

  // ============================================================
  // FILTER CHIPS
  // ============================================================

  Widget _buildFilterChips() {
    return SizedBox(
      height: 39,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];

          final selected =
              selectedFilter == filter;

          return InkWell(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            borderRadius:
                BorderRadius.circular(12),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color:
                    selected ? teal : Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? teal
                      : border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter != 'All') ...[
                    Text(
                      _filterEmoji(filter),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      color: selected ? Colors.white : darkText,
                      fontSize: 10.5,
                      fontWeight:
                          selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT ROW
  // ============================================================

  Widget _buildProductRow(
    Map<String, dynamic> product,
  ) {
    final productName =
        product['name'].toString();

    final isAdded =
        CartStore.quantityOf(product) > 0;
    final isFavorite =
        FavoritesStore.contains(product);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(
              product: product,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.022,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // IMAGE
            Container(
              width: 88,
              height: 88,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7F6),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Image.network(
                product['image'].toString(),
                fit: BoxFit.cover,
                cacheWidth: 300,
                cacheHeight: 300,
                errorBuilder: (_, _, _) {
                  return const Center(
                    child: Icon(
                      Icons
                          .shopping_basket_outlined,
                      color: teal,
                      size: 32,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // INFORMATION
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                    productName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product['unit'].toString(),
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color:
                            Color(0xFFFFB629),
                        size: 13,
                      ),

                      const SizedBox(width: 2),

                      Text(
                        '${product['rating']} (${product['reviews'] ?? (620 + productName.length * 31)})',
                        style: const TextStyle(
                          color: subText,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Container(
                        width: 3,
                        height: 3,
                        decoration:
                            const BoxDecoration(
                          color:
                              Color(0xFFB8C3C1),
                          shape:
                              BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Text(
                        product['discount']
                            .toString(),
                        style:
                            const TextStyle(
                          color: teal,
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Text(
                        '₹${product['price']}',
                        style:
                            const TextStyle(
                          color: darkText,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '₹${product['oldPrice']}',
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF9EA8A6),
                          fontSize: 9,
                          decoration:
                              TextDecoration
                                  .lineThrough,
                        ),
                      ),
                    ],
                  ),
                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(width: 8),

            // FAVORITE + ADD
            SizedBox(
              width: 65,
              height: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      _toggleFavorite(product);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? const Color(0xFFE94D67)
                            : subText,
                        size: 20,
                      ),
                    ),
                  ),

                  const Spacer(),

                  InkWell(
                    onTap: () {
                      _addProduct(product);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 65,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isAdded
                            ? lightMint
                            : const Color(0xFFDDF8F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAdded
                              ? teal.withValues(alpha: 0.30)
                              : const Color(0xFFC9F2E6),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isAdded ? 'Added' : 'Add',
                          style: TextStyle(
                            color: isAdded ? darkTeal : teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: lightMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: teal,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(
                color: darkText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Try another search or choose a different filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 10.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}