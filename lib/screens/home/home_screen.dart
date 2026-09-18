import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freegi/data/favorites_store.dart';
import 'package:freegi/data/cart_store.dart';
import 'package:freegi/data/product_catalog.dart';
import 'package:freegi/data/notification_store.dart';

import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../categories/category_items_screen.dart';
import '../search/search_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../product/product_details_screen.dart';
import '../location/location_screen.dart';

class HomeScreen extends StatefulWidget {
final bool showBottomNavigation;

const HomeScreen({
super.key,
this.showBottomNavigation = true,
});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
int _selectedBottomIndex = 0;

String _homeLocation = 'Set delivery location';

Future<void> _loadSavedLocation() async {
  final prefs = await SharedPreferences.getInstance();

  final area = (prefs.getString('deliveryArea') ?? '').trim();
  final city = (prefs.getString('deliveryCity') ?? '').trim();
  final state = (prefs.getString('deliveryState') ?? '').trim();

  // Home header must use only the explicitly selected location fields.
  // Do NOT fall back to `deliveryAddress`, because that key is also used
  // by saved/checkout addresses and can contain an old locality even after
  // the user removes the current Home location.
  final parts = <String>[];
  for (final value in [area, city, state]) {
    if (value.isNotEmpty &&
        !parts.any((item) => item.toLowerCase() == value.toLowerCase())) {
      parts.add(value);
    }
  }

  final displayLocation = parts.join(', ');

  if (!mounted) return;

  setState(() {
    _homeLocation =
        displayLocation.isNotEmpty ? displayLocation : 'Set delivery location';
  });
}

// ============================================================
// COLORS
// ============================================================

static const Color teal = Color(0xFF00AFA8);
static const Color darkTeal = Color(0xFF08756E);
static const Color darkGreen = Color(0xFF075C50);
static const Color mint = Color(0xFFE5F8F4);
static const Color orange = Color(0xFFFFA928);
static const Color dark = Color(0xFF172321);
static const Color grey = Color(0xFF75837F);
static const Color bg = Color(0xFFF8FCFA);

// ============================================================
// HERO SLIDER
// ============================================================

final PageController _heroController = PageController(
initialPage: 1000,
);

Timer? _heroTimer;

final List<Map<String, dynamic>> heroSlides = [
{
'badge': 'Freegi Fresh',
'title': 'Fresh groceries\ndelivered fast.',
'subtitle':
'Everyday essentials and fresh products at your doorstep.',
'button': 'Shop Now',
'offer': 'Up to 30% OFF',
'image':
'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1600&q=92',
'alignment': Alignment.centerRight,
'start': const Color(0xFF064E46),
'middle': const Color(0xFF08756E),
'end': const Color(0xFF00AFA8),
},
{
'badge': 'Farm Fresh',
'title': 'Fresh vegetables\nevery single day.',
'subtitle':
'Tomato, onion, potato and more selected for freshness.',
'button': 'Buy Fresh',
'offer': 'Fresh Today',
'image':
'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1600&q=92',
'alignment': Alignment.centerRight,
'start': const Color(0xFF194D25),
'middle': const Color(0xFF397A38),
'end': const Color(0xFF77B255),
},
{
'badge': 'Freegi Deals',
'title': 'Big savings on\ndaily essentials.',
'subtitle':
'Save more on milk, bread, fruits, snacks and groceries.',
'button': 'View Deals',
'offer': 'Save More',
'image':
'https://images.unsplash.com/photo-1601598851547-4302969d0614?auto=format&fit=crop&w=1600&q=92',
'alignment': Alignment.centerRight,
'start': const Color(0xFF8D4700),
'middle': const Color(0xFFCE6D06),
'end': const Color(0xFFFFA928),
},
{
'badge': 'Fast Delivery',
'title': 'Groceries at\nyour convenience.',
'subtitle':
'Easy shopping, secure payment and reliable delivery.',
'button': 'Order Now',
'offer': 'Fast & Easy',
'image':
'https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?auto=format&fit=crop&w=1600&q=92',
'alignment': Alignment.centerRight,
'start': const Color(0xFF24356A),
'middle': const Color(0xFF5359A5),
'end': const Color(0xFF8478DD),
},
];

@override
void initState() {
super.initState();
_loadSavedLocation();


// Always moves FORWARD:
// 1 -> 2 -> 3 -> 4 -> 1 -> 2 -> 3 -> 4 ...
_heroTimer = Timer.periodic(
  const Duration(seconds: 4),
  (_) {
    if (!mounted ||
        !_heroController.hasClients ||
        heroSlides.isEmpty) {
      return;
    }

    _heroController.nextPage(
      duration: const Duration(
        milliseconds: 650,
      ),
      curve: Curves.easeInOutCubic,
    );
  },
);

}

@override
void dispose() {
_heroTimer?.cancel();
_heroController.dispose();
super.dispose();
}

// ============================================================
// CATEGORIES
// ============================================================

final List<Map<String, dynamic>> categories = [
{
'name': 'Fruits',
'image':
'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Vegetables',
'image':
'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Dairy',
'image':
'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Bakery',
'image':
'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Snacks',
'image':
'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Beverages',
'image':
'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Household',
'image':
'https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=600&q=90',
},
{
'name': 'Personal Care',
'image':
'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=90',
},
];

// ============================================================
// TODAY'S BEST DEALS
// ============================================================

final List<Map<String, dynamic>> popularProducts =
    ProductCatalog.homePopularProducts;

// ============================================================
// DAILY ESSENTIALS
// ============================================================

final List<Map<String, dynamic>> dailyEssentials =
    ProductCatalog.homeDailyEssentials;

// ============================================================
// TOP PICKS
// ============================================================

final List<Map<String, dynamic>> topPicks =
    ProductCatalog.homeTopPicks;

// ============================================================
// BREAKFAST
// ============================================================

final List<Map<String, dynamic>> breakfastProducts =
    ProductCatalog.homeBreakfastProducts;

// ============================================================
// NAVIGATION
// ============================================================

Future<void> _openChangeLocation() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LocationScreen(
        isChangeMode: true,
      ),
    ),
  );

  // Always reload when returning from LocationScreen.
  // This also refreshes the header when the user removes a location and
  // the location screen returns false/null instead of `true`.
  if (mounted) {
    await _loadSavedLocation();
  }
}

