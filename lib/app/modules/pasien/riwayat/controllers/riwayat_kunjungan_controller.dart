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
  final availableBulan = <String>['Semua'].obs;

  @override
  void onInit() {
    super.onInit();
    loadAvailableBulan();
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
    await loadAvailableBulan();
    await loadRiwayat();
  }

  Future<void> loadAvailableBulan() async {
    try {
      final riwayatData = await _riwayatService.getRiwayatKunjungan();
      
      // Extract unique months from riwayat data
      final bulanSet = <String>{'Semua'};
      
      for (var riwayat in riwayatData) {
        final monthName = _getMonthName(riwayat.tanggalKunjungan.month);
        final year = riwayat.tanggalKunjungan.year;
        final bulanString = '$monthName $year';
        bulanSet.add(bulanString);
      }
      
      // Sort bulan (terbaru dulu)
      final sortedBulan = bulanSet.toList()..sort((a, b) {
        if (a == 'Semua') return -1;
        if (b == 'Semua') return 1;
        
        final aParts = a.split(' ');
        final bParts = b.split(' ');
        
        final aMonth = _getMonthNumber(aParts[0]);
        final bMonth = _getMonthNumber(bParts[0]);
        final aYear = int.parse(aParts[1]);
        final bYear = int.parse(bParts[1]);
        
        // Sort by year desc, then month desc
        if (aYear != bYear) return bYear.compareTo(aYear);
        return bMonth.compareTo(aMonth);
      });
      
      availableBulan.value = sortedBulan;
      
      // Reset selectedBulan jika tidak tersedia
      if (!availableBulan.contains(selectedBulan.value)) {
        selectedBulan.value = 'Semua';
      }
      
    } catch (e) {
      print('Error loading available bulan: $e');
      availableBulan.value = ['Semua'];
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }
}
