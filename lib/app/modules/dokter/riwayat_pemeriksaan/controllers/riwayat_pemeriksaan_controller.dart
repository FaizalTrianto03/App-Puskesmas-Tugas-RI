import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';

class DokterRiwayatPemeriksaanController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadPoliList();
    _loadRiwayatPemeriksaan();

    // Listen to search and filter changes
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 500));
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

  /// Load semua riwayat pemeriksaan dokter
  Future<void> _loadRiwayatPemeriksaan() async {
    try {
      isLoading.value = true;

      // Gunakan firebaseUid, fallback ke userId untuk backward compatibility
      final dokterId = _sessionService.getFirebaseUid() ?? _sessionService.getUserId();
      if (dokterId == null) {
        SnackbarHelper.showError('Session tidak ditemukan, silakan login ulang');
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('antrian')
          .orderBy('createdAt', descending: true)
          .get();

      riwayatList.clear();

      final dokterNama = _sessionService.getNamaLengkap();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Cek apakah data ini milik dokter yang login
        bool isMyData = false;

        // Cek dari dokterData (untuk data yang sudah diperiksa)
        final dokterData = data['dokterData'];
        if (dokterData != null && dokterData is Map<String, dynamic>) {
          if (dokterData['dokterId'] == dokterId) {
            isMyData = true;
          }
        }
        
        // Cek dari dokterId di root level (struktur baru)
        if (!isMyData && data['dokterId'] == dokterId) {
          isMyData = true;
        }

        // Cek dari dibatalkanOleh (untuk data yang dibatalkan oleh dokter)
        if (!isMyData &&
            data['status'] == 'dibatalkan' &&
            data['dibatalkanOleh'] == 'dokter') {
          final dibatalkanOlehId = data['dibatalkanOlehId'];
          final dibatalkanOlehNama = data['dibatalkanOlehNama'];

          // Match by ID atau nama (karena ID bisa kosong string di data lama)
          if (dibatalkanOlehId == dokterId ||
              (dibatalkanOlehId == '' && dibatalkanOlehNama == dokterNama)) {
            isMyData = true;
          }
        }

        // Skip jika bukan data dokter ini
        if (!isMyData) continue;

        // Simpan data ASLI dari Firestore dengan menambahkan id saja
        // Sama persis seperti yang dilakukan di Dashboard Dokter
        riwayatList.add({
          'id': doc.id,
          ...data,
        });
      }

      _calculateStatistik();
      _applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat riwayat pemeriksaan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Hitung statistik pemeriksaan
  void _calculateStatistik() {
    totalPemeriksaan.value = riwayatList.length;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    pemeriksaanHariIni.value = _countByPeriod(startOfToday);
    pemeriksaanMingguIni.value = _countByPeriod(startOfWeek);
    pemeriksaanBulanIni.value = _countByPeriod(startOfMonth);
  }

  /// Get tanggal dari data antrian
  DateTime? _getTanggalFromData(Map<String, dynamic> item) {
    // Coba ambil dari dokterData.examinedAt terlebih dahulu
    final dokterData = item['dokterData'] as Map<String, dynamic>?;
    if (dokterData != null && dokterData['examinedAt'] != null) {
      final examinedAt = dokterData['examinedAt'];
      if (examinedAt is Timestamp) {
        return examinedAt.toDate();
      }
    }
    // Fallback ke createdAt
    final createdAt = item['createdAt'];
    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }
    return null;
  }

  /// Count pemeriksaan by period
  int _countByPeriod(DateTime startDate) {
    return riwayatList.where((item) {
      final tanggal = _getTanggalFromData(item);
      if (tanggal == null) return false;
      return tanggal.isAfter(startDate) || tanggal.isAtSameMomentAs(startDate);
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

    filteredRiwayatList.value = filtered;
  }

  /// Apply search filter
  List<Map<String, dynamic>> _applySearchFilter(
      List<Map<String, dynamic>> list) {
    final query = searchQuery.value.toLowerCase();
    return list.where((item) {
      final namaLengkap = item['namaLengkap']?.toString().toLowerCase() ?? '';
      final noRekamMedis = item['noRekamMedis']?.toString().toLowerCase() ?? '';
      final queueNumber = item['queueNumber']?.toString().toLowerCase() ?? '';
      final keluhan = item['keluhan']?.toString().toLowerCase() ?? '';
      // Diagnosa bisa di root level atau di dokterData
      final dokterData = item['dokterData'] as Map<String, dynamic>? ?? {};
      final diagnosa = (item['diagnosa'] ?? dokterData['diagnosa'] ?? '').toString().toLowerCase();
      
      return namaLengkap.contains(query) ||
          noRekamMedis.contains(query) ||
          queueNumber.contains(query) ||
          diagnosa.contains(query) ||
          keluhan.contains(query);
    }).toList();
  }

  /// Apply period filter
  List<Map<String, dynamic>> _applyPeriodFilter(
      List<Map<String, dynamic>> list) {
    final now = DateTime.now();

    switch (selectedPeriod.value) {
      case 'hari_ini':
        final startOfToday = DateTime(now.year, now.month, now.day);
        return list.where((item) {
          final tanggal = _getTanggalFromData(item);
          return tanggal != null && (tanggal.isAfter(startOfToday) || tanggal.isAtSameMomentAs(startOfToday));
        }).toList();

      case 'minggu_ini':
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        return list.where((item) {
          final tanggal = _getTanggalFromData(item);
          return tanggal != null && (tanggal.isAfter(startOfWeek) || tanggal.isAtSameMomentAs(startOfWeek));
        }).toList();

      case 'bulan_ini':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return list.where((item) {
          final tanggal = _getTanggalFromData(item);
          return tanggal != null && (tanggal.isAfter(startOfMonth) || tanggal.isAtSameMomentAs(startOfMonth));
        }).toList();

      case 'tahun_ini':
        final startOfYear = DateTime(now.year, 1, 1);
        return list.where((item) {
          final tanggal = _getTanggalFromData(item);
          return tanggal != null && (tanggal.isAfter(startOfYear) || tanggal.isAtSameMomentAs(startOfYear));
        }).toList();

      default:
        return list;
    }
  }

  /// Apply poli filter
  List<Map<String, dynamic>> _applyPoliFilter(List<Map<String, dynamic>> list) {
    return list
        .where((item) => (item['jenisLayanan'] ?? item['poli'] ?? '').toString() == selectedPoli.value)
        .toList();
  }

  /// Apply status filter
  List<Map<String, dynamic>> _applyStatusFilter(
      List<Map<String, dynamic>> list) {
    return list.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';

      switch (selectedStatus.value) {
        case 'selesai':
          return status == 'selesai' ||
              status == 'selesai_diperiksa' ||
              status == 'siap_ambil_obat';
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

  /// Format tanggal - handle both DateTime and Timestamp
  String formatTanggal(dynamic tanggal) {
    if (tanggal == null) return '-';
    DateTime dateTime;
    if (tanggal is Timestamp) {
      dateTime = tanggal.toDate();
    } else if (tanggal is DateTime) {
      dateTime = tanggal;
    } else {
      return '-';
    }
    return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
  }

  /// Format waktu - handle both DateTime and Timestamp
  String formatWaktu(dynamic tanggal) {
    if (tanggal == null) return '-';
    DateTime dateTime;
    if (tanggal is Timestamp) {
      dateTime = tanggal.toDate();
    } else if (tanggal is DateTime) {
      dateTime = tanggal;
    } else {
      return '-';
    }
    return DateFormat('HH:mm', 'id_ID').format(dateTime);
  }
}
