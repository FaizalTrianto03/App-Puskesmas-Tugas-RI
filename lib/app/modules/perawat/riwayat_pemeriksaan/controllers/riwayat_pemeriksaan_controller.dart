import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiwayatPemeriksaanController extends GetxController {
  // Observable variables
  final riwayatList = <Map<String, dynamic>>[].obs;
  final filteredRiwayatList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'semua'.obs; // semua, minggu_ini, bulan_ini
  final selectedPasienId = ''.obs;
  final selectedPasienNama = ''.obs;

  // Statistik
  final totalPemeriksaan = 0.obs;
  final pemeriksaanBulanIni = 0.obs;
  final pemeriksaanMingguIni = 0.obs;

  // Chart data untuk vital signs trend
  final chartDataTekananDarah = <Map<String, dynamic>>[].obs;
  final chartDataSuhuTubuh = <Map<String, dynamic>>[].obs;
  final chartDataBeratBadan = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRiwayatPemeriksaan();
    
    // Listen to search and filter changes
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => _applyFilters());
  }

  /// Load semua riwayat pemeriksaan
  Future<void> _loadRiwayatPemeriksaan() async {
    try {
      isLoading.value = true;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('pemeriksaan')
          .orderBy('tanggal_pemeriksaan', descending: true)
          .get();

      riwayatList.clear();
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Ambil data pasien
        String namaPasien = 'Pasien Tidak Diketahui';
        String noRM = '-';
        
        if (data['pasien_id'] != null) {
          final pasienDoc = await FirebaseFirestore.instance
              .collection('pasien')
              .doc(data['pasien_id'])
              .get();
          
          if (pasienDoc.exists) {
            final pasienData = pasienDoc.data()!;
            namaPasien = pasienData['nama'] ?? 'Pasien Tidak Diketahui';
            noRM = pasienData['no_rm'] ?? '-';
          }
        }

        riwayatList.add({
          'id': doc.id,
          'pasien_id': data['pasien_id'] ?? '',
          'nama_pasien': namaPasien,
          'no_rm': noRM,
          'tanggal_pemeriksaan': (data['tanggal_pemeriksaan'] as Timestamp).toDate(),
          'keluhan': data['keluhan'] ?? '-',
          'diagnosa': data['diagnosa'] ?? '-',
          'tindakan': data['tindakan'] ?? '-',
          'tekanan_darah_sistolik': data['tekanan_darah_sistolik'] ?? 0,
          'tekanan_darah_diastolik': data['tekanan_darah_diastolik'] ?? 0,
          'suhu_tubuh': data['suhu_tubuh'] ?? 0.0,
          'nadi': data['nadi'] ?? 0,
          'pernapasan': data['pernapasan'] ?? 0,
          'tinggi_badan': data['tinggi_badan'] ?? 0.0,
          'berat_badan': data['berat_badan'] ?? 0.0,
          'imt': data['imt'] ?? 0.0,
          'perawat_id': data['perawat_id'] ?? '',
          'perawat_nama': data['perawat_nama'] ?? '-',
          'status': data['status'] ?? 'selesai',
        });
      }

      _calculateStatistik();
      _applyFilters();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat pemeriksaan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Hitung statistik pemeriksaan
  void _calculateStatistik() {
    totalPemeriksaan.value = riwayatList.length;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    pemeriksaanBulanIni.value = riwayatList.where((item) {
      final tanggal = item['tanggal_pemeriksaan'] as DateTime;
      return tanggal.isAfter(startOfMonth);
    }).length;

    pemeriksaanMingguIni.value = riwayatList.where((item) {
      final tanggal = item['tanggal_pemeriksaan'] as DateTime;
      return tanggal.isAfter(startOfWeek);
    }).length;
  }

  /// Apply search and filter
  void _applyFilters() {
    var filtered = riwayatList.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        return item['nama_pasien'].toString().toLowerCase().contains(query) ||
               item['no_rm'].toString().toLowerCase().contains(query) ||
               item['keluhan'].toString().toLowerCase().contains(query) ||
               item['diagnosa'].toString().toLowerCase().contains(query);
      }).toList();
    }

    // Apply date filter
    final now = DateTime.now();
    if (selectedFilter.value == 'minggu_ini') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      filtered = filtered.where((item) {
        final tanggal = item['tanggal_pemeriksaan'] as DateTime;
        return tanggal.isAfter(startOfWeek);
      }).toList();
    } else if (selectedFilter.value == 'bulan_ini') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      filtered = filtered.where((item) {
        final tanggal = item['tanggal_pemeriksaan'] as DateTime;
        return tanggal.isAfter(startOfMonth);
      }).toList();
    }

    filteredRiwayatList.value = filtered;
  }

  /// Load riwayat untuk pasien tertentu
  Future<void> loadRiwayatByPasien(String pasienId, String namaPasien) async {
    try {
      isLoading.value = true;
      selectedPasienId.value = pasienId;
      selectedPasienNama.value = namaPasien;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('pemeriksaan')
          .where('pasien_id', isEqualTo: pasienId)
          .orderBy('tanggal_pemeriksaan', descending: true)
          .get();

      riwayatList.clear();
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        riwayatList.add({
          'id': doc.id,
          'pasien_id': data['pasien_id'] ?? '',
          'nama_pasien': namaPasien,
          'no_rm': data['no_rm'] ?? '-',
          'tanggal_pemeriksaan': (data['tanggal_pemeriksaan'] as Timestamp).toDate(),
          'keluhan': data['keluhan'] ?? '-',
          'diagnosa': data['diagnosa'] ?? '-',
          'tindakan': data['tindakan'] ?? '-',
          'tekanan_darah_sistolik': data['tekanan_darah_sistolik'] ?? 0,
          'tekanan_darah_diastolik': data['tekanan_darah_diastolik'] ?? 0,
          'suhu_tubuh': data['suhu_tubuh'] ?? 0.0,
          'nadi': data['nadi'] ?? 0,
          'pernapasan': data['pernapasan'] ?? 0,
          'tinggi_badan': data['tinggi_badan'] ?? 0.0,
          'berat_badan': data['berat_badan'] ?? 0.0,
          'imt': data['imt'] ?? 0.0,
          'perawat_id': data['perawat_id'] ?? '',
          'perawat_nama': data['perawat_nama'] ?? '-',
          'status': data['status'] ?? 'selesai',
        });
      }

      _generateChartData();
      _applyFilters();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat pasien: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate data untuk chart vital signs
  void _generateChartData() {
    chartDataTekananDarah.clear();
    chartDataSuhuTubuh.clear();
    chartDataBeratBadan.clear();

    // Ambil max 10 data terbaru untuk chart
    final chartData = riwayatList.take(10).toList().reversed.toList();

    for (var item in chartData) {
      final tanggal = item['tanggal_pemeriksaan'] as DateTime;
      final tanggalStr = '${tanggal.day}/${tanggal.month}';

      // Data tekanan darah
      chartDataTekananDarah.add({
        'tanggal': tanggalStr,
        'sistolik': item['tekanan_darah_sistolik'],
        'diastolik': item['tekanan_darah_diastolik'],
      });

      // Data suhu tubuh
      chartDataSuhuTubuh.add({
        'tanggal': tanggalStr,
        'suhu': item['suhu_tubuh'],
      });

      // Data berat badan
      chartDataBeratBadan.add({
        'tanggal': tanggalStr,
        'berat': item['berat_badan'],
      });
    }
  }

  /// Navigate to detail riwayat
  void navigateToDetail(Map<String, dynamic> riwayat) {
    Get.toNamed(
      '/perawat/riwayat-pemeriksaan/detail',
      arguments: riwayat,
    );
  }

  /// Refresh data
  Future<void> refreshData() async {
    await _loadRiwayatPemeriksaan();
  }

  /// Clear filters
  void clearFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'semua';
    selectedPasienId.value = '';
    selectedPasienNama.value = '';
    _applyFilters();
  }

  /// Export summary (simulasi)
  Future<void> exportSummary() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        barrierDismissible: false,
      );

      // Simulasi proses export
      await Future.delayed(const Duration(seconds: 2));

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Berhasil',
        'Riwayat pemeriksaan berhasil di-export ke PDF',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal export: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'dalam_pemeriksaan':
        return Colors.orange;
      case 'menunggu':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Get status text
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'dalam_pemeriksaan':
        return 'Dalam Pemeriksaan';
      case 'menunggu':
        return 'Menunggu';
      default:
        return 'Unknown';
    }
  }

  /// Format tanggal
  String formatTanggal(DateTime tanggal) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }

  /// Format waktu
  String formatWaktu(DateTime tanggal) {
    final hour = tanggal.hour.toString().padLeft(2, '0');
    final minute = tanggal.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  /// Get kategori IMT
  String getKategoriIMT(double imt) {
    if (imt < 18.5) return 'Kurus';
    if (imt < 25.0) return 'Normal';
    if (imt < 30.0) return 'Gemuk';
    return 'Obesitas';
  }

  /// Get color kategori IMT
  Color getColorKategoriIMT(double imt) {
    if (imt < 18.5) return Colors.orange;
    if (imt < 25.0) return Colors.green;
    if (imt < 30.0) return Colors.orange;
    return Colors.red;
  }

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}
