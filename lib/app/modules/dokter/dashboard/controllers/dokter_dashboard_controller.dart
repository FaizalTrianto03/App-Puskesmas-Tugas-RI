import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../data/services/pemeriksaan/pemeriksaan_service.dart';
import '../../../../data/services/antrian/antrian_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../pemeriksaan/views/form_pemeriksaan_view.dart';

class DokterDashboardController extends GetxController {
  final PemeriksaanService _pemeriksaanService = PemeriksaanService();
  final AntreanService _antreanService = Get.find<AntreanService>();
  final SessionService _sessionService = Get.find<SessionService>();

  final userName = ''.obs;
  final userRole = ''.obs;

  final antrianList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _pemeriksaanService.initializeDummyData();
    loadAntrianTerverifikasi();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data setiap kali view siap ditampilkan
    loadAntrianTerverifikasi();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void loadUserData() {
    final userData = AuthHelper.currentUserData;
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
    }
  }

  void loadAntrianTerverifikasi() {
    isLoading.value = true;
    
    antrianList.value = _antreanService.getAntrianByStatus('menunggu_dokter')
      ..sort((a, b) {
        final dateA = DateTime.parse(a['verifiedAt']);
        final dateB = DateTime.parse(b['verifiedAt']);
        return dateA.compareTo(dateB);
      });

    isLoading.value = false;
  }

  List<Map<String, dynamic>> get antrianMenunggu {
    return antrianList
        .where((a) => a['status'] == 'menunggu_dokter')
        .toList();
  }

  List<Map<String, dynamic>> get antrianSedangDilayani {
    final dokterId = _sessionService.getUserId();
    return _antreanService.getAllAntrian()
        .where((a) => 
            a['status'] == 'sedang_dilayani' && 
            a['dokterId'] == dokterId)
        .toList();
  }

  List<Map<String, dynamic>> get antrianSelesai {
    final dokterId = _sessionService.getUserId();
    return _antreanService.getAllAntrian()
        .where((a) => 
            a['status'] == 'selesai' && 
            a['dokterId'] == dokterId)
        .toList();
  }

  Future<void> mulaiPelayanan(Map<String, dynamic> antrian) async {
    final dokterId = _sessionService.getUserId();
    final dokterName = _sessionService.getNamaLengkap();

    if (dokterId == null || dokterName == null) {
      SnackbarHelper.showError('Sesi tidak valid');
      return;
    }

    if (antrianSedangDilayani.isNotEmpty) {
      SnackbarHelper.showWarning('Selesaikan pasien yang sedang dilayani terlebih dahulu');
      return;
    }

    isLoading.value = true;

    final success = await _antreanService.assignDokter(
      antrianId: antrian['id'],
      dokterId: dokterId,
      dokterName: dokterName,
    );

    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess('Pasien ${antrian['namaLengkap']} mulai dilayani');
      loadAntrianTerverifikasi();
    } else {
      SnackbarHelper.showError('Gagal memulai pelayanan');
    }
  }

  Future<void> selesaiPelayanan({
    required String antrianId,
    required String diagnosis,
    String? tindakan,
    String? resep,
  }) async {
    isLoading.value = true;

    final success = await _antreanService.selesaiPelayanan(
      antrianId: antrianId,
      diagnosis: diagnosis,
      tindakan: tindakan,
      resep: resep,
    );

    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess('Pelayanan selesai');
      loadAntrianTerverifikasi();
    } else {
      SnackbarHelper.showError('Gagal menyelesaikan pelayanan');
    }
  }

  int getTotalAntrianHariIni() {
    return antrianList.length;
  }

  int getAntrianMenungguCount() {
    return antrianMenunggu.length;
  }

  int getAntrianSelesaiCount() {
    return antrianSelesai.length;
  }

  void refreshData() {
    loadAntrianTerverifikasi();
  }

  void navigateToFormPemeriksaan(Map<String, dynamic> antrian) {
    Get.to(() => FormPemeriksaanView(pasienData: antrian));
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'dokter':
        return 'Dokter';
      case 'admin':
        return 'Admin';
      case 'perawat':
        return 'Perawat';
      case 'apoteker':
        return 'Apoteker';
      default:
        return 'Pasien';
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    await _sessionService.clearSession();
    isLoading.value = false;
    Get.offAllNamed(Routes.splash);
  }
}
