import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/firestore/poli_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';

class KelolaPoliController extends GetxController {
  final PoliFirestoreService _poliService = PoliFirestoreService();

  final namaPoliController = TextEditingController();
  final kodePoliController = TextEditingController();
  final deskripsiController = TextEditingController();

  // Search controller
  final searchController = TextEditingController();

  final selectedStatus = 'aktif'.obs;
  final poliList = <Map<String, dynamic>>[].obs;
  final filteredPoliList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'Semua'.obs;
  final isLoading = false.obs;

  final statusFilters = ['Semua', 'Aktif', 'Tidak Aktif'];
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadPoli();
  }

  @override
  void onClose() {
    namaPoliController.dispose();
    kodePoliController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  Future<void> loadPoli() async {
    try {
      final data = await _poliService.getAllPoli();
      poliList.value = data;
      applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data poli');
    }
  }

  void applyFilters() {
    var filtered = poliList.toList();
    
    // Filter by status
    if (selectedStatusFilter.value != 'Semua') {
      filtered = filtered.where((poli) {
        final status = poli['status'];
        if (status == null) return false;
        if (selectedStatusFilter.value == 'Aktif') {
          return status.toString().toLowerCase() == 'aktif';
        } else {
          return status.toString().toLowerCase() == 'tidak aktif';
        }
      }).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((poli) {
        final nama = poli['namaPoli']?.toString() ?? '';
        final kode = poli['kodePoli']?.toString() ?? '';
        final deskripsi = poli['deskripsi']?.toString() ?? '';
        
        return nama.toLowerCase().contains(query) ||
               kode.toLowerCase().contains(query) ||
               deskripsi.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredPoliList.value = filtered;
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

  Map<String, int> getPoliStatistics() {
    final stats = <String, int>{
      'total': poliList.length,
      'aktif': 0,
      'tidakAktif': 0,
    };

    for (var poli in poliList) {
      final status = poli['status'];
      if (status != null) {
        final statusStr = status.toString().toLowerCase();
        if (statusStr == 'aktif') {
          stats['aktif'] = (stats['aktif'] ?? 0) + 1;
        } else {
          stats['tidakAktif'] = (stats['tidakAktif'] ?? 0) + 1;
        }
      }
    }

    return stats;
  }

  String? validateNamaPoli(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama poli harus diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama poli minimal 3 karakter';
    }
    return null;
  }

  String? validateKodePoli(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode poli harus diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode poli minimal 2 karakter';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.trim())) {
      return 'Kode poli hanya boleh huruf kapital dan angka';
    }
    return null;
  }

  Future<void> addPoli() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Check if kode poli already exists
      final kodeExists = await _poliService.isKodePoliExists(
        kodePoliController.text.trim().toUpperCase(),
      );

      if (kodeExists) {
        SnackbarHelper.showError('Kode poli sudah terdaftar');
        isLoading.value = false;
        return;
      }

      final poliData = {
        'namaPoli': namaPoliController.text.trim(),
        'kodePoli': kodePoliController.text.trim().toUpperCase(),
        'deskripsi': deskripsiController.text.trim(),
        'status': selectedStatus.value,
      };

      final id = await _poliService.addPoli(poliData);

      if (id != null) {
        await loadPoli();
        clearForm();

        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showSuccess('Poli berhasil ditambahkan');
      } else {
        SnackbarHelper.showError('Gagal menambahkan poli');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePoli(String poliId) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (poliId.isEmpty) {
      SnackbarHelper.showError('ID poli tidak valid');
      return;
    }

    isLoading.value = true;

    try {
      // Verify poli exists
      final existingPoli = await _poliService.getPoliById(poliId);
      if (existingPoli == null) {
        SnackbarHelper.showError('Poli tidak ditemukan');
        isLoading.value = false;
        return;
      }

      // Check if kode poli already exists (excluding current)
      final kodeExists = await _poliService.isKodePoliExists(
        kodePoliController.text.trim().toUpperCase(),
        excludeId: poliId,
      );

      if (kodeExists) {
        SnackbarHelper.showError('Kode poli sudah digunakan oleh poli lain');
        isLoading.value = false;
        return;
      }

      final updates = {
        'namaPoli': namaPoliController.text.trim(),
        'kodePoli': kodePoliController.text.trim().toUpperCase(),
        'deskripsi': deskripsiController.text.trim(),
        'status': selectedStatus.value,
      };

      final success = await _poliService.updatePoli(poliId, updates);

      if (success) {
        await loadPoli();
        clearForm();

        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showSuccess('Poli berhasil diperbarui');
      } else {
        SnackbarHelper.showError('Gagal memperbarui poli');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePoli(String poliId, String namaPoli) async {
    final confirmed = await ConfirmationDialog.show(
      title: 'Hapus Poli',
      message: 'Apakah Anda yakin ingin menghapus poli "$namaPoli"?\n\nData yang dihapus tidak dapat dikembalikan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      type: ConfirmationType.danger,
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      final success = await _poliService.deletePoli(poliId);

      if (success) {
        await loadPoli();
        SnackbarHelper.showSuccess('Poli berhasil dihapus');
      } else {
        SnackbarHelper.showError('Gagal menghapus poli');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    namaPoliController.clear();
    kodePoliController.clear();
    deskripsiController.clear();
    selectedStatus.value = 'aktif';
  }

  void populateFormForEdit(Map<String, dynamic> poli) {
    namaPoliController.text = poli['namaPoli'] ?? '';
    kodePoliController.text = poli['kodePoli'] ?? '';
    deskripsiController.text = poli['deskripsi'] ?? '';
    selectedStatus.value = poli['status'] ?? 'aktif';
  }
}
