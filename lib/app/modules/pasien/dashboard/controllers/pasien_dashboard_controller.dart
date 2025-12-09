import 'package:get/get.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../data/services/antrian/antrian_service.dart';
import '../../../../routes/app_pages.dart';

class PasienDashboardController extends GetxController {
  late final SessionService _sessionService;
  late final AntreanService _antreanService;
  
  // Observable states
  final userName = ''.obs;
  final userEmail = ''.obs;
  final noRekamMedis = ''.obs;
  final hasActiveQueue = false.obs;
  final queueNumber = ''.obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    print('PasienDashboardController: onInit()');
    
    // Pastikan services tersedia
    try {
      _sessionService = Get.find<SessionService>();
      _antreanService = Get.find<AntreanService>();
      print('PasienDashboardController: Services found');
    } catch (e) {
      print('PasienDashboardController: Error finding services - $e');
      rethrow;
    }
    
    loadUserData();
    checkActiveQueue();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh antrian setiap kali view siap ditampilkan
    checkActiveQueue();
  }
  
  void loadUserData() {
    print('PasienDashboardController: loadUserData()');
    final isLoggedIn = _sessionService.isLoggedIn();
    print('PasienDashboardController: Is logged in = $isLoggedIn');
    
    if (isLoggedIn) {
      userName.value = _sessionService.getNamaLengkap() ?? 'Pasien';
      userEmail.value = _sessionService.getEmail() ?? '';
      print('PasienDashboardController: Loaded user - ${userName.value}');
      
      final userId = _sessionService.getUserId();
      if (userId != null) {
        final userData = _sessionService.getUserData(userId);
        if (userData != null) {
          noRekamMedis.value = userData['noRekamMedis'] ?? '-';
        }
      }
    }
  }
  
  void checkActiveQueue() {
    final userId = _sessionService.getUserId();
    if (userId == null) {
      hasActiveQueue.value = false;
      queueNumber.value = '';
      return;
    }
    
    // Cek antrian aktif dari AntreanService
    final activeAntrian = _antreanService.getActiveAntrianByPasienId(userId);
    
    if (activeAntrian != null) {
      hasActiveQueue.value = true;
      queueNumber.value = activeAntrian['queueNumber'] ?? '';
    } else {
      hasActiveQueue.value = false;
      queueNumber.value = '';
    }
  }
  
  // Navigation functions
  void goToPendaftaran() {
    Get.toNamed(Routes.pasienPendaftaran);
  }
  
  void goToStatusAntrean() {
    Get.snackbar('Info', 'Fitur Status Antrian sedang dalam pengembangan');
  }
  
  void goToRiwayatKunjungan() {
    Get.toNamed(Routes.pasienRiwayat);
  }
  
  void goToLayananLainnya() {
    Get.snackbar('Info', 'Fitur Layanan Lainnya sedang dalam pengembangan');
  }
  
  void goToProfile() {
    Get.snackbar('Info', 'Fitur Profile sedang dalam pengembangan');
  }
  
  void goToSettings() {
    Get.toNamed(Routes.pasienSettings);
  }
  
  void goToNotifikasi() {
    Get.snackbar('Info', 'Fitur Notifikasi sedang dalam pengembangan');
  }
  
  Future<void> logout() async {
    isLoading.value = true;
    await _sessionService.clearSession();
    isLoading.value = false;
    Get.offAllNamed(Routes.splash);
  }
}
