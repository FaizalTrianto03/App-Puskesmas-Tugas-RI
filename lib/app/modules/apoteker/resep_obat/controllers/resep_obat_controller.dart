import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/resep_obat/resep_obat_service.dart';
import '../../../../data/services/auth/session_service.dart';

class ResepObatController extends GetxController {
  // Service Layer
  final ResepObatService _resepObatService = ResepObatService();
  final SessionService _sessionService = Get.find<SessionService>();

  // Observable list untuk resep yang belum diserahkan
  final resepBelumSelesai = <Map<String, dynamic>>[].obs;

  // Observable list untuk resep yang sudah diserahkan
  final resepSelesai = <Map<String, dynamic>>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Filter status
  final RxString selectedFilter = 'Menunggu'.obs;
  final List<String> filterOptions = ['Semua', 'Menunggu', 'Selesai'];

  // Get filtered resep
  List<Map<String, dynamic>> get filteredResep {
    if (selectedFilter.value == 'Menunggu') {
      return resepBelumSelesai;
    } else if (selectedFilter.value == 'Selesai') {
      return resepSelesai;
    } else {
      return [...resepBelumSelesai, ...resepSelesai];
    }
  }

  // Count resep menunggu
  int get countMenunggu => resepBelumSelesai.length;

  // Count resep selesai hari ini
  int get countSelesaiHariIni => resepSelesai.length;

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Konfirmasi penyerahan obat
  void konfirmasiPenyerahan(String resepId) async {
    isLoading.value = true;

    final success = await _resepObatService.selesaikanResep(resepId);

    if (success) {
      await loadResepData(); // Reload data from service

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Resep telah diserahkan kepada pasien',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  // Batalkan resep (jika pasien tidak jadi ambil)
  void batalkanResep(String resepId) async {
    isLoading.value = true;

    final success = await _resepObatService.batalkanResep(resepId);

    if (success) {
      await loadResepData(); // Reload data from service

      Get.back();
      Get.snackbar(
        'Dibatalkan',
        'Resep telah dibatalkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  // Load resep data from service
  Future<void> loadResepData() async {
    isLoading.value = true;

    try {
      final belumSelesai = _resepObatService.getResepBelumSelesai();
      final selesai = _resepObatService.getResepSelesai();

      // Convert statusColor from int back to Color
      resepBelumSelesai.value =
          belumSelesai.map((resep) {
            resep['statusColor'] = Color(resep['statusColor']);
            return resep;
          }).toList();

      resepSelesai.value =
          selesai.map((resep) {
            resep['statusColor'] = Color(resep['statusColor']);
            return resep;
          }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data resep',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize dummy data dan load resep
    _resepObatService.initDummyData().then((_) {
      loadResepData();
    });
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
