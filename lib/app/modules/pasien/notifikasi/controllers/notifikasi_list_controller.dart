import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/notifikasi_model.dart';
import '../../../../data/services/firestore/notifikasi_firestore_service.dart';

class NotifikasiListController {
  final NotifikasiFirestoreService _notifikasiService = NotifikasiFirestoreService();
  
  final selectedFilter = ValueNotifier<String>('Semua');
  final hoveredIndex = ValueNotifier<int?>(null);
  final pressedIndex = ValueNotifier<int?>(null);
  final hoveredFilterIndex = ValueNotifier<int?>(null);
  
  // Firestore data
  final notifikasiList = ValueNotifier<List<NotifikasiModel>>([]);
  final unreadCount = ValueNotifier<int>(0);
  final isLoading = ValueNotifier<bool>(false);
  
  StreamSubscription? _notifikasiSubscription;
  StreamSubscription? _unreadCountSubscription;
  
  NotifikasiListController() {
    _watchNotifikasi();
    _watchUnreadCount();
  }
  
  void dispose() {
    _notifikasiSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    selectedFilter.dispose();
    hoveredIndex.dispose();
    pressedIndex.dispose();
    hoveredFilterIndex.dispose();
    notifikasiList.dispose();
    unreadCount.dispose();
    isLoading.dispose();
  }
  
  void _watchNotifikasi() {
    _notifikasiSubscription = _notifikasiService.watchNotifikasi().listen((data) {
      notifikasiList.value = data;
    });
  }
  
  void _watchUnreadCount() {
    _unreadCountSubscription = _notifikasiService.watchUnreadCount().listen((count) {
      unreadCount.value = count;
    });
  }
  
  List<NotifikasiModel> get filteredNotifikasi {
    if (selectedFilter.value == 'Semua') {
      return notifikasiList.value;
    }
    return notifikasiList.value.where((n) => n.type == selectedFilter.value).toList();
  }
  
  Future<void> markAsRead(String notifikasiId) async {
    try {
      await _notifikasiService.markAsRead(notifikasiId);
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

  void setSelectedFilter(String filter) {
    selectedFilter.value = filter;
  }
  void setHoveredIndex(int? index) {
    hoveredIndex.value = index;
  }
  void setPressedIndex(int? index) {
    pressedIndex.value = index;
  }
  void setHoveredFilterIndex(int? index) {
    hoveredFilterIndex.value = index;
  }
}
