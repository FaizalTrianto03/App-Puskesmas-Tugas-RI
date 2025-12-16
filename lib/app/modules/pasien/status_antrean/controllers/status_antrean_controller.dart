import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/snackbar_helper.dart';

class StatusAntreanController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();

  final antrianData = Rxn<AntrianModel>();
  final userProfile = Rxn<UserProfileModel>();
  final queuePosition = 0.obs;
  final estimatedTime = ''.obs;
  final isLoading = false.obs;
  
  StreamSubscription? _antrianSubscription;
  Timer? _positionTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _watchAntrianData();
    _startPositionUpdate();
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      userProfile.value = profile;
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  @override
  void onClose() {
    _antrianSubscription?.cancel();
    _positionTimer?.cancel();
    super.onClose();
  }

  void _watchAntrianData() {
    // Real-time listener untuk antrian aktif
    _antrianSubscription = _antrianService.watchActiveAntrian().listen(
      (antrian) {
        if (antrian == null) {
          SnackbarHelper.showInfo('Tidak ada antrian aktif');
          Get.offAllNamed(Routes.pasienDashboard);
          return;
        }

        final oldStatus = antrianData.value?.status;
        antrianData.value = antrian;
        
        // Update posisi antrian
        _updateQueuePosition();
        
        // Show notification jika status berubah
        if (oldStatus != null && oldStatus != antrian.status) {
          _showStatusNotification(antrian.status);
        }
      },
      onError: (error) {
        print('Error watching antrian: $error');
        SnackbarHelper.showError('Gagal memuat data antrian');
      },
    );
  }

  void _startPositionUpdate() {
    // Update posisi antrian setiap 30 detik
    _positionTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _updateQueuePosition();
    });
  }

  Future<void> _updateQueuePosition() async {
    if (antrianData.value == null) return;

    try {
      final position = await _antrianService.getQueuePosition(
        antrianData.value!.queueNumber,
        antrianData.value!.jenisLayanan,
      );
      
      queuePosition.value = position;

      if (position > 0) {
        final minutes = position * 15;
        estimatedTime.value = '$minutes menit';
      } else {
        estimatedTime.value = 'Segera dipanggil';
      }
    } catch (e) {
      print('Error updating queue position: $e');
    }
  }

  Future<void> refreshData() async {
    // Manual refresh
    await _updateQueuePosition();
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
    final status = antrianData.value?.status ?? '';
    switch (status) {
      case 'menunggu':
        return 'Menunggu Dipanggil';
      case 'dipanggil':
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
    final status = antrianData.value?.status ?? '';
    switch (status) {
      case 'menunggu':
        return 'orange';
      case 'dipanggil':
        return 'blue';
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

    try {
      final antrianId = antrianData.value!.id;
      if (antrianId != null) {
        await _antrianService.cancelAntrian(antrianId);
        SnackbarHelper.showSuccess('Antrian berhasil dibatalkan');
        Future.delayed(Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.pasienDashboard);
        });
      } else {
        SnackbarHelper.showError('ID antrian tidak ditemukan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal membatalkan antrian');
      print('Error canceling antrian: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void kembaliKeDashboard() {
    Get.offAllNamed(Routes.pasienDashboard);
  }
}
