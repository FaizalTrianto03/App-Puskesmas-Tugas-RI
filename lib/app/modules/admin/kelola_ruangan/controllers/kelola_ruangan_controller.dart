import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/firestore/ruangan_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';

class KelolaRuanganController extends GetxController {
  final RuanganFirestoreService _ruanganService = RuanganFirestoreService();

  final namaRuanganController = TextEditingController();
  final kodeRuanganController = TextEditingController();
  final lokasiController = TextEditingController();
  final kapasitasController = TextEditingController();
  final fasilitasController = TextEditingController();

  // Search controller
  final searchController = TextEditingController();

  final selectedStatus = 'tersedia'.obs;
  final ruanganList = <Map<String, dynamic>>[].obs;
  final filteredRuanganList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'Semua'.obs;
  final isLoading = false.obs;

  final statusFilters = ['Semua', 'Tersedia', 'Digunakan'];
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadRuangan();
  }

  @override
  void onClose() {
    namaRuanganController.dispose();
    kodeRuanganController.dispose();
    lokasiController.dispose();
    kapasitasController.dispose();
    fasilitasController.dispose();
    super.onClose();
  }

  Future<void> loadRuangan() async {
    try {
      final data = await _ruanganService.getAllRuangan();
      ruanganList.value = data;
      applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data ruangan');
    }
  }

  void applyFilters() {
    var filtered = ruanganList.toList();
    
    // Filter by status
    if (selectedStatusFilter.value != 'Semua') {
      filtered = filtered.where((ruangan) {
        final status = ruangan['status'];
        if (status == null) return false;
        if (selectedStatusFilter.value == 'Tersedia') {
          return status.toString().toLowerCase() == 'tersedia';
        } else {
          return status.toString().toLowerCase() == 'digunakan';
        }
      }).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((ruangan) {
        final nama = ruangan['namaRuangan']?.toString() ?? '';
        final kode = ruangan['kodeRuangan']?.toString() ?? '';
        final lokasi = ruangan['lokasi']?.toString() ?? '';
        final fasilitas = ruangan['fasilitas']?.toString() ?? '';
        
        return nama.toLowerCase().contains(query) ||
               kode.toLowerCase().contains(query) ||
               lokasi.toLowerCase().contains(query) ||
               fasilitas.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredRuanganList.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    searchController.text = query;
    applyFilters();
  }

  void onStatusFilterChanged(String status) {
    selectedStatusFilter.value = status;
    applyFilters();
  }

  Map<String, int> getRuanganStatistics() {
    final stats = <String, int>{
      'total': ruanganList.length,
      'tersedia': 0,
      'digunakan': 0,
    };

    for (var ruangan in ruanganList) {
      final status = ruangan['status'];
      if (status != null) {
        final statusStr = status.toString().toLowerCase();
        if (statusStr == 'tersedia') {
          stats['tersedia'] = (stats['tersedia'] ?? 0) + 1;
        } else {
          stats['digunakan'] = (stats['digunakan'] ?? 0) + 1;
        }
      }
    }

    return stats;
  }

  String? validateNamaRuangan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama ruangan harus diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama ruangan minimal 3 karakter';
    }
    return null;
  }

  String? validateKodeRuangan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode ruangan harus diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode ruangan minimal 2 karakter';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.trim())) {
      return 'Kode ruangan hanya boleh huruf kapital dan angka';
    }
    return null;
  }

  String? validateLokasi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lokasi harus diisi';
    }
    return null;
  }

  String? validateKapasitas(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kapasitas harus diisi';
    }
    final kapasitas = int.tryParse(value.trim());
    if (kapasitas == null || kapasitas < 1) {
      return 'Kapasitas harus berupa angka minimal 1';
    }
    return null;
  }

  Future<void> addRuangan() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Check if kode ruangan already exists
      final kodeExists = await _ruanganService.isKodeRuanganExists(
        kodeRuanganController.text.trim().toUpperCase(),
      );

      if (kodeExists) {
        SnackbarHelper.showError('Kode ruangan sudah terdaftar');
        isLoading.value = false;
        return;
      }

      final ruanganData = {
        'namaRuangan': namaRuanganController.text.trim(),
        'kodeRuangan': kodeRuanganController.text.trim().toUpperCase(),
        'lokasi': lokasiController.text.trim(),
        'kapasitas': int.parse(kapasitasController.text.trim()),
        'fasilitas': fasilitasController.text.trim(),
        'status': selectedStatus.value,
      };

      final id = await _ruanganService.addRuangan(ruanganData);

      if (id != null) {
        await loadRuangan();
        clearForm();

        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showSuccess('Ruangan berhasil ditambahkan');
      } else {
        SnackbarHelper.showError('Gagal menambahkan ruangan');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRuangan(String id) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Check if kode ruangan already exists (exclude current)
      final kodeExists = await _ruanganService.isKodeRuanganExists(
        kodeRuanganController.text.trim().toUpperCase(),
        excludeId: id,
      );

      if (kodeExists) {
        SnackbarHelper.showError('Kode ruangan sudah terdaftar');
        isLoading.value = false;
        return;
      }

      final ruanganData = {
        'namaRuangan': namaRuanganController.text.trim(),
        'kodeRuangan': kodeRuanganController.text.trim().toUpperCase(),
        'lokasi': lokasiController.text.trim(),
        'kapasitas': int.parse(kapasitasController.text.trim()),
        'fasilitas': fasilitasController.text.trim(),
        'status': selectedStatus.value,
      };

      final success = await _ruanganService.updateRuangan(id, ruanganData);

      if (success) {
        await loadRuangan();
        clearForm();

        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showSuccess('Ruangan berhasil diperbarui');
      } else {
        SnackbarHelper.showError('Gagal memperbarui ruangan');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRuangan(String id, String namaRuangan) async {
    final confirmed = await ConfirmationDialog.show(
      title: 'Hapus Ruangan',
      message: 'Apakah Anda yakin ingin menghapus ruangan "$namaRuangan"?',
      type: ConfirmationType.danger,
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );

    if (confirmed == true) {
      try {
        final success = await _ruanganService.deleteRuangan(id);
        
        if (success) {
          await loadRuangan();
          SnackbarHelper.showSuccess('Ruangan berhasil dihapus');
        } else {
          SnackbarHelper.showError('Gagal menghapus ruangan');
        }
      } catch (e) {
        SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  void populateFormForEdit(Map<String, dynamic> ruangan) {
    namaRuanganController.text = ruangan['namaRuangan'] ?? '';
    kodeRuanganController.text = ruangan['kodeRuangan'] ?? '';
    lokasiController.text = ruangan['lokasi'] ?? '';
    kapasitasController.text = (ruangan['kapasitas'] ?? '').toString();
    fasilitasController.text = ruangan['fasilitas'] ?? '';
    selectedStatus.value = ruangan['status'] ?? 'tersedia';
  }

  void clearForm() {
    namaRuanganController.clear();
    kodeRuanganController.clear();
    lokasiController.clear();
    kapasitasController.clear();
    fasilitasController.clear();
    selectedStatus.value = 'tersedia';
  }
}
