import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/obat_model.dart';
import '../../../../data/services/firestore/obat_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/confirmation_dialog.dart';

class StokObatController extends GetxController {
  final ObatFirestoreService _obatService = ObatFirestoreService();

  final obatList = <ObatModel>[].obs;
  final filteredObatList = <ObatModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  // Filter options
  final filterOptions = ['Semua', 'Aman', 'Hampir Habis', 'Kritis', 'Habis'].obs;

  // Statistik
  final totalObat = 0.obs;
  final stokAman = 0.obs;
  final stokHampirHabis = 0.obs;
  final stokKritis = 0.obs;
  final stokHabis = 0.obs;
  final obatKadaluarsa = 0.obs;

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final namaObatController = TextEditingController();
  final stokController = TextEditingController();
  final hargaSatuanController = TextEditingController();
  final keteranganController = TextEditingController();
  final tanggalKadaluarsa = ''.obs;

  // Form dropdowns
  final selectedJenisObat = ''.obs;
  final selectedKategori = ''.obs;
  final selectedSatuan = ''.obs;

  // Dropdown options
  final jenisObatOptions = ['Tablet', 'Kapsul', 'Sirup', 'Salep', 'Injeksi'];
  final kategoriOptions = ['Antibiotik', 'Analgesik', 'Antipiretik', 'Vitamin', 'Lainnya'];
  final satuanOptions = ['Strip', 'Box', 'Botol', 'Tube', 'Ampul'];

  @override
  void onInit() {
    super.onInit();
    loadObat();
    
    // Listen to search changes
    debounce(
      searchQuery,
      (_) => applyFilters(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> loadObat() async {
    try {
      isLoading.value = true;
      final data = await _obatService.getAllObat();
      obatList.value = data;
      updateStatistik();
      applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data obat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateStatistik() {
    totalObat.value = obatList.length;
    stokAman.value = obatList.where((o) => o.isStokAman).length;
    stokHampirHabis.value = obatList.where((o) => o.isStokHampirHabis).length;
    stokKritis.value = obatList.where((o) => o.isStokKritis && o.stok > 0).length;
    stokHabis.value = obatList.where((o) => o.stok == 0).length;
    
    // Count obat kadaluarsa (expired or expiring within 30 days)
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    obatKadaluarsa.value = obatList.where((o) {
      if (o.tanggalKadaluarsa == null) return false;
      // Include if expiry date is today or in the next 30 days (or already expired)
      return o.tanggalKadaluarsa!.isBefore(thirtyDaysFromNow) || 
             o.tanggalKadaluarsa!.isAtSameMomentAs(thirtyDaysFromNow);
    }).length;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void applyFilters() {
    var filtered = obatList.toList();

    // Apply filter by status
    switch (selectedFilter.value) {
      case 'Habis':
        filtered = filtered.where((o) => o.stok == 0).toList();
        break;
      case 'Kritis':
        filtered = filtered.where((o) => o.isStokKritis && o.stok > 0).toList();
        break;
      case 'Hampir Habis':
        filtered = filtered.where((o) => o.isStokHampirHabis).toList();
        break;
      case 'Aman':
        filtered = filtered.where((o) => o.isStokAman).toList();
        break;
      default:
        // Semua
        break;
    }

    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((obat) {
        return obat.namaObat.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               obat.kategori.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    filteredObatList.value = filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> refreshObat() async {
    await loadObat();
  }

  // Navigate to detail/edit - changed to directly edit
  void goToDetailObat(ObatModel obat) {
    goToEditObat(obat);
  }

  // Navigate to add obat
  void goToTambahObat() {
    clearForm(); // Clear form before navigating to add mode
    Get.toNamed('/apoteker/stok-obat/tambah');
  }

  // Navigate to edit obat
  void goToEditObat(ObatModel obat) {
    // Populate form with obat data
    namaObatController.text = obat.namaObat;
    stokController.text = obat.stok.toString();
    
    // Format harga dengan separator ribuan
    final formatter = NumberFormat.decimalPattern('id_ID');
    hargaSatuanController.text = formatter.format(obat.hargaSatuan);
    
    keteranganController.text = obat.keterangan ?? '';
    
    // Set tanggal kadaluarsa
    if (obat.tanggalKadaluarsa != null) {
      tanggalKadaluarsa.value = '${obat.tanggalKadaluarsa!.day.toString().padLeft(2, '0')}/${obat.tanggalKadaluarsa!.month.toString().padLeft(2, '0')}/${obat.tanggalKadaluarsa!.year}';
    } else {
      tanggalKadaluarsa.value = '';
    }
    
    selectedJenisObat.value = obat.jenisObat;
    selectedKategori.value = obat.kategori;
    selectedSatuan.value = obat.satuan;
    
    Get.toNamed(
      '/apoteker/stok-obat/tambah',
      arguments: {
        'isEdit': true,
        'obatId': obat.id,
      },
    );
  }

  // Simpan obat (add or edit)
  Future<void> simpanObat({bool isEdit = false, String? obatId}) async {
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Mohon lengkapi semua field yang diperlukan');
      return;
    }

    isLoading.value = true;
    try {
      // Parse harga satuan (remove formatting)
      final hargaNumericValue = hargaSatuanController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Parse tanggal kadaluarsa
      DateTime? kdlDate;
      if (tanggalKadaluarsa.value.isNotEmpty) {
        final parts = tanggalKadaluarsa.value.split('/');
        if (parts.length == 3) {
          kdlDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      
      final obat = ObatModel(
        id: obatId ?? '',
        namaObat: namaObatController.text.trim(),
        jenisObat: selectedJenisObat.value,
        kategori: selectedKategori.value,
        stok: int.parse(stokController.text.trim()),
        satuan: selectedSatuan.value,
        hargaSatuan: int.parse(hargaNumericValue),
        keterangan: keteranganController.text.trim(),
        tanggalKadaluarsa: kdlDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit && obatId != null) {
        await _obatService.updateObat(obatId, obat);
        Get.snackbar(
          'Berhasil',
          'Obat berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        await _obatService.addObat(obat);
        Get.snackbar(
          'Berhasil',
          'Obat berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      clearForm();
      isLoading.value = false;
      
      // Reload data
      await loadObat();
      
      // Navigate back to StokObatView
      Get.until((route) => route.settings.name == '/apoteker/stok-obat');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal menyimpan obat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Hapus obat
  Future<void> hapusObat(String obatId, String namaObat) async {
    // Show confirmation dialog
    final confirm = await ConfirmationDialog.show(
      title: 'Hapus Obat',
      message: 'Apakah Anda yakin ingin menghapus "$namaObat"? Tindakan ini tidak dapat dibatalkan.',
      type: ConfirmationType.danger,
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;
      await _obatService.deleteObat(obatId);
      
      Get.snackbar(
        'Berhasil',
        'Obat berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      clearForm();
      await loadObat();
      
      // Navigate back to StokObatView
      Get.until((route) => route.settings.name == '/apoteker/stok-obat');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus obat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    namaObatController.clear();
    stokController.clear();
    hargaSatuanController.clear();
    keteranganController.clear();
    tanggalKadaluarsa.value = '';
    selectedJenisObat.value = '';
    selectedKategori.value = '';
    selectedSatuan.value = '';
  }

  @override
  void onClose() {
    namaObatController.dispose();
    stokController.dispose();
    hargaSatuanController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}
