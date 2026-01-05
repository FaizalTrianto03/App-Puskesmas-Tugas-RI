import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../models/user_notification_model.dart';

/// Service for managing user notifications using new unified structure
/// Each user has ONE document in 'user_notifications' collection
class UserNotificationService extends GetxService {
  static UserNotificationService get to => Get.find<UserNotificationService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const _uuid = Uuid();

  CollectionReference get _collection => _firestore.collection('user_notifications');

  /// Get current user's document reference
  DocumentReference? get _userDocRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _collection.doc(uid);
  }

  // ============================================
  // INITIALIZATION & DOCUMENT MANAGEMENT
  // ============================================

  /// Initialize or get user notification document
  /// Creates document if it doesn't exist
  Future<UserNotificationModel?> initializeUserNotificationDoc({
    required String role,
    String? namaLengkap,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final docRef = _collection.doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Create new document with default values
        final defaultTopics = _getDefaultTopics(user.uid, role);
        
        final model = UserNotificationModel(
          odUserId: user.uid,
          fcmTokens: [],
          subscribedTopics: defaultTopics,
          notificationSubscription: true,
          notifications: [],
          unreadCount: 0,
          role: role,
          namaLengkap: namaLengkap,
          platform: defaultTargetPlatform.name,
        );

        await docRef.set(model.toMap());
        debugPrint('[UserNotifService] Created new notification doc for ${user.uid}');
        return model;
      }

      // Update existing document with role/name if provided
      await docRef.update({
        'role': role,
        if (namaLengkap != null) 'namaLengkap': namaLengkap,
        'platform': defaultTargetPlatform.name,
      });

      return UserNotificationModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('[UserNotifService] Error initializing doc: $e');
      return null;
    }
  }

  /// Get default topics based on role
  List<String> _getDefaultTopics(String uid, String role) {
    final topics = <String>['user-$uid', 'general'];
    
    // Broadcast roles get their role topic
    const broadcastRoles = ['admin', 'perawat', 'apoteker'];
    if (broadcastRoles.contains(role)) {
      topics.add(role);
    }
    
    return topics;
  }

  // ============================================
  // FCM TOKEN MANAGEMENT
  // ============================================

  /// Save FCM token to user's notification document
  /// Also ensures document has all required fields
  Future<void> saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _collection.doc(user.uid);

    try {
      final doc = await docRef.get();
      
      if (!doc.exists) {
        // Document doesn't exist - create with full structure
        await docRef.set({
          'fcmTokens': [token],
          'subscribedTopics': ['user-${user.uid}', 'general'],
          'notificationSubscription': true,
          'notifications': [],
          'unreadCount': 0,
          'role': null,
          'namaLengkap': null,
          'platform': defaultTargetPlatform.name,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('[UserNotifService] Created new doc with FCM token');
      } else {
        // Document exists - just add token
        await docRef.update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.name,
        });
        debugPrint('[UserNotifService] FCM token saved to existing doc');
      }
    } catch (e) {
      debugPrint('[UserNotifService] Error saving FCM token: $e');
    }
  }

  /// Remove FCM token from user's notification document
  Future<void> removeFcmToken(String token) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      await docRef.update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
      debugPrint('[UserNotifService] FCM token removed');
    } catch (e) {
      debugPrint('[UserNotifService] Error removing FCM token: $e');
    }
  }

  /// Replace all FCM tokens (after refresh)
  Future<void> replaceFcmToken(String newToken) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      await docRef.set({
        'fcmTokens': [newToken],
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));
      
      debugPrint('[UserNotifService] FCM token replaced');
    } catch (e) {
      debugPrint('[UserNotifService] Error replacing FCM token: $e');
    }
  }

  // ============================================
  // SUBSCRIPTION MANAGEMENT
  // ============================================

  /// Get notification subscription status
  Future<bool> getNotificationSubscription() async {
    final docRef = _userDocRef;
    if (docRef == null) return true; // Default to true

    try {
      final doc = await docRef.get();
      if (!doc.exists) return true;
      
      final data = doc.data() as Map<String, dynamic>?;
      return data?['notificationSubscription'] ?? true;
    } catch (e) {
      debugPrint('[UserNotifService] Error getting subscription: $e');
      return true;
    }
  }

  /// Watch notification subscription status (realtime)
  Stream<bool> watchNotificationSubscription() {
    final docRef = _userDocRef;
    if (docRef == null) return Stream.value(true);

    return docRef.snapshots().map((doc) {
      if (!doc.exists) return true;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['notificationSubscription'] ?? true;
    });
  }

  /// Update notification subscription status
  Future<void> setNotificationSubscription(bool enabled) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      await docRef.set({
        'notificationSubscription': enabled,
      }, SetOptions(merge: true));
      
      debugPrint('[UserNotifService] Subscription set to $enabled');
    } catch (e) {
      debugPrint('[UserNotifService] Error setting subscription: $e');
    }
  }

  /// Update subscribed topics
  Future<void> updateSubscribedTopics(List<String> topics) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      await docRef.update({
        'subscribedTopics': topics,
      });
      debugPrint('[UserNotifService] Topics updated: $topics');
    } catch (e) {
      debugPrint('[UserNotifService] Error updating topics: $e');
    }
  }

  // ============================================
  // NOTIFICATION MANAGEMENT
  // ============================================

  /// Get user notification document
  Future<UserNotificationModel?> getUserNotifications() async {
    final docRef = _userDocRef;
    if (docRef == null) return null;

    try {
      final doc = await docRef.get();
      if (!doc.exists) return null;
      return UserNotificationModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('[UserNotifService] Error getting notifications: $e');
      return null;
    }
  }

  /// Watch user notification document (realtime)
  Stream<UserNotificationModel?> watchUserNotifications() {
    final docRef = _userDocRef;
    if (docRef == null) {
      debugPrint('[UserNotifService] watchUserNotifications: No user logged in');
      return Stream.value(null);
    }

    return docRef.snapshots().map((doc) {
      if (!doc.exists) {
        debugPrint('[UserNotifService] watchUserNotifications: Doc not exists');
        return null;
      }
      try {
        return UserNotificationModel.fromFirestore(doc);
      } catch (e) {
        debugPrint('[UserNotifService] Error parsing notification doc: $e');
        return null;
      }
    }).handleError((error) {
      debugPrint('[UserNotifService] Stream error: $error');
      return null;
    });
  }

  /// Watch only unread count
  Stream<int> watchUnreadCount() {
    final docRef = _userDocRef;
    if (docRef == null) return Stream.value(0);

    return docRef.snapshots().map((doc) {
      if (!doc.exists) return 0;
      try {
        final data = doc.data() as Map<String, dynamic>?;
        final count = data?['unreadCount'];
        if (count is int) return count;
        if (count is double) return count.toInt();
        return 0;
      } catch (e) {
        debugPrint('[UserNotifService] Error parsing unread count: $e');
        return 0;
      }
    }).handleError((error) {
      debugPrint('[UserNotifService] UnreadCount stream error: $error');
      return 0;
    });
  }

  /// Add a notification to user's document (called by Cloud Functions usually)
  /// This is for manual testing or local notification creation
  Future<void> addNotification({
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      final notificationId = _uuid.v4();
      final notifItem = NotificationItem(
        id: notificationId,
        type: type,
        title: title,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
        data: data,
      );

      await docRef.update({
        'notifications': FieldValue.arrayUnion([notifItem.toMap()]),
        'unreadCount': FieldValue.increment(1),
      });
      
      debugPrint('[UserNotifService] Notification added: $title');
    } catch (e) {
      debugPrint('[UserNotifService] Error adding notification: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      // Get current document
      final doc = await docRef.get();
      if (!doc.exists) return;

      final model = UserNotificationModel.fromFirestore(doc);
      final notifications = model.notifications.toList();
      
      // Find and update the notification
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index == -1) return;
      
      if (notifications[index].isRead) return; // Already read
      
      notifications[index] = notifications[index].copyWith(isRead: true);
      
      // Update document
      await docRef.update({
        'notifications': notifications.map((n) => n.toMap()).toList(),
        'unreadCount': FieldValue.increment(-1),
      });
      
      debugPrint('[UserNotifService] Notification marked as read: $notificationId');
    } catch (e) {
      debugPrint('[UserNotifService] Error marking as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      final doc = await docRef.get();
      if (!doc.exists) return;

      final model = UserNotificationModel.fromFirestore(doc);
      final notifications = model.notifications.map((n) => 
        n.copyWith(isRead: true)
      ).toList();
      
      await docRef.update({
        'notifications': notifications.map((n) => n.toMap()).toList(),
        'unreadCount': 0,
      });
      
      debugPrint('[UserNotifService] All notifications marked as read');
    } catch (e) {
      debugPrint('[UserNotifService] Error marking all as read: $e');
    }
  }

  /// Delete a specific notification
  Future<void> deleteNotification(String notificationId) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      final doc = await docRef.get();
      if (!doc.exists) return;

      final model = UserNotificationModel.fromFirestore(doc);
      final notifToDelete = model.notifications.firstWhereOrNull(
        (n) => n.id == notificationId,
      );
      
      if (notifToDelete == null) return;
      
      final decrementUnread = !notifToDelete.isRead ? 1 : 0;
      
      final notifications = model.notifications
          .where((n) => n.id != notificationId)
          .toList();
      
      await docRef.update({
        'notifications': notifications.map((n) => n.toMap()).toList(),
        if (decrementUnread > 0) 'unreadCount': FieldValue.increment(-1),
      });
      
      debugPrint('[UserNotifService] Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('[UserNotifService] Error deleting notification: $e');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    try {
      await docRef.update({
        'notifications': [],
        'unreadCount': 0,
      });
      
      debugPrint('[UserNotifService] All notifications deleted');
    } catch (e) {
      debugPrint('[UserNotifService] Error deleting all notifications: $e');
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Check if user notification document exists
  Future<bool> doesDocumentExist() async {
    final docRef = _userDocRef;
    if (docRef == null) return false;

    try {
      final doc = await docRef.get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get full document data for debugging
  Future<Map<String, dynamic>?> getDebugInfo() async {
    final docRef = _userDocRef;
    if (docRef == null) return null;

    try {
      final doc = await docRef.get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Call Cloud Function to fix incomplete user_notifications documents
  /// Admin use only
  Future<Map<String, dynamic>?> fixAllUserNotificationStructures() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'fixUserNotificationStructure',
      );
      final result = await callable.call();
      debugPrint('[UserNotifService] Fix structure result: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('[UserNotifService] Error fixing structures: $e');
      return null;
    }
  }

  /// Ensure current user's document has complete structure
  /// Call this after login to fix any incomplete docs
  Future<void> ensureCompleteStructure() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _collection.doc(user.uid);

    try {
      final doc = await docRef.get();
      if (!doc.exists) {
        debugPrint('[UserNotifService] Doc not exist, will be created on token save');
        return;
      }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      final updateData = <String, dynamic>{};

      // Check and fill missing fields
      if (data['fcmTokens'] == null) {
        updateData['fcmTokens'] = [];
      }
      if (data['subscribedTopics'] == null) {
        updateData['subscribedTopics'] = ['user-${user.uid}', 'general'];
      }
      if (data['notificationSubscription'] == null) {
        updateData['notificationSubscription'] = true;
      }
      if (data['notifications'] == null) {
        updateData['notifications'] = [];
      }
      if (data['unreadCount'] == null) {
        updateData['unreadCount'] = 0;
      }

      if (updateData.isNotEmpty) {
        await docRef.update(updateData);
        debugPrint('[UserNotifService] Fixed missing fields: ${updateData.keys.join(', ')}');
      } else {
        debugPrint('[UserNotifService] Document structure is complete');
      }
    } catch (e) {
      debugPrint('[UserNotifService] Error ensuring complete structure: $e');
    }
  }
}
