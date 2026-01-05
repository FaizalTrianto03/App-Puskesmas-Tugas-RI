import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/notification/fcm_service.dart';
import '../data/services/notification/user_notification_service.dart';
import '../utils/snackbar_helper.dart';

/// A reusable widget for toggling notification settings
/// Now uses unified user_notifications collection with realtime updates
/// This allows users to enable/disable push notifications
class NotificationToggleTile extends StatefulWidget {
  final String role;
  
  const NotificationToggleTile({
    super.key,
    required this.role,
  });

  @override
  State<NotificationToggleTile> createState() => _NotificationToggleTileState();
}

class _NotificationToggleTileState extends State<NotificationToggleTile> {
  final _isLoading = false.obs;
  StreamSubscription? _subscription;
  final _isEnabled = true.obs; // Default to true
  
  @override
  void initState() {
    super.initState();
    _initializeAndWatch();
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  /// Initialize the notification document if needed and start watching
  Future<void> _initializeAndWatch() async {
    try {
      // Ensure document exists
      final exists = await UserNotificationService.to.doesDocumentExist();
      if (!exists) {
        // Initialize with default values
        await UserNotificationService.to.initializeUserNotificationDoc(
          role: widget.role,
        );
      }
      
      // Start watching realtime changes
      _subscription = UserNotificationService.to
          .watchNotificationSubscription()
          .listen((enabled) {
        _isEnabled.value = enabled;
      });
    } catch (e) {
      debugPrint('[NotificationToggle] Error initializing: $e');
      // Fallback to default true
      _isEnabled.value = true;
    }
  }
  
  /// Toggle notification subscription
  Future<void> _toggleNotification(bool value) async {
    _isLoading.value = true;
    
    try {
      // Use FCM Service to handle topic subscription + Firestore update
      await FCMService.to.toggleNotificationSubscription(value, widget.role);
      
      // Value will be updated via stream automatically
      
      SnackbarHelper.showSuccess(
        value 
          ? 'Notifikasi diaktifkan' 
          : 'Notifikasi dinonaktifkan',
      );
    } catch (e) {
      debugPrint('[NotificationToggle] Error toggling: $e');
      SnackbarHelper.showError('Gagal mengubah pengaturan notifikasi');
    } finally {
      _isLoading.value = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF02B1BA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isEnabled.value 
              ? Icons.notifications_active 
              : Icons.notifications_off_outlined,
            color: const Color(0xFF02B1BA),
            size: 24,
          ),
        ),
        title: const Text(
          'Pemberitahuan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _isEnabled.value 
            ? 'Aktif - Anda akan menerima notifikasi' 
            : 'Nonaktif - Notifikasi dimatikan',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: _isLoading.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF02B1BA),
              ),
            )
          : Switch(
              value: _isEnabled.value,
              onChanged: _toggleNotification,
              activeColor: const Color(0xFF02B1BA),
              activeTrackColor: const Color(0xFF02B1BA).withOpacity(0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
      )),
    );
  }
}