void _openSearch() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const SearchScreen(),
),
);
}

void _openCategories() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const CategoriesScreen(),
),
);
}

void _openCart() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const CartScreen(),
),
);
}

void _openOrders() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const OrdersScreen(),
),
);
}

void _openProfile() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ProfileScreen(),
),
);
}

void _openNotifications() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const NotificationsScreen(),
),
);
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

Map<String, dynamic> _productForDetails(
Map<String, dynamic> product,
) {
return {
...product,
'rating': product['rating'] ?? 4.7,
'oldPrice':
product['oldPrice'] ?? product['price'],
'discount': product['discount'] ?? '',
};
}

Future<void> _openProduct(
Map<String, dynamic> product,
) async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => ProductDetailsScreen(
product: _productForDetails(product),
),
),
);


if (mounted) {
  setState(() {});
}

}

// ============================================================
// FAVORITES
// ============================================================

bool _isFavorite(
Map<String, dynamic> product,
) {
return FavoritesStore.contains(product);
}

void _toggleFavorite(
Map<String, dynamic> product, {
bool showMessage = true,
}) {
final wasFavorite =
FavoritesStore.contains(product);


FavoritesStore.toggle(product);

if (mounted) {
  setState(() {});
}

if (!showMessage) {
  return;
}

ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      content: Text(
        wasFavorite
            ? '${product['name']} removed from Favorites'
            : '${product['name']} added to Favorites',
      ),
      backgroundColor: darkTeal,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    ),
  );

}

List<Map<String, dynamic>>
get _likedProducts {
  // IMPORTANT:
  // The FavoritesStore is the single source of truth.
  // Previously this getter rebuilt favorites only from Home's local
  // product lists, so products liked from Categories/Product Details
  // increased the header badge but were missing from this popup.
  // Using favoriteProducts keeps the popup count and contents in sync
  // with the global persistent favorites list.
  return FavoritesStore.favoriteProducts.value
      .map((product) => Map<String, dynamic>.from(product))
      .toList();
}

