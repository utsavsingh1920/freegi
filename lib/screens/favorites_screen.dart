import 'package:flutter/material.dart';

import '../data/cart_store.dart';
import '../data/favorites_store.dart';
import 'product/product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onExploreProducts;

  const FavoritesScreen({
    super.key,
    this.onExploreProducts,
  });

  static const Color teal =
      Color(0xFF00AFA8);

  static const Color darkTeal =
      Color(0xFF08756E);

  static const Color darkGreen =
      Color(0xFF075C50);

  static const Color darkText =
      Color(0xFF172321);

  static const Color subText =
      Color(0xFF71807D);

  static const Color background =
      Color(0xFFF8FCFA);

  static const Color borderColor =
      Color(0xFFE2ECEA);

  static const Color lightMint =
      Color(0xFFE9F8F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: ValueListenableBuilder<
                  Set<String>>(
                valueListenable:
                    FavoritesStore.favorites,
                builder: (
                  context,
                  favorites,
                  _,
                ) {
                  if (favorites.isEmpty) {
                    return _buildEmptyState(
                      context,
                    );
                  }

                  return ValueListenableBuilder<
                      List<
                          Map<String,
                              dynamic>>>(
                    valueListenable:
                        FavoritesStore
                            .favoriteProducts,
                    builder: (
                      context,
                      products,
                      _,
                    ) {
                      return _buildFavoritesList(
                        context,
                        favorites,
                        products,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        10,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () =>
                Navigator.maybePop(
              context,
            ),
            borderRadius:
                BorderRadius.circular(13),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                size: 17,
                color: darkText,
              ),
            ),
          ),

          const Expanded(
            child: Column(
              children: [
                Text(
                  'My Favorites',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your saved grocery picks',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 40,
            height: 40,
            decoration:
                const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: teal,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        24,
        42,
        24,
        24,
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),

          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 24,
                  offset:
                      const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment:
                  Alignment.center,
              children: [
                const Icon(
                  Icons
                      .shopping_basket_rounded,
                  color: teal,
                  size: 54,
                ),

                Positioned(
                  right: 22,
                  top: 24,
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      shape:
                          BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons
                          .favorite_rounded,
                      color: teal,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'No favorites yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 9),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Text(
              'Save the groceries you love and find them quickly whenever you shop.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 12,
                height: 1.55,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (onExploreProducts !=
                    null) {
                  onExploreProducts!();
                  return;
                }

                if (Navigator.canPop(
                  context,
                )) {
                  Navigator.pop(
                    context,
                  );
                }
              },
              style:
                  ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: teal,
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              child: const Text(
                'Explore Products',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          _buildBenefits(),
        ],
      ),
    );
  }

  // ============================================================
  // BENEFITS
  // ============================================================

  Widget _buildBenefits() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _BenefitItem(
              icon: Icons
                  .favorite_outline_rounded,
              title: 'Save',
              subtitle: 'Your picks',
            ),
          ),

          _BenefitDivider(),

          Expanded(
            child: _BenefitItem(
              icon:
                  Icons.flash_on_rounded,
              title: 'Quick',
              subtitle: 'Easy access',
            ),
          ),

          _BenefitDivider(),

          Expanded(
            child: _BenefitItem(
              icon: Icons
                  .shopping_bag_outlined,
              title: 'Shop',
              subtitle: 'Anytime',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAVORITES LIST
  // ============================================================

  Widget _buildFavoritesList(
    BuildContext context,
    Set<String> favoriteNames,
    List<Map<String, dynamic>>
        products,
  ) {
    final List<Map<String, dynamic>>
        availableProducts =
        products.where(
      (product) {
        return favoriteNames.contains(
          FavoritesStore.key(
            product,
          ),
        );
      },
    ).toList();

    return ListView(
      physics:
          const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        26,
      ),
      children: [
        Row(
          children: [
            const Text(
              'Saved Products',
              style: TextStyle(
                color: darkText,
                fontSize: 16,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const Spacer(),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color: lightMint,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                '${favoriteNames.length} '
                '${favoriteNames.length == 1 ? 'item' : 'items'}',
                style:
                    const TextStyle(
                  color: darkTeal,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Complete product cards
        ...availableProducts.map(
          (product) =>
              _FavoriteProductCard(
            product: product,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailsScreen(
                    product:
                        Map<String,
                            dynamic>.from(
                      product,
                    ),
                  ),
                ),
              );
            },

            onRemove: () {
              FavoritesStore.remove(
                product,
              );
            },

            onAddToCart: () {
              CartStore.addProduct(
                product,
              );

              ScaffoldMessenger.of(
                context,
              )
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      '${product['name']} added to cart',
                    ),
                  ),
                );
            },
          ),
        ),

        // Old saved favorites may only have names.
        // They stay visible instead of disappearing.
        ...favoriteNames
            .where(
          (name) =>
              !availableProducts.any(
            (product) =>
                FavoritesStore.key(
                  product,
                ) ==
                name,
          ),
        )
            .map(
          (productName) =>
              _LegacyFavoriteCard(
            productName:
                productName,
            onRemove: () {
              FavoritesStore
                  .removeByName(
                productName,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COMPLETE FAVORITE PRODUCT CARD
// ============================================================

class _FavoriteProductCard
    extends StatelessWidget {
  final Map<String, dynamic> product;

  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _FavoriteProductCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
    required this.onAddToCart,
  });

  String get name =>
      product['name']
          ?.toString() ??
      'Product';

  String get unit =>
      product['unit']
          ?.toString() ??
      '';

  String get image =>
      product['image']
          ?.toString() ??
      '';

  double get price =>
      _number(
        product['price'],
      );

  double get oldPrice =>
      _number(
        product['oldPrice'],
      );

  String get discount =>
      product['discount']
          ?.toString() ??
      '';

  static double _number(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value
              ?.toString()
              .replaceAll(
                RegExp(
                  r'[^0-9.]',
                ),
                '',
              ) ??
              '',
        ) ??
        0;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              FavoritesScreen
                  .borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(18),
          child: Padding(
            padding:
                const EdgeInsets.all(
              11,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .center,
              children: [
                // Product image
                Container(
                  width: 76,
                  height: 76,
                  clipBehavior:
                      Clip.antiAlias,
                  decoration:
                      BoxDecoration(
                    color:
                        FavoritesScreen
                            .lightMint,
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),
                  child: image.isEmpty
                      ? const Icon(
                          Icons
                              .shopping_basket_rounded,
                          color:
                              FavoritesScreen
                                  .teal,
                          size: 30,
                        )
                      : Image.network(
                          image,
                          fit:
                              BoxFit.cover,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .shopping_basket_rounded,
                              color:
                                  FavoritesScreen
                                      .teal,
                              size: 30,
                            );
                          },
                        ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // Product information
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    FavoritesScreen
                                        .darkText,
                                fontSize:
                                    13.5,
                                height: 1.2,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          InkWell(
                            onTap:
                                onRemove,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            child:
                                const Padding(
                              padding:
                                  EdgeInsets
                                      .all(
                                4,
                              ),
                              child: Icon(
                                Icons
                                    .favorite_rounded,
                                color:
                                    Color(
                                  0xFFE85469,
                                ),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (unit.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 4,
                          ),
                          child: Text(
                            unit,
                            style:
                                const TextStyle(
                              color:
                                  FavoritesScreen
                                      .subText,
                              fontSize:
                                  10,
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style:
                                const TextStyle(
                              color:
                                  FavoritesScreen
                                      .darkTeal,
                              fontSize:
                                  15,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),

                          if (oldPrice >
                              price) ...[
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              '₹${oldPrice.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF9AA4A2,
                                ),
                                fontSize:
                                    10,
                                decoration:
                                    TextDecoration
                                        .lineThrough,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],

                          const Spacer(),

                          InkWell(
                            onTap:
                                onAddToCart,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              11,
                            ),
                            child:
                                Container(
                              height: 34,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    11,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    FavoritesScreen
                                        .teal,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  11,
                                ),
                              ),
                              child:
                                  const Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,
                                children: [
                                  Icon(
                                    Icons
                                        .add_shopping_cart_rounded,
                                    color:
                                        Colors
                                            .white,
                                    size:
                                        15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Add',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .white,
                                      fontSize:
                                          10,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (discount
                          .isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 5,
                          ),
                          child: Text(
                            discount,
                            style:
                                const TextStyle(
                              color:
                                  FavoritesScreen
                                      .darkTeal,
                              fontSize:
                                  8.5,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LEGACY NAME-ONLY FAVORITE
// ============================================================

class _LegacyFavoriteCard
    extends StatelessWidget {
  final String productName;
  final VoidCallback onRemove;

  const _LegacyFavoriteCard({
    required this.productName,
    required this.onRemove,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              FavoritesScreen
                  .borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                BoxDecoration(
              color:
                  FavoritesScreen
                      .lightMint,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons
                  .local_grocery_store_rounded,
              color:
                  FavoritesScreen.teal,
              size: 25,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              productName,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color:
                    FavoritesScreen
                        .darkText,
                fontSize: 13,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          IconButton(
            onPressed: onRemove,
            tooltip:
                'Remove from favorites',
            icon: const Icon(
              Icons.favorite_rounded,
              color:
                  Color(0xFFE85469),
              size: 21,
            ),
          ),
        ],
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

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              FavoritesScreen.teal,
          size: 20,
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style:
              const TextStyle(
            color:
                FavoritesScreen
                    .darkText,
            fontSize: 10.5,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                FavoritesScreen
                    .subText,
            fontSize: 8.5,
            fontWeight:
                FontWeight.w500,
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 1,
      height: 38,
      color:
          FavoritesScreen
              .borderColor,
    );
  }
}