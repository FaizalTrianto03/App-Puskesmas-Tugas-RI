import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../utils/snackbar_helper.dart';
import '../../detail_pemeriksaan/views/detail_pemeriksaan_view.dart';

/// Controller untuk halaman Referensi Antrean Selesai
/// Menampilkan SEMUA antrean yang sudah selesai dari semua perawat sebagai bahan referensi
class ReferensiSelesaiController extends GetxController {
  // TextEditingController untuk SearchBar
  late final TextEditingController searchController;
  
  // Observable variables
  final riwayatList = <Map<String, dynamic>>[].obs;
  final filteredRiwayatList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedPeriod = 'bulan_ini'.obs;
  final selectedPoli = 'Semua'.obs;
  final poliList = <String>['Semua'].obs;

  // Statistik
  final totalSelesai = 0.obs;
  final selesaiBulanIni = 0.obs;
  final selesaiMingguIni = 0.obs;
  final selesaiHariIni = 0.obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadPoliList();
    _loadAllSelesai();
    
    // Listen to search and filter changes
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedPeriod, (_) => _applyFilters());
    ever(selectedPoli, (_) => _applyFilters());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load daftar poli dari Firestore
  Future<void> loadPoliList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('poli')
          .orderBy('namaPoli')
          .get();
      
      final poliNames = snapshot.docs
          .map((doc) => doc.data()['namaPoli'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      
      poliList.value = ['Semua', ...poliNames];
    } catch (e) {
      poliList.value = ['Semua'];
    }
  }

  /// Load SEMUA antrean yang sudah selesai (dari semua perawat)
  Future<void> _loadAllSelesai() async {
    try {
      isLoading.value = true;

      // Query tanpa orderBy untuk menghindari kebutuhan index
      final querySnapshot = await FirebaseFirestore.instance
          .collection('antrian')
          .where('status', isEqualTo: 'selesai')
          .get();

      riwayatList.clear();
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // Konversi Map dengan benar untuk menghindari masalah casting LinkedHashMap
        final perawatData = data['perawatData'] != null 
            ? Map<String, dynamic>.from(data['perawatData'] as Map) 
            : <String, dynamic>{};
        final dokterData = data['dokterData'] != null 
            ? Map<String, dynamic>.from(data['dokterData'] as Map) 
            : <String, dynamic>{};
        final apotekerData = data['apotekerData'] != null 
            ? Map<String, dynamic>.from(data['apotekerData'] as Map) 
            : <String, dynamic>{};
        
        final verifiedAt = perawatData['verifiedAt'];
        
        riwayatList.add(_mapAntrianData(doc.id, data, perawatData, dokterData, apotekerData, verifiedAt));
      }
      
      // Sort manual di memory (terbaru dulu)
      riwayatList.sort((a, b) {
        final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
        final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      _calculateStatistik();
      _applyFilters();
      
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data referensi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Map data antrian ke format yang dibutuhkan
  /// Mapping sama lengkap dengan riwayat_pemeriksaan + data mentah
  Map<String, dynamic> _mapAntrianData(
    String docId,
    Map<String, dynamic> data,
    Map<String, dynamic> perawatData,
    Map<String, dynamic> dokterData,
    Map<String, dynamic> apotekerData,
    dynamic verifiedAt,
  ) {
    final createdAt = data['createdAt'];
    final tanggal = verifiedAt != null 
        ? (verifiedAt as Timestamp).toDate() 
        : createdAt != null 
            ? (createdAt as Timestamp).toDate()
            : DateTime.now();

    // Gabungkan semua data mentah + mapped data
    return {
      // Data mentah dari Firestore (agar detail view bisa akses semua)
      ...data,
      // Override/tambahan dengan mapped fields
      'id': docId,
      'pasien_id': data['pasienId'] ?? '',
      'pasienId': data['pasienId'] ?? '',
      'namaLengkap': data['namaLengkap'] ?? 'Tidak Diketahui',
      'nama_pasien': data['namaLengkap'] ?? 'Tidak Diketahui',
      'noRekamMedis': data['noRekamMedis'] ?? '-',
      'no_rm': data['noRekamMedis'] ?? '-',
      'jenisLayanan': data['jenisLayanan'] ?? '-',
      'tanggal': tanggal,
      'tanggal_pemeriksaan': tanggal,
      'keluhan': data['keluhan'] ?? '-',
      'queueNumber': data['queueNumber'] ?? '-',
      'status': data['status'] ?? 'selesai',
      // Tanda Vital
      'tekananDarahSistolik': perawatData['tekananDarahSistolik'] ?? 0,
      'tekanan_darah_sistolik': perawatData['tekananDarahSistolik'] ?? 0,
      'tekananDarahDiastolik': perawatData['tekananDarahDiastolik'] ?? 0,
      'tekanan_darah_diastolik': perawatData['tekananDarahDiastolik'] ?? 0,
      'nadi': perawatData['nadi'] ?? 0,
      'suhu': perawatData['suhu'] ?? 0.0,
      'suhu_tubuh': perawatData['suhu'] ?? 0.0,
      'pernapasan': perawatData['pernapasan'] ?? 0,
      // Antropometri
      'beratBadan': perawatData['beratBadan'] ?? 0.0,
      'berat_badan': perawatData['beratBadan'] ?? 0.0,
      'tinggiBadan': perawatData['tinggiBadan'] ?? 0.0,
      'tinggi_badan': perawatData['tinggiBadan'] ?? 0.0,
      'imt': perawatData['imt'] ?? 0.0,
      // Keluhan & Anamnesis
      'keluhanUtama': perawatData['keluhanUtama'] ?? '-',
      'keluhan_utama': perawatData['keluhanUtama'] ?? '-',
      'riwayatPenyakit': perawatData['riwayatPenyakit'] ?? '-',
      'riwayat_penyakit': perawatData['riwayatPenyakit'] ?? '-',
      'alergi': perawatData['alergi'] ?? '-',
      // Perawat info
      'perawatNama': perawatData['perawatName'] ?? perawatData['perawatNama'] ?? '-',
      'perawat_nama': perawatData['perawatName'] ?? perawatData['perawatNama'] ?? '-',
      'perawatId': perawatData['perawatId'] ?? '-',
      // Dokter & Diagnosa
      'diagnosa': dokterData['diagnosis'] ?? dokterData['diagnosa'] ?? data['diagnosis'] ?? '-',
      'diagnosis': dokterData['diagnosis'] ?? dokterData['diagnosa'] ?? data['diagnosis'] ?? '-',
      'tindakan': dokterData['tindakan'] ?? data['tindakan'] ?? '-',
      'dokterNama': dokterData['dokterNama'] ?? data['dokterNama'] ?? '-',
      'dokterId': dokterData['dokterId'] ?? data['dokterId'] ?? '-',
      'catatanDokter': dokterData['catatanDokter'] ?? '-',
      // Resep Obat
      'resepObat': data['resepObat'] ?? [],
      // Apoteker
      'apotekerNama': apotekerData['apotekerNama'] ?? '-',
      'apotekerId': apotekerData['apotekerId'] ?? '-',
      // Nested data untuk kompatibilitas
      'perawatData': perawatData,
      'dokterData': dokterData,
      'apotekerData': apotekerData,
      // Pembayaran
      'pembayaranData': data['pembayaranData'] ?? {},
    };
  }

  /// Hitung statistik
  void _calculateStatistik() {
    totalSelesai.value = riwayatList.length;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    // Senin minggu ini
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);

    selesaiHariIni.value = _countByPeriod(startOfToday);
    selesaiMingguIni.value = _countByPeriod(startOfWeek);
    selesaiBulanIni.value = _countByPeriod(startOfMonth);
  }

  /// Count by period
  int _countByPeriod(DateTime startDate) {
    return riwayatList.where((item) {
      final tanggal = item['tanggal'] as DateTime;
      final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
      // tanggal >= startDate
      return !tanggalDate.isBefore(startDate);
    }).length;
  }

  /// Apply search and filter
  void _applyFilters() {
    var filtered = riwayatList.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      filtered = _applySearchFilter(filtered);
    }

    // Apply period filter
    filtered = _applyPeriodFilter(filtered);

    // Apply poli filter
    if (selectedPoli.value != 'Semua') {
      filtered = _applyPoliFilter(filtered);
    }
    
    // Sort by tanggal descending (terbaru dulu)
    filtered.sort((a, b) {
      final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
      final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    
    filteredRiwayatList.value = filtered;
  }

  /// Apply search filter
  List<Map<String, dynamic>> _applySearchFilter(List<Map<String, dynamic>> list) {
    final query = searchQuery.value.toLowerCase();
    return list.where((item) {
      return item['namaLengkap'].toString().toLowerCase().contains(query) ||
             item['noRekamMedis'].toString().toLowerCase().contains(query) ||
             item['queueNumber'].toString().toLowerCase().contains(query) ||
             item['keluhanUtama'].toString().toLowerCase().contains(query) ||
             item['diagnosa'].toString().toLowerCase().contains(query) ||
             item['perawatNama'].toString().toLowerCase().contains(query) ||
             item['dokterNama'].toString().toLowerCase().contains(query);
    }).toList();
  }

  /// Apply period filter
  List<Map<String, dynamic>> _applyPeriodFilter(List<Map<String, dynamic>> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (selectedPeriod.value) {
      case 'hari_ini':
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          // tanggal >= today
          return !tanggalDate.isBefore(today);
        }).toList();
      
      case 'minggu_ini':
        // Senin minggu ini (weekday: 1=Senin, 7=Minggu)
        final daysToSubtract = now.weekday - 1; // Senin=0, Selasa=1, dst
        final mondayThisWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          // tanggal >= mondayThisWeek
          return !tanggalDate.isBefore(mondayThisWeek);
        }).toList();
      
      case 'bulan_ini':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          // tanggal >= startOfMonth
          return !tanggalDate.isBefore(startOfMonth);
        }).toList();
      
      case 'tahun_ini':
        final startOfYear = DateTime(now.year, 1, 1);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          // tanggal >= startOfYear
          return !tanggalDate.isBefore(startOfYear);
        }).toList();
      
      default:
        return list;
    }
  }

  /// Apply poli filter
  List<Map<String, dynamic>> _applyPoliFilter(List<Map<String, dynamic>> list) {
    return list.where((item) => item['jenisLayanan'].toString() == selectedPoli.value).toList();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedPeriod.value = 'bulan_ini';
    selectedPoli.value = 'Semua';
  }

  /// Refresh data
  Future<void> refreshData() async {
    await _loadAllSelesai();
  }

  /// Format tanggal
  String formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(tanggal);
  }

  /// Format waktu
  String formatWaktu(DateTime tanggal) {
    return DateFormat('HH:mm', 'id_ID').format(tanggal);
  }
  
  /// Navigate ke detail pemeriksaan
  /// Fetch data lengkap dari Firestore untuk memastikan detail view mendapat semua data
  Future<void> navigateToDetail(Map<String, dynamic> data) async {
    try {
      final antrianId = data['id'] as String;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('antrian')
          .doc(antrianId)
          .get();
      
      if (docSnapshot.exists) {
        final fullData = docSnapshot.data()!;
        fullData['id'] = docSnapshot.id;
        Get.to(() => const DetailPemeriksaanView(), arguments: fullData);
      } else {
        SnackbarHelper.showError('Data antrian tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data: $e');
    }
  }
}
