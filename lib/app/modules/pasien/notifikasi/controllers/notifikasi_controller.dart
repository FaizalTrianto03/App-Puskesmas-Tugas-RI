import 'package:get/get.dart';

class NotifikasiController extends GetxController {
  final notificationList = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final selectedFilter = 'Semua'.obs;
  
  final filterOptions = ['Semua', 'Belum Dibaca', 'Sudah Dibaca'];
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }
  
  void loadNotifications() {
    isLoading.value = true;
    
    notificationList.value = [
      {
        'id': 'N001',
        'title': 'Pendaftaran Berhasil',
        'message': 'Pendaftaran Anda untuk Poli Umum telah berhasil. Nomor antrian: A001',
        'type': 'pendaftaran',
        'isRead': false,
        'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'icon': 'check_circle',
        'color': 'green',
      },
      {
        'id': 'N002',
        'title': 'Antrian Segera Dipanggil',
        'message': 'Nomor antrian Anda (A001) akan segera dipanggil. Silakan bersiap.',
        'type': 'antrian',
        'isRead': false,
        'date': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'icon': 'notifications_active',
        'color': 'orange',
      },
      {
        'id': 'N003',
        'title': 'Hasil Pemeriksaan Tersedia',
        'message': 'Hasil pemeriksaan Anda telah tersedia. Silakan cek di menu Riwayat Kunjungan.',
        'type': 'hasil',
        'isRead': true,
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'icon': 'assignment',
        'color': 'blue',
      },
      {
        'id': 'N004',
        'title': 'Jadwal Kontrol',
        'message': 'Anda memiliki jadwal kontrol pada 15 Desember 2025. Jangan lupa hadir.',
        'type': 'jadwal',
        'isRead': true,
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'icon': 'calendar_today',
        'color': 'purple',
      },
      {
        'id': 'N005',
        'title': 'Pengingat Minum Obat',
        'message': 'Jangan lupa minum obat Anda pukul 14:00. Amoxicillin 500mg.',
        'type': 'pengingat',
        'isRead': true,
        'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'icon': 'medication',
        'color': 'teal',
      },
    ];
    
    updateUnreadCount();
    isLoading.value = false;
  }
  
  void updateUnreadCount() {
    unreadCount.value = notificationList.where((n) => n['isRead'] == false).length;
  }
  
  void markAsRead(String notificationId) {
    final index = notificationList.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      notificationList[index]['isRead'] = true;
      notificationList.refresh();
      updateUnreadCount();
    }
  }
  
  void markAllAsRead() {
    for (var notification in notificationList) {
      notification['isRead'] = true;
    }
    notificationList.refresh();
    updateUnreadCount();
  }
  
  void deleteNotification(String notificationId) {
    notificationList.removeWhere((n) => n['id'] == notificationId);
    updateUnreadCount();
  }
  
  void clearAllNotifications() {
    notificationList.clear();
    updateUnreadCount();
  }
  
  void applyFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter.value == 'Belum Dibaca') {
      return notificationList.where((n) => n['isRead'] == false).toList();
    } else if (selectedFilter.value == 'Sudah Dibaca') {
      return notificationList.where((n) => n['isRead'] == true).toList();
    }
    return notificationList.toList();
  }
  
  Map<String, dynamic>? getNotificationDetail(String notificationId) {
    try {
      return notificationList.firstWhere((n) => n['id'] == notificationId);
    } catch (e) {
      return null;
    }
  }
}
