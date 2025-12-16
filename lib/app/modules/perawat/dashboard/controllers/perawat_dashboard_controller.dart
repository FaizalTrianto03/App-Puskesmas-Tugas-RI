import 'dart:async';

import 'package:get/get.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../rekam_medis/views/form_rekam_medis_view.dart';

class PerawatDashboardController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final SessionService _sessionService = Get.find<SessionService>();
  
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
    print('=== PERAWAT DASHBOARD DEBUG ===');
    print('Loading user data for dashboard...');
    
    final userData = await AuthHelper.currentUserData;
    print('UserData from Firestore: $userData');
    
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
      
      print('Dashboard loaded:');
      print('  - Name: ${userName.value}');
      print('  - Role: ${userRole.value}');
    } else {
      print('ERROR: userData is NULL!');
    }
    print('=== END PERAWAT DASHBOARD DEBUG ===');
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
    _antrianSubscription = _antrianService.watchAllAntrianToday().listen(
      (antrianData) {
        antrianList.value = antrianData;
      },
      onError: (error) {
        print('Error listening to antrian: $error');
      },
    );
  }

  Future<void> loadAntrian() async {
    isLoading.value = true;
    
    try {
      final data = await _antrianService.getAllAntrianToday();
      antrianList.value = data;
    } catch (e) {
      print('Error loading antrian: $e');
      SnackbarHelper.showError('Gagal memuat data antrian');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get antrianMenungguVerifikasi {
    return _filteredAntrianList
        .where((a) => a['status'] == 'menunggu_verifikasi')
        .toList();
  }

  List<Map<String, dynamic>> get antrianTerverifikasi {
    return _filteredAntrianList
        .where((a) => a['status'] == 'menunggu_dokter' || a['status'] == 'sedang_dilayani')
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
      filtered = filtered.where((a) => a['status'] == 'menunggu_verifikasi').toList();
    } else if (selectedFilter.value == 'terverifikasi') {
      filtered = filtered.where((a) => 
        a['status'] == 'menunggu_dokter' || a['status'] == 'sedang_dilayani'
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
    loadAntrian();
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
      refreshData();
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

  /// Ubah status antrian dengan dropdown
  Future<void> ubahStatusAntrian({
    required String antrianId,
    required String newStatus,
    required Map<String, dynamic> antrian,
  }) async {
    final perawatId = _sessionService.getUserId();
    final perawatName = _sessionService.getNamaLengkap();

    if (perawatId == null || perawatName == null) {
      SnackbarHelper.showError('Sesi tidak valid');
      return;
    }

    isLoading.value = true;

    bool success = false;
    String message = '';

    switch (newStatus) {
      case 'menunggu_dokter':
        // Verifikasi & kirim ke dokter
        success = await _antrianService.verifikasiAntrian(
          antrianId: antrianId,
          perawatId: perawatId,
          perawatName: perawatName,
          catatan: 'Diverifikasi dan dikirim ke dokter',
        );
        message = success
            ? 'Antrian ${antrian['queueNumber']} berhasil dikirim ke dokter'
            : 'Gagal mengirim antrian ke dokter';
        break;

      case 'dibatalkan':
        // Batalkan antrian
        success = await _antrianService.batalkanAntrian(
          antrianId,
          'Dibatalkan oleh perawat',
        );
        message = success
            ? 'Antrian ${antrian['queueNumber']} berhasil dibatalkan'
            : 'Gagal membatalkan antrian';
        break;

      default:
        SnackbarHelper.showError('Status tidak valid');
        isLoading.value = false;
        return;
    }

    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess(message);
      refreshData();
    } else {
      SnackbarHelper.showError(message);
    }
  }
}
