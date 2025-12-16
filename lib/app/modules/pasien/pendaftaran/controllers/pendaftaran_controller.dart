import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/antrian/antrian_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../dashboard/controllers/pasien_dashboard_controller.dart';

class PendaftaranController extends GetxController {
  final AntreanService _antreanService = Get.find<AntreanService>();
  final SessionService _sessionService = Get.find<SessionService>();

  final formKey = GlobalKey<FormState>();
  
  final jenisLayananController = TextEditingController();
  final keluhanController = TextEditingController();
  final nomorBPJSController = TextEditingController();
  
  final selectedLayanan = ''.obs;
  final useBPJS = false.obs;
  final isLoading = false.obs;
  
  final layananOptions = [
    {'value': 'Umum', 'label': 'Poli Umum', 'icon': Icons.medical_services},
    {'value': 'Gigi', 'label': 'Poli Gigi', 'icon': Icons.coronavirus},
    {'value': 'KB', 'label': 'Poli KB/KIA', 'icon': Icons.pregnant_woman},
    {'value': 'Lansia', 'label': 'Poli Lansia', 'icon': Icons.elderly},
    {'value': 'Imunisasi', 'label': 'Poli Imunisasi', 'icon': Icons.vaccines},
  ];

  @override
  void onInit() {
    super.onInit();
    _checkActiveQueue();
  }

  @override
  void onClose() {
    jenisLayananController.dispose();
    keluhanController.dispose();
    nomorBPJSController.dispose();
    super.onClose();
  }

  void _checkActiveQueue() {
    final pasienId = _sessionService.getUserId();
    if (pasienId == null) return;
    
    final activeQueue = _antreanService.getActiveAntrianByPasienId(pasienId);
    if (activeQueue != null) {
      SnackbarHelper.showWarning(
        'Anda masih memiliki antrian aktif (${activeQueue['queueNumber']})',
      );
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed(Routes.pasienDashboard);
      });
    }
  }

  void setLayanan(String layanan) {
    selectedLayanan.value = layanan;
    jenisLayananController.text = layanan;
  }

  void toggleBPJS(bool value) {
    useBPJS.value = value;
    if (!value) {
      nomorBPJSController.clear();
    }
  }

  String? validateLayanan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pilih jenis layanan';
    }
    return null;
  }

  String? validateKeluhan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Keluhan tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'Keluhan minimal 10 karakter';
    }
    return null;
  }

  String? validateBPJS(String? value) {
    if (!useBPJS.value) return null;
    
    if (value == null || value.isEmpty) {
      return 'Nomor BPJS tidak boleh kosong';
    }
    if (value.length != 13) {
      return 'Nomor BPJS harus 13 digit';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor BPJS hanya boleh angka';
    }
    return null;
  }

  Future<void> submitPendaftaran() async {
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Mohon lengkapi form dengan benar');
      return;
    }

    final pasienId = _sessionService.getUserId();
    final namaLengkap = _sessionService.getNamaLengkap();
    
    if (pasienId == null || namaLengkap == null) {
      SnackbarHelper.showError('Sesi tidak valid, silakan login kembali');
      Get.offAllNamed(Routes.pasienLogin);
      return;
    }

    final activeQueue = _antreanService.getActiveAntrianByPasienId(pasienId);
    if (activeQueue != null) {
      SnackbarHelper.showWarning(
        'Anda masih memiliki antrian aktif (${activeQueue['queueNumber']})',
      );
      return;
    }

    isLoading.value = true;

    try {
      final noRekamMedis = 'RM${pasienId.substring(1)}';
      
      final antrian = await _antreanService.createAntrian(
        pasienId: pasienId,
        namaLengkap: namaLengkap,
        noRekamMedis: noRekamMedis,
        jenisLayanan: selectedLayanan.value,
        keluhan: keluhanController.text.trim(),
        nomorBPJS: useBPJS.value ? nomorBPJSController.text.trim() : null,
      );

      isLoading.value = false;

      SnackbarHelper.showSuccess(
        'Pendaftaran Berhasil! Nomor antrian: ${antrian['queueNumber']}',
      );

      await Future.delayed(Duration(milliseconds: 500));
      
      Get.delete<PasienDashboardController>();
      
      Get.offAllNamed(Routes.pasienDashboard);
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Gagal mendaftar: ${e.toString()}');
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    jenisLayananController.clear();
    keluhanController.clear();
    nomorBPJSController.clear();
    selectedLayanan.value = '';
    useBPJS.value = false;
  }
}