void _showFavorites() {
showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: Colors.transparent,
builder: (sheetContext) {
return StatefulBuilder(
builder: (
context,
sheetSetState,
) {
final liked = _likedProducts;


        return Container(
          height:
              MediaQuery.of(context).size.height *
                  0.72,
          decoration:
              const BoxDecoration(
            color: bg,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFD4DFDD,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    13,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'My Favorites',
                              style: TextStyle(
                                color: dark,
                                fontSize: 15.5,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Products you liked',
                              style: TextStyle(
                                color: grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: mint,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          '${liked.length} items',
                          style:
                              const TextStyle(
                            color: darkTeal,
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  color:
                      Color(0xFFE1EBE9),
                ),

                Expanded(
                  child: liked.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .favorite_border_rounded,
                                size: 55,
                                color: Color(
                                  0xFFB4C0BE,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No favorites yet',
                                style: TextStyle(
                                  color: dark,
                                  fontSize: 14.5,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Tap the heart on a product to save it here.',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color: grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          itemCount:
                              liked.length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            height: 10,
                          ),
                          itemBuilder:
                              (context, index) {
                            final product =
                                liked[index];

                            return InkWell(
                              onTap: () {
                                Navigator.pop(
                                  sheetContext,
                                );

                                _openProduct(
                                  product,
                                );
                              },
                              borderRadius:
                                  BorderRadius.circular(
                                17,
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .all(9),
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    17,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                      0xFFE1EBE9,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        13,
                                      ),
                                      child:
                                          Image.network(
                                        product[
                                                'image']
                                            .toString(),
                                        width: 66,
                                        height: 66,
                                        fit: BoxFit
                                            .cover,
                                        errorBuilder:
                                            (_, _, _) {
                                          return Container(
                                            width:
                                                66,
                                            height:
                                                66,
                                            color:
                                                mint,
                                            alignment:
                                                Alignment
                                                    .center,
                                            child:
                                                const Icon(
                                              Icons
                                                  .shopping_basket_outlined,
                                              color:
                                                  teal,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 11,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            product[
                                                    'name']
                                                .toString(),
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  dark,
                                              fontSize:
                                                  12.5,
                                              fontWeight:
                                                  FontWeight
                                                      .w900,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                4,
                                          ),
                                          Text(
                                            product[
                                                    'unit']
                                                .toString(),
                                            style:
                                                const TextStyle(
                                              color:
                                                  grey,
                                              fontSize:
                                                  9,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                6,
                                          ),
                                          Text(
                                            '₹${product['price']}',
                                            style:
                                                const TextStyle(
                                              color:
                                                  darkTeal,
                                              fontSize:
                                                  13,
                                              fontWeight:
                                                  FontWeight
                                                      .w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    IconButton(
                                      onPressed: () {
                                        _toggleFavorite(
                                          product,
                                          showMessage:
                                              false,
                                        );

                                        sheetSetState(
                                          () {},
                                        );
                                      },
                                      icon:
                                          const Icon(
                                        Icons
                                            .favorite_rounded,
                                        color:
                                            Color(
                                          0xFFE85E65,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
).whenComplete(
  () {
    if (mounted) {
      setState(() {});
    }
  },
);

}

// ============================================================
// MESSAGES
// ============================================================

void _showAddedMessage(String name) {
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Row(
children: [
const Icon(
Icons.check_circle_rounded,
color: Colors.white,
),
const SizedBox(width: 10),
Expanded(
child: Text(
'$name added to cart',
),
),
],
),
backgroundColor: darkTeal,
behavior:
SnackBarBehavior.floating,
margin: const EdgeInsets.all(16),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
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
backgroundColor: bg,
body: SafeArea(
bottom: false,
child: Column(
children: [
// ====================================================
// FIXED TOP AREA
// ====================================================
_buildHeader(),


        const SizedBox(height: 9),

        _buildSearchBar(),

        const SizedBox(height: 10),

        // ====================================================
        // SCROLL STARTS FROM HERO SECTION
        // ====================================================
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom:
                  widget.showBottomNavigation ? 34 : 115,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSlider(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: 'Shop by Category',
                  onTap: _openCategories,
                ),

                const SizedBox(height: 10),

                _buildCategories(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: "Today's Best Deals",
                  onTap: _openCategories,
                ),

                const SizedBox(height: 10),

                _buildProducts(
                  products: popularProducts,
                  showDiscount: true,
                ),

                const SizedBox(height: 20),

                _buildOfferCard(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: 'Daily Essentials',
                  onTap: _openCategories,
                ),

                const SizedBox(height: 10),

                _buildProducts(
                  products: dailyEssentials,
                  showDiscount: true,
                ),

                const SizedBox(height: 20),

                _buildFreshBanner(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: 'Top Picks for You',
                  onTap: _openCategories,
                ),

                const SizedBox(height: 10),

                _buildProducts(
                  products: topPicks,
                  showDiscount: true,
                ),

                const SizedBox(height: 20),

                _buildMiniOfferBanner(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: 'Breakfast & Bakery',
                  onTap: _openCategories,
                ),

                const SizedBox(height: 10),

                _buildProducts(
                  products: breakfastProducts,
                ),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  title: 'Recommended for You',
                  onTap: _openCategories,
                ),

                const SizedBox(height: 10),

                _buildProducts(
                  products:
                      popularProducts.reversed.toList(),
                  showDiscount: true,
                ),

                const SizedBox(height: 22),

                _buildDeliveryBenefits(),

                const SizedBox(height: 18),

                _buildEndMessage(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    ),
  ),

  // MainNavigationScreen owns the shared navbar when this is false.
  bottomNavigationBar: widget.showBottomNavigation
      ? _buildBottomNavigation()
      : null,
);

}

// ============================================================
// HEADER
// ============================================================

Widget _buildHeader() {
return Padding(
padding: const EdgeInsets.fromLTRB(
16,
8,
16,
0,
),
child: Row(
children: [
// APP ICON
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFDCEBE8),
            ),
            boxShadow: [
              BoxShadow(
                color: teal.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Image.asset(
              'assets/icon/freegi_icon.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) {
                return const Center(
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    color: teal,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 11),

      // BRAND + LOCATION IN SAME HEADER
      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Freegi',
              style: TextStyle(
                color: darkTeal,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: _openChangeLocation,
              borderRadius:
                  BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: teal,
                      size: 14,
                    ),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        _homeLocation,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: grey,
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      color: teal,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      ValueListenableBuilder<Set<String>>(
        valueListenable: NotificationStore.readIds,
        builder: (context, readIds, child) {
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: NotificationStore.dynamicNotifications,
            builder: (context, notifications, child) {
              return _headerButton(
                icon: Icons.notifications_none_rounded,
                onTap: _openNotifications,
                showBadge: NotificationStore.hasUnread,
              );
            },
          );
        },
      ),

      const SizedBox(width: 9),

      _favoriteHeaderButton(),
    ],
  ),
);

}

Widget _headerButton({
required IconData icon,
required VoidCallback onTap,
bool showBadge = false,
}) {
return InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(13),
child: Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(13),
border: Border.all(
color:
const Color(0xFFE3ECEA),
),
),
child: Stack(
alignment: Alignment.center,
children: [
Icon(
icon,
color: dark,
size: 19,
),
if (showBadge)
Positioned(
top: 7,
right: 7,
child: Container(
width: 8,
height: 8,
decoration:
const BoxDecoration(
color: orange,
shape:
BoxShape.circle,
),
),
),
],
),
),
);
}

Widget _favoriteHeaderButton() {
return ValueListenableBuilder<
Set<String>>(
valueListenable:
FavoritesStore.favorites,
builder: (
context,
favorites,
child,
) {
return InkWell(
onTap: _showFavorites,
borderRadius:
BorderRadius.circular(13),
child: Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
13,
),
border: Border.all(
color: favorites.isEmpty
? const Color(
0xFFE3ECEA,
)
: const Color(
0xFFFFCDD8,
),
),
),
child: Stack(
alignment:
Alignment.center,
children: [
Icon(
favorites.isEmpty
? Icons
.favorite_border_rounded
: Icons
.favorite_rounded,
color: favorites.isEmpty
? dark
: const Color(
0xFFE85E65,
),
size: 18,
),


            if (favorites.isNotEmpty)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  constraints:
                      const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 4,
                  ),
                  alignment:
                      Alignment.center,
                  decoration:
                      const BoxDecoration(
                    color: Color(
                      0xFFE85E65,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Text(
                    '${favorites.length}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 8,
                      fontWeight:
                          FontWeight
                              .w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  },
);

}

// ============================================================
// SEARCH
// ============================================================

Widget _buildSearchBar() {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: InkWell(
onTap: _openSearch,
borderRadius:
BorderRadius.circular(14),
child: Container(
height: 46,
padding:
const EdgeInsets.symmetric(
horizontal: 13,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color:
const Color(0xFFE1EBE9),
),
),
child: Row(
children: [
Icon(
Icons.search_rounded,
color: teal,
size: 20,
),
SizedBox(width: 11),
Expanded(
child: Text(
'Search fruits, vegetables, milk...',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: TextStyle(
color:
Color(0xFF9AA7A5),
fontSize: 12,
),
),
),
Icon(
Icons.tune_rounded,
color:
Color(0xFF71807D),
size: 20,
),
],
),
),
),
);
}

// ============================================================
// HERO SLIDER
// 4px overflow fixed by increasing available height
// ============================================================

Widget _buildHeroSlider() {
return SizedBox(
height: 184,
child: PageView.builder(
controller: _heroController,


    // No itemCount = virtually infinite pages.
    // Auto slide always calls nextPage(), therefore:
    // 1 -> 2 -> 3 -> 4 -> 1 -> 2 -> 3 -> 4 ...
    itemBuilder: (
      context,
      index,
    ) {
      final hero =
          heroSlides[index % heroSlides.length];

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: _heroCard(hero),
      );
    },
  ),
);

}

Widget _heroCard(
Map<String, dynamic> hero,
) {
return Container(
width: double.infinity,
clipBehavior: Clip.antiAlias,
decoration: BoxDecoration(
color: darkTeal,
borderRadius:
BorderRadius.circular(21),
boxShadow: [
BoxShadow(
color:
darkTeal.withValues(
alpha: 0.17,
),
blurRadius: 18,
offset:
const Offset(0, 8),
),
],
),
child: Stack(
fit: StackFit.expand,
children: [
Image.network(
hero['image'].toString(),
fit: BoxFit.cover,
alignment:
hero['alignment'] as Alignment? ??
Alignment.centerRight,
filterQuality: FilterQuality.high,
loadingBuilder: (
context,
child,
loadingProgress,
) {
if (loadingProgress == null) {
return child;
}


          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  hero['start'] as Color,
                  hero['middle'] as Color,
                  hero['end'] as Color,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  hero['start'] as Color,
                  hero['middle'] as Color,
                  hero['end'] as Color,
                ],
              ),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(
              right: 24,
            ),
            child: Icon(
              Icons.shopping_basket_rounded,
              color: Colors.white.withValues(
                alpha: 0.35,
              ),
              size: 72,
            ),
          );
        },
      ),

      Container(
        decoration: BoxDecoration(
          gradient:
              LinearGradient(
            begin:
                Alignment.centerLeft,
            end:
                Alignment.centerRight,
            colors: [
              (hero['start']
                      as Color)
                  .withValues(
                alpha: 0.94,
              ),
              (hero['middle']
                      as Color)
                  .withValues(
                alpha: 0.66,
              ),
              (hero['end']
                      as Color)
                  .withValues(
                alpha: 0.18,
              ),
              Colors.transparent,
            ],
            stops: const [
              0.00,
              0.40,
              0.72,
              1.00,
            ],
          ),
        ),
      ),

      Padding(
        padding:
            const EdgeInsets
                .fromLTRB(
          16,
          13,
          16,
          13,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.18,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                hero['badge']
                    .toString(),
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              hero['title']
                  .toString(),
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 21,
                height: 1.04,
                fontWeight:
                    FontWeight.w900,
                letterSpacing:
                    -0.4,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              hero['subtitle']
                  .toString(),
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white
                    .withValues(
                  alpha: 0.84,
                ),
                fontSize: 10,
                height: 1.3,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                InkWell(
                  onTap:
                      _openCategories,
                  splashColor:
                      Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  highlightColor:
                      Colors.transparent,
                  borderRadius:
                      BorderRadius
                          .circular(
                    11,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: orange,
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        Text(
                          hero['button']
                              .toString(),
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                10.5,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons
                              .arrow_forward_rounded,
                          color:
                              Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  width: 9,
                ),

                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.14,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                    ),
                    child: Text(
                      hero['offer']
                          .toString(),
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);

}

// ============================================================
// SECTION TITLE
// ============================================================

Widget _buildSectionTitle({
required String title,
required VoidCallback onTap,
}) {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: Row(
children: [
Expanded(
child: Text(
title,
style:
const TextStyle(
color: dark,
fontSize: 16,
fontWeight:
FontWeight.w900,
),
),
),


      InkWell(
        onTap: onTap,
        child: const Padding(
          padding:
              EdgeInsets.all(4),
          child: Row(
            children: [
              Text(
                'See all',
                style: TextStyle(
                  color: teal,
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                color: teal,
                size: 10,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);

}

// ============================================================
// CATEGORY LIST
// ============================================================

Widget _buildCategories() {
final List<List<Color>> categoryColors = [
[const Color(0xFFFFE4E8), const Color(0xFFFFF3F5)],
[const Color(0xFFE2F7E7), const Color(0xFFF2FCF5)],
[const Color(0xFFE4F1FF), const Color(0xFFF3F8FF)],
[const Color(0xFFFFEDD9), const Color(0xFFFFF7ED)],
[const Color(0xFFFFEAF1), const Color(0xFFFFF6F9)],
[const Color(0xFFEDE9FF), const Color(0xFFF7F5FF)],
[const Color(0xFFE3F8F5), const Color(0xFFF4FFFD)],
[const Color(0xFFFFF1E5), const Color(0xFFFFFAF5)],
];


final List<IconData> categoryIcons = [
  Icons.apple_rounded,
  Icons.eco_rounded,
  Icons.local_drink_rounded,
  Icons.bakery_dining_rounded,
  Icons.fastfood_rounded,
  Icons.local_cafe_rounded,
  Icons.cleaning_services_rounded,
  Icons.spa_rounded,
];

final List<Color> iconColors = [
  const Color(0xFFE85E65),
  const Color(0xFF53A95C),
  const Color(0xFF3B82C4),
  const Color(0xFFD17A32),
  const Color(0xFFE4874E),
  const Color(0xFF7A5AF8),
  const Color(0xFF00AFA8),
  const Color(0xFFC05AA7),
];

return LayoutBuilder(
  builder: (context, constraints) {
    // Exactly 4 category cards remain visible.
    const horizontalPadding = 16.0;
    const gap = 9.0;

    final itemWidth =
        (constraints.maxWidth -
                (horizontalPadding * 2) -
                (gap * 3)) /
            4;

    return SizedBox(
      height: 126,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: gap),
        itemBuilder: (context, index) {
          final item = categories[index];

          final colors = categoryColors[
              index % categoryColors.length];

          final icon = categoryIcons[
              index % categoryIcons.length];

          final iconColor = iconColors[
              index % iconColors.length];

          return InkWell(
            onTap: () {
              _openCategory(
                item['name'].toString(),
              );
            },
            borderRadius:
                BorderRadius.circular(18),
            child: Container(
              width: itemWidth,
              padding:
                  const EdgeInsets.fromLTRB(
                5,
                8,
                5,
                7,
              ),
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // Bigger circular category image
                  Container(
                    width: 61,
                    height: 61,
                    padding:
                        const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 7,
                          offset:
                              const Offset(
                            0,
                            2,
                          ),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        item['image']
                            .toString(),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, _, _) {
                          return Container(
                            color: mint,
                            alignment:
                                Alignment.center,
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Small colored category icon
                  Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    item['name'].toString(),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: dark,
                      fontSize: 9.6,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  },
);

}

// ============================================================
// PRODUCT LIST
// ============================================================

Widget _buildProducts({
required List<Map<String, dynamic>>
products,
bool showDiscount = false,
}) {
return SizedBox(
height: 220,
child: ListView.separated(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
scrollDirection:
Axis.horizontal,
physics:
const BouncingScrollPhysics(),
itemCount: products.length,
separatorBuilder: (_, _) =>
const SizedBox(
width: 10,
),
itemBuilder:
(context, index) {
final product =
products[index];


      final List<Color>
          softColors = [
        const Color(
          0xFFE8F8F3,
        ),
        const Color(
          0xFFFFF3DE,
        ),
        const Color(
          0xFFEAF3FF,
        ),
        const Color(
          0xFFFFECF1,
        ),
        const Color(
          0xFFF1EDFF,
        ),
      ];

      final softColor =
          softColors[
              index %
                  softColors
                      .length];

      return ValueListenableBuilder<
          Set<String>>(
        valueListenable:
            FavoritesStore
                .favorites,
        builder: (
          context,
          favorites,
          child,
        ) {
          final isFavorite =
              _isFavorite(
            product,
          );

          return Material(
            color:
                Colors.transparent,
            child: InkWell(
              onTap: () {
                _openProduct(
                  product,
                );
              },
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
              child: Container(
                width: 142,
                padding:
                    const EdgeInsets
                        .all(
                  8,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                    22,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFE0EBE9,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withValues(
                        alpha:
                            0.04,
                      ),
                      blurRadius:
                          14,
                      offset:
                          const Offset(
                        0,
                        6,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double
                              .infinity,
                          height:
                              104,
                          clipBehavior:
                              Clip
                                  .antiAlias,
                          decoration:
                              BoxDecoration(
                            color:
                                softColor,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                          child:
                              Image.network(
                            product[
                                    'image']
                                .toString(),
                            fit:
                                BoxFit.cover,
                            errorBuilder:
                                (_, _, _) {
                              return Container(
                                color:
                                    softColor,
                                alignment:
                                    Alignment
                                        .center,
                                child:
                                    const Icon(
                                  Icons
                                      .shopping_basket_rounded,
                                  color:
                                      teal,
                                  size:
                                      42,
                                ),
                              );
                            },
                          ),
                        ),

                        if (showDiscount &&
                            product[
                                    'discount'] !=
                                null &&
                            product[
                                    'discount']
                                .toString()
                                .isNotEmpty)
                          Positioned(
                            left: 6,
                            top: 6,
                            child:
                                Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    7,
                                vertical:
                                    4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    orange,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                              ),
                              child:
                                  Text(
                                product[
                                        'discount']
                                    .toString(),
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      8,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                            ),
                          ),

                        Positioned(
                          top: 6,
                          right: 6,
                          child:
                              Material(
                            color:
                                Colors.white,
                            shape:
                                const CircleBorder(),
                            elevation:
                                2,
                            child:
                                InkWell(
                              customBorder:
                                  const CircleBorder(),
                              onTap:
                                  () {
                                _toggleFavorite(
                                  product,
                                );
                              },
                              child:
                                  SizedBox(
                                width:
                                    29,
                                height:
                                    29,
                                child:
                                    Icon(
                                  isFavorite
                                      ? Icons
                                          .favorite_rounded
                                      : Icons
                                          .favorite_border_rounded,
                                  color: isFavorite
                                      ? const Color(
                                          0xFFE85E65,
                                        )
                                      : const Color(
                                          0xFF657472,
                                        ),
                                  size:
                                      16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    SizedBox(
                      height: 27,
                      child: Text(
                        product[
                                'name']
                            .toString(),
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: dark,
                          fontSize:
                              11.5,
                          height:
                              1.18,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              Text(
                            product[
                                    'unit']
                                .toString(),
                            maxLines:
                                1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  grey,
                              fontSize:
                                  8.8,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons
                              .star_rounded,
                          color:
                              orange,
                          size: 12,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          '${product['rating'] ?? 4.7}',
                          style:
                              const TextStyle(
                            color:
                                grey,
                            fontSize:
                                8.5,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            mainAxisSize:
                                MainAxisSize
                                    .min,
                            children: [
                              Text(
                                '₹${product['price']}',
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      darkTeal,
                                  fontSize:
                                      13.5,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),

                              if (product[
                                          'oldPrice'] !=
                                      null &&
                                  product[
                                          'oldPrice'] !=
                                      product[
                                          'price'])
                                Text(
                                  'MRP ₹${product['oldPrice']}',
                                  maxLines:
                                      1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF9CA8A5,
                                    ),
                                    fontSize:
                                        7.8,
                                    decoration:
                                        TextDecoration
                                            .lineThrough,
                                  ),
                                )
                              else
                                const SizedBox(
                                  height:
                                      10,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        InkWell(
                          onTap: () {
                            CartStore.addProduct(product);
                            _showAddedMessage(
                              product[
                                      'name']
                                  .toString(),
                            );
                          },
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                          child:
                              Container(
                            width: 32,
                            height: 32,
                            decoration:
                                BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(
                                    0xFF18CABD,
                                  ),
                                  Color(
                                    0xFF08756E,
                                  ),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                11,
                              ),
                            ),
                            child:
                                const Icon(
                              Icons
                                  .add_rounded,
                              color:
                                  Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ),
);

}

// ============================================================
// OFFER
// ============================================================

Widget _buildOfferCard() {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(15),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
Color(0xFFFFF1D7),
Color(0xFFFFE4AF),
Color(0xFFFFF8EC),
],
),
borderRadius:
BorderRadius.circular(22),
),
child: Row(
children: [
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [
const Text(
'WEEKEND OFFER',
style: TextStyle(
color:
Color(0xFFD47B00),
fontSize: 9,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 7),
const Text(
'Get 25% OFF',
style: TextStyle(
color: dark,
fontSize: 19,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 4),
const Text(
'On fresh fruits & vegetables',
style: TextStyle(
color:
Color(0xFF796746),
fontSize: 10.5,
),
),
const SizedBox(height: 12),
InkWell(
onTap:
_openCategories,
child: const Text(
'Shop now  →',
style: TextStyle(
color: Color(
0xFFD47B00,
),
fontSize: 11,
fontWeight:
FontWeight.w900,
),
),
),
],
),
),


        Container(
          width: 88,
          height: 88,
          decoration:
              BoxDecoration(
            color: Colors.white
                .withValues(
              alpha: 0.65,
            ),
            shape:
                BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '25%\nOFF',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: orange,
                fontSize: 20,
                height: 1,
                fontWeight:
                    FontWeight.w900,
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
// FRESH BANNER
// ============================================================

Widget _buildFreshBanner() {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: Container(
padding:
const EdgeInsets.all(15),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
Color(0xFFE6F8F3),
Color(0xFFF0FFF9),
Color(0xFFEAF7FF),
],
),
borderRadius:
BorderRadius.circular(22),
),
child: const Row(
children: [
CircleAvatar(
radius: 29,
backgroundColor:
Colors.white,
child: Icon(
Icons.eco_rounded,
color:
Color(0xFF55B956),
size: 31,
),
),
SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [
Text(
'100% Fresh Promise',
style: TextStyle(
color: dark,
fontSize: 17,
fontWeight:
FontWeight.w900,
),
),
SizedBox(height: 6),
Text(
'Fresh products carefully selected for your everyday needs.',
style: TextStyle(
color: grey,
fontSize: 10.5,
height: 1.4,
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
// FREE DELIVERY
// ============================================================

Widget _buildMiniOfferBanner() {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: Container(
padding:
const EdgeInsets.all(15),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
darkGreen,
darkTeal,
teal,
],
),
borderRadius:
BorderRadius.circular(22),
),
child: Row(
children: [
Container(
width: 52,
height: 52,
decoration:
BoxDecoration(
color: Colors.white
.withValues(
alpha: 0.14,
),
borderRadius:
BorderRadius.circular(
16,
),
),
child: const Icon(
Icons
.delivery_dining_rounded,
color: Colors.white,
size: 24,
),
),


        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              const Text(
                'Free Delivery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'On orders above ₹499',
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.75,
                  ),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons
              .arrow_forward_ios_rounded,
          color: Colors.white,
          size: 15,
        ),
      ],
    ),
  ),
);

}

// ============================================================
// BENEFITS
// ============================================================

Widget _buildDeliveryBenefits() {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: Container(
padding:
const EdgeInsets.symmetric(
horizontal: 8,
vertical: 14,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color:
const Color(0xFFE3ECEA),
),
),
child: const Row(
children: [
Expanded(
child: _BenefitItem(
icon: Icons
.delivery_dining_rounded,
title: 'Fast',
subtitle: 'Delivery',
color:
Color(0xFF4388E6),
background:
Color(0xFFEAF3FF),
),
),
_BenefitDivider(),
Expanded(
child: _BenefitItem(
icon:
Icons.verified_rounded,
title: 'Fresh',
subtitle: 'Quality',
color:
Color(0xFF55B956),
background:
Color(0xFFE9F9EC),
),
),
_BenefitDivider(),
Expanded(
child: _BenefitItem(
icon:
Icons.payments_outlined,
title: 'Secure',
subtitle: 'Payment',
color:
Color(0xFF7C65E8),
background:
Color(0xFFF1EDFF),
),
),
],
),
),
);
}

Widget _buildEndMessage() {
return const Center(
child: Padding(
padding:
EdgeInsets.symmetric(
vertical: 8,
),
child: Column(
children: [
Icon(
Icons.eco_rounded,
color: teal,
size: 20,
),
SizedBox(height: 5),
Text(
'Fresh groceries, faster to you.',
style: TextStyle(
color:
Color(0xFF9AA5A3),
fontSize: 9.5,
),
),
],
),
),
);
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

void _handleBottomTap(int index) {
if (index == 0) {
setState(() {
_selectedBottomIndex = 0;
});
return;
}


setState(() {
  _selectedBottomIndex = index;
});

switch (index) {
  case 1:
    _openCategories();
    break;

  case 2:
    _openCart();
    break;

  case 3:
    _openOrders();
    break;

  case 4:
    _openProfile();
    break;
}

Future.delayed(
  const Duration(
    milliseconds: 200,
  ),
  () {
    if (mounted) {
      setState(() {
        _selectedBottomIndex = 0;
      });
    }
  },
);

}

Widget _buildBottomNavigation() {
return SafeArea(
top: false,
child: Container(
height: 62,
margin:
const EdgeInsets.fromLTRB(
12,
0,
12,
10,
),
padding:
const EdgeInsets.symmetric(
horizontal: 4,
vertical: 3,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(22),
border: Border.all(
color:
const Color(0xFFE3ECEA),
),
boxShadow: [
BoxShadow(
color: Colors.black
.withValues(
alpha: 0.07,
),
blurRadius: 22,
offset:
const Offset(0, 8),
),
],
),
child: Row(
children: [
Expanded(
child: _navItem(
index: 0,
icon:
Icons.home_rounded,
label: 'Home',
),
),
Expanded(
child: _navItem(
index: 1,
icon: Icons
.grid_view_rounded,
label: 'Categories',
),
),
Expanded(
child: _cartNavItem(),
),
Expanded(
child: _navItem(
index: 3,
icon: Icons
.receipt_long_rounded,
label: 'Orders',
),
),
Expanded(
child: _navItem(
index: 4,
icon: Icons
.person_rounded,
label: 'Profile',
),
),
],
),
),
);
}

Widget _navItem({
required int index,
required IconData icon,
required String label,
}) {
final active =
_selectedBottomIndex == index;


return InkWell(
  onTap: () {
    _handleBottomTap(index);
  },
  borderRadius:
      BorderRadius.circular(15),
  child: SizedBox(
    height: 52,
    child: Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: active
              ? teal
              : const Color(
                  0xFF879390,
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8.8,
            color: active
                ? darkTeal
                : const Color(
                    0xFF879390,
                  ),
            fontWeight: active
                ? FontWeight.w900
                : FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
);

}

Widget _cartNavItem() {
return InkWell(
onTap: () {
_handleBottomTap(2);
},
borderRadius:
BorderRadius.circular(18),
child: SizedBox(
height: 54,
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Container(
width: 38,
height: 38,
decoration:
BoxDecoration(
gradient:
const LinearGradient(
colors: [
Color(
0xFF18CABD,
),
Color(
0xFF08756E,
),
],
),
borderRadius:
BorderRadius.circular(
13,
),
),
child: const Icon(
Icons
.shopping_cart_rounded,
color: Colors.white,
size: 21,
),
),
const SizedBox(height: 2),
const Text(
'Cart',
style: TextStyle(
color: darkTeal,
fontSize: 8.5,
fontWeight:
FontWeight.w900,
),
),
],
),
),
);
}
}

// ============================================================
// BENEFIT ITEM
// ============================================================

class _BenefitItem
extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
final Color color;
final Color background;

const _BenefitItem({
required this.icon,
required this.title,
required this.subtitle,
required this.color,
required this.background,
});

@override
Widget build(BuildContext context) {
return Column(
children: [
Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color: background,
borderRadius:
BorderRadius.circular(
13,
),
),
child: Icon(
icon,
color: color,
size: 21,
),
),
const SizedBox(height: 7),
Text(
title,
style:
const TextStyle(
color:
Color(0xFF172321),
fontSize: 10.5,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 2),
Text(
subtitle,
style:
const TextStyle(
color:
Color(0xFF75837F),
fontSize: 8.5,
),
),
],
);
}
}

class _BenefitDivider
extends StatelessWidget {
const _BenefitDivider();

@override
Widget build(BuildContext context) {
return Container(
width: 1,
height: 48,
color:
const Color(0xFFE4ECEA),
);
}
}