import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Single notification item stored in user's notification document
class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    // Safely parse data field - could be Map, null, or other
    Map<String, dynamic>? parsedData;
    final rawData = map['data'];
    if (rawData is Map) {
      parsedData = Map<String, dynamic>.from(rawData);
    }

    // Safely parse createdAt - could be Timestamp, int (milliseconds), String, or null
    DateTime parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return NotificationItem(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      isRead: map['isRead'] == true,
      createdAt: parsedCreatedAt,
      data: parsedData,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

/// User notification document model
/// Each user has ONE document containing all their notification settings and messages
class UserNotificationModel {
  final String odUserId; // Same as firebaseUid
  final List<String> fcmTokens;
  final List<String> subscribedTopics;
  final bool notificationSubscription;
  final DateTime? lastTokenUpdate;
  final List<NotificationItem> notifications;
  final int unreadCount;
  final String? role;
  final String? namaLengkap;
  final String? platform;

  UserNotificationModel({
    required this.odUserId,
    this.fcmTokens = const [],
    this.subscribedTopics = const [],
    this.notificationSubscription = true,
    this.lastTokenUpdate,
    this.notifications = const [],
    this.unreadCount = 0,
    this.role,
    this.namaLengkap,
    this.platform,
  });

  Map<String, dynamic> toMap() {
    return {
      'odUserId': odUserId,
      'fcmTokens': fcmTokens,
      'subscribedTopics': subscribedTopics,
      'notificationSubscription': notificationSubscription,
      'lastTokenUpdate': lastTokenUpdate != null 
          ? Timestamp.fromDate(lastTokenUpdate!) 
          : FieldValue.serverTimestamp(),
      'notifications': notifications.map((n) => n.toMap()).toList(),
      'unreadCount': unreadCount,
      'role': role,
      'namaLengkap': namaLengkap,
      'platform': platform,
    };
  }

  factory UserNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Parse notifications array with robust error handling
    final notificationsList = <NotificationItem>[];
    final rawNotifications = data['notifications'];
    if (rawNotifications != null && rawNotifications is List) {
      for (var item in rawNotifications) {
        try {
          if (item is Map) {
            notificationsList.add(
              NotificationItem.fromMap(Map<String, dynamic>.from(item)),
            );
          }
        } catch (e) {
          // Skip malformed notification items
          debugPrint('[UserNotificationModel] Error parsing notification item: $e');
        }
      }
    }
    
    // Sort by createdAt descending
    notificationsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Parse fcmTokens safely
    List<String> parsedTokens = [];
    final rawTokens = data['fcmTokens'];
    if (rawTokens is List) {
      parsedTokens = rawTokens.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }

    // Parse subscribedTopics safely
    List<String> parsedTopics = [];
    final rawTopics = data['subscribedTopics'];
    if (rawTopics is List) {
      parsedTopics = rawTopics.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }

    // Parse lastTokenUpdate safely
    DateTime? parsedLastUpdate;
    final rawLastUpdate = data['lastTokenUpdate'];
    if (rawLastUpdate is Timestamp) {
      parsedLastUpdate = rawLastUpdate.toDate();
    } else if (rawLastUpdate is int) {
      parsedLastUpdate = DateTime.fromMillisecondsSinceEpoch(rawLastUpdate);
    }

    // Parse unreadCount safely
    int parsedUnreadCount = 0;
    final rawUnreadCount = data['unreadCount'];
    if (rawUnreadCount is int) {
      parsedUnreadCount = rawUnreadCount;
    } else if (rawUnreadCount is double) {
      parsedUnreadCount = rawUnreadCount.toInt();
    }
    
    return UserNotificationModel(
      odUserId: doc.id,
      fcmTokens: parsedTokens,
      subscribedTopics: parsedTopics,
      notificationSubscription: data['notificationSubscription'] == true || 
          data['notificationSubscription'] == null, // default true if not set
      lastTokenUpdate: parsedLastUpdate,
      notifications: notificationsList,
      unreadCount: parsedUnreadCount,
      role: data['role']?.toString(),
      namaLengkap: data['namaLengkap']?.toString(),
      platform: data['platform']?.toString(),
    );
  }

  /// Get only unread notifications
  List<NotificationItem> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  /// Get only read notifications
  List<NotificationItem> get readNotifications =>
      notifications.where((n) => n.isRead).toList();

  UserNotificationModel copyWith({
    String? odUserId,
    List<String>? fcmTokens,
    List<String>? subscribedTopics,
    bool? notificationSubscription,
    DateTime? lastTokenUpdate,
    List<NotificationItem>? notifications,
    int? unreadCount,
    String? role,
    String? namaLengkap,
    String? platform,
  }) {
    return UserNotificationModel(
      odUserId: odUserId ?? this.odUserId,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      notificationSubscription: notificationSubscription ?? this.notificationSubscription,
      lastTokenUpdate: lastTokenUpdate ?? this.lastTokenUpdate,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      role: role ?? this.role,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      platform: platform ?? this.platform,
    );
  }
}
