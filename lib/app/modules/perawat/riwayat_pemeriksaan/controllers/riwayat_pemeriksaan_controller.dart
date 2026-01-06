import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../rekam_medis/views/form_rekam_medis_view.dart';
import '../../detail_pemeriksaan/views/detail_pemeriksaan_view.dart';

class RiwayatPemeriksaanController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();
  
  // Getter untuk SessionService
  SessionService get sessionService => _sessionService;
  
  // TextEditingController untuk SearchBar
  late final TextEditingController searchController;
  
  // Observable variables
  final riwayatList = <Map<String, dynamic>>[].obs;
  final filteredRiwayatList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedPeriod = 'hari_ini'.obs;
  final selectedPoli = 'Semua'.obs;
  final selectedFilter = 'semua'.obs;
  final selectedStatus = Rxn<String>();
  final poliList = <String>['Semua'].obs;

  // Statistik
  final totalPemeriksaan = 0.obs;
  final pemeriksaanBulanIni = 0.obs;
  final pemeriksaanMingguIni = 0.obs;
  final pemeriksaanHariIni = 0.obs;
  
  // For chart data
  final selectedPasienId = ''.obs;
  final chartData = <Map<String, dynamic>>[].obs;
  
  // Computed chart data for different vital signs
  List<Map<String, dynamic>> get chartDataTekananDarah => chartData;
  List<Map<String, dynamic>> get chartDataSuhuTubuh => chartData;
  List<Map<String, dynamic>> get chartDataBeratBadan => chartData;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadPoliList();
    _loadRiwayatPemeriksaan();
    
    // Listen to search and filter changes
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedPeriod, (_) {
      selectedFilter.value = selectedPeriod.value;
      _applyFilters();
    });
    ever(selectedPoli, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
    ever(selectedFilter, (_) {
      if (selectedFilter.value != selectedPeriod.value) {
        selectedPeriod.value = selectedFilter.value;
      }
    });
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

  /// Load semua riwayat pemeriksaan
  Future<void> _loadRiwayatPemeriksaan() async {
    try {
      isLoading.value = true;

      final perawatId = _sessionService.getUserId();
      if (perawatId == null) {
        SnackbarHelper.showError('Session tidak ditemukan');
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('antrian')
          .orderBy('createdAt', descending: true)
          .get();

      riwayatList.clear();
      
      final perawatNama = _sessionService.getNamaLengkap();
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Cek apakah data ini milik perawat yang login
        bool isMyData = false;
        
        // Cek dari perawatData (untuk data yang sudah diverifikasi)
        final perawatData = data['perawatData'];
        if (perawatData != null && perawatData is Map<String, dynamic>) {
          if (perawatData['perawatId'] == perawatId) {
            isMyData = true;
          }
        }
        
        // Cek dari dibatalkanOleh (untuk data yang dibatalkan oleh perawat)
        if (!isMyData && data['status'] == 'dibatalkan' && data['dibatalkanOleh'] == 'perawat') {
          final dibatalkanOlehId = data['dibatalkanOlehId'];
          final dibatalkanOlehNama = data['dibatalkanOlehNama'];
          
          // Match by ID atau nama (karena ID bisa kosong string di data lama)
          if (dibatalkanOlehId == perawatId || 
              (dibatalkanOlehId == '' && dibatalkanOlehNama == perawatNama)) {
            isMyData = true;
          }
        }
        
        // Skip jika bukan data perawat ini
        if (!isMyData) continue;
        
        final verifiedAt = perawatData != null && perawatData is Map<String, dynamic>
            ? perawatData['verifiedAt']
            : null;
        
        riwayatList.add(_mapAntrianData(doc.id, data, perawatData ?? {}, verifiedAt));
      }

      _calculateStatistik();
      _applyFilters();
      
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat riwayat pemeriksaan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Map data antrian ke format yang dibutuhkan
  Map<String, dynamic> _mapAntrianData(
    String docId,
    Map<String, dynamic> data,
    Map<String, dynamic> perawatData,
    dynamic verifiedAt,
  ) {
    final tanggal = verifiedAt != null 
        ? (verifiedAt as Timestamp).toDate() 
        : (data['createdAt'] as Timestamp).toDate();

    return {
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
      // Dokter & Diagnosa
      'diagnosa': (data['dokterData'] as Map<String, dynamic>?)?['diagnosa'] ?? '-',
      'tindakan': (data['dokterData'] as Map<String, dynamic>?)?['tindakan'] ?? '-',
      'perawat_nama': perawatData['perawatNama'] ?? '-',
      'status': data['status'] ?? '',
      'queueNumber': data['queueNumber'] ?? '-',
      // Data pembatalan
      'alasanPembatalan': data['alasanPembatalan'],
      'dibatalkanOleh': data['dibatalkanOleh'],
      'dibatalkanOlehNama': data['dibatalkanOlehNama'],
      'waktuPembatalan': data['waktuPembatalan'],
    };
  }

  /// Hitung statistik pemeriksaan
  void _calculateStatistik() {
    totalPemeriksaan.value = riwayatList.length;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    // Senin minggu ini (weekday: 1=Senin, 7=Minggu)
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);

    pemeriksaanHariIni.value = _countByPeriod(startOfToday);
    pemeriksaanMingguIni.value = _countByPeriod(startOfWeek);
    pemeriksaanBulanIni.value = _countByPeriod(startOfMonth);
  }

  /// Count pemeriksaan by period
  int _countByPeriod(DateTime startDate) {
    return riwayatList.where((item) {
      final tanggal = item['tanggal'] as DateTime;
      final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
      // tanggal >= startDate (tidak sebelum startDate)
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
    
    // Apply status filter
    if (selectedStatus.value != null) {
      filtered = _applyStatusFilter(filtered);
    }
    
    // ✅ SORT: Aktif (terlama dulu) → Dilewati → Selesai → Dibatalkan
    final aktif = filtered.where((a) {
      final status = a['status']?.toString() ?? '';
      return status != 'dibatalkan' && status != 'dilewati' && status != 'selesai';
    }).toList();
    
    final dilewati = filtered.where((a) => a['status'] == 'dilewati').toList();
    final selesai = filtered.where((a) => a['status'] == 'selesai').toList();
    final dibatalkan = filtered.where((a) => a['status'] == 'dibatalkan').toList();
    
    // Sort aktif: terlama dulu (tanggal ASC)
    aktif.sort((a, b) {
      final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
      final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
      return aTime.compareTo(bTime); // ASC - terlama dulu
    });
    
    // Sort dilewati: terlama dulu
    dilewati.sort((a, b) {
      final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
      final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
      return aTime.compareTo(bTime);
    });
    
    // Sort selesai: terbaru dulu (tanggal DESC)
    selesai.sort((a, b) {
      final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
      final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
      return bTime.compareTo(aTime); // DESC - terbaru dulu
    });
    
    // Sort dibatalkan: terbaru dulu
    dibatalkan.sort((a, b) {
      final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
      final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    
    // Gabung: aktif → dilewati → selesai → dibatalkan
    filteredRiwayatList.value = [...aktif, ...dilewati, ...selesai, ...dibatalkan];
  }

  /// Apply search filter
  List<Map<String, dynamic>> _applySearchFilter(List<Map<String, dynamic>> list) {
    final query = searchQuery.value.toLowerCase();
    return list.where((item) {
      return item['namaLengkap'].toString().toLowerCase().contains(query) ||
             item['noRekamMedis'].toString().toLowerCase().contains(query) ||
             item['queueNumber'].toString().toLowerCase().contains(query) ||
             item['keluhanUtama'].toString().toLowerCase().contains(query);
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
          return !tanggalDate.isBefore(today);
        }).toList();
      
      case 'minggu_ini':
        final daysToSubtract = now.weekday - 1;
        final mondayThisWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          return !tanggalDate.isBefore(mondayThisWeek);
        }).toList();
      
      case 'bulan_ini':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          return !tanggalDate.isBefore(startOfMonth);
        }).toList();
      
      case 'tahun_ini':
        final startOfYear = DateTime(now.year, 1, 1);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
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

  /// Apply status filter
  List<Map<String, dynamic>> _applyStatusFilter(List<Map<String, dynamic>> list) {
    return list.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      
      switch (selectedStatus.value) {
        case 'terverifikasi':
          // ✅ FIX: Include selesai dan semua status pasca verifikasi
          return status == 'terverifikasi' || 
                 status == 'menunggu_dokter' ||
                 status == 'sedang_dilayani' ||
                 status == 'dilayani_dokter' ||
                 status == 'selesai_diperiksa' ||
                 status == 'siap_ambil_obat' ||
                 status == 'menunggu_apoteker' ||
                 status == 'dilayani_apoteker' ||
                 status == 'selesai' ||
                 status == 'dipanggil' ||
                 status.contains('dilayani');
        case 'selesai':
          return status == 'selesai';
        case 'dibatalkan':
          return status == 'dibatalkan';
        default:
          return true;
      }
    }).toList();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedPeriod.value = 'semua';
    selectedPoli.value = 'Semua';
    selectedFilter.value = 'semua';
    selectedStatus.value = null;
  }

  /// Refresh data
  Future<void> refreshData() async {
    await _loadRiwayatPemeriksaan();
  }

  /// Export summary
  void exportSummary() {
    SnackbarHelper.showInfo('Fitur export akan segera tersedia');
  }

  /// Format tanggal
  String formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(tanggal);
  }
  
  /// Format waktu
  String formatWaktu(DateTime waktu) {
    return DateFormat('HH:mm', 'id_ID').format(waktu);
  }
  
  /// Format timestamp
  String formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return '-';
      }
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
  
  /// Get status text
  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'menunggu':
        return 'Menunggu';
      case 'proses':
        return 'Sedang Diproses';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
  
  /// Get status color
  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'menunggu':
        return Colors.orange;
      case 'proses':
        return Colors.blue;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get border color based on status
  Color getBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'menunggu_verifikasi':
      case 'dipanggil':
        return const Color(0xFFFFA726);
      case 'dilewati':
        return const Color(0xFFFF9800);
      case 'terverifikasi':
      case 'menunggu_dokter':
      case 'sedang_dilayani':
      case 'dilayani_dokter':
        return const Color(0xFF4CAF50);
      case 'selesai':
      case 'selesai_diperiksa':
      case 'siap_ambil_obat':
      case 'menunggu_apoteker':
      case 'dilayani_apoteker':
        return const Color(0xFF2196F3); // Biru - selesai
      case 'dibatalkan':
        return const Color(0xFFF44336);
      default:
        return Colors.grey.shade300;
    }
  }
  
  /// Get kategori IMT
  String getKategoriIMT(double imt) {
    if (imt < 18.5) {
      return 'Kurus';
    } else if (imt < 25.0) {
      return 'Normal';
    } else if (imt < 30.0) {
      return 'Gemuk';
    } else {
      return 'Obesitas';
    }
  }
  
  /// Get color kategori IMT
  Color getColorKategoriIMT(double imt) {
    if (imt < 18.5) {
      return Colors.orange;
    } else if (imt < 25.0) {
      return Colors.green;
    } else if (imt < 30.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  /// Load riwayat by pasien for chart
  Future<void> loadRiwayatByPasien(String pasienId, String namaPasien) async {
    try {
      selectedPasienId.value = pasienId;
      
      final snapshot = await FirebaseFirestore.instance
          .collection('antrian')
          .where('pasienId', isEqualTo: pasienId)
          .where('status', isEqualTo: 'selesai')
          .orderBy('createdAt', descending: false)
          .limit(10)
          .get();
      
      chartData.value = snapshot.docs.map((doc) {
        final data = doc.data();
        final perawatData = data['perawatData'] as Map<String, dynamic>?;
        
        return {
          'tanggal': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'tekanan_darah_sistolik': perawatData?['tekananDarahSistolik'] ?? 0,
          'tekanan_darah_diastolik': perawatData?['tekananDarahDiastolik'] ?? 0,
          'nadi': perawatData?['nadi'] ?? 0,
          'suhu_tubuh': perawatData?['suhu'] ?? 0,
          'pernapasan': perawatData?['pernapasan'] ?? 0,
          'berat_badan': perawatData?['beratBadan'] ?? 0,
          'tinggi_badan': perawatData?['tinggiBadan'] ?? 0,
        };
      }).toList();
      
    } catch (e) {
    }
  }

  /// Navigate to detail
  void navigateToDetail(Map<String, dynamic> data) {
    navigateToFormRekamMedis(data);
  }

  /// Navigasi ke form/detail rekam medis
  Future<void> navigateToFormRekamMedis(Map<String, dynamic> antrian) async {
    final status = antrian['status'] as String?;
    
    if (status == 'menunggu_dokter' || status == 'sedang_dilayani' || status == 'selesai') {
      try {
        final antrianId = antrian['id'] as String;
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
    } else {
      Get.to(() => FormRekamMedisView(pasienData: antrian));
    }
  }

  /// Lewati antrian
  Future<void> lewatiAntrian(String antrianId) async {
    try {
      await FirebaseFirestore.instance
          .collection('antrian')
          .doc(antrianId)
          .update({
        'status': 'dilewati',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      SnackbarHelper.showSuccess('Antrian berhasil dilewati');
      await refreshData();
    } catch (e) {
      SnackbarHelper.showError('Gagal melewati antrian: $e');
    }
  }

  /// Batalkan antrian dengan alasan
  Future<void> batalkanAntrian(Map<String, dynamic> antrian, String alasan) async {
    try {
      // Ambil userId dari session, fallback ke Firebase Auth UID
      var perawatId = _sessionService.getUserId();
      final perawatNama = _sessionService.getNamaLengkap();
      
      // Second handler: gunakan Firebase Auth UID jika session kosong
      if (perawatId == null || perawatId.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Cari user di Firestore berdasarkan firebaseUid
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('firebaseUid', isEqualTo: currentUser.uid)
              .limit(1)
              .get();
          
          if (userSnapshot.docs.isNotEmpty) {
            perawatId = userSnapshot.docs.first.id;
          }
        }
      }

      await FirebaseFirestore.instance
          .collection('antrian')
          .doc(antrian['id'])
          .update({
        'status': 'dibatalkan',
        'alasanPembatalan': alasan,
        'dibatalkanOleh': 'perawat',
        'dibatalkanOlehId': perawatId ?? '',
        'dibatalkanOlehNama': perawatNama ?? '',
        'waktuPembatalan': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      SnackbarHelper.showSuccess('Antrian berhasil dibatalkan');
      await refreshData();
    } catch (e) {
      SnackbarHelper.showError('Gagal membatalkan antrian: $e');
    }
  }
}
