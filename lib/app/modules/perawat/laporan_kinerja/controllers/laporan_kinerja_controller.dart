import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';

class LaporanKinerjaController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();

  final isLoading = false.obs;
  final selectedPeriod = 'hari_ini'.obs; // semua, hari_ini, minggu_ini, bulan_ini, tahun_ini
  
  // Statistik
  final totalPasien = 0.obs;
  final totalVerifikasi = 0.obs;
  final pasienSelesai = 0.obs;
  final pasienMenunggu = 0.obs;
  final totalRekamMedis = 0.obs;
  final totalDibatalkan = 0.obs;
  final totalDilewati = 0.obs;
  
  // Detail per poli
  final pasienPerPoli = <Map<String, dynamic>>[].obs;
  
  // Statistik waktu
  final waktuTercepat = ''.obs;
  final waktuTerlama = ''.obs;
  final rataRataWaktu = ''.obs;
  
  // Getter untuk nama user
  String get userName => _sessionService.getNamaLengkap() ?? 'Perawat';
  
  // Getter untuk breakdown poli (Map<String, int>)
  Map<String, int> get poliBreakdown {
    final Map<String, int> result = {};
    for (var item in pasienPerPoli) {
      result[item['poli'] as String] = item['jumlah'] as int;
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    loadLaporanKinerja();
  }

  Future<void> loadLaporanKinerja() async {
    isLoading.value = true;
    
    try {
      final perawatId = _sessionService.getUserId();
      final perawatName = _sessionService.getNamaLengkap() ?? 'Perawat';
      
      if (perawatId == null) {
        Get.snackbar('Error', 'Session tidak ditemukan');
        return;
      }

      // Hitung range tanggal berdasarkan periode
      final now = DateTime.now();
      DateTime startDate;
      
      switch (selectedPeriod.value) {
        case 'hari_ini':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'minggu_ini':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'bulan_ini':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'tahun_ini':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      // Query antrian yang dihandle oleh perawat ini dalam periode tersebut
      QuerySnapshot antrianSnapshot;
      
      if (selectedPeriod.value == 'semua') {
        // Untuk periode 'semua', ambil semua data tanpa filter tanggal
        antrianSnapshot = await FirebaseFirestore.instance
            .collection('antrian')
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        antrianSnapshot = await FirebaseFirestore.instance
            .collection('antrian')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .orderBy('createdAt', descending: true)
            .get();
      }

      // Filter data yang dihandle oleh perawat ini
      final antrianList = antrianSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Cek dari perawatData (untuk data yang sudah diverifikasi)
        final perawatData = data['perawatData'];
        if (perawatData != null && perawatData is Map<String, dynamic>) {
          if (perawatData['perawatId'] == perawatId) {
            return true;
          }
        }
        
        // Cek dari dibatalkanOleh (untuk data yang dibatalkan oleh perawat)
        if (data['status'] == 'dibatalkan' && data['dibatalkanOleh'] == 'perawat') {
          final dibatalkanOlehId = data['dibatalkanOlehId'];
          final dibatalkanOlehNama = data['dibatalkanOlehNama'];
          
          // Match by ID atau nama (karena ID bisa kosong string di data lama)
          if (dibatalkanOlehId == perawatId || 
              (dibatalkanOlehId == '' && dibatalkanOlehNama == perawatName)) {
            return true;
          }
        }
        
        // Cek dari dilewatiOleh (untuk data yang dilewati oleh perawat)
        if (data['status'] == 'dilewati') {
          final dilewatiOlehId = data['dilewatiOlehId'];
          final dilewatiOlehNama = data['dilewatiOlehNama'];
          
          if (dilewatiOlehId == perawatId || 
              (dilewatiOlehId == '' && dilewatiOlehNama == perawatName)) {
            return true;
          }
        }
        
        return false;
      }).toList();

      // Hitung statistik
      totalPasien.value = antrianList.length;
      
      totalVerifikasi.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'];
        return status != 'menunggu' && status != 'dibatalkan';
      }).length;
      
      pasienSelesai.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'selesai';
      }).length;
      
      pasienMenunggu.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'];
        return status == 'menunggu_dokter' || 
               status == 'dilayani_dokter' ||
               status == 'menunggu_apoteker' ||
               status == 'dilayani_apoteker';
      }).length;
      
      totalRekamMedis.value = totalVerifikasi.value; // Sama dengan total verifikasi
      totalDibatalkan.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'dibatalkan';
      }).length;
      totalDilewati.value = antrianList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'dilewati';
      }).length;

      // Hitung pasien per poli
      final Map<String, int> poliCount = {};
      for (var doc in antrianList) {
        final data = doc.data() as Map<String, dynamic>;
        final poli = data['jenisLayanan'] ?? 'Tidak Diketahui';
        poliCount[poli] = (poliCount[poli] ?? 0) + 1;
      }
      
      pasienPerPoli.value = poliCount.entries.map((entry) => {
        'poli': entry.key,
        'jumlah': entry.value,
      }).toList();
      
      // Sort by jumlah descending
      pasienPerPoli.sort((a, b) => b['jumlah'].compareTo(a['jumlah']));

      // Hitung waktu pemeriksaan (dari createdAt ke verifiedAt)
      final List<Duration> durations = [];
      for (var doc in antrianList) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final perawatData = data['perawatData'];
        if (perawatData != null && perawatData['verifiedAt'] != null) {
          final verifiedAt = (perawatData['verifiedAt'] as Timestamp).toDate();
          durations.add(verifiedAt.difference(createdAt));
        }
      }

      if (durations.isNotEmpty) {
        durations.sort();
        waktuTercepat.value = _formatDuration(durations.first);
        waktuTerlama.value = _formatDuration(durations.last);
        
        final totalMinutes = durations.fold<int>(
          0, 
          (sum, duration) => sum + duration.inMinutes
        );
        final avgMinutes = totalMinutes / durations.length;
        rataRataWaktu.value = '${avgMinutes.toStringAsFixed(0)} menit';
      } else {
        waktuTercepat.value = '-';
        waktuTerlama.value = '-';
        rataRataWaktu.value = '-';
      }
      
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat laporan kinerja: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadLaporanKinerja();
  }

  Future<void> refreshData() async {
    await loadLaporanKinerja();
  }
  
  String get periodLabel {
    switch (selectedPeriod.value) {
      case 'semua':
        return 'Semua Waktu';
      case 'hari_ini':
        return 'Hari Ini';
      case 'minggu_ini':
        return 'Minggu Ini';
      case 'bulan_ini':
        return 'Bulan Ini';
      case 'tahun_ini':
        return 'Tahun Ini';
      default:
        return 'Hari Ini';
    }
  }
  
  // Hitung persentase verifikasi
  double get persentaseVerifikasi {
    if (totalPasien.value == 0) return 0;
    return (totalVerifikasi.value / totalPasien.value) * 100;
  }

  double get persentaseSelesai {
    if (totalPasien.value == 0) return 0;
    return (pasienSelesai.value / totalPasien.value) * 100;
  }
  
  // Hitung persentase dibatalkan
  double get persentaseDibatalkan {
    if (totalPasien.value == 0) return 0;
    return (totalDibatalkan.value / totalPasien.value) * 100;
  }
}
