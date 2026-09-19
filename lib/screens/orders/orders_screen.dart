import 'package:flutter/material.dart';

import '../../models/freegi_order.dart';
import '../../services/order_storage.dart';
import 'order_success_screen.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  final bool showBottomNavigation;
  const OrdersScreen({super.key, this.showBottomNavigation = true});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color successGreen = Color(0xFF268B60);
  static const Color danger = Color(0xFFD55B5B);
  int selectedTab = 0;
  List<Map<String, dynamic>> orders = [];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final List<FreegiOrder> savedOrders = await OrderStorage.getOrders();

      final List<Map<String, dynamic>> convertedOrders = savedOrders
          .map(_orderToMap)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        orders = convertedOrders;
        _isLoadingOrders = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        orders = [];
        _isLoadingOrders = false;
      });
    }
  }

  Map<String, dynamic> _orderToMap(FreegiOrder order) {
    return {
      'orderId': order.orderId,
      'date': _formatOrderDate(order.placedAt),
      'status': order.status,
      'type': order.type,
      'total': order.totalAmount,
      'items': order.itemCount,
      'paymentMethod': order.paymentMethod,
      'payment': _paymentLabel(order.paymentMethod),
      'products': order.productNames,
      'images': order.productImages,
      'itemTotal': order.itemTotal,
      'discount': order.discount,
      'deliveryFee': order.deliveryFee,
      'platformFee': order.platformFee,
      'addressType': order.addressType,
      'deliveryAddress': order.deliveryAddress,
      'landmark': order.landmark,
      'area': order.area,
      'city': order.city,
      'state': order.state,
      'postalCode': order.postalCode,
      'deliverySlot': order.deliverySlot,
    };
  }

  String _paymentLabel(String paymentMethod) {
    switch (paymentMethod.toUpperCase()) {
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

  String _formatOrderDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String day = date.day.toString().padLeft(2, '0');
    final String month = months[date.month - 1];
    final String year = date.year.toString();

    int hour = date.hour;
    final String period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year • $hour:$minute $period';
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedTab == 0) {
      return orders;
    }

    if (selectedTab == 1) {
      return orders.where((order) => order['type'] == 'active').toList();
    }

    if (selectedTab == 2) {
      return orders.where((order) => order['type'] == 'delivered').toList();
    }

    return orders.where((order) => order['type'] == 'cancelled').toList();
  }

  Future<void> _openTracking(String orderId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
    );

    if (!mounted) return;
    await _loadOrders();
  }

  void _openOrderSuccess(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          orderId: order['orderId'].toString(),
          totalAmount: (order['total'] as num).toInt(),
          paymentMethod: order['paymentMethod']?.toString() ?? 'UPI',
        ),
      ),
    );
  }

  void _showReorderMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Items added to cart for reorder.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _OrderDetailsSheet(
          order: order,
          onTrack: () {
            Navigator.pop(context);
            _openTracking(order['orderId'].toString());
          },
          onSuccess: () {
            Navigator.pop(context);
            _openOrderSuccess(order);
          },
          onReorder: () {
            Navigator.pop(context);
            _showReorderMessage();
          },
        );
      },
    );
  }

  Future<void> _showOrderMenu() async {
    final action = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 76, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: const [
        PopupMenuItem<String>(
          value: 'clear_history',
          child: Row(
            children: [
              Icon(Icons.delete_sweep_outlined, color: danger, size: 20),
              SizedBox(width: 10),
              Text(
                'Clear Order History',
                style: TextStyle(
                  color: Color(0xFF172321),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (action == 'clear_history' && mounted) {
      await _confirmClearOrderHistory();
    }
  }

  Future<void> _confirmClearOrderHistory() async {
    final historyOrders = orders
        .where(
          (order) =>
              order['type'] == 'delivered' || order['type'] == 'cancelled',
        )
        .toList();

    if (historyOrders.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('No delivered or cancelled orders to clear.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: darkTeal,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Clear order history?',
            style: TextStyle(
              color: Color(0xFF172321),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Delivered and cancelled orders will be removed from this device. Active orders will stay safe.',
            style: TextStyle(color: Color(0xFF71807D), height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: danger),
              child: const Text(
                'Clear History',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) return;

    try {
      // Delete only delivered and cancelled history.
      // Active orders stay safe.
      final savedOrders = await OrderStorage.getOrders();

      final historyOrders = savedOrders
          .where(
            (order) => order.type == 'delivered' || order.type == 'cancelled',
          )
          .toList();

      for (final order in historyOrders) {
        await OrderStorage.deleteOrder(order.orderId);
      }

      if (!mounted) return;
      await _loadOrders();

      if (!mounted) return;
      setState(() {
        selectedTab = 0;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Order history cleared. Active orders were kept.',
            ),
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Unable to clear order history right now.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: danger,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FCFA);

    return Scaffold(
      backgroundColor: background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ONE header only:
            // My Orders + 3-dot always stay at the top.
            // Stats card scrolls/collapses away.
            // Tabs move up and stay directly below My Orders.
            SliverPersistentHeader(
              pinned: true,
              delegate: _OrdersStickyHeaderDelegate(
                backgroundColor: background,
                header: _buildHeader(),
                statsCard: _buildStatsCard(),
                tabs: _buildTabs(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            if (_isLoadingOrders)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: teal,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (filteredOrders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  widget.showBottomNavigation ? 30 : 112,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index.isOdd) {
                      return const SizedBox(height: 9);
                    }

                    final orderIndex = index ~/ 2;
                    return _buildOrderCard(filteredOrders[orderIndex]);
                  }, childCount: filteredOrders.length * 2 - 1),
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
  Widget _buildHeader() {
    const textColor = Color(0xFF172321);
    const border = Color(0xFFE2ECEA);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Text(
                'My Orders',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: InkWell(
                onTap: _showOrderMenu,
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: border),
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: textColor,
                    size: 21,
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
  // STATS
  // ============================================================
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal, teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.16),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              value: '${orders.length}',
              label: 'Total Orders',
              icon: Icons.shopping_bag_rounded,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _statItem(
              value: '${orders.where((o) => o['type'] == 'delivered').length}',
              label: 'Delivered',
              icon: Icons.local_shipping_rounded,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _statItem(
              value: '${orders.where((o) => o['type'] == 'active').length}',
              label: 'Active',
              icon: Icons.inventory_2_rounded,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _statItem(
              value: '${orders.where((o) => o['type'] == 'cancelled').length}',
              label: 'Cancelled',
              icon: Icons.cancel_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 7.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }

  // ============================================================
  // TABS
  // ============================================================
  Widget _buildTabs() {
    final tabs = ['All', 'Active', 'Delivered', 'Cancelled'];

    const holderColor = Colors.white;

    final selectedColor = teal;

    const unselectedText = Color(0xFF71807D);

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: holderColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1EBE9)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selected ? Colors.white : unselectedText,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'].toString();

    final type = order['type'].toString();

    final active = type == 'active';

    final delivered = type == 'delivered';

    final images = List<String>.from(order['images'] as List);

    const surface = Colors.white;

    const border = Color(0xFFE2ECEA);

    const textColor = Color(0xFF172321);

    const subText = Color(0xFF71807D);

    return InkWell(
      onTap: () {
        _showOrderDetails(order);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? teal.withValues(alpha: 0.34) : border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _imageStack(images),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['orderId'].toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order['date'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subText,
                          fontSize: 7.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _statusBadge(status, type),
              ],
            ),

            const SizedBox(height: 14),

            Divider(height: 1, color: const Color(0xFFEDF2F1)),

            const SizedBox(height: 13),

            Text(
              _productPreview(order),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _smallInfo(
                  Icons.shopping_basket_outlined,
                  '${order['items']} items',
                  subText,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _smallInfo(
                    Icons.account_balance_wallet_outlined,
                    order['payment'].toString(),
                    subText,
                  ),
                ),
                Text(
                  '₹${order['total']}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {
                        _showOrderDetails(order);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: teal,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: active
                          ? () {
                              _openTracking(order['orderId'].toString());
                            }
                          : delivered
                          ? () {
                              _openOrderSuccess(order);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: active
                            ? teal
                            : delivered
                            ? successGreen
                            : const Color(0xFFE7ECEB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE7ECEB),
                        disabledForegroundColor: const Color(0xFF9AA6A3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            active
                                ? Icons.location_on_rounded
                                : delivered
                                ? Icons.check_circle_outline_rounded
                                : Icons.close_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              active
                                  ? 'Track Order'
                                  : delivered
                                  ? 'Order Success'
                                  : 'Cancelled',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageStack(List<String> images) {
    final visible = images.take(3).toList();

    return SizedBox(
      width: 76,
      height: 52,
      child: Stack(
        children: List.generate(visible.length, (index) {
          return Positioned(
            left: index * 17.0,
            top: 1,
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  visible[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      color: const Color(0xFFE9F8F4),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: teal,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) {
                    return Container(
                      color: const Color(0xFFE9F8F4),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_basket_rounded,
                        color: teal,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _smallInfo(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================
  Widget _statusBadge(String status, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: _statusLightColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(type),
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _statusColor(String type) {
    if (type == 'active') {
      return teal;
    }

    if (type == 'delivered') {
      return successGreen;
    }

    return danger;
  }

  Color _statusLightColor(String type) {
    if (type == 'active') {
      return const Color(0xFFE9F8F4);
    }

    if (type == 'delivered') {
      return const Color(0xFFE8F7EE);
    }

    return const Color(0xFFFFECEC);
  }

  String _productPreview(Map<String, dynamic> order) {
    final products = List<String>.from(order['products'] as List);

    return products.join(' • ');
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmptyState() {
    const textColor = Color(0xFF172321);

    const subText = Color(0xFF71807D);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F8F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: teal,
                size: 44,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No orders found',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Your orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Widget header;
  final Widget statsCard;
  final Widget tabs;

  const _OrdersStickyHeaderDelegate({
    required this.backgroundColor,
    required this.header,
    required this.statsCard,
    required this.tabs,
  });

  // Initial layout:
  // header 54 + gap 8 + stats 86 + gap 10 + tabs 48 + bottom 5
  @override
  double get maxExtent => 211;

  // Scrolled layout:
  // header 54 + gap 5 + tabs 48 + bottom 5
  @override
  double get minExtent => 112;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final maxShrink = maxExtent - minExtent;
    final progress = maxShrink <= 0
        ? 1.0
        : (shrinkOffset / maxShrink).clamp(0.0, 1.0);

    return Container(
      color: backgroundColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // This is the SAME original My Orders header at all times.
          // No second/compact duplicate header is created.
          Positioned(top: 0, left: 0, right: 0, child: header),

          // Stats starts below the header and disappears while scrolling.
          Positioned(
            top: 62 - (progress * 99),
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - progress).clamp(0.0, 1.0),
              child: IgnorePointer(ignoring: progress > 0.15, child: statsCard),
            ),
          ),

          // Tabs stay at the bottom of the shrinking header.
          // Therefore they naturally move upward and finally stop
          // directly below the SAME My Orders header.
          Positioned(left: 0, right: 0, bottom: 5, child: tabs),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _OrdersStickyHeaderDelegate oldDelegate) {
    return true;
  }
}

// ============================================================
// ORDER DETAILS SHEET
// ============================================================
class _OrderDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTrack;
  final VoidCallback onSuccess;
  final VoidCallback onReorder;
  const _OrderDetailsSheet({
    required this.order,
    required this.onTrack,
    required this.onSuccess,
    required this.onReorder,
  });
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color successGreen = Color(0xFF268B60);
  @override
  Widget build(BuildContext context) {
    final type = order['type'].toString();

    final products = List<String>.from(order['products'] as List);

    final images = List<String>.from(order['images'] as List);

    const surface = Colors.white;

    const cardColor = Color(0xFFF7FAF9);

    const border = Color(0xFFE2ECEA);

    const textColor = Color(0xFF172321);

    const subText = Color(0xFF71807D);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE5E3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['orderId'].toString(),
                          style: TextStyle(
                            color: subText,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _sheetStatus(type, order['status'].toString()),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: List.generate(products.length, (index) {
                    final image = index < images.length ? images[index] : '';

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == products.length - 1 ? 0 : 11,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 42,
                              height: 42,
                              child: Image.network(
                                image,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }

                                  return Container(
                                    color: const Color(0xFFE9F8F4),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.7,
                                        color: teal,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, _, _) {
                                  return Container(
                                    color: const Color(0xFFE9F8F4),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.shopping_basket_rounded,
                                      color: teal,
                                      size: 18,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              products[index],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(
                'Order Date',
                order['date'].toString(),
                textColor: textColor,
                subText: subText,
              ),

              const SizedBox(height: 9),

              _detailRow(
                'Payment',
                order['payment'].toString(),
                textColor: textColor,
                subText: subText,
              ),

              const SizedBox(height: 9),

              _detailRow(
                'Items',
                '${order['items']} items',
                textColor: textColor,
                subText: subText,
              ),

              Divider(height: 25, color: border),

              _detailRow(
                'Total Amount',
                '₹${order['total']}',
                textColor: textColor,
                subText: subText,
                bold: true,
              ),

              const SizedBox(height: 20),

              if (type == 'active')
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.location_on_rounded, size: 18),
                    label: const Text(
                      'Track Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

              if (type == 'delivered') ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onSuccess,
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'View Order Success',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onReorder,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Reorder Items',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkTeal,
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],

              if (type == 'cancelled')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD85B5B),
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'This order was cancelled.',
                          style: TextStyle(
                            color: const Color(0xFFB84949),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
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
    );
  }

  Widget _sheetStatus(String type, String status) {
    Color fg;
    Color bg;

    if (type == 'active') {
      fg = teal;
      bg = const Color(0xFFE9F8F4);
    } else if (type == 'delivered') {
      fg = successGreen;
      bg = const Color(0xFFE8F7EE);
    } else {
      fg = const Color(0xFFD55B5B);
      bg = const Color(0xFFFFECEC);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 8.5, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    required Color textColor,
    required Color subText,
    bool bold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: subText,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: textColor,
              fontSize: bold ? 14 : 10.5,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
