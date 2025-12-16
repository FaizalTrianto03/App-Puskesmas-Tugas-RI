import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/models/notifikasi_model.dart';
import '../../../../data/services/firestore/notifikasi_firestore_service.dart';

class NotifikasiListController extends GetxController {
  final NotifikasiFirestoreService _notifikasiService = NotifikasiFirestoreService();
  
  final selectedFilter = 'Semua'.obs;
  final hoveredIndex = Rxn<int>();
  final pressedIndex = Rxn<int>();
  final hoveredFilterIndex = Rxn<int>();
  
  // Firestore data
  final notifikasiList = <NotifikasiModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  
  StreamSubscription? _notifikasiSubscription;
  StreamSubscription? _unreadCountSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _watchNotifikasi();
    _watchUnreadCount();
  }
  
  @override
  void onClose() {
    _notifikasiSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.onClose();
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
      return notifikasiList;
    }
    return notifikasiList.where((n) => n.type == selectedFilter.value).toList();
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

  void setSelectedFilter(String filter) => selectedFilter.value = filter;
  void setHoveredIndex(int? index) => hoveredIndex.value = index;
  void setPressedIndex(int? index) => pressedIndex.value = index;
  void setHoveredFilterIndex(int? index) => hoveredFilterIndex.value = index;
}
