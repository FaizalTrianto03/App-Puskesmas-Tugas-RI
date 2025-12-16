import 'package:get/get.dart';
import '../../../../data/services/resep_obat/resep_obat_service.dart';
import '../../../../data/services/auth/session_service.dart';

class ApotekerDashboardController extends GetxController {
  // Services
  final ResepObatService _resepObatService = ResepObatService();
  final SessionService _sessionService = Get.find<SessionService>();

  // Observable states
  final userName = ''.obs;
  final userRole = ''.obs;
  final isLoading = false.obs;

  // Statistik observables
  final totalResep = 0.obs;
  final resepMenunggu = 0.obs;
  final resepDiproses = 0.obs;
  final resepSelesai = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadStatistik();
  }

  // Load user data from session
  void loadUserData() {
    final namaLengkap = _sessionService.getNamaLengkap();
    final role = _sessionService.getRole();

    userName.value = namaLengkap ?? 'Apoteker';
    userRole.value = role ?? 'apoteker';
  }

  // Load statistik resep
  Future<void> loadStatistik() async {
    isLoading.value = true;

    try {
      await _resepObatService.initDummyData();
      final stats = _resepObatService.getStatistik();

      totalResep.value = stats['total'] ?? 0;
      resepMenunggu.value = stats['menunggu'] ?? 0;
      resepDiproses.value = stats['diproses'] ?? 0;
      resepSelesai.value = stats['selesai'] ?? 0;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat statistik',
        snackPosition: SnackPosition.TOP,
      );
    }

    isLoading.value = false;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadStatistik();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
