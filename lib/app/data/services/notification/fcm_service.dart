import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'local_notification_service.dart';
import 'user_notification_service.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Local notification will be shown automatically by FCM for background messages
}

/// FCM Service for handling Firebase Cloud Messaging
class FCMService extends GetxService {
  static FCMService get to => Get.find<FCMService>();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Reference to UserNotificationService
  UserNotificationService get _userNotifService => UserNotificationService.to;
  
  final _token = Rxn<String>();
  String? get token => _token.value;
  
  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;
  
  StreamSubscription? _tokenRefreshSubscription;
  StreamSubscription? _foregroundMessageSubscription;
  
  /// Initialize FCM Service
  Future<FCMService> init() async {
    if (_isInitialized.value) return this;
    
    try {
      // Request permission
      await _requestPermission();
      
      // Get FCM token
      await _getToken();
      
      // Listen for token refresh
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(_onTokenRefresh);
      
      // Configure message handlers
      _configureMessageHandlers();
      
      _isInitialized.value = true;
    } catch (e) {
    }
    
    return this;
  }
  
  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    } else {
    }
  }
  
  /// Get FCM token
  Future<void> _getToken() async {
    try {
      String? fcmToken;
      
      if (kIsWeb) {
        fcmToken = await _messaging.getToken();
      } else {
        fcmToken = await _messaging.getToken();
      }
      
      _token.value = fcmToken;
      debugPrint('[FCM] Got token: ${fcmToken?.substring(0, 20)}...');
      
      // Save token to Firestore if user is logged in
      await _saveTokenToFirestore(fcmToken);
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
    }
  }
  
  /// Handle token refresh
  void _onTokenRefresh(String newToken) {
    debugPrint('[FCM] Token refreshed: ${newToken.substring(0, 20)}...');
    _token.value = newToken;
    _saveTokenToFirestore(newToken);
  }
  
  /// Save FCM token to Firestore
  /// Now uses unified user_notifications collection + legacy users collection
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[FCM] No user logged in, cannot save token');
      return;
    }
    
    try {
      // PRIMARY: Save to user_notifications collection (new unified structure)
      await _userNotifService.saveFcmToken(token);
      
      // LEGACY: Also save to users collection for backward compatibility
      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      debugPrint('[FCM] Token saved to both collections: ${user.uid}');
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
      // Fallback: try merge set
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmTokens': [token],
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        debugPrint('[FCM] Failed to save token: $e2');
      }
    }
  }
  
  /// Force refresh and save FCM token (call on login)
  Future<void> refreshAndSaveToken() async {
    try {
      // Delete old token and get new one
      await _messaging.deleteToken();
      final newToken = await _messaging.getToken();
      
      if (newToken != null) {
        _token.value = newToken;
        await _saveTokenToFirestore(newToken);
        debugPrint('[FCM] Token refreshed and saved: ${newToken.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('[FCM] Error refreshing token: $e');
      // Fallback to just getting token
      await _getToken();
    }
  }
  
  /// Configure message handlers
  void _configureMessageHandlers() {
    // Foreground messages
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background message opened (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Check if app was opened from terminated state via notification
    _checkInitialMessage();
  }
  
  /// Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] Foreground message received: ${message.notification?.title}');
    
    // Show local notification
    await LocalNotificationService.to.showNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'Puskesmas Dau',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }
  
  /// Handle message when app is opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    _navigateBasedOnMessage(message.data);
  }
  
  /// Check initial message (app opened from terminated state)
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Delay navigation to ensure app is fully loaded
      Future.delayed(const Duration(seconds: 1), () {
        _navigateBasedOnMessage(initialMessage.data);
      });
    }
  }
  
  /// Navigate based on message data
  void _navigateBasedOnMessage(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'antrian_created':
      case 'status_update':
      case 'cancelled':
        // Navigate to antrian/status page
        if (Get.currentRoute != Routes.pasienStatusAntrean) {
          Get.toNamed(Routes.pasienStatusAntrean);
        }
        break;
        
      case 'medicine_ready':
      case 'visit_complete':
        // Navigate to status antrean (notification page removed)
        if (Get.currentRoute != Routes.pasienStatusAntrean) {
          Get.toNamed(Routes.pasienStatusAntrean);
        }
        break;
        
      case 'new_patient':
      case 'patient_waiting':
        // For staff, navigate to dashboard
        break;
        
      case 'stock_alert':
      case 'expiry_alert':
        // Navigate to stock management
        break;
        
      case 'daily_summary':
        // Navigate to reports
        break;
        
      default:
    }
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
    }
  }
  
  /// Setup user topics during LOGIN (for existing/old accounts)
  /// Now uses unified user_notifications collection
  /// This will setup topics if not exists, but WILL NOT change notificationSubscription status
  Future<void> setupUserTopicsOnLogin(String role, {String? namaLengkap}) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[FCM] setupUserTopicsOnLogin: No user logged in');
      return;
    }
    
    debugPrint('[FCM] setupUserTopicsOnLogin: Starting for role=$role, uid=${user.uid}');
    
    try {
      // STEP 0: Ensure existing document has complete structure
      await _userNotifService.ensureCompleteStructure();
      
      // STEP 1: Initialize/update user_notifications document
      await _userNotifService.initializeUserNotificationDoc(
        role: role,
        namaLengkap: namaLengkap,
      );
      
      // STEP 2: Refresh and save FCM token
      await refreshAndSaveToken();
      
      // STEP 3: Get current subscription status from new unified collection
      final isSubscribed = await _userNotifService.getNotificationSubscription();
      
      // Personal topic for this user
      final personalTopic = 'user-${user.uid}';
      
      // Build list of topics to subscribe
      const broadcastRoleTopics = ['admin', 'perawat', 'apoteker'];
      final topicsToSubscribe = <String>[personalTopic, 'general'];
      
      if (broadcastRoleTopics.contains(role)) {
        topicsToSubscribe.add(role);
      }
      
      debugPrint('[FCM] setupUserTopicsOnLogin: isSubscribed=$isSubscribed, topics=$topicsToSubscribe');
      
      // STEP 4: Subscribe to FCM topics if enabled
      if (isSubscribed) {
        for (final topic in topicsToSubscribe) {
          await subscribeToTopic(topic);
          debugPrint('[FCM] Subscribed to topic: $topic');
        }
        // Force subscribe via Cloud Function to ensure server-side sync
        await forceSubscribeViaCloudFunction();
      }
      
      // STEP 5: Update topics in new unified collection
      await _userNotifService.updateSubscribedTopics(topicsToSubscribe);
      
      // LEGACY: Also update users collection for backward compatibility
      await _firestore.collection('users').doc(user.uid).update({
        'subscribedTopics': topicsToSubscribe,
        'lastTopicUpdate': FieldValue.serverTimestamp(),
      });
      
      debugPrint('[FCM] setupUserTopicsOnLogin: Complete');
    } catch (e) {
      debugPrint('[FCM] setupUserTopicsOnLogin error: $e');
    }
  }
  
  /// Setup user topics during REGISTRATION (new accounts)
  /// This will ALWAYS set notificationSubscription = true
  /// Use this for registration flow
  Future<void> setupUserTopicsOnRegistration(String role, {String? namaLengkap}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final personalTopic = 'user-${user.uid}';
      const broadcastRoleTopics = ['admin', 'perawat', 'apoteker'];
      
      // Build list of topics to subscribe
      final topicsToSubscribe = <String>[personalTopic, 'general'];
      
      if (broadcastRoleTopics.contains(role)) {
        topicsToSubscribe.add(role);
      }
      
      // Subscribe to all FCM topics
      for (final topic in topicsToSubscribe) {
        await subscribeToTopic(topic);
      }
      
      // Initialize user_notifications document with subscription enabled
      await _userNotifService.initializeUserNotificationDoc(
        role: role,
        namaLengkap: namaLengkap,
      );
      await _userNotifService.setNotificationSubscription(true);
      await _userNotifService.updateSubscribedTopics(topicsToSubscribe);
      
      // LEGACY: Update users collection for backward compatibility
      await _firestore.collection('users').doc(user.uid).update({
        'notificationSubscription': true,
        'notificationCreatedAt': FieldValue.serverTimestamp(),
        'subscribedTopics': topicsToSubscribe,
        'lastTopicUpdate': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      debugPrint('[FCM] setupUserTopicsOnRegistration error: $e');
    }
  }
  
  /// Subscribe user to role-based topic after login
  /// @deprecated Use setupUserTopicsOnLogin() or setupUserTopicsOnRegistration() instead
  /// Kept for backward compatibility
  Future<void> subscribeUserToRoleTopic(String role) async {
    // Delegate to login setup for backward compatibility
    await setupUserTopicsOnLogin(role);
  }
  
  /// Unsubscribe user from all topics (when disabling notifications)
  Future<void> unsubscribeUserFromAllTopics() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Get user's subscribed topics
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      final topics = List<String>.from(data?['subscribedTopics'] ?? []);
      
      // Unsubscribe from all topics
      for (final topic in topics) {
        await unsubscribeFromTopic(topic);
      }
      
      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'notificationSubscription': false,
      });
      
    } catch (e) {
    }
  }
  
  /// Remove current token (on logout)
  Future<void> removeToken() async {
    final user = _auth.currentUser;
    final currentToken = _token.value;
    
    if (user != null && currentToken != null) {
      try {
        // Remove from unified collection
        await _userNotifService.removeFcmToken(currentToken);
        
        // LEGACY: Also remove from users collection
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayRemove([currentToken]),
        });
      } catch (e) {
        debugPrint('[FCM] Error removing token: $e');
      }
    }
  }
  
  /// Check if user has notification subscription enabled
  /// Now reads from unified user_notifications collection
  Future<bool> isNotificationEnabled() async {
    return await _userNotifService.getNotificationSubscription();
  }
  
  /// Watch notification subscription status (realtime)
  Stream<bool> watchNotificationEnabled() {
    return _userNotifService.watchNotificationSubscription();
  }
  
  /// Toggle notification subscription
  /// Now uses unified user_notifications collection
  Future<void> toggleNotificationSubscription(bool enabled, String role) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      if (enabled) {
        // Re-subscribe to topics
        final personalTopic = 'user-${user.uid}';
        const broadcastRoleTopics = ['admin', 'perawat', 'apoteker'];
        final topicsToSubscribe = <String>[personalTopic, 'general'];
        
        if (broadcastRoleTopics.contains(role)) {
          topicsToSubscribe.add(role);
        }
        
        for (final topic in topicsToSubscribe) {
          await subscribeToTopic(topic);
        }
        
        // Update unified collection
        await _userNotifService.setNotificationSubscription(true);
        await _userNotifService.updateSubscribedTopics(topicsToSubscribe);
        
        // Force server-side sync
        await forceSubscribeViaCloudFunction();
        
        // LEGACY: Update users collection
        await _firestore.collection('users').doc(user.uid).update({
          'notificationSubscription': true,
          'subscribedTopics': topicsToSubscribe,
        });
      } else {
        // Get current topics and unsubscribe
        final userNotif = await _userNotifService.getUserNotifications();
        final topics = userNotif?.subscribedTopics ?? [];
        
        for (final topic in topics) {
          await unsubscribeFromTopic(topic);
        }
        
        // Update unified collection
        await _userNotifService.setNotificationSubscription(false);
        
        // LEGACY: Update users collection
        await _firestore.collection('users').doc(user.uid).update({
          'notificationSubscription': false,
        });
      }
      
      debugPrint('[FCM] Notification subscription toggled to: $enabled');
    } catch (e) {
      debugPrint('[FCM] Error toggling subscription: $e');
      rethrow;
    }
  }
  
  /// Force subscribe user's FCM tokens to their topics via Cloud Function
  /// This ensures server-side subscription is in sync with Firestore
  /// Call this after login to guarantee push notifications work
  Future<void> forceSubscribeViaCloudFunction() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('forceSubscribeUserTopics');
      final result = await callable.call();
      
      if (result.data['success'] == true) {
        final topics = result.data['topics'] as List?;
        debugPrint('[FCM] Force subscribed to topics: $topics');
      }
    } catch (e) {
      debugPrint('[FCM] Force subscribe failed: $e');
      // Silent fail - local subscription should still work
    }
  }
  
  @override
  void onClose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    super.onClose();
  }
}