import 'package:flutter/material.dart';
import 'package:freegi/data/notification_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../orders/orders_screen.dart';
import '../offers/offers_screen.dart';
import '../wallet/wallet_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF7FCFA);
  static const Color borderColor = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE8F8F4);

  int selectedTab = 0;

  static const String _dismissedKey = 'freegi_dismissed_notification_ids';
  Set<String> _dismissedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDismissedNotifications();
  }

  Future<void> _loadDismissedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_dismissedKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _dismissedIds = saved.toSet());
  }

  Future<void> _clearAllNotifications() async {
    final currentIds = NotificationStore.allNotifications
        .map((item) => item['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Color(0xFFD64C4C),
                    size: 27,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Clear all notifications?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'All notifications currently shown in Freegi will be removed from this list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subText,
                    fontSize: 9.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkText,
                          side: const BorderSide(color: borderColor),
                          minimumSize: const Size.fromHeight(47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFD64C4C),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    _dismissedIds.addAll(currentIds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedKey, _dismissedIds.toList());

    if (!mounted) return;
    setState(() {});
    _showMessage('All notifications cleared.');
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'delivery':
        return Icons.delivery_dining_rounded;

      case 'offer':
        return Icons.local_offer_rounded;

      case 'wallet':
        return Icons.account_balance_wallet_rounded;

      case 'delivered':
        return Icons.check_circle_rounded;

      case 'shipping':
        return Icons.local_shipping_rounded;

      case 'bag':
        return Icons.shopping_bag_rounded;

      case 'coupon':
        return Icons.confirmation_number_rounded;

      case 'preparing':
        return Icons.inventory_2_rounded;

      case 'cancelled':
        return Icons.cancel_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }

  // ============================================================
  // ALL NOTIFICATIONS
  // ============================================================

  List<Map<String, dynamic>> get notifications {
    return NotificationStore.allNotifications
        .where((source) {
          final id = source['id']?.toString() ?? '';
          return id.isEmpty || !_dismissedIds.contains(id);
        })
        .map((source) {
      final item = Map<String, dynamic>.from(source);

      item['icon'] = _iconFor(
        source['icon']?.toString() ?? 'notification',
      );

      item['iconColor'] = Color(
        source['iconColor'] as int? ?? 0xFF00AFA8,
      );

      item['iconBg'] = Color(
        source['iconBg'] as int? ?? 0xFFE8F8F4,
      );

      item['unread'] = NotificationStore.isUnread(
        source['id']?.toString() ?? '',
      );

      return item;
    }).toList();
  }

  // ============================================================
  // FILTERED NOTIFICATIONS
  // ============================================================

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedTab == 0) {
      return notifications;
    }

    if (selectedTab == 1) {
      return notifications
          .where(
            (item) => item['type'] == 'order',
          )
          .toList();
    }

    if (selectedTab == 2) {
      return notifications
          .where(
            (item) => item['type'] == 'offer',
          )
          .toList();
    }

    return notifications
        .where(
          (item) => item['type'] == 'wallet',
        )
        .toList();
  }

  // ============================================================
  // UNREAD COUNT
  // ============================================================

  int get unreadCount {
    return notifications.where((item) => item['unread'] == true).length;
  }

  // ============================================================
  // MARK ALL READ
  // ============================================================

  Future<void> _markAllAsRead() async {
    await NotificationStore.markAllAsRead();

    if (!mounted) return;

    setState(() {});

    _showMessage(
      'All notifications marked as read.',
    );
  }

  // ============================================================
  // MARK SINGLE READ
  // ============================================================

  Future<void> _markAsRead(
    Map<String, dynamic> item,
  ) async {
    if (item['unread'] != true) {
      return;
    }

    await NotificationStore.markAsRead(
      item['id'].toString(),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
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

  // ============================================================
  // OPEN NOTIFICATION
  // ============================================================

  Future<void> _openNotification(
    Map<String, dynamic> item,
  ) async {
    await _markAsRead(item);

    if (!mounted) return;

    final String type =
        item['type']?.toString() ?? '';

    if (type == 'order') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OrdersScreen(),
        ),
      );
      return;
    }

    if (type == 'offer') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OffersScreen(),
        ),
      );
      return;
    }

    if (type == 'wallet') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WalletScreen(),
        ),
      );
      return;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: NotificationStore.dynamicNotifications,
      builder: (context, dynamicItems, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: NotificationStore.readIds,
          builder: (context, readIds, _) {
            final items = filteredNotifications;

            return Scaffold(
              backgroundColor: bg,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          4,
                          18,
                          30,
                        ),
                        child: Column(
                          children: [
                            _buildSummaryCard(),

                            const SizedBox(height: 18),

                            _buildFilterTabs(),

                            const SizedBox(height: 18),

                            _buildSectionHeader(),

                            const SizedBox(height: 12),

                            if (items.isEmpty)
                              _buildEmptyState()
                            else
                              _buildNotificationsList(
                                items,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        12,
      ),
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
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkText,
                size: 18,
              ),
            ),
          ),

          const Spacer(),

          const Column(
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Orders, offers and updates',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          PopupMenuButton<String>(
            tooltip: 'Notification options',
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 5,
            offset: const Offset(0, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'read') {
                _markAllAsRead();
              } else if (value == 'clear') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'read',
                enabled: unreadCount > 0,
                child: const Row(
                  children: [
                    Icon(Icons.done_all_rounded, color: teal, size: 19),
                    SizedBox(width: 10),
                    Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_outlined,
                      color: Color(0xFFD64C4C),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Clear all',
                      style: TextStyle(
                        color: Color(0xFFD64C4C),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: teal,
                size: 21,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      height: 174,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal, teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: .17),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -42,
              child: Container(
                width: 135,
                height: 135,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 25,
              bottom: -55,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 29,
              child: _bellArtwork(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 22, 150, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'STAY UPDATED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    unreadCount > 0
                        ? '$unreadCount new updates'
                        : 'You are all\ncaught up',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    unreadCount > 0
                        ? 'Orders, offers and wallet updates are waiting for you.'
                        : 'No unread updates right now.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .76),
                      fontSize: 8.8,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
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

  Widget _bellArtwork() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 73,
            height: 73,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .13),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: teal,
              size: 39,
            ),
          ),
          const Positioned(
            right: 5,
            top: 13,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFD66B),
              size: 20,
            ),
          ),
          const Positioned(
            left: 4,
            bottom: 17,
            child: Icon(
              Icons.eco_rounded,
              color: Color(0xFF9DE0C7),
              size: 22,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 18,
              top: 27,
              child: Container(
                constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA928),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER TABS
  // ============================================================

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _filterChip(
            index: 0,
            label: 'All',
            icon: Icons.grid_view_rounded,
          ),

          const SizedBox(width: 8),

          _filterChip(
            index: 1,
            label: 'Orders',
            icon: Icons.shopping_bag_rounded,
          ),

          const SizedBox(width: 8),

          _filterChip(
            index: 2,
            label: 'Offers',
            icon: Icons.local_offer_rounded,
          ),

          const SizedBox(width: 8),

          _filterChip(
            index: 3,
            label: 'Wallet',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final bool selected =
        selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? teal
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? teal
                : borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? Colors.white
                  : subText,
            ),

            const SizedBox(width: 6),

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : darkText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Recent Updates',
            style: TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        if (unreadCount > 0)
          TextButton(
            onPressed: _markAllAsRead,
            style: TextButton.styleFrom(
              foregroundColor: teal,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Mark all as read',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // NOTIFICATIONS LIST
  // ============================================================

  Widget _buildNotificationsList(
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 11,
              ),
              child: _buildNotificationCard(
                item,
              ),
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(
    Map<String, dynamic> item,
  ) {
    final bool unread =
        item['unread'] == true;

    return InkWell(
      onTap: () {
        _openNotification(
          item,
        );
      },
      borderRadius: BorderRadius.circular(19),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread
              ? const Color(0xFFF4FBF9)
              : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: unread
                ? teal.withValues(
                    alpha: 0.22,
                  )
                : borderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item['iconBg'] as Color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['iconColor'] as Color,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['title']?.toString() ??
                              'Notification',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 11.5,
                            fontWeight: unread
                                ? FontWeight.w900
                                : FontWeight.w800,
                          ),
                        ),
                      ),

                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(
                            top: 3,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item['message']?.toString() ?? '',
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFFA0ABA8),
                        size: 13,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        item['time']?.toString() ??
                            'Just now',
                        style: const TextStyle(
                          color: Color(0xFFA0ABA8),
                          fontSize: 8.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 7),

            const Padding(
              padding: EdgeInsets.only(
                top: 16,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFFB4BEBC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: teal,
              size: 34,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No notifications',
            style: TextStyle(
              color: darkText,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'There are no updates in this category right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subText,
              fontSize: 9.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}