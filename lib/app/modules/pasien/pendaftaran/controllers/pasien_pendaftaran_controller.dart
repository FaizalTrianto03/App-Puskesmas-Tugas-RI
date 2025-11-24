import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasienPendaftaranController extends GetxController {
  final poliController = TextEditingController();
  final keluhanController = TextEditingController();
  
  var selectedPoli = ''.obs;
  var selectedJenisBPJS = ''.obs;

  @override
  void onClose() {
    poliController.dispose();
    keluhanController.dispose();
    super.onClose();
  }

  void setSelectedPoli(String poli) {
    selectedPoli.value = poli;
    poliController.text = poli;
  }

  void setJenisBPJS(String jenis) {
    selectedJenisBPJS.value = jenis;
  }

  void daftarAntrean() {
    if (selectedPoli.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan pilih poli tujuan',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (keluhanController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan isi keluhan Anda',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (selectedJenisBPJS.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan pilih jenis pembayaran',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Simulasi daftar berhasil
    Get.snackbar(
      'Berhasil',
      'Pendaftaran antrean berhasil!',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }
}
