import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/pemeriksaan/pemeriksaan_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';

class FormPemeriksaanController extends GetxController {
  final PemeriksaanService _pemeriksaanService = PemeriksaanService();

  final formKey = GlobalKey<FormState>();

  // Controllers untuk form
  final diagnosaController = TextEditingController();
  final keluhanController = TextEditingController();
  final tindakanController = TextEditingController();
  final catatanController = TextEditingController();

  // Tanda Vital Controllers
  final tekananDarahController = TextEditingController();
  final suhuController = TextEditingController();
  final nadiController = TextEditingController();
  final pernapasanController = TextEditingController();

  // Obat List - observable
  final obatList = <Map<String, TextEditingController>>[].obs;
  final isLoading = false.obs;

  String? pasienId;
  String? pasienNama;
  String? pasienKeluhan;

  @override
  void onInit() {
    super.onInit();
    // Tambah 1 obat default
    tambahObat();
  }

  void initializePasienData(Map<String, dynamic> pasienData) {
    pasienId = pasienData['id'] ?? pasienData['antrian'] ?? '';
    pasienNama = pasienData['nama'] ?? '';
    pasienKeluhan = pasienData['keluhan'] ?? '';
    
    // Isi keluhan dari data pasien
    keluhanController.text = pasienKeluhan ?? '';

    // Cek apakah sudah ada pemeriksaan sebelumnya
    final existingPemeriksaan = _pemeriksaanService.getPemeriksaanByPasienId(pasienId!);
    if (existingPemeriksaan != null) {
      loadExistingData(existingPemeriksaan);
    }
  }

  void loadExistingData(Map<String, dynamic> data) {
    diagnosaController.text = data['diagnosa'] ?? '';
    keluhanController.text = data['keluhan'] ?? '';
    tindakanController.text = data['tindakan'] ?? '';
    catatanController.text = data['catatan'] ?? '';

    final tandaVital = data['tandaVital'] as Map<String, dynamic>? ?? {};
    tekananDarahController.text = tandaVital['tekananDarah'] ?? '';
    suhuController.text = tandaVital['suhu'] ?? '';
    nadiController.text = tandaVital['nadi'] ?? '';
    pernapasanController.text = tandaVital['pernapasan'] ?? '';

    // Load obat list
    obatList.clear();
    final obatData = data['obatList'] as List? ?? [];
    if (obatData.isNotEmpty) {
      for (var obat in obatData) {
        final namaController = TextEditingController(text: obat['nama']);
        final dosisController = TextEditingController(text: obat['dosis']);
        obatList.add({
          'nama': namaController,
          'dosis': dosisController,
        });
      }
    } else {
      tambahObat();
    }
  }

  void tambahObat() {
    obatList.add({
      'nama': TextEditingController(),
      'dosis': TextEditingController(),
    });
  }

  void hapusObat(int index) {
    if (obatList.length > 1) {
      obatList[index]['nama']!.dispose();
      obatList[index]['dosis']!.dispose();
      obatList.removeAt(index);
    } else {
      SnackbarHelper.showWarning('Minimal 1 obat harus ada');
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini harus diisi';
    }
    return null;
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini harus diisi';
    }
    if (double.tryParse(value) == null) {
      return 'Harus berupa angka';
    }
    return null;
  }

  void simpanHasilPemeriksaan() async {
    if (formKey.currentState?.validate() ?? false) {
      // Validasi minimal 1 obat terisi
      bool adaObat = false;
      for (var obat in obatList) {
        if (obat['nama']!.text.isNotEmpty && obat['dosis']!.text.isNotEmpty) {
          adaObat = true;
          break;
        }
      }

      if (!adaObat) {
        SnackbarHelper.showError('Minimal 1 obat harus diisi');
        return;
      }

      try {
        isLoading.value = true;

        // Get nama dokter dari session
        final userData = AuthHelper.currentUserData;
        final namaDokter = userData?['namaLengkap'] ?? 'Dokter';

        // Prepare data
        final pemeriksaanData = {
          'pasienId': pasienId,
          'pasienNama': pasienNama,
          'dokter': namaDokter,
          'diagnosa': diagnosaController.text.trim(),
          'keluhan': keluhanController.text.trim(),
          'tindakan': tindakanController.text.trim(),
          'catatan': catatanController.text.trim(),
          'tandaVital': {
            'tekananDarah': tekananDarahController.text.trim(),
            'suhu': suhuController.text.trim(),
            'nadi': nadiController.text.trim(),
            'pernapasan': pernapasanController.text.trim(),
          },
          'obatList': obatList
              .where((obat) =>
                  obat['nama']!.text.isNotEmpty &&
                  obat['dosis']!.text.isNotEmpty)
              .map((obat) => {
                    'nama': obat['nama']!.text.trim(),
                    'dosis': obat['dosis']!.text.trim(),
                  })
              .toList(),
          'timestamp': DateTime.now().toIso8601String(),
        };

        await _pemeriksaanService.savePemeriksaan(pemeriksaanData);

        SnackbarHelper.showSuccess('Hasil pemeriksaan berhasil disimpan');

        await Future.delayed(const Duration(milliseconds: 600));
        Get.back(result: true); // Return true untuk refresh dashboard
      } catch (e) {
        SnackbarHelper.showError('Gagal menyimpan: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    diagnosaController.dispose();
    keluhanController.dispose();
    tindakanController.dispose();
    catatanController.dispose();
    tekananDarahController.dispose();
    suhuController.dispose();
    nadiController.dispose();
    pernapasanController.dispose();
    for (var obat in obatList) {
      obat['nama']!.dispose();
      obat['dosis']!.dispose();
    }
    super.onClose();
  }
}
