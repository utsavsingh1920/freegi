import 'package:flutter/material.dart';

import '../../models/freegi_order.dart';
import '../../data/cart_store.dart';
import '../checkout/checkout_screen.dart';
import '../offers/offers_screen.dart';

class CartScreen extends StatefulWidget {
  final bool showBottomNavigation;
  final VoidCallback? onContinueShopping;

  const CartScreen({
    super.key,
    this.showBottomNavigation = true,
    this.onContinueShopping,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color orange = Color(0xFFFFA928);
  static const Color green = Color(0xFF4CA859);
  static const Color danger = Color(0xFFE06A6A);

  List<Map<String, dynamic>> get cartItems => CartStore.cartItems.value;

  // ============================================================
  // YOU MAY ALSO LIKE
  // ============================================================

  final List<Map<String, dynamic>> recommendedProducts = [
    {
      'name': 'Fresh Apple',
      'unit': '1 kg',
      'price': 120,
      'image': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=500&q=90',
    },
    {
      'name': 'Sweet Orange',
      'unit': '1 kg',
      'price': 90,
      'image': 'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&w=500&q=90',
    },
    {
      'name': 'Fresh Tomato',
      'unit': '500 g',
      'price': 45,
      'image': 'https://images.unsplash.com/photo-1561136594-7f68413baa99?auto=format&fit=crop&w=500&q=90',
    },
    {
      'name': 'Fresh Potato',
      'unit': '1 kg',
      'price': 30,
      'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=500&q=90',
    },
    {
      'name': 'Brown Bread',
      'unit': '400 g',
      'price': 48,
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=500&q=90',
    },
    {
      'name': 'Farm Eggs',
      'unit': '6 pcs',
      'price': 72,
      'image': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=500&q=90',
    },
  ];

  int get subtotal {
    var result = 0;

    for (final item in cartItems) {
      result += (item['price'] as int) * (item['quantity'] as int);
    }

    return result;
  }

  int get discount {
    if (subtotal >= 300) {
      return 40;
    }
    return 0;
  }

  int get deliveryFee {
    if (subtotal == 0) {
      return 0;
    }

    if (subtotal >= 500) {
      return 0;
    }

    return 35;
  }

  int get total {
    return subtotal - discount + deliveryFee;
  }

  void _increaseQuantity(int index) {
    CartStore.increaseQuantity(index);
  }

  void _decreaseQuantity(int index) {
    CartStore.decreaseQuantity(index);
  }

  void _removeItem(int index) {
    final name = cartItems[index]['name'].toString();

    CartStore.removeAt(index);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$name removed from cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _clearAllCart() async {
    if (cartItems.isEmpty) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Clear cart?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) return;

    for (int i = cartItems.length - 1; i >= 0; i--) {
      CartStore.removeAt(i);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Cart cleared'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _addRecommendedToCart(Map<String, dynamic> product) {
    CartStore.addProduct(product);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product['name']} added to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _proceedToCheckout() {
    if (cartItems.isEmpty) {
      return;
    }

    final List<FreegiOrderItem> checkoutItems = cartItems.map((item) {
      return FreegiOrderItem(
        name: item['name']?.toString() ?? '',
        unit: item['unit']?.toString() ?? '',
        price: (item['price'] as num?)?.toInt() ?? 0,
        quantity: (item['quantity'] as num?)?.toInt() ?? 1,
        image: item['image']?.toString() ?? '',
      );
    }).toList();

    const int platformFee = 5;

    final int checkoutTotal = subtotal - discount + deliveryFee + platformFee;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: checkoutItems,
          itemTotal: subtotal,
          discount: discount,
          deliveryFee: deliveryFee,
          platformFee: platformFee,
          totalAmount: checkoutTotal,
        ),
      ),
    );
  }

