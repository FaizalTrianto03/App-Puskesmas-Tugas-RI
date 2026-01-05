import 'package:get/get.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';

class RiwayatKunjunganController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  
  final selectedBulan = 'Semua'.obs;
  final selectedPoli = 'Semua'.obs;
  final antrianList = <AntrianModel>[].obs;
  final availablePoliList = <String>[].obs;
  final isLoading = false.obs;
  final totalKunjungan = 0.obs;
  final availableBulan = <String>['Semua'].obs;

  @override
  void onInit() {
    super.onInit();
    loadRiwayat();
  }

  void setSelectedBulan(String bulan) {
    selectedBulan.value = bulan;
    applyFilters();
  }
  
  void setSelectedPoli(String poli) {
    selectedPoli.value = poli;
    applyFilters();
  }

  Future<void> loadRiwayat() async {
    try {
      isLoading.value = true;
      
      // Load semua antrian pasien (termasuk yang sedang berjalan)
      final allAntrian = await _antrianService.getAllAntrianByUser();
      
      // Sort by createdAt descending (terbaru dulu)
      allAntrian.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      antrianList.value = allAntrian;
      
      // Extract available bulan
      _extractAvailableBulan(allAntrian);
      
      // Extract available poli dari data pasien
      _extractAvailablePoli(allAntrian);
      
      // Apply initial filter
      applyFilters();
      
    } catch (e) {
      antrianList.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _extractAvailablePoli(List<AntrianModel> allAntrian) {
    final poliSet = <String>{'Semua'};
    
    for (var antrian in allAntrian) {
      if (antrian.jenisLayanan.isNotEmpty) {
        poliSet.add(antrian.jenisLayanan);
      }
    }
    
    availablePoliList.value = poliSet.toList()..sort();
  }

  void _extractAvailableBulan(List<AntrianModel> allAntrian) {
    final bulanSet = <String>{'Semua'};
    
    for (var antrian in allAntrian) {
      final monthName = _getMonthName(antrian.createdAt.month);
      final year = antrian.createdAt.year;
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
  }

  void applyFilters() {
    var filtered = antrianList.toList();
    
    // Filter by bulan
    if (selectedBulan.value != 'Semua') {
      final parts = selectedBulan.value.split(' ');
      if (parts.length == 2) {
        final month = _getMonthNumber(parts[0]);
        final year = int.tryParse(parts[1]);
        
        if (month != null) {
          filtered = filtered.where((antrian) {
            return antrian.createdAt.month == month &&
                   antrian.createdAt.year == year;
          }).toList();
        }
      }
    }
    
    // Filter by poli
    if (selectedPoli.value != 'Semua') {
      filtered = filtered.where((antrian) {
        return antrian.jenisLayanan == selectedPoli.value;
      }).toList();
    }
    
    totalKunjungan.value = filtered.length;
  }

  List<AntrianModel> get filteredAntrian {
    var filtered = antrianList.toList();
    
    // Filter by bulan
    if (selectedBulan.value != 'Semua') {
      final parts = selectedBulan.value.split(' ');
      if (parts.length == 2) {
        final month = _getMonthNumber(parts[0]);
        final year = int.tryParse(parts[1]);
        
        if (month != null) {
          filtered = filtered.where((antrian) {
            return antrian.createdAt.month == month &&
                   antrian.createdAt.year == year;
          }).toList();
        }
      }
    }
    
    // Filter by poli
    if (selectedPoli.value != 'Semua') {
      filtered = filtered.where((antrian) {
        return antrian.jenisLayanan == selectedPoli.value;
      }).toList();
    }
    
    return filtered;
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

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }
}