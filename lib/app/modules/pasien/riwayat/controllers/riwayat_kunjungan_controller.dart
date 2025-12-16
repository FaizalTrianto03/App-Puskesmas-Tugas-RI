import 'package:get/get.dart';

import '../../../../data/models/riwayat_kunjungan_model.dart';
import '../../../../data/services/firestore/riwayat_firestore_service.dart';

class RiwayatKunjunganController extends GetxController {
  final RiwayatFirestoreService _riwayatService = RiwayatFirestoreService();
  
  final selectedBulan = 'Semua'.obs;
  final selectedPoli = 'Semua'.obs;
  final riwayatList = <RiwayatKunjunganModel>[].obs;
  final isLoading = false.obs;
  final totalKunjungan = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRiwayat();
  }

  void setSelectedBulan(String bulan) {
    selectedBulan.value = bulan;
    loadRiwayat();
  }
  
  void setSelectedPoli(String poli) {
    selectedPoli.value = poli;
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    try {
      isLoading.value = true;
      
      List<RiwayatKunjunganModel> data;
      
      if (selectedBulan.value == 'Semua' && selectedPoli.value == 'Semua') {
        // Load all riwayat
        data = await _riwayatService.getRiwayatKunjungan();
      } else {
        // Parse month/year from selectedBulan
        int? month;
        int? year;
        
        if (selectedBulan.value != 'Semua') {
          final parts = selectedBulan.value.split(' ');
          if (parts.length == 2) {
            month = _getMonthNumber(parts[0]);
            year = int.tryParse(parts[1]);
          }
        }
        
        // Load filtered riwayat
        data = await _riwayatService.getRiwayatFiltered(
          month: month,
          year: year,
          poli: selectedPoli.value,
        );
      }
      
      riwayatList.value = data;
      totalKunjungan.value = data.length;
      
    } catch (e) {
      print('Error loading riwayat: $e');
      riwayatList.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
      'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
      'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
    };
    return months[monthName] ?? 1;
  }

  Future<void> refreshRiwayat() async {
    await loadRiwayat();
  }
}
