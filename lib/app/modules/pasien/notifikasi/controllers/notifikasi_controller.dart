import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/models/notifikasi_model.dart';
import '../../../../data/services/firestore/notifikasi_firestore_service.dart';

class NotifikasiController extends GetxController {
  final NotifikasiFirestoreService _notifikasiService = NotifikasiFirestoreService();
  
  final notificationList = <NotifikasiModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final selectedFilter = 'Semua'.obs;
  
  final filterOptions = ['Semua', 'Belum Dibaca', 'Sudah Dibaca'];
  
  StreamSubscription? _notifikasiSubscription;
  StreamSubscription? _unreadSubscription;
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    watchUnreadCount();
  }
  
  @override
  void onClose() {
    _notifikasiSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.onClose();
  }
  
  void loadNotifications() async {
    try {
      isLoading.value = true;
      
      // Use real-time stream
      _notifikasiSubscription?.cancel();
      _notifikasiSubscription = _notifikasiService.watchNotifikasi().listen((notifikasi) {
        notificationList.value = notifikasi;
        applyFilter();
      });
      
    } catch (e) {
      print('Error loading notifications: $e');
      notificationList.value = [];
    } finally {
      isLoading.value = false;
    }
  }
  
  void watchUnreadCount() {
    _unreadSubscription?.cancel();
    _unreadSubscription = _notifikasiService.watchUnreadCount().listen((count) {
      unreadCount.value = count;
    });
  }
  
  void applyFilter() {
    // Filter is applied in getter
  }
  
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  List<NotifikasiModel> get filteredNotifications {
    if (selectedFilter.value == 'Belum Dibaca') {
      return notificationList.where((n) => !n.isRead).toList();
    } else if (selectedFilter.value == 'Sudah Dibaca') {
      return notificationList.where((n) => n.isRead).toList();
    }
    return notificationList.toList();
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notifikasiService.markAsRead(notificationId);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _notifikasiService.markAllAsRead();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notifikasiService.deleteNotifikasi(notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  NotifikasiModel? getNotificationDetail(String notificationId) {
    try {
      return notificationList.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> refreshNotifications() async {
    loadNotifications();
  }
}
