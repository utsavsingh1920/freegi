import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/freegi_order.dart';

class OrderStorage {
  OrderStorage._();

  static const String _ordersKey = 'freegi_saved_orders';

  // ============================================================
  // GET ALL ORDERS
  // ============================================================

  static Future<List<FreegiOrder>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedOrders =
          prefs.getStringList(_ordersKey) ?? <String>[];

      final orders = <FreegiOrder>[];

      for (final savedOrder in savedOrders) {
        try {
          final decoded = jsonDecode(savedOrder);

          if (decoded is Map) {
            orders.add(
              FreegiOrder.fromJson(
                Map<String, dynamic>.from(decoded),
              ),
            );
          }
        } catch (_) {
          // Ignore only the broken order entry.
          // Other valid orders will still load.
        }
      }

      orders.sort(
        (a, b) => b.placedAt.compareTo(a.placedAt),
      );

      return orders;
    } catch (_) {
      return <FreegiOrder>[];
    }
  }

  // ============================================================
  // SAVE NEW ORDER
  // ============================================================

  static Future<void> saveOrder(
    FreegiOrder order,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final orders = await getOrders();

    // Prevent duplicate order IDs.
    orders.removeWhere(
      (existingOrder) =>
          existingOrder.orderId == order.orderId,
    );

    // Latest order stays first.
    orders.insert(0, order);

    await _saveAllOrders(
      prefs,
      orders,
    );
  }

  // ============================================================
  // GET SINGLE ORDER
  // ============================================================

  static Future<FreegiOrder?> getOrderById(
    String orderId,
  ) async {
    final orders = await getOrders();

    for (final order in orders) {
      if (order.orderId == orderId) {
        return order;
      }
    }

    return null;
  }

  // ============================================================
  // UPDATE ORDER
  // ============================================================

  static Future<void> updateOrder(
    FreegiOrder updatedOrder,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final orders = await getOrders();

    final index = orders.indexWhere(
      (order) =>
          order.orderId == updatedOrder.orderId,
    );

    if (index == -1) {
      orders.insert(0, updatedOrder);
    } else {
      orders[index] = updatedOrder;
    }

    await _saveAllOrders(
      prefs,
      orders,
    );
  }

  // ============================================================
  // DELETE SINGLE ORDER
  // ============================================================

  static Future<void> deleteOrder(
    String orderId,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final orders = await getOrders();

    orders.removeWhere(
      (order) => order.orderId == orderId,
    );

    await _saveAllOrders(
      prefs,
      orders,
    );
  }

  // ============================================================
  // CLEAR ALL ORDERS
  // ============================================================

  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_ordersKey);
  }

  // ============================================================
  // ORDER COUNTS
  // ============================================================

  static Future<int> getTotalOrderCount() async {
    final orders = await getOrders();

    return orders.length;
  }

  static Future<int> getActiveOrderCount() async {
    final orders = await getOrders();

    return orders
        .where(
          (order) => order.type == 'active',
        )
        .length;
  }

  static Future<int> getDeliveredOrderCount() async {
    final orders = await getOrders();

    return orders
        .where(
          (order) => order.type == 'delivered',
        )
        .length;
  }

  static Future<int> getCancelledOrderCount() async {
    final orders = await getOrders();

    return orders
        .where(
          (order) => order.type == 'cancelled',
        )
        .length;
  }

  // ============================================================
  // INTERNAL SAVE
  // ============================================================

  static Future<void> _saveAllOrders(
    SharedPreferences prefs,
    List<FreegiOrder> orders,
  ) async {
    final encodedOrders = orders
        .map(
          (order) => jsonEncode(
            order.toJson(),
          ),
        )
        .toList();

    final success = await prefs.setStringList(
      _ordersKey,
      encodedOrders,
    );

    if (!success) {
      throw Exception(
        'Unable to save Freegi orders.',
      );
    }
  }
}