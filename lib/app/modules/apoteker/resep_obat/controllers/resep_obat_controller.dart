import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class ResepObatController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();

  // Text controller for catatan dan search
  final catatanController = TextEditingController();
  final searchController = TextEditingController();

  // Observable list untuk antrian dengan resep
  final antrianMenunggu = <AntrianModel>[].obs;
  final antrianSelesai = <AntrianModel>[].obs;
  
  // Search query
  final searchQuery = ''.obs;

  // Loading state
  final isLoading = false.obs;

  // Filter status
  final selectedFilter = 'Menunggu'.obs;
  final filterOptions = ['Semua', 'Menunggu', 'Selesai'];
  
  // Filter periode (untuk tab Selesai)
  final selectedPeriode = 'Hari Ini'.obs;
  final periodeOptions = ['Hari Ini', '7 Hari', '30 Hari', 'Semua'];

  @override
  void onInit() {
    super.onInit();
    loadResep();
    
    // Listen to search controller
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    catatanController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Change periode filter
  void changePeriode(String periode) {
    selectedPeriode.value = periode;
    loadResep(); // Reload data dengan filter baru
  }

  // Get filtered resep with search
  List<AntrianModel> get filteredAntrian {
    List<AntrianModel> result;
    
    if (selectedFilter.value == 'Menunggu') {
      result = antrianMenunggu.toList();
    } else if (selectedFilter.value == 'Selesai') {
      result = antrianSelesai.toList();
    } else {
      result = [...antrianMenunggu, ...antrianSelesai];
    }
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((a) {
        final nama = a.namaLengkap.toLowerCase();
        final noRM = a.noRekamMedis.toLowerCase();
        final queueNo = a.queueNumber.toLowerCase();
        final query = searchQuery.value;
        return nama.contains(query) || 
               noRM.contains(query) || 
               queueNo.contains(query);
      }).toList();
    }
    
    return result;
  }

  // Count resep menunggu
  int get countMenunggu => antrianMenunggu.length;

  // Count resep selesai
  int get countSelesai => antrianSelesai.length;

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
  
  // Helper: get filter date based on periode
  DateTime? _getFilterDate() {
    final now = DateTime.now();
    switch (selectedPeriode.value) {
      case 'Hari Ini':
        return DateTime(now.year, now.month, now.day);
      case '7 Hari':
        return now.subtract(const Duration(days: 7));
      case '30 Hari':
        return now.subtract(const Duration(days: 30));
      case 'Semua':
      default:
        return null; // No filter
    }
  }

  // Load resep dari Firestore dengan filter periode
  Future<void> loadResep() async {
    try {
      isLoading.value = true;
      
      // Get current apoteker ID (field 'id' adalah doc.id dari Firestore)
      final userData = await AuthHelper.currentUserData;
      final currentApotekerId = userData?['id'] as String? ?? '';
      
      // Get filter date
      final filterDate = _getFilterDate();

      // Get antrian dengan status 'selesai_diperiksa' (menunggu apoteker)
      // Menunggu selalu tampil semua (tidak di-filter periode)
      final menunggu = await _antrianService.getAntrianUntukApoteker();
      antrianMenunggu.value = menunggu;

      // Get semua antrian yang sudah diproses OLEH APOTEKER INI
      final allAntrian = await _antrianService.getAllAntrian();
      
      final selesai = allAntrian
          .map((data) => AntrianModel.fromMap(data))
          .where((a) {
            final hasResep = a.adaResepObat;
            final statusOk = a.status == 'siap_ambil_obat' || a.status == 'selesai';
            final sudahDisiapkan = a.sudahDisiapkanApoteker;
            final apotekerIdMatch = a.apotekerData?['apotekerId'] == currentApotekerId;
            
            // Filter by date if filterDate is set
            bool dateOk = true;
            if (filterDate != null) {
              dateOk = a.createdAt.isAfter(filterDate) || 
                       a.createdAt.isAtSameMomentAs(filterDate);
            }
            
            return hasResep && statusOk && sudahDisiapkan && apotekerIdMatch && dateOk;
          })
          .toList();
      
      // Sort by date descending (terbaru di atas)
      selesai.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      antrianSelesai.value = selesai;

    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data resep: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Konfirmasi siapkan obat (auto-reduce stok)
  Future<void> konfirmasiSiapkanObat(AntrianModel antrian) async {
    try {
      isLoading.value = true;
      
      final userData = await AuthHelper.currentUserData;
      if (userData == null) {
        throw Exception('Data user tidak ditemukan');
      }
      
      // Field 'id' adalah doc.id dari Firestore, bukan 'uid'
      final apotekerId = userData['id'] as String? ?? '';
      final apotekerNama = userData['namaLengkap'] as String? ?? 'Apoteker';
      
      if (apotekerId.isEmpty) {
        throw Exception('User ID tidak valid');
      }

      final success = await _antrianService.konfirmasiSiapkanObat(
        antrianId: antrian.id!,
        apotekerId: apotekerId,
        apotekerNama: apotekerNama,
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (success) {
        SnackbarHelper.showSuccess(
          'Obat berhasil disiapkan!\nStok otomatis dikurangi.',
        );
        catatanController.clear();
        
        // Reload data dan kembali ke list
        await loadResep();
        Get.back();
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal menyiapkan obat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Lihat detail resep
  void lihatDetailResep(AntrianModel antrian) {
    Get.toNamed(
      '/apoteker/resep-obat/detail',
      arguments: antrian,
    );
  }

  // Refresh data
  Future<void> refreshResep() async {
    await loadResep();
  }
}
