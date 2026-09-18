import 'package:flutter/material.dart';

import '../../data/notification_store.dart';

import '../../models/freegi_order.dart';
import '../../services/order_storage.dart';
import '../main_navigation_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color borderColor = Color(0xFFE2ECEA);
  static const Color lightMint = Color(0xFFE9F8F4);
  static const Color orange = Color(0xFFFFA928);

  FreegiOrder? _order;
  bool _isLoading = true;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final order = await OrderStorage.getOrderById(widget.orderId);
    if (!mounted) return;
    setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _addressText(FreegiOrder order) {
    if (order.deliveryAddress.trim().isNotEmpty) return order.deliveryAddress.trim();
    final parts = [order.area, order.city, order.state, order.postalCode]
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Delivery address not available' : parts.join(', ');
  }

  Future<void> _updateOrderStatus({
    required String status,
    required String type,
  }) async {
    if (_order == null || _isUpdatingStatus) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final updatedOrder = _order!.copyWith(
        status: status,
        type: type,
      );

      // Save the updated order first.
      await OrderStorage.updateOrder(updatedOrder);

      // Create a matching unread notification for this order event.
      String notificationTitle;
      String notificationMessage;
      String notificationIcon;
      int notificationIconColor;
      int notificationIconBg;

      switch (status) {
        case 'Preparing Your Order':
          notificationTitle = 'Preparing your order';
          notificationMessage =
              'Your order ${widget.orderId} is being packed and prepared.';
          notificationIcon = 'preparing';
          notificationIconColor = 0xFF00AFA8;
          notificationIconBg = 0xFFE8F8F4;
          break;

        case 'Out for Delivery':
          notificationTitle = 'Order is out for delivery';
          notificationMessage =
              'Your order ${widget.orderId} is on the way and will arrive soon.';
          notificationIcon = 'delivery';
          notificationIconColor = 0xFF00AFA8;
          notificationIconBg = 0xFFE8F8F4;
          break;

        case 'Delivered':
          notificationTitle = 'Order delivered';
          notificationMessage =
              'Your order ${widget.orderId} was delivered successfully.';
          notificationIcon = 'delivered';
          notificationIconColor = 0xFF4FA86B;
          notificationIconBg = 0xFFEAF8EE;
          break;

        case 'Cancelled':
          notificationTitle = 'Order cancelled';
          notificationMessage =
              'Your order ${widget.orderId} has been cancelled.';
          notificationIcon = 'cancelled';
          notificationIconColor = 0xFFD9534F;
          notificationIconBg = 0xFFFFEEEE;
          break;

        default:
          notificationTitle = 'Order updated';
          notificationMessage =
              'Your order ${widget.orderId} status has been updated to $status.';
          notificationIcon = 'bag';
          notificationIconColor = 0xFF00AFA8;
          notificationIconBg = 0xFFE8F8F4;
      }

      final notificationStatusKey = status
          .toLowerCase()
          .replaceAll(' ', '_');

      await NotificationStore.addNotification(
        id: 'order_${widget.orderId}_$notificationStatusKey',
        type: 'order',
        title: notificationTitle,
        message: notificationMessage,
        icon: notificationIcon,
        iconColor: notificationIconColor,
        iconBg: notificationIconBg,
      );

      if (!mounted) return;

      setState(() {
        _order = updatedOrder;
        _isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Order status updated to $status.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: darkTeal,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUpdatingStatus = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Could not update order status.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
    }
  }

  Future<void> _cancelOrder() async {
    if (_order == null || _isUpdatingStatus) return;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'This order will be moved to Cancelled. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      await _updateOrderStatus(status: 'Cancelled', type: 'cancelled');
    }
  }

  int _statusStep() {
    if (_order == null) return 0;
    if (_order!.type == 'delivered' || _order!.status == 'Delivered') return 3;
    if (_order!.status == 'Out for Delivery') return 2;
    if (_order!.status == 'Preparing Your Order') return 1;
    return 0;
  }

  _TrackingStatus _timelineStatus(int index) {
    if (_order!.type == 'cancelled') {
      return index == 0 ? _TrackingStatus.done : _TrackingStatus.upcoming;
    }
    final step = _statusStep();
    if (index < step) return _TrackingStatus.done;
    if (index == step) return _TrackingStatus.current;
    return _TrackingStatus.upcoming;
  }

  void _openOrders(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(
          initialIndex: 3,
        ),
      ),
      (route) => false,
    );
  }

  void _showComingSoon(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: teal)),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(backgroundColor: bg, elevation: 0),
        body: const Center(
          child: Text('Order details not found.', style: TextStyle(color: darkText, fontWeight: FontWeight.w700)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderCard(),

                    const SizedBox(height: 12),

                    _buildEstimatedDelivery(),

                    const SizedBox(height: 12),

                    _buildRiderCard(context),

                    const SizedBox(height: 15),

                    const Text(
                      'Order Status',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 9),

                    _buildTimeline(),

                    const SizedBox(height: 14),

                    _buildDeliveryAddress(),

                    const SizedBox(height: 14),

                    _buildStatusTestingControls(),

                    const SizedBox(height: 14),

                    _buildHelpCard(context),

                    const SizedBox(height: 16),

                    _buildViewOrdersButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: darkText,
              ),
            ),
          ),

          const Spacer(),

          const Column(
            children: [
              Text(
                'Track Order',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Live delivery updates',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          InkWell(
            onTap: () {
              _showComingSoon(context, 'Support will be connected later.');
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: teal,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _order!.type == 'delivered' ? 'Your order was delivered' : _order!.type == 'cancelled' ? 'Your order was cancelled' : 'Your order is on the way',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.orderId,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_order!.type != 'delivered' &&
                    _order!.type != 'cancelled') ...[
                  const SizedBox(height: 5),
                  Text(
                    'Arriving in ${_order!.deliverySlot}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _order!.type.toUpperCase(),
              style: TextStyle(
                color: darkTeal,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
            ],
          ),
          if (_order!.type != 'cancelled') ...[
            const SizedBox(height: 13),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: (_statusStep() + 1) / 4,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7BE2CC),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstimatedDelivery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule_rounded, color: teal, size: 25),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _order!.deliverySlot,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5DF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.flash_on_rounded, color: orange, size: 15),
                SizedBox(width: 3),
                Text(
                  'Fast',
                  style: TextStyle(
                    color: Color(0xFFB97400),
                    fontSize: 10,
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

  Widget _buildRiderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightMint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: teal,
              size: 29,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Partner',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Freegi Delivery Partner',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: orange, size: 15),
                    SizedBox(width: 3),
                    Text(
                      '4.9',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () {
              _showComingSoon(
                context,
                'Calling feature will be connected later.',
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 43,
              height: 43,
              decoration: const BoxDecoration(
                color: lightMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded, color: teal, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              _showComingSoon(
                context,
                'Chat feature will be connected later.',
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 43,
              height: 43,
              decoration: const BoxDecoration(
                color: lightMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: teal,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _TimelineItem(
            title: 'Order Confirmed',
            subtitle: 'Your order has been received.',
            time: _formatTime(_order!.placedAt),
            icon: Icons.check_circle_rounded,
            status: _timelineStatus(0),
            showLine: true,
          ),

          _TimelineItem(
            title: 'Preparing Your Order',
            subtitle: 'Your groceries are being packed.',
            time: _formatTime(_order!.placedAt.add(const Duration(minutes: 5))),
            icon: Icons.inventory_2_rounded,
            status: _timelineStatus(1),
            showLine: true,
          ),

          _TimelineItem(
            title: 'Out for Delivery',
            subtitle: 'Your delivery partner is on the way.',
            time: _formatTime(_order!.placedAt.add(const Duration(minutes: 15))),
            icon: Icons.delivery_dining_rounded,
            status: _timelineStatus(2),
            showLine: true,
          ),

          _TimelineItem(
            title: 'Delivered',
            subtitle: 'Order will arrive at your doorstep.',
            time: _order!.type == 'delivered' ? 'Done' : 'Soon',
            icon: Icons.home_rounded,
            status: _timelineStatus(3),
            showLine: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: teal, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _order!.addressType.isEmpty ? 'Home' : _order!.addressType,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  _addressText(_order!),
                  style: TextStyle(
                    color: subText,
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTestingControls() {
    final order = _order!;
    final bool finished = order.type == 'delivered' || order.type == 'cancelled';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sync_rounded, color: teal, size: 19),
              SizedBox(width: 8),
              Text(
                'Update Order Status',
                style: TextStyle(
                  color: darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            finished
                ? 'Final status: ${order.status}'
                : 'Current status: ${order.status}',
            style: const TextStyle(
              color: subText,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          if (_isUpdatingStatus)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CircularProgressIndicator(color: teal, strokeWidth: 2.5),
              ),
            )
          else if (finished)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.type == 'delivered'
                    ? '✓ This order is marked as Delivered.'
                    : 'This order is marked as Cancelled.',
                style: const TextStyle(
                  color: darkTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else ...[
            if (order.status == 'Order Confirmed')
              _statusButton(
                label: 'Mark Preparing',
                icon: Icons.inventory_2_rounded,
                onPressed: () => _updateOrderStatus(
                  status: 'Preparing Your Order',
                  type: 'active',
                ),
              ),
            if (order.status == 'Preparing Your Order')
              _statusButton(
                label: 'Mark Out for Delivery',
                icon: Icons.delivery_dining_rounded,
                onPressed: () => _updateOrderStatus(
                  status: 'Out for Delivery',
                  type: 'active',
                ),
              ),
            if (order.status == 'Out for Delivery')
              _statusButton(
                label: 'Mark Delivered',
                icon: Icons.check_circle_rounded,
                onPressed: () => _updateOrderStatus(
                  status: 'Delivered',
                  type: 'delivered',
                ),
              ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _cancelOrder,
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text(
                  'Cancel Order',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9534F),
                  side: const BorderSide(color: Color(0xFFF1C8C6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: teal,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'We’re here for you 24×7.',
                  style: TextStyle(
                    color: subText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {
              _showComingSoon(
                context,
                'Help & Support screen will be connected later.',
              );
            },
            child: const Text(
              'Contact Support',
              style: TextStyle(
                color: teal,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOrdersButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _openOrders(context),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 19),
            SizedBox(width: 8),
            Text(
              'View My Orders',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TrackingStatus { done, current, upcoming }

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final _TrackingStatus status;
  final bool showLine;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.status,
    required this.showLine,
  });

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);

  @override
  Widget build(BuildContext context) {
    final bool isDone = status == _TrackingStatus.done;
    final bool isCurrent = status == _TrackingStatus.current;

    final Color iconColor = isDone || isCurrent
        ? teal
        : const Color(0xFFB9C4C2);

    final Color circleColor = isCurrent
        ? const Color(0xFFE5F8F4)
        : isDone
        ? teal
        : const Color(0xFFF1F5F4);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: teal, width: 2)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isDone ? Colors.white : iconColor,
                  ),
                ),

                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: isDone ? teal : const Color(0xFFDDE5E3),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: isCurrent ? darkTeal : darkText,
                                  fontSize: 12.5,
                                  fontWeight: isCurrent
                                      ? FontWeight.w900
                                      : FontWeight.w800,
                                ),
                              ),
                            ),

                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F8F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'NOW',
                                  style: TextStyle(
                                    color: darkTeal,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: subText,
                            fontSize: 9.8,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    time,
                    style: TextStyle(
                      color: isCurrent ? darkTeal : subText,
                      fontSize: 9.5,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