  Future<void> _openCoupons() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const OffersScreen()));
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FCFA);

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: CartStore.cartItems,
      builder: (context, _, _) {
        return Scaffold(
          backgroundColor: background,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: cartItems.isEmpty
                      ? _buildEmptyCart()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            2,
                            16,
                            widget.showBottomNavigation ? 118 : 188,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSavingsBanner(),
                              const SizedBox(height: 8),
                              _buildItemCount(),
                              const SizedBox(height: 8),

                              ...List.generate(cartItems.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: _buildCartItem(index),
                                );
                              }),

                              const SizedBox(height: 2),
                              _buildCouponCard(),
                              const SizedBox(height: 10),
                              _buildBillDetails(),
                              const SizedBox(height: 6),
                              _buildDeliveryNote(),
                              const SizedBox(height: 13),
                              _buildRecommendationTitle(),
                              const SizedBox(height: 8),
                              _buildRecommendations(),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              cartItems.isEmpty ? null : _buildBottomBar(),
        );
      },
    );
  }


  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Review your items',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subText,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (cartItems.isNotEmpty)
              Positioned(
                right: 0,
                child: InkWell(
                  onTap: _clearAllCart,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: danger,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsBanner() {
    return Container(
      width: double.infinity,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F8EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4F0DF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            color: Color(0xFF28A96B),
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              "You're saving ₹$discount on this order!",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF23865B),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // ITEM COUNT
  // ============================================================

  Widget _buildItemCount() {
    const textColor = Color(0xFF172321);

    return Row(
      children: [
        Text(
          '${cartItems.length} Items',
          style: TextStyle(
            color: textColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),

        const Spacer(),

        Text(
          'Subtotal ₹$subtotal',
          style: const TextStyle(
            color: teal,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _buildCartItem(int index) {
    final item = cartItems[index];

    final itemPrice = item['price'] as int;

    final quantity = item['quantity'] as int;

    final itemTotal = itemPrice * quantity;

    const surface = Colors.white;

    const border = Color(0xFFE2ECEA);

    const textColor = Color(0xFF172321);

    const subText = Color(0xFF71807D);

    const imageBackground = Color(0xFFF2F7F6);

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                item['image'].toString(),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: imageBackground,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: teal,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, _, _) {
                  return Container(
                    color: imageBackground,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shopping_basket_outlined,
                      color: teal,
                      size: 34,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        _removeItem(index);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: danger,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  item['unit'].toString(),
                  style: TextStyle(
                    color: subText,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      '₹$itemTotal',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const Spacer(),

                    _quantityButton(
                      icon: Icons.remove_rounded,
                      enabled: quantity > 1,
                      onTap: () {
                        _decreaseQuantity(index);
                      },
                    ),

                    SizedBox(
                      width: 28,
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    _quantityButton(
                      icon: Icons.add_rounded,
                      enabled: true,
                      primary: true,
                      onTap: () {
                        _increaseQuantity(index);
                      },
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

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    const inactiveBackground = Color(0xFFF1F6F5);

    const inactiveText = Color(0xFF172321);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: primary ? teal : inactiveBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 17,
          color: !enabled
              ? const Color(0xFF8A9694)
              : primary
              ? Colors.white
              : inactiveText,
        ),
      ),
    );
  }

  // ============================================================
  // COUPON CARD
  // ============================================================

  Widget _buildCouponCard() {
    const cardColor = Color(0xFFFFF4E0);

    const circleColor = Colors.white;

    const textColor = Color(0xFF172321);

    const subText = Color(0xFF71807D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openCoupons();
        },
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFFFE6BA)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: orange,
                  size: 21,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply Coupon',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Save more on your order',
                      style: TextStyle(
                        color: subText,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: _openCoupons,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Apply',
                        style: TextStyle(
                          color: orange,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: orange,
                        size: 11,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BILL DETAILS
  // ============================================================

  Widget _buildBillDetails() {
    const surface = Colors.white;

    const border = Color(0xFFE2ECEA);

    const textColor = Color(0xFF172321);

    const subText = Color(0xFF71807D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 15),

          _billRow(
            'Item Total',
            '₹$subtotal',
            textColor: textColor,
            subText: subText,
          ),

          const SizedBox(height: 11),

          _billRow(
            'Discount',
            discount > 0 ? '- ₹$discount' : '₹0',
            textColor: textColor,
            subText: subText,
            valueColor: discount > 0 ? green : textColor,
          ),

          const SizedBox(height: 11),

          _billRow(
            'Delivery Fee',
            deliveryFee == 0 ? 'FREE' : '₹$deliveryFee',
            textColor: textColor,
            subText: subText,
            valueColor: deliveryFee == 0 ? green : textColor,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: const Color(0xFFE4ECEA)),
          ),

          _billRow(
            'Total Amount',
            '₹$total',
            textColor: textColor,
            subText: subText,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String label,
    String value, {
    required Color textColor,
    required Color subText,
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? textColor : subText,
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textColor,
            fontSize: bold ? 16 : 12,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DELIVERY NOTE
  // ============================================================

  Widget _buildDeliveryNote() {
    const cardColor = Color(0xFFE8F8F5);

    const textColor = Color(0xFF71807D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining_rounded, color: teal, size: 25),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Fresh groceries will be packed carefully and delivered safely.',
              style: TextStyle(
                color: textColor,
                fontSize: 10.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // YOU MAY ALSO LIKE
  // ============================================================

  Widget _buildRecommendationTitle() {
    const textColor = Color(0xFF172321);

    return Row(
      children: [
        const Icon(Icons.favorite_rounded, color: Color(0xFFE85E65), size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'You may also like',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Text(
          'See all',
          style: TextStyle(
            color: teal,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 3),
        const Icon(Icons.arrow_forward_ios_rounded, color: teal, size: 9),
      ],
    );
  }

  Widget _buildRecommendations() {
    final screenWidth = MediaQuery.of(context).size.width;

    // 16px left + 16px right content padding, plus 3 gaps.
    // This makes four recommendation cards visible together.
    final cardWidth = (screenWidth - 32 - (8 * 3)) / 4;

    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recommendedProducts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final product = recommendedProducts[index];
          return _recommendationCard(product, cardWidth);
        },
      ),
    );
  }

  Widget _recommendationCard(Map<String, dynamic> product, double width) {
    const surface = Colors.white;
    const border = Color(0xFFE1EBE9);
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);
    const imageBg = Color(0xFFF1F8F6);

    return Container(
      width: width,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: double.infinity,
              height: 70,
              child: Image.network(
                product['image'].toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: imageBg,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shopping_basket_outlined,
                      color: teal,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            product['name'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 9.2,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            product['unit'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: subText, fontSize: 7.8),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: Text(
                  '₹${product['price']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkTeal,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _addRecommendedToCart(product);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHECKOUT ACTION BAR
  // ============================================================

  Widget _buildBottomBar() {
    const surface = Colors.white;
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        7,
        16,
        widget.showBottomNavigation ? 8 : 82,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.13)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: subText,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '₹$total',
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Proceed to Checkout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 17),
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


  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _buildEmptyCart() {
    const textColor = Color(0xFF172321);
    const subText = Color(0xFF71807D);
    const softMint = Color(0xFFE7F8F4);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            widget.showBottomNavigation ? 120 : 36,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  (widget.showBottomNavigation ? 120 : 36),
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),

                // Friendly empty-cart illustration built only with Flutter.
                // No extra image asset is required.
                SizedBox(
                  width: 260,
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 8,
                        child: Container(
                          width: 210,
                          height: 185,
                          decoration: const BoxDecoration(
                            color: softMint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 18,
                        top: 58,
                        child: Icon(
                          Icons.eco_rounded,
                          color: Color(0xFFB8E8DC),
                          size: 44,
                        ),
                      ),
                      const Positioned(
                        right: 16,
                        bottom: 25,
                        child: Icon(
                          Icons.eco_rounded,
                          color: Color(0xFFC5EEE5),
                          size: 52,
                        ),
                      ),
                      Positioned(
                        top: 52,
                        child: Container(
                          width: 126,
                          height: 94,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: teal, width: 5),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sentiment_satisfied_alt_rounded,
                                    color: darkTeal,
                                    size: 34,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 135,
                        child: Icon(
                          Icons.shopping_cart_rounded,
                          color: teal,
                          size: 78,
                        ),
                      ),
                      const Positioned(
                        right: 20,
                        top: 16,
                        child: Icon(
                          Icons.near_me_outlined,
                          color: Color(0xFF70BFAE),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Your cart is empty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Add some fresh groceries to continue shopping.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subText,
                    fontSize: 11.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onContinueShopping != null) {
                        widget.onContinueShopping!();
                        return;
                      }

                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _EmptyCartBenefit(
                      icon: Icons.eco_rounded,
                      title: 'Fresh\nProducts',
                    ),
                    _EmptyCartBenefit(
                      icon: Icons.local_shipping_outlined,
                      title: 'Fast\nDelivery',
                    ),
                    _EmptyCartBenefit(
                      icon: Icons.verified_user_outlined,
                      title: 'Safe &\nSecure',
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Shop Fresh • Live Better',
                      style: TextStyle(
                        color: darkTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.eco_rounded, color: teal, size: 15),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyCartBenefit extends StatelessWidget {
  final IconData icon;
  final String title;

  const _EmptyCartBenefit({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00AFA8);
    const darkTeal = Color(0xFF08756E);
    const subText = Color(0xFF71807D);

    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F8F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: darkTeal, size: 23),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: subText,
              fontSize: 9.5,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 12,
            height: 2,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}