import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class RiwayatPenyiapanController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();

  final riwayatList = <AntrianModel>[].obs;
  final filteredRiwayatList = <AntrianModel>[].obs;
  final isLoading = false.obs;

  // Search
  late final TextEditingController searchController;
  final searchQuery = ''.obs;

  // Statistik
  final totalResepDisiapkan = 0.obs;
  final totalItemObat = 0.obs;
  final totalNilaiObat = 0.obs;

  // Filter - simplified like perawat/dokter
  final selectedPeriod = 'hari_ini'.obs;
  
  // Legacy filter (for backwards compatibility)
  final tanggalMulai = Rxn<DateTime>();
  final tanggalAkhir = Rxn<DateTime>();
  final selectedPreset = 'Hari Ini'.obs;
  final presetOptions = ['Hari Ini', '7 Hari', '30 Hari', 'Custom'];

  String? _apotekerId;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    _initApoteker();
    
    // Listen to search changes
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onPeriodChanged(String period) {
    selectedPeriod.value = period;
    // Map new period to old preset for loading
    final now = DateTime.now();
    switch (period) {
      case 'hari_ini':
        tanggalMulai.value = DateTime(now.year, now.month, now.day);
        tanggalAkhir.value = now;
        selectedPreset.value = 'Hari Ini';
        break;
      case 'minggu_ini':
        final daysToSubtract = now.weekday - 1;
        tanggalMulai.value = DateTime(now.year, now.month, now.day - daysToSubtract);
        tanggalAkhir.value = now;
        selectedPreset.value = '7 Hari';
        break;
      case 'bulan_ini':
        tanggalMulai.value = DateTime(now.year, now.month, 1);
        tanggalAkhir.value = now;
        selectedPreset.value = '30 Hari';
        break;
      case 'tahun_ini':
        tanggalMulai.value = DateTime(now.year, 1, 1);
        tanggalAkhir.value = now;
        selectedPreset.value = '30 Hari';
        break;
      default:
        tanggalMulai.value = null;
        tanggalAkhir.value = null;
    }
    loadRiwayat();
  }

  Future<void> _initApoteker() async {
    try {
      final userData = await AuthHelper.currentUserData;
      // Use 'id' field (doc.id from Firestore), NOT 'uid'
      _apotekerId = userData?['id'];
      
      if (_apotekerId != null) {
        setPresetFilter('Hari Ini');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data apoteker');
    }
  }

  void setPresetFilter(String preset) {
    selectedPreset.value = preset;
    final now = DateTime.now();

    switch (preset) {
      case 'Hari Ini':
        tanggalMulai.value = DateTime(now.year, now.month, now.day);
        tanggalAkhir.value = now;
        break;
      case '7 Hari':
        tanggalMulai.value = now.subtract(const Duration(days: 7));
        tanggalAkhir.value = now;
        break;
      case '30 Hari':
        tanggalMulai.value = now.subtract(const Duration(days: 30));
        tanggalAkhir.value = now;
        break;
      case 'Custom':
        // User will select dates manually
        return;
    }

    loadRiwayat();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    tanggalMulai.value = start;
    tanggalAkhir.value = end;
    selectedPreset.value = 'Custom';
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    if (_apotekerId == null) return;

    try {
      isLoading.value = true;

      final result = await _antrianService.getStatistikPenyiapanApoteker(
        apotekerId: _apotekerId!,
        tanggalMulai: tanggalMulai.value,
        tanggalAkhir: tanggalAkhir.value,
      );

      totalResepDisiapkan.value = result['totalResepDisiapkan'] ?? 0;
      totalItemObat.value = result['totalItemObat'] ?? 0;
      totalNilaiObat.value = result['totalNilaiObat'] ?? 0;
      riwayatList.value = result['riwayat'] as List<AntrianModel>;
      
      applyFilters();

    } catch (e) {
      SnackbarHelper.showError('Gagal memuat riwayat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    applyFilters();
  }
  
  void applyFilters() {
    var filtered = riwayatList.toList();
    
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        return (item.namaLengkap?.toLowerCase() ?? '').contains(query) ||
               (item.noRekamMedis?.toLowerCase() ?? '').contains(query) ||
               (item.queueNumber?.toLowerCase() ?? '').contains(query);
      }).toList();
    }
    
    // Sort by date descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    filteredRiwayatList.value = filtered;
  }

  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedPeriod.value = 'hari_ini';
  }

  Future<void> refreshRiwayat() async {
    await loadRiwayat();
  }

  String formatTanggal(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void lihatDetail(AntrianModel antrian) {
    Get.toNamed('/apoteker/resep-obat/detail', arguments: antrian);
  }
}
