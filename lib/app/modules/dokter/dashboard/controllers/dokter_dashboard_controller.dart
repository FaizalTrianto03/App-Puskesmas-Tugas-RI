import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../data/services/pemeriksaan/pemeriksaan_service.dart';

class DokterDashboardController extends GetxController {
  final PemeriksaanService _pemeriksaanService = PemeriksaanService();

  // Observable untuk data user
  final userName = ''.obs;
  final userRole = ''.obs;

  // Observable untuk daftar pasien
  final pasienList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  
  // Observable untuk tab
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    // Inisialisasi dummy data dari service
    _pemeriksaanService.initializeDummyData();
    loadPasienList();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Pasien saat ini (1 pasien sedang diperiksa + yang menunggu)
  List<Map<String, dynamic>> get pasienSaatIni {
    return pasienList.where((pasien) {
      final status = getStatusPasien(pasien['id']);
      return status == 'Sedang Diperiksa' || status == 'Menunggu Pemeriksaan';
    }).toList();
  }

  // Pasien yang sudah selesai
  List<Map<String, dynamic>> get pasienSelesai {
    return pasienList.where((pasien) {
      final status = getStatusPasien(pasien['id']);
      return status == 'Selesai Pemeriksaan';
    }).toList();
  }

  void loadUserData() {
    final userData = AuthHelper.currentUserData;
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
    }
  }

  void loadPasienList() {
    isLoading.value = true;
    
    // Load data pasien dari service
    pasienList.value = _pemeriksaanService.getAllPasien();

    isLoading.value = false;
  }

  String getStatusPasien(String pasienId) {
    // Cek apakah pasien ini sedang diperiksa
    final pasien = pasienList.firstWhere(
      (p) => p['id'] == pasienId,
      orElse: () => {},
    );
    
    if (pasien['sedangDiperiksa'] == true) {
      return 'Sedang Diperiksa';
    }
    
    // Cek apakah sudah ada hasil pemeriksaan
    final pemeriksaan = _pemeriksaanService.getPemeriksaanByPasienId(pasienId);
    return pemeriksaan != null ? 'Selesai Pemeriksaan' : 'Menunggu Pemeriksaan';
  }

  int getTotalPasien() {
    return pasienList.length;
  }

  int getPasienSelesai() {
    int count = 0;
    for (var pasien in pasienList) {
      if (getStatusPasien(pasien['id']) == 'Selesai Pemeriksaan') {
        count++;
      }
    }
    return count;
  }

  int getPasienMenunggu() {
    return getTotalPasien() - getPasienSelesai();
  }

  void refreshData() {
    loadPasienList();
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
}
