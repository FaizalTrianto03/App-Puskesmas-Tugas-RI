import 'package:get/get.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';

class LaporanKinerjaController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final SessionService _sessionService = Get.find<SessionService>();

  final isLoading = false.obs;
  final selectedPeriod = 'Hari Ini'.obs;
  
  // Statistik
  final totalPasien = 0.obs;
  final totalVerifikasi = 0.obs;
  final totalDibatalkan = 0.obs;
  final totalRekamMedis = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadLaporanKinerja();
  }

  Future<void> loadLaporanKinerja() async {
    isLoading.value = true;
    
    try {
      final perawatId = _sessionService.getUserId();
      if (perawatId == null) {
        Get.snackbar('Error', 'Session tidak ditemukan');
        return;
      }

      // Load data antrian hari ini
      final antrianData = await _antrianService.getAllAntrianToday();
      
      // Hitung statistik berdasarkan perawat yang login
      totalPasien.value = antrianData.length;
      
      // Hitung yang diverifikasi oleh perawat ini
      totalVerifikasi.value = antrianData.where((antrian) {
        return antrian['verifiedBy'] == perawatId && 
               (antrian['status'] == 'menunggu_dokter' || 
                antrian['status'] == 'sedang_dilayani' || 
                antrian['status'] == 'selesai');
      }).length;
      
      // Hitung yang dibatalkan
      totalDibatalkan.value = antrianData.where((antrian) {
        return antrian['status'] == 'dibatalkan';
      }).length;
      
      // TODO: Hitung total rekam medis yang diinput
      // Perlu tambahkan field perawatId di collection rekam_medis
      totalRekamMedis.value = 0;
      
    } catch (e) {
      print('Error loading laporan kinerja: $e');
      Get.snackbar('Error', 'Gagal memuat laporan kinerja');
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // TODO: Implement filter berdasarkan periode
    loadLaporanKinerja();
  }

  String get userName => _sessionService.getNamaLengkap() ?? '';
}
