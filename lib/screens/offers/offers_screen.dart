import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/coupon_store.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color green = Color(0xFF079A70);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color borderColor = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE8F8F4);
  static const Color orange = Color(0xFFFFA928);

  int selectedTab = 0;
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> coupons = const [
    {
      'code': 'FREEGI50',
      'title': '₹50 OFF',
      'subtitle': 'On orders above ₹399',
      'description': 'Get ₹50 instant discount on eligible grocery orders.',
      'expiry': 'Valid till 30 Sep',
      'category': 'Grocery',
      'badge': '🔥 Most Popular',
      'icon': Icons.local_offer_rounded,
      'color': Color(0xFF079A70),
      'bg': Color(0xFFE8F8F4),
    },
    {
      'code': 'FRESH20',
      'title': '20% OFF',
      'subtitle': 'On Fruits & Vegetables',
      'description': 'Save up to ₹100 on fresh fruits and vegetables.',
      'expiry': 'Valid till 25 Sep',
      'category': 'Fruits & Veg',
      'badge': '🌿 Fruits & Veg',
      'icon': Icons.shopping_cart_rounded,
      'color': Color(0xFFE84E72),
      'bg': Color(0xFFFFEDF2),
    },
    {
      'code': 'WELCOME100',
      'title': '₹100 OFF',
      'subtitle': 'For new users',
      'description': 'Get ₹100 off on your first eligible Freegi order.',
      'expiry': 'Limited period',
      'category': 'Grocery',
      'badge': '★ New User Offer',
      'icon': Icons.card_giftcard_rounded,
      'color': Color(0xFF7A5AF8),
      'bg': Color(0xFFF0ECFF),
    },
    {
      'code': 'FREEDEL',
      'title': 'FREE DELIVERY',
      'subtitle': 'On orders above ₹299',
      'description': 'Enjoy zero delivery charge on eligible orders.',
      'expiry': 'Valid till 05 Oct',
      'category': 'Grocery',
      'badge': '🚚 Save Delivery Fee',
      'icon': Icons.delivery_dining_rounded,
      'color': Color(0xFFFF8A30),
      'bg': Color(0xFFFFF1E6),
    },
  ];

  final List<Map<String, dynamic>> deals = const [
    {
      'title': 'Fresh Vegetables',
      'subtitle': 'Up to 30% OFF',
      'description': 'On selected fresh vegetables',
      'category': 'Fruits & Veg',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF46A966),
      'bg': Color(0xFFEAF8EE),
    },
    {
      'title': 'Fresh Fruits',
      'subtitle': 'Starting ₹49',
      'description': 'Special prices on seasonal fruits',
      'category': 'Fruits & Veg',
      'icon': Icons.apple_rounded,
      'color': Color(0xFFE95A58),
      'bg': Color(0xFFFFEEEE),
    },
    {
      'title': 'Dairy & Essentials',
      'subtitle': 'Up to 25% OFF',
      'description': 'Save on daily household essentials',
      'category': 'Dairy',
      'icon': Icons.local_drink_rounded,
      'color': Color(0xFF4F8DE8),
      'bg': Color(0xFFEAF2FF),
    },
    {
      'title': 'Snacks & Beverages',
      'subtitle': 'Buy More, Save More',
      'description': 'Exclusive Freegi combo offers',
      'category': 'Snacks',
      'icon': Icons.fastfood_rounded,
      'color': Color(0xFFFFA928),
      'bg': Color(0xFFFFF3DE),
    },
  ];

  @override
  void initState() {
    super.initState();
    CouponStore.selectedCoupon.addListener(_onCouponChanged);
    CouponStore.loadCoupon();
  }

  @override
  void dispose() {
    CouponStore.selectedCoupon.removeListener(_onCouponChanged);
    super.dispose();
  }

  void _onCouponChanged() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _copyCoupon(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _showMessage('$code copied');
  }

  Future<void> _applyCoupon(Map<String, dynamic> coupon) async {
    final code = coupon['code']?.toString() ?? '';
    final storeCoupon = CouponStore.findByCode(code);

    if (storeCoupon == null) {
      _showMessage('Coupon unavailable.');
      return;
    }

    await CouponStore.selectCoupon(storeCoupon);
    if (!mounted) return;
    _showMessage('$code selected. Eligibility will be checked at checkout.');
  }

  List<Map<String, dynamic>> get filteredCoupons {
    return coupons.where((coupon) {
      return selectedCategory == 'All' ||
          coupon['category'] == selectedCategory ||
          (selectedCategory == 'Fruits & Veg' &&
              coupon['code'] == 'FRESH20');
    }).toList();
  }

  List<Map<String, dynamic>> get filteredDeals {
    return deals.where((deal) {
      return selectedCategory == 'All' ||
          deal['category'] == selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(),
                    const SizedBox(height: 14),
                    _buildTabs(),
                    if (selectedTab == 0) ...[
                      const SizedBox(height: 12),
                      _buildCategoryFilters(),
                    ],
                    const SizedBox(height: 17),
                    _buildSectionHeader(),
                    const SizedBox(height: 11),
                    if (selectedTab == 0)
                      _buildCouponsList()
                    else
                      _buildDealsList(),
                    const SizedBox(height: 18),
                    _buildPromoStrip(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          _squareButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Column(
            children: [
              Text(
                'Offers & Coupons',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.eco_rounded, color: green, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Save more with Freegi',
                    style: TextStyle(
                      color: subText,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _squareButton(
            icon: Icons.help_outline_rounded,
            iconColor: darkGreen,
            background: lightMint,
            onTap: () {
              _showMessage(
                'Choose a coupon now. Eligibility is verified at checkout.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _squareButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = darkText,
    Color background = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildHeroBanner() {
    final isDeals = selectedTab == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: 177,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDeals
              ? const [Color(0xFF0A6A42), Color(0xFF0D8A55)]
              : const [darkGreen, darkTeal, teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -35,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 12,
              child: _buildGroceryArtwork(isDeals),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 18, 155, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDeals)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FREEGI SPECIAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  if (!isDeals) const SizedBox(height: 9),
                  Text(
                    isDeals
                        ? 'Big Deals\nBigger Savings'
                        : 'Save More\nEvery Day',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDeals
                        ? 'Fresh groceries. Best prices.\nOnly on Freegi!'
                        : 'Fresh savings on your\nfavorite groceries.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 9.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isDeals) {
                          _showMessage('Explore the deals below.');
                        } else {
                          _showMessage('Choose a coupon below.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        isDeals ? 'Explore Deals' : 'Shop Now',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 13,
              child: Transform.rotate(
                angle: -0.08,
                child: Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD94F),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isDeals ? 'UP TO\n50%\nOFF' : 'SAVE\nBIG',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF25311F),
                      fontSize: 9,
                      height: 0.95,
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

  Widget _buildGroceryArtwork(bool isDeals) {
    return SizedBox(
      width: 135,
      height: 104,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 118,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF087C62),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
                top: Radius.circular(7),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 43,
            child: _foodCircle('🥬', 43),
          ),
          Positioned(
            left: 36,
            bottom: 49,
            child: _foodCircle('🥕', 39),
          ),
          Positioned(
            right: 32,
            bottom: 47,
            child: _foodCircle('🍅', 43),
          ),
          Positioned(
            right: 5,
            bottom: 42,
            child: _foodCircle(isDeals ? '🍌' : '🥦', 45),
          ),
          Positioned(
            bottom: 10,
            child: Text(
              'Freegi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodCircle(String emoji, double size) {
    return Text(emoji, style: TextStyle(fontSize: size));
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'Coupons',
              icon: Icons.confirmation_number_rounded,
              index: 0,
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Deals',
              icon: Icons.percent_rounded,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final selected = selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
          selectedCategory = 'All';
        });
      },
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? green : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: green.withValues(alpha: 0.18),
                    blurRadius: 9,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : subText,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : subText,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    const categories = ['All', 'Grocery', 'Fruits & Veg', 'Dairy', 'Snacks'];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return InkWell(
            onTap: () => setState(() => selectedCategory = category),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? green : const Color(0xFFF0F5F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF596764),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    final count = filteredCoupons.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedTab == 0 ? 'Available Coupons' : 'Categories & Deals',
                style: const TextStyle(
                  color: darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                selectedTab == 0
                    ? '$count coupons available'
                    : 'Special Freegi discounts for you',
                style: const TextStyle(
                  color: subText,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (selectedTab == 0)
          const Row(
            children: [
              Icon(Icons.swap_vert_rounded, color: darkText, size: 17),
              SizedBox(width: 3),
              Text(
                'Sort',
                style: TextStyle(
                  color: darkText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: () => setState(() {
              selectedCategory = 'All';
            }),
            child: const Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: darkGreen, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCouponsList() {
    final list = filteredCoupons;
    if (list.isEmpty) return _emptyState('No coupons found');

    return Column(
      children: [
        for (int i = 0; i < list.length; i++) ...[
          _buildCouponCard(list[i]),
          if (i != list.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final code = coupon['code'].toString();
    final isApplied = CouponStore.selectedCode == code;

    return InkWell(
      onTap: () => _showCouponDetails(coupon),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 11, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isApplied ? teal.withValues(alpha: 0.45) : borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: coupon['bg'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                coupon['icon'] as IconData,
                color: coupon['color'] as Color,
                size: 29,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon['title'].toString(),
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coupon['subtitle'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _copyCoupon(code),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                code,
                                style: const TextStyle(
                                  color: darkTeal,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.35,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.content_copy_rounded,
                                color: darkTeal,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          coupon['expiry'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF98A3A1),
                            fontSize: 7.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            SizedBox(
              width: 102,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 102),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (coupon['bg'] as Color).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coupon['badge'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: coupon['color'] as Color,
                          fontSize: 6.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: isApplied
                          ? null
                          : () => _applyCoupon(coupon),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        disabledBackgroundColor:
                            green.withValues(alpha: 0.13),
                        disabledForegroundColor: green,
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isApplied ? 'APPLIED ✓' : 'APPLY',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: subText,
                          fontSize: 7.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: darkTeal,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsList() {
    final list = filteredDeals;
    if (list.isEmpty) return _emptyState('No deals found');

    return Column(
      children: [
        for (int i = 0; i < list.length; i++) ...[
          _buildDealCard(list[i]),
          if (i != list.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal) {
    return InkWell(
      onTap: () => _showMessage('${deal['title']} selected'),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.022),
              blurRadius: 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 60,
              decoration: BoxDecoration(
                color: deal['bg'] as Color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    deal['icon'] as IconData,
                    color: deal['color'] as Color,
                    size: 32,
                  ),
                  Positioned(
                    right: 5,
                    bottom: 4,
                    child: Text(
                      deal['category'] == 'Fruits & Veg' ? '🥬' : '🛒',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal['title'].toString(),
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    deal['subtitle'].toString(),
                    style: TextStyle(
                      color: deal['color'] as Color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    deal['description'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 8.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: lightMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: teal,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: subText, size: 30),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponDetails(Map<String, dynamic> coupon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final code = coupon['code'].toString();
        final applied = CouponStore.selectedCode == code;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE5E3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: coupon['bg'] as Color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        coupon['icon'] as IconData,
                        color: coupon['color'] as Color,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon['title'].toString(),
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            coupon['subtitle'].toString(),
                            style: const TextStyle(
                              color: subText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Coupon Code',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                InkWell(
                  onTap: () => _copyCoupon(code),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: lightMint,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: teal.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            code,
                            style: const TextStyle(
                              color: darkTeal,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.content_copy_rounded,
                          color: teal,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Offer Details',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coupon['description'].toString(),
                  style: const TextStyle(
                    color: subText,
                    fontSize: 10.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: orange,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      coupon['expiry'].toString(),
                      style: const TextStyle(
                        color: subText,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: applied
                        ? null
                        : () async {
                            Navigator.pop(sheetContext);
                            await _applyCoupon(coupon);
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: green.withValues(alpha: 0.13),
                      disabledForegroundColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      applied ? 'APPLIED ✓' : 'Apply Coupon',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
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

  Widget _buildPromoStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFE8B7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: orange, size: 23),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offers may have minimum order value and category conditions. Check offer details before applying.',
              style: TextStyle(
                color: subText,
                fontSize: 8.8,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
