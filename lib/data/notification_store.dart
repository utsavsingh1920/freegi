import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStore {
  NotificationStore._();

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _readIdsKey = 'freegi_read_notification_ids';
  static const String _dynamicNotificationsKey =
      'freegi_dynamic_notifications';

  // ============================================================
  // NOTIFIERS
  // ============================================================

  static final ValueNotifier<Set<String>> readIds =
      ValueNotifier<Set<String>>(<String>{});

  static final ValueNotifier<List<Map<String, dynamic>>>
      dynamicNotifications =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // ============================================================
  // ALL NOTIFICATIONS
  // Only real/dynamic notifications are shown.
  // Fresh install starts with zero notifications.
  // ============================================================

  static List<Map<String, dynamic>> get allNotifications {
    return dynamicNotifications.value
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // LOAD
  // ============================================================

  static Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // ---------------- READ / UNREAD ----------------

    final savedReadIds = prefs.getStringList(_readIdsKey);
    readIds.value = savedReadIds?.toSet() ?? <String>{};

    // ---------------- DYNAMIC NOTIFICATIONS ----------------

    final savedDynamic = prefs.getString(_dynamicNotificationsKey);

    if (savedDynamic == null || savedDynamic.trim().isEmpty) {
      dynamicNotifications.value = [];
      return;
    }

    try {
      final decoded = jsonDecode(savedDynamic);

      if (decoded is List) {
        dynamicNotifications.value = decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        dynamicNotifications.value = [];
      }
    } catch (_) {
      dynamicNotifications.value = [];
    }
  }

  // ============================================================
  // READ / UNREAD
  // ============================================================

  static bool isUnread(String id) {
    return !readIds.value.contains(id);
  }

  static int get unreadCount {
    return allNotifications.where((item) {
      final id = item['id']?.toString() ?? '';

      if (id.isEmpty) {
        return false;
      }

      return isUnread(id);
    }).length;
  }

  static bool get hasUnread => unreadCount > 0;

  static Future<void> markAsRead(String id) async {
    if (id.isEmpty || readIds.value.contains(id)) {
      return;
    }

    final next = Set<String>.from(readIds.value)..add(id);

    readIds.value = next;

    await _saveReadIds();
  }

  static Future<void> markAllAsRead() async {
    final next = Set<String>.from(readIds.value);

    for (final item in allNotifications) {
      final id = item['id']?.toString() ?? '';

      if (id.isNotEmpty) {
        next.add(id);
      }
    }

    readIds.value = next;

    await _saveReadIds();
  }

  // ============================================================
  // ADD REAL / DYNAMIC NOTIFICATION
  // ============================================================

  static Future<void> addNotification({
    required String id,
    required String type,
    required String title,
    required String message,
    String icon = 'bag',
    int iconColor = 0xFF00AFA8,
    int iconBg = 0xFFE8F8F4,
  }) async {
    if (id.trim().isEmpty) {
      return;
    }

    final cleanId = id.trim();

    // Prevent the exact same event notification from being added twice.
    final alreadyExists = dynamicNotifications.value.any(
      (item) => item['id']?.toString() == cleanId,
    );

    if (alreadyExists) {
      return;
    }

    final notification = <String, dynamic>{
      'id': cleanId,
      'type': type,
      'title': title,
      'message': message,
      'time': 'Just now',
      'createdAt': DateTime.now().toIso8601String(),
      'icon': icon,
      'iconColor': iconColor,
      'iconBg': iconBg,
    };

    final next = List<Map<String, dynamic>>.from(
      dynamicNotifications.value,
    );

    // Newest notification at the top.
    next.insert(0, notification);

    dynamicNotifications.value = next;

    // New notification MUST be unread.
    final nextReadIds = Set<String>.from(readIds.value)..remove(cleanId);

    readIds.value = nextReadIds;

    await _saveDynamicNotifications();
    await _saveReadIds();
  }

  // ============================================================
  // OPTIONAL HELPERS
  // ============================================================

  static Future<void> removeNotification(String id) async {
    final next = dynamicNotifications.value
        .where(
          (item) => item['id']?.toString() != id,
        )
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();

    dynamicNotifications.value = next;

    final nextReadIds = Set<String>.from(readIds.value)..remove(id);

    readIds.value = nextReadIds;

    await _saveDynamicNotifications();
    await _saveReadIds();
  }

  static Future<void> clearDynamicNotifications() async {
    final dynamicIds = dynamicNotifications.value
        .map(
          (item) => item['id']?.toString() ?? '',
        )
        .where(
          (id) => id.isNotEmpty,
        )
        .toSet();

    dynamicNotifications.value = [];

    final nextReadIds = Set<String>.from(readIds.value)
      ..removeAll(dynamicIds);

    readIds.value = nextReadIds;

    await _saveDynamicNotifications();
    await _saveReadIds();
  }

  // ============================================================
  // SAVE
  // ============================================================

  static Future<void> _saveReadIds() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _readIdsKey,
      readIds.value.toList(),
    );
  }

  static Future<void> _saveDynamicNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _dynamicNotificationsKey,
      jsonEncode(dynamicNotifications.value),
    );
  }
}
