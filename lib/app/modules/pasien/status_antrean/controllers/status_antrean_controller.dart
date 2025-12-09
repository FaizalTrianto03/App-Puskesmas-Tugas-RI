import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/antrian/antrian_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class StatusAntreanController extends GetxController {
  final AntreanService _antreanService = Get.find<AntreanService>();
  final SessionService _sessionService = Get.find<SessionService>();

  final antrianData = Rxn<Map<String, dynamic>>();
  final queuePosition = 0.obs;
  final estimatedTime = ''.obs;
  final isLoading = false.obs;
  
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadAntrianData();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _loadAntrianData() {
    final pasienId = _sessionService.getUserId();
    if (pasienId == null) {
      SnackbarHelper.showError('Sesi tidak valid');
      Get.offAllNamed(Routes.pasienLogin);
      return;
    }

    final activeAntrian = _antreanService.getActiveAntrianByPasienId(pasienId);
    
    if (activeAntrian == null) {
      SnackbarHelper.showInfo('Tidak ada antrian aktif');
      Get.offAllNamed(Routes.pasienDashboard);
      return;
    }

    antrianData.value = activeAntrian;
    _updateQueueInfo();
  }

  void _updateQueueInfo() {
    if (antrianData.value == null) return;

    final antrianId = antrianData.value!['id'];
    final position = _antreanService.getQueuePosition(antrianId);
    queuePosition.value = position;

    if (position > 0) {
      final minutes = position * 15;
      estimatedTime.value = '$minutes menit';
    } else {
      estimatedTime.value = 'Segera dipanggil';
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      refreshData();
    });
  }

  Future<void> refreshData() async {
    final pasienId = _sessionService.getUserId();
    if (pasienId == null) return;

    final latestData = _antreanService.getActiveAntrianByPasienId(pasienId);
    
    if (latestData == null) {
      _refreshTimer?.cancel();
      SnackbarHelper.showInfo('Antrian Anda sudah selesai');
      Future.delayed(Duration(seconds: 1), () {
        Get.offAllNamed(Routes.pasienDashboard);
      });
      return;
    }

    final oldStatus = antrianData.value?['status'];
    final newStatus = latestData['status'];

    antrianData.value = latestData;
    _updateQueueInfo();

    if (oldStatus != newStatus) {
      _showStatusNotification(newStatus);
    }
  }

  void _showStatusNotification(String status) {
    switch (status) {
      case 'menunggu_dokter':
        SnackbarHelper.showSuccess('Rekam medis Anda sudah diverifikasi perawat');
        break;
      case 'sedang_dilayani':
        SnackbarHelper.showInfo('Antrian Anda sedang dilayani dokter');
        break;
      case 'selesai':
        SnackbarHelper.showSuccess('Pemeriksaan selesai, silakan ke apotek');
        break;
      case 'dibatalkan':
        SnackbarHelper.showWarning('Antrian Anda dibatalkan');
        break;
    }
  }

  String getStatusText() {
    final status = antrianData.value?['status'] ?? '';
    switch (status) {
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi Perawat';
      case 'menunggu_dokter':
        return 'Menunggu Dipanggil Dokter';
      case 'sedang_dilayani':
        return 'Sedang Dilayani';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  String getStatusColor() {
    final status = antrianData.value?['status'] ?? '';
    switch (status) {
      case 'menunggu_verifikasi':
        return 'orange';
      case 'menunggu_dokter':
        return 'blue';
      case 'sedang_dilayani':
        return 'green';
      case 'selesai':
        return 'gray';
      case 'dibatalkan':
        return 'red';
      default:
        return 'gray';
    }
  }

  Future<void> batalkanAntrian() async {
    if (antrianData.value == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Batalkan Antrian?'),
        content: Text('Apakah Anda yakin ingin membatalkan antrian ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    final antrianId = antrianData.value!['id'];
    final success = await _antreanService.batalkanAntrian(
      antrianId,
      'Dibatalkan oleh pasien',
    );

    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess('Antrian berhasil dibatalkan');
      _refreshTimer?.cancel();
      Future.delayed(Duration(milliseconds: 500), () {
        Get.offAllNamed(Routes.pasienDashboard);
      });
    } else {
      SnackbarHelper.showError('Gagal membatalkan antrian');
    }
  }

  void kembaliKeDashboard() {
    Get.offAllNamed(Routes.pasienDashboard);
  }
}
