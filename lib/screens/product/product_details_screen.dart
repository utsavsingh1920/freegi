import 'package:flutter/material.dart';

import '../../data/cart_store.dart';
import '../../data/favorites_store.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color orange = Color(0xFFFFA928);
  static const Color purple = Color(0xFF7C65E8);
  static const Color pink = Color(0xFFFF6F91);
  static const Color bg = Color(0xFFF7FBFA);
  static const Color dark = Color(0xFF172321);
  static const Color grey = Color(0xFF75837F);

  int quantity = 1;

  String get name =>
      widget.product['name']?.toString() ?? 'Product';

  String get unit =>
      widget.product['unit']?.toString() ?? '';

  String get image =>
      widget.product['image']?.toString() ?? '';

  double get price {
    final value = widget.product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll(
                RegExp(r'[^0-9.]'),
                '',
              ),
        ) ??
        0;
  }

  double get oldPrice {
    final value =
        widget.product['oldPrice'] ?? widget.product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll(
                RegExp(r'[^0-9.]'),
                '',
              ),
        ) ??
        price;
  }

  double get rating {
    final value = widget.product['rating'] ?? 4.7;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 4.7;
  }

  String get discount =>
      widget.product['discount']?.toString() ?? '';

  double get total => price * quantity;

  void _addToCart() {
    CartStore.addProduct(
      widget.product,
      quantity: quantity,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$quantity × $name added to cart',
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _toggleFavorite() {
    final wasFavorite =
        FavoritesStore.contains(widget.product);

    FavoritesStore.toggle(widget.product);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            wasFavorite
                ? '$name removed from Favorites'
                : '$name added to Favorites',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),

                    Transform.translate(
                      offset: const Offset(0, -18),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          24,
                          20,
                          26,
                        ),
                        decoration: const BoxDecoration(
                          color: bg,
                          borderRadius:
                              BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildProductTitle(),

                            const SizedBox(height: 18),

                            _buildPriceRow(),

                            const SizedBox(height: 20),

                            _buildQuantityCard(),

                            const SizedBox(height: 22),

                            _buildColorfulBenefits(),

                            const SizedBox(height: 22),

                            _buildAboutCard(),

                            const SizedBox(height: 18),

                            _buildDeliveryCard(),

                            const SizedBox(height: 18),

                            _buildQualityCard(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomCartBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return SizedBox(
      height: 330,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFFE9F7F4),
            child: image.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.shopping_basket_rounded,
                      color: teal,
                      size: 80,
                    ),
                  )
                : Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return const Center(
                        child: Icon(
                          Icons.shopping_basket_rounded,
                          color: teal,
                          size: 80,
                        ),
                      );
                    },
                  ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.24,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 14,
            left: 16,
            child: _circleButton(
              icon:
                  Icons.arrow_back_ios_new_rounded,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          Positioned(
            top: 14,
            right: 16,
            child: ValueListenableBuilder<Set<String>>(
              valueListenable:
                  FavoritesStore.favorites,
              builder: (
                context,
                favorites,
                child,
              ) {
                final liked =
                    FavoritesStore.contains(
                  widget.product,
                );

                return _circleButton(
                  icon: liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: liked
                      ? const Color(0xFFE85469)
                      : dark,
                  onTap: _toggleFavorite,
                );
              },
            ),
          ),

          if (discount.isNotEmpty)
            Positioned(
              left: 18,
              bottom: 32,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFA928),
                      Color(0xFFFF7A45),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: orange.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = dark,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: iconColor,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _buildProductTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: dark,
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                unit,
                style: const TextStyle(
                  color: grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4DC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: orange,
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Wrap(
      crossAxisAlignment:
          WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: darkTeal,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),

        if (oldPrice > price)
          Text(
            '₹${oldPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFF9AA4A2),
              fontSize: 14,
              decoration:
                  TextDecoration.lineThrough,
              fontWeight: FontWeight.w600,
            ),
          ),

        if (oldPrice > price)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F8F2),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: const Text(
              'SAVE MORE',
              style: TextStyle(
                color: darkTeal,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8FAF6),
            Color(0xFFF5FFFC),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD3EEE8),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity',
                  style: TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Choose required quantity',
                  style: TextStyle(
                    color: grey,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFDDE9E7),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quantityButton(
                  Icons.remove_rounded,
                  () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                ),

                SizedBox(
                  width: 34,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                _quantityButton(
                  Icons.add_rounded,
                  () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(
          icon,
          color: teal,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildColorfulBenefits() {
    return Row(
      children: [
        Expanded(
          child: _benefitCard(
            icon: Icons.eco_rounded,
            title: 'Fresh',
            subtitle: 'Quality',
            background:
                const Color(0xFFE9F9EC),
            iconColor:
                const Color(0xFF55B75A),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _benefitCard(
            icon:
                Icons.delivery_dining_rounded,
            title: 'Fast',
            subtitle: 'Delivery',
            background:
                const Color(0xFFE8F4FF),
            iconColor:
                const Color(0xFF4388E6),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _benefitCard(
            icon:
                Icons.verified_user_rounded,
            title: 'Safe',
            subtitle: 'Payment',
            background:
                const Color(0xFFF2EDFF),
            iconColor: purple,
          ),
        ),
      ],
    );
  }

  Widget _benefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              color: dark,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            style: const TextStyle(
              color: grey,
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2ECEA),
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'About this product',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Carefully selected fresh grocery product with quality checks to give you a great everyday shopping experience.',
            style: TextStyle(
              color: grey,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5FF),
            Color(0xFFF4FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.delivery_dining_rounded,
              color: Color(0xFF3786DD),
              size: 26,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Fast delivery',
                  style: TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Fresh groceries delivered quickly to your doorstep.',
                  style: TextStyle(
                    color: grey,
                    fontSize: 9.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF0F4),
            Color(0xFFFFF8FA),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.favorite_rounded,
              color: pink,
              size: 24,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Freegi quality promise',
                  style: TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Freshness and quality carefully checked before delivery.',
                  style: TextStyle(
                    color: grey,
                    fontSize: 9.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCartBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.07,
            ),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: grey,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: dark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 5,
              child: InkWell(
                onTap: _addToCart,
                borderRadius:
                    BorderRadius.circular(16),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF00B9AD),
                        Color(0xFF08756E),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: teal.withValues(
                          alpha: 0.26,
                        ),
                        blurRadius: 14,
                        offset:
                            const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .shopping_cart_checkout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}