import 'package:flutter/material.dart';

import 'order_tracking_screen.dart';
import '../main_navigation_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final int totalAmount;
  final String paymentMethod;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
  });

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color borderColor = Color(0xFFE2ECEA);

  void _openTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
    );
  }

  void _continueShopping(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(
          initialIndex: 0,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Column(
            children: [
              const SizedBox(height: 5),

              _buildSuccessIcon(),

              const SizedBox(height: 11),

              const Text(
                'Order Placed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'Your groceries are on the way.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subText,
                  fontSize: 11.5,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 13),

              _buildOrderIllustration(),

              const SizedBox(height: 15),

              _buildOrderInfoCard(),

              const SizedBox(height: 13),

              _buildDeliveryCard(),

              const SizedBox(height: 15),

              _buildTrackButton(context),

              const SizedBox(height: 10),

              _buildOrdersButton(context),

              const SizedBox(height: 11),

              const Text(
                'Thank you for shopping with Freegi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F8F3),
        shape: BoxShape.circle,
        border: Border.all(color: teal.withValues(alpha: 0.18), width: 2),
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 31),
        ),
      ),
    );
  }

  Widget _buildOrderIllustration() {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            left: 22,
            child: _circleDecoration(
              size: 18,
              color: const Color(0xFFFFE7B8),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 22,
            child: _circleDecoration(
              size: 23,
              color: const Color(0xFFD8F3ED),
            ),
          ),
          Positioned(
            top: 12,
            right: 24,
            child: Icon(
              Icons.eco_rounded,
              color: teal.withValues(alpha: 0.30),
              size: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(42, 2, 42, 2),
            child: Image.asset(
              'assets/images/splash_grocery_bag.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.shopping_basket_rounded,
                  color: teal,
                  size: 82,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleDecoration({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _infoRow(
            label: 'Order ID',
            value: orderId,
            icon: Icons.receipt_long_rounded,
          ),

          const Divider(height: 15, color: Color(0xFFEDF2F1)),

          _infoRow(
            label: 'Payment',
            value: _paymentLabel(paymentMethod),
            icon: Icons.account_balance_wallet_rounded,
          ),

          const Divider(height: 15, color: Color(0xFFEDF2F1)),

          _infoRow(
            label: 'Total Amount',
            value: '₹$totalAmount',
            icon: Icons.currency_rupee_rounded,
            valueBold: true,
          ),

          const Divider(height: 15, color: Color(0xFFEDF2F1)),

          _infoRow(
            label: 'Order Date',
            value: _formattedOrderDate(),
            icon: Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    required IconData icon,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8F5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: teal, size: 17),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: subText,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                value,
                style: TextStyle(
                  color: darkText,
                  fontSize: 11.5,
                  fontWeight: valueBold ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF8),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: teal,
              size: 21,
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery',
                  style: TextStyle(
                    color: subText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '25 - 35 minutes',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFFF3A61B), size: 14),
                SizedBox(width: 2),
                Text(
                  'Fast',
                  style: TextStyle(
                    color: Color(0xFFD88B00),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 47,
      child: ElevatedButton(
        onPressed: () => _openTracking(context),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, size: 18),
            SizedBox(width: 8),
            Text(
              'Track Order',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
            SizedBox(width: 9),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        onPressed: () => _continueShopping(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTeal,
          side: const BorderSide(color: teal, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Continue Shopping',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  String _formattedOrderDate() {
    final now = DateTime.now();
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour12 = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${now.day} ${months[now.month - 1]} ${now.year}, '
        '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  String _paymentLabel(String value) {
    switch (value) {
      case 'CARD':
        return 'Debit / Credit Card';
      case 'COD':
        return 'Cash on Delivery';
      case 'WALLET':
        return 'Freegi Wallet';
      case 'UPI':
      default:
        return 'UPI';
    }
  }
}
