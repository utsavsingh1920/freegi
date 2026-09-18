import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freegi/data/cart_store.dart';
import 'package:freegi/data/product_catalog.dart';

import '../product/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color mint = Color(0xFFDDF7F3);
  static const Color darkText = Color(0xFF172326);
  static const Color greyText = Color(0xFF6E7C7C);
  static const Color bg = Color(0xFFF8FBFA);

  final TextEditingController _controller = TextEditingController();

  static const String _recentSearchesKey = 'freegi_recent_searches';

  List<String> recentSearches = [];

  final List<String> trending = [
    'Organic',
    'Fruits',
    'Vegetables',
    'Dairy',
    'Healthy',
    'Snacks',
  ];

  List<Map<String, dynamic>> get products =>
      ProductCatalog.allProducts;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_recentSearchesKey) ?? <String>[];

    if (!mounted) return;
    setState(() {
      recentSearches = saved;
    });
  }

  Future<void> _addRecentSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final updated = <String>[
      query,
      ...recentSearches.where(
        (item) => item.toLowerCase() != query.toLowerCase(),
      ),
    ].take(6).toList();

    setState(() {
      recentSearches = updated;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, updated);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim().toLowerCase();

    final filteredProducts = products.where((product) {
      if (query.isEmpty) return false;

      final searchableText = [
        product['name'],
        product['unit'],
        product['category'],
        product['filter'],
      ].where((value) => value != null).join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: darkText,
        centerTitle: true,
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE3ECEA),
                ),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (_) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  _addRecentSearch(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search groceries...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF96A3A3),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: teal,
                    size: 25,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: greyText,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            if (_controller.text.isEmpty) ...[
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              ...recentSearches.map(
                (item) => InkWell(
                  onTap: () {
                    _controller.text = item;
                    setState(() {});
                    _addRecentSearch(item);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color: Color(0xFF899494),
                          size: 21,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.north_west_rounded,
                          color: Color(0xFF899494),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Trending',
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: trending.map(
                  (item) {
                    return InkWell(
                      onTap: () {
                        _controller.text = item;
                        setState(() {});
                        _addRecentSearch(item);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: mint,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: teal,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],

            if (_controller.text.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredProducts.length} found',
                    style: const TextStyle(
                      color: teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (filteredProducts.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        color: Color(0xFFB1BBBB),
                        size: 54,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No products found',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredProducts.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        _addRecentSearch(_controller.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(
                              product: Map<String, dynamic>.from(product),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE5EEEC),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              product['image'],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Container(
                                  width: 72,
                                  height: 72,
                                  color: mint,
                                  child: const Icon(
                                    Icons.shopping_basket_outlined,
                                    color: teal,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    color: darkText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['unit'],
                                  style: const TextStyle(
                                    color: greyText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${product['price']}',
                                  style: const TextStyle(
                                    color: darkText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              CartStore.addProduct(product);

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    backgroundColor: teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Text(
                                      '${product['name']} added to cart',
                                    ),
                                  ),
                                );
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: teal,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}