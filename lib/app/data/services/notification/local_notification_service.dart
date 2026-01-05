import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local Notification Service for showing notifications when app is in foreground
class LocalNotificationService extends GetxService {
  static LocalNotificationService get to => Get.find<LocalNotificationService>();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;
  
  /// Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'puskesmas_notifications',
    'Notifikasi Puskesmas',
    description: 'Notifikasi dari aplikasi Puskesmas Dau',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notif_puskesmas_dau'),
    enableVibration: true,
  );
  
  /// Initialize Local Notification Service
  Future<LocalNotificationService> init() async {
    if (_isInitialized.value) return this;
    
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );
      
      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }
      
      _isInitialized.value = true;
    } catch (e) {
    }
    
    return this;
  }
  
  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }
  }
  
  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    _handleNotificationPayload(response.payload);
  }
  
  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    _handleNotificationPayload(response.payload);
  }
  
  /// Handle notification payload for navigation
  static void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'];
      
      // Navigation will be handled by FCMService._navigateBasedOnMessage
    } catch (e) {
    }
  }
  
  /// Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized.value) {
      return;
    }
    
    final androidDetails = AndroidNotificationDetails(
      'puskesmas_notifications',
      'Notifikasi Puskesmas',
      channelDescription: 'Notifikasi dari aplikasi Puskesmas Dau',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notif_puskesmas_dau'),
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF02B1BA),
      styleInformation: BigTextStyleInformation(body),
    );
    
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notif_puskesmas_dau.mp3',
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
    
    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    
  }
  
  /// Show notification with big picture (for rich notifications)
  Future<void> showNotificationWithImage({
    required int id,
    required String title,
    required String body,
    required String imagePath,
    String? payload,
  }) async {
    if (!_isInitialized.value) return;
    
    final bigPictureStyle = BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      contentTitle: title,
      summaryText: body,
    );
    
    final androidDetails = AndroidNotificationDetails(
      'puskesmas_notifications',
      'Notifikasi Puskesmas',
      channelDescription: 'Notifikasi dari aplikasi Puskesmas Dau',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notif_puskesmas_dau'),
      styleInformation: bigPictureStyle,
    );
    
    final notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notifications.show(id, title, body, notificationDetails, payload: payload);
  }
  
  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized.value) return;
    
    const androidDetails = AndroidNotificationDetails(
      'puskesmas_notifications',
      'Notifikasi Puskesmas',
      channelDescription: 'Notifikasi dari aplikasi Puskesmas Dau',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_puskesmas_dau'),
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    // Convert to TZDateTime
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
    
  }
  
  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true;
  }
  
  /// Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }
    return true;
  }
}
