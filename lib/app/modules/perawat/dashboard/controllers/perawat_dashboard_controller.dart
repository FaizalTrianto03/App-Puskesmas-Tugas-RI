import 'package:get/get.dart';
import '../../../../data/services/antrian/antrian_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../rekam_medis/views/form_rekam_medis_view.dart';

class PerawatDashboardController extends GetxController {
  final AntreanService _antreanService = Get.find<AntreanService>();
  final SessionService _sessionService = Get.find<SessionService>();

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
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data setiap kali view siap ditampilkan
    loadAntrian();
  }

  void loadUserData() {
    final userData = AuthHelper.currentUserData;
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

  void loadAntrian() {
    isLoading.value = true;
    
    antrianList.value = _antreanService.getAllAntrian()
      ..sort((a, b) {
        final dateA = DateTime.parse(a['tanggalDaftar']);
        final dateB = DateTime.parse(b['tanggalDaftar']);
        return dateA.compareTo(dateB);
      });
    
    isLoading.value = false;
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

    final success = await _antreanService.verifikasiAntrian(
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
        success = await _antreanService.verifikasiAntrian(
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
        success = await _antreanService.batalkanAntrian(
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
