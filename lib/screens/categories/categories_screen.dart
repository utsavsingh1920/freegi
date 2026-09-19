import 'package:flutter/material.dart';

import 'category_items_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const CategoriesScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const Color teal = Color(0xFF00AFA8);

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Fruits',
      'icon': Icons.apple_rounded,
      'image':
          'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFE7E5),
    },
    {
      'name': 'Vegetables',
      'icon': Icons.eco_rounded,
      'image':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE5F6DF),
    },
    {
      'name': 'Dairy',
      'icon': Icons.local_drink_rounded,
      'image':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE5F1FF),
    },
    {
      'name': 'Bakery',
      'icon': Icons.bakery_dining_rounded,
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFEAD6),
    },
    {
      'name': 'Beverages',
      'icon': Icons.local_cafe_rounded,
      'image':
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE7EEFF),
    },
    {
      'name': 'Snacks',
      'icon': Icons.fastfood_rounded,
      'image':
          'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFE6D9),
    },
    {
      'name': 'Personal Care',
      'icon': Icons.spa_rounded,
      'image':
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFF3E4FA),
    },
    {
      'name': 'Household',
      'icon': Icons.cleaning_services_rounded,
      'image':
          'https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE2F5F3),
    },
    {
      'name': 'Atta, Rice & Dal',
      'icon': Icons.rice_bowl_rounded,
      'image':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFF3E9DB),
    },
    {
      'name': 'Masala & Spices',
      'icon': Icons.local_fire_department_rounded,
      'image':
          'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFE7DE),
    },
    {
      'name': 'Instant Food',
      'icon': Icons.ramen_dining_rounded,
      'image':
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFEDD6),
    },
    {
      'name': 'Baby Care',
      'icon': Icons.child_care_rounded,
      'image':
          'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFE5ED),
    },
    {
      'name': 'Pet Care',
      'icon': Icons.pets_rounded,
      'image':
          'https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFEAD6),
    },
    {
      'name': 'Organic',
      'icon': Icons.energy_savings_leaf_rounded,
      'image':
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE2F6DD),
    },
    {
      'name': 'Frozen Food',
      'icon': Icons.ac_unit_rounded,
      'image':
          'https://images.unsplash.com/photo-1580915411954-282cb1f7901d?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE3F2FF),
    },
    {
      'name': 'Dry Fruits',
      'icon': Icons.nature_rounded,
      'image':
          'https://images.unsplash.com/photo-1606923829579-0cb981a83e2e?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFF5E6D7),
    },
    {
      'name': 'Breakfast',
      'icon': Icons.breakfast_dining_rounded,
      'image':
          'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFEBD8),
    },
    {
      'name': 'Tea & Coffee',
      'icon': Icons.coffee_rounded,
      'image':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFF1E4D8),
    },
    {
      'name': 'Biscuits',
      'icon': Icons.cookie_rounded,
      'image':
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFE9D2),
    },
    {
      'name': 'Cooking Oil',
      'icon': Icons.water_drop_rounded,
      'image':
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFF1C9),
    },
    {
      'name': 'Cleaning',
      'icon': Icons.cleaning_services_outlined,
      'image':
          'https://images.unsplash.com/photo-1563453392212-326f5e854473?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE2F4FF),
    },
    {
      'name': 'Beauty',
      'icon': Icons.face_retouching_natural_rounded,
      'image':
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFFFE5F0),
    },
    {
      'name': 'Health',
      'icon': Icons.health_and_safety_rounded,
      'image':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE5F2FF),
    },
    {
      'name': 'More',
      'icon': Icons.grid_view_rounded,
      'image':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=700&q=90',
      'lightColor': Color(0xFFE5F8F4),
    },
  ];

  List<Map<String, dynamic>> get filteredCategories {
    if (searchQuery.trim().isEmpty) {
      return categories;
    }

    final query = searchQuery.toLowerCase().trim();

    return categories.where((category) {
      final name = (category['name'] as String).toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryItemsScreen(
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCategories = filteredCategories;
    const background = Color(0xFFF8FCFA);

    final keyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: background,
      extendBody: false,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: CustomScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Categories is the only header text.
              // It stays pinned at the top while everything below scrolls.
              SliverPersistentHeader(
                pinned: true,
                delegate: const _CategoriesStickyHeaderDelegate(),
              ),

              // Search scrolls away.
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Existing hero/banner scrolls away.
              SliverToBoxAdapter(
                child: _buildHeroBanner(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              if (visibleCategories.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 360,
                    child: _buildEmptyState(),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'All Categories',
                            style: TextStyle(
                              color: Color(0xFF172321),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.25,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F8F4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${visibleCategories.length} Categories',
                            style: const TextStyle(
                              color: teal,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 14),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _categoryItem(
                          visibleCategories[index],
                        );
                      },
                      childCount: visibleCategories.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.74,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: _buildBottomInfo(),
                  ),
                ),
              ],

              // Safe space above the app's fixed bottom navigation.
              SliverToBoxAdapter(
                child: SizedBox(
                  height: widget.showBottomNavigation
                      ? 32
                      : keyboardOpen
                          ? 24
                          : 112,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ============================================================
  // SEARCH BAR - COMPACT
  // ============================================================

  Widget _buildSearchBar() {
    const surface = Colors.white;
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);
    const border = Color(0xFFE1EBE9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: TextStyle(
              color: subText,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: teal,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 43,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        searchQuery = '';
                      });
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: subText,
                      size: 18,
                    ),
                  )
                : Icon(
                    Icons.tune_rounded,
                    color: subText,
                    size: 18,
                  ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // THIN HERO BANNER
  // ============================================================

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 122,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFE4F8F2),
          border: Border.all(
            color: const Color(0xFFD0EEE6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Clear grocery image on the right.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 185,
              child: Image.network(
                'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1200&q=95',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: const Color(0xFFD9F5EA),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shopping_basket_rounded,
                      color: teal,
                      size: 46,
                    ),
                  );
                },
              ),
            ),

            // Gradient only protects the text area. The right side stays clear.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFE4F8F2),
                        const Color(0xFFE4F8F2),
                        const Color(0xFFE4F8F2).withValues(alpha: 0.78),
                        const Color(0xFFE4F8F2).withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 0.56, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 155, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Freegi Fresh',
                      style: TextStyle(
                        color: teal,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Explore Fresh\nCategories',
                    maxLines: 2,
                    style: TextStyle(
                      color: Color(0xFF12312D),
                      fontSize: 18,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Everything you need, all in one place.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF58726D),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
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
  // CATEGORY CARD - HOME STYLE / LIGHT COLOR CONTAINER
  // ============================================================

  Widget _categoryItem(
    Map<String, dynamic> category,
  ) {
    final cardColor = category['lightColor'] as Color;
    const textColor = Color(0xFF172321);
    const borderColor = Colors.white;

    return InkWell(
      onTap: () {
        _openCategory(
          category['name'] as String,
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          5,
          7,
          5,
          7,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.035,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      category['image'].toString(),
                      fit: BoxFit.cover,
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          color: cardColor,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: teal,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: cardColor,
                          alignment: Alignment.center,
                          child: Icon(
                            category['icon'] as IconData,
                            color: teal,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  category['name'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 9.4,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
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
  // BOTTOM INFO
  // ============================================================

  Widget _buildBottomInfo() {
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFFE7F8F4),
            Color(0xFFF4FCFA),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD8F0EA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: teal,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh groceries, every day',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Explore more categories as you scroll.',
                  style: TextStyle(
                    color: subText,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            color: teal,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F8F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: teal,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No category found',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with another category name.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 10,
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

// ============================================================
// CATEGORIES STICKY HEADER
// ============================================================

class _CategoriesStickyHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _CategoriesStickyHeaderDelegate();

  @override
  double get minExtent => 54;

  @override
  double get maxExtent => 54;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF8FCFA),
      alignment: Alignment.center,
      child: const Text(
        'Categories',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF172321),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant _CategoriesStickyHeaderDelegate oldDelegate,
  ) {
    return false;
  }
}
