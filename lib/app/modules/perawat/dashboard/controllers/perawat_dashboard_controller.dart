import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../rekam_medis/views/form_rekam_medis_view.dart';

class PerawatDashboardController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final SessionService _sessionService = Get.find<SessionService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription? _antrianSubscription;

  final userName = ''.obs;
  final userRole = ''.obs;
  final antrianList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  
  // Search & Filter
  final searchQuery = ''.obs;
  final selectedFilter = 'semua'.obs; // semua, menunggu_verifikasi, terverifikasi

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadAntrian();
    // Start listening to real-time updates
    _startAntrianListener();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data setiap kali view siap ditampilkan
    loadAntrian();
  }

  @override
  void onClose() {
    _antrianSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
    
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
    }
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'perawat':
        return 'Perawat';
      default:
        return role;
    }
  }

  void _startAntrianListener() {
    // Subscribe to real-time updates menggunakan stream
    _antrianSubscription?.cancel();
    
    // ✅ GUNAKAN STREAM untuk auto refresh real-time dari Firestore
    _antrianSubscription = _antrianService.watchAllAntrianToday().listen(
      (data) {
        print('[PerawatDashboardController] Real-time update: ${data.length} antrian');
        antrianList.value = data;
        isLoading.value = false;
      },
      onError: (error) {
        print('[PerawatDashboardController] Stream error: $error');
        SnackbarHelper.showError('Gagal memuat data antrian');
        isLoading.value = false;
      },
    );
  }

  Future<void> loadAntrian() async {
    isLoading.value = true;
    
    try {
      // Load antrian dari Firestore (manual refresh)
      List<Map<String, dynamic>> data = await _antrianService.getAllAntrian();
      antrianList.value = data;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data antrian');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get antrianMenungguVerifikasi {
    return _filteredAntrianList
        .where((a) => a['status'] == 'menunggu' || a['status'] == 'menunggu_verifikasi')
        .toList();
  }

  List<Map<String, dynamic>> get antrianTerverifikasi {
    return _filteredAntrianList
        .where((a) => a['status'] == 'menunggu_dokter' || a['status'] == 'sedang_dilayani' || a['status'] == 'dipanggil')
        .toList();
  }
  
  /// Filtered list berdasarkan search & filter
  List<Map<String, dynamic>> get _filteredAntrianList {
    var filtered = antrianList.toList();
    
    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((antrian) {
        final nama = (antrian['namaLengkap'] ?? '').toLowerCase();
        final noAntrian = (antrian['queueNumber'] ?? '').toLowerCase();
        final noRM = (antrian['noRekamMedis'] ?? '').toLowerCase();
        return nama.contains(query) || 
               noAntrian.contains(query) || 
               noRM.contains(query);
      }).toList();
    }
    
    // Apply status filter
    if (selectedFilter.value == 'menunggu_verifikasi') {
      filtered = filtered.where((a) => 
        a['status'] == 'menunggu' || a['status'] == 'menunggu_verifikasi'
      ).toList();
    } else if (selectedFilter.value == 'terverifikasi') {
      filtered = filtered.where((a) => 
        a['status'] == 'menunggu_dokter' || 
        a['status'] == 'sedang_dilayani' || 
        a['status'] == 'dipanggil'
      ).toList();
    }
    
    return filtered;
  }
  
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  void clearSearch() {
    searchQuery.value = '';
  }

  int getTotalAntrianHariIni() {
    return antrianList.length;
  }

  int getMenungguVerifikasiCount() {
    return antrianMenungguVerifikasi.length;
  }

  int getTerverifikasiCount() {
    return antrianTerverifikasi.length;
  }

  void refreshData() {
    // ✅ Tidak perlu manual refresh karena sudah ada stream real-time
    // Stream akan otomatis update ketika ada perubahan data di Firestore
    // Hanya perlu trigger manual jika stream belum aktif
    if (_antrianSubscription == null || _antrianSubscription!.isPaused) {
      _startAntrianListener();
    }
  }

  Future<void> verifikasiAntrian(Map<String, dynamic> antrian) async {
    final perawatId = _sessionService.getUserId();
    final perawatName = _sessionService.getNamaLengkap();

    if (perawatId == null || perawatName == null) {
      SnackbarHelper.showError('Sesi tidak valid');
      return;
    }

    isLoading.value = true;

    final success = await _antrianService.verifikasiAntrian(
      antrianId: antrian['id'],
      perawatId: perawatId,
      perawatName: perawatName,
      catatan: 'Diverifikasi dari dashboard',
    );

    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess(
        'Antrian ${antrian['queueNumber']} berhasil diverifikasi',
      );
      // ✅ Tidak perlu refresh manual, stream akan auto-update
    } else {
      SnackbarHelper.showError('Gagal memverifikasi antrian');
    }
  }

  void navigateToVerifikasi() {
    SnackbarHelper.showInfo(
      'Klik tombol "Verifikasi" pada kartu antrian untuk memverifikasi',
    );
  }

  void navigateToFormRekamMedis(Map<String, dynamic> antrian) {
    Get.to(() => FormRekamMedisView(pasienData: antrian));
  }

  Future<void> ubahStatusAntrian({
    required String antrianId,
    required String newStatus,
    required Map<String, dynamic> antrian,
  }) async {
    // Validasi input
    if (antrianId.isEmpty) {
      SnackbarHelper.showError('ID antrian tidak valid');
      return;
    }

    // Prevent double-click
    if (isLoading.value) {
      print('[PerawatDashboardController] Already processing, ignoring duplicate request');
      return;
    }

    isLoading.value = true;

    try {
      print('[PerawatDashboardController] Updating status: $antrianId -> $newStatus');
      
      // Update status di Firestore
      await _firestore.collection('antrian').doc(antrianId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('[PerawatDashboardController] ✅ Status updated successfully');

      // Close dialog jika ada
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show success message
      SnackbarHelper.showSuccess('Status berhasil diubah ke: ${_formatStatusText(newStatus)}');

      // Stream akan otomatis update data, tidak perlu manual refresh
      
    } catch (e) {
      print('[PerawatDashboardController] ❌ Error updating status: $e');
      
      // Close dialog jika ada
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      SnackbarHelper.showError('Gagal mengubah status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatStatusText(String status) {
    switch (status) {
      case 'menunggu':
        return 'Menunggu Verifikasi';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'menunggu_dokter':
        return 'Menunggu Dokter';
      case 'dipanggil':
        return 'Dipanggil';
      case 'sedang_dilayani':
        return 'Sedang Dilayani';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
