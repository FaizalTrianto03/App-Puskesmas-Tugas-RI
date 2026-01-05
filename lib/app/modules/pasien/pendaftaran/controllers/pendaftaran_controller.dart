import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/poli_firestore_service.dart';
import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../data/services/firestore/jam_operasional_firestore_service.dart';
import '../../../../data/services/firestore/puskesmas_firestore_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../dashboard/controllers/pasien_dashboard_controller.dart';

class PendaftaranController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  final PoliFirestoreService _poliService = PoliFirestoreService();
  final JamOperasionalFirestoreService _jamOperasionalService = JamOperasionalFirestoreService();
  final PuskesmasFirestoreService _puskesmasService = PuskesmasFirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  
  final jenisLayananController = TextEditingController();
  final keluhanController = TextEditingController();
  final nomorBPJSController = TextEditingController();
  
  final selectedLayanan = ''.obs;
  final useBPJS = false.obs;
  final isLoading = false.obs;
  final isLoadingPoli = true.obs;
  final hasActiveQueue = false.obs;
  final activeQueueNumber = ''.obs;
  
  // Estimasi waktu
  final estimatedTime = Rx<DateTime?>(null);
  final queueCount = 0.obs;
  Timer? _estimationTimer;
  
  // Poli dari Firestore
  final poliList = <Map<String, dynamic>>[].obs;
  final layananOptions = <Map<String, dynamic>>[].obs;
  
  // User profile
  final userProfile = Rxn<dynamic>();
  final isLoadingProfile = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPoliFromFirestore();
    _loadUserProfile();
    _checkActiveQueue();
  }
  
  @override
  void onReady() {
    super.onReady();
    _checkActiveQueue();
    // Reload profile saat halaman siap (untuk refresh data setelah edit)
    _loadUserProfile();
  }
  
  // Calculate estimation for first poli without selecting
  Future<void> _calculateDefaultEstimation() async {
    if (layananOptions.isEmpty) return;
    
    final firstPoliData = layananOptions.first;
    final firstPoliNama = firstPoliData['value'] as String? ?? '';
    
    try {
      // Get count from antrian collection
      final count = await _antrianService.getTodayQueueCountByPoli(firstPoliNama);
      queueCount.value = count;
      
      const minutesPerPatient = 15;
      final totalMinutes = (count + 1) * minutesPerPatient;
      
      final now = DateTime.now();
      estimatedTime.value = now.add(Duration(minutes: totalMinutes));
    } catch (e) {
      estimatedTime.value = null;
      queueCount.value = 0;
    }
  }
  
  Future<void> _loadUserProfile() async {
    isLoadingProfile.value = true;
    try {
      final profile = await _profileService.getUserProfile();
      userProfile.value = profile;
      isLoadingProfile.value = false;
    } catch (e) {
      isLoadingProfile.value = false;
    }
  }
  
  // Public method untuk refresh profile dari view
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  @override
  void onClose() {
    _estimationTimer?.cancel();
    jenisLayananController.dispose();
    keluhanController.dispose();
    nomorBPJSController.dispose();
    super.onClose();
  }

  // Load poli dari Firestore
  Future<void> _loadPoliFromFirestore() async {
    isLoadingPoli.value = true;
    try {
      final allPoli = await _poliService.getAllPoli();
      
      if (allPoli.isEmpty) {
        SnackbarHelper.showError('Tidak ada poli tersedia saat ini. Silakan hubungi admin.');
        layananOptions.value = [];
        poliList.value = [];
        isLoadingPoli.value = false;
        return;
      }
      
      // Convert to layanan options format
      layananOptions.value = allPoli.map((poli) {
        final namaPoli = poli['namaPoli'] as String? ?? 'Poli';
        final kodePoli = poli['kodePoli'] as String? ?? 'XXX';
        IconData icon = Icons.medical_services;
        
        // Map icon berdasarkan nama poli
        if (namaPoli.toLowerCase().contains('gigi')) {
          icon = Icons.coronavirus;
        } else if (namaPoli.toLowerCase().contains('kia') || 
                   namaPoli.toLowerCase().contains('kb')) {
          icon = Icons.pregnant_woman;
        } else if (namaPoli.toLowerCase().contains('lansia')) {
          icon = Icons.elderly;
        } else if (namaPoli.toLowerCase().contains('imunisasi')) {
          icon = Icons.vaccines;
        }
        
        return {
          'value': namaPoli,
          'label': namaPoli,
          'icon': icon,
          'kodePoli': kodePoli,
          'deskripsi': poli['deskripsi'],
        };
      }).toList();
      
      poliList.value = allPoli;
      
      // Auto-calculate estimation immediately after poli loaded
      if (layananOptions.isNotEmpty) {
        _calculateDefaultEstimation();
      }
    } catch (e) {
      // Kasih tau user terjadi error
      SnackbarHelper.showError('Gagal memuat data poli: ${e.toString()}');
      layananOptions.value = [];
      poliList.value = [];
    } finally {
      isLoadingPoli.value = false;
    }
  }

  // Check active queue
  void _checkActiveQueue() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }
    
    isLoading.value = true;
    
    try {
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (activeAntrian != null) {
        hasActiveQueue.value = true;
        activeQueueNumber.value = activeAntrian.queueNumber;
        
        SnackbarHelper.showError(
          'TIDAK BISA DAFTAR! Anda masih memiliki antrian aktif: ${activeAntrian.queueNumber}',
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          Get.back(result: false);
        });
      } else {
        hasActiveQueue.value = false;
        activeQueueNumber.value = '';
      }
    } catch (e) {
      hasActiveQueue.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void setLayanan(String layanan) {
    selectedLayanan.value = layanan;
    jenisLayananController.text = layanan;
    
    // Update estimasi waktu saat poli dipilih
    _updateEstimation();
    
    // Setup timer untuk update estimasi setiap 30 detik
    _estimationTimer?.cancel();
    _estimationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateEstimation();
    });
  }

  // Update estimasi waktu tunggu secara real-time
  Future<void> _updateEstimation() async {
    if (selectedLayanan.value.isEmpty) {
      estimatedTime.value = null;
      queueCount.value = 0;
      return;
    }

    try {
      // Get count from antrian collection
      final count = await _antrianService.getTodayQueueCountByPoli(selectedLayanan.value);
      queueCount.value = count;
      
      const minutesPerPatient = 15;
      final totalMinutes = (count + 1) * minutesPerPatient;
      
      final now = DateTime.now();
      estimatedTime.value = now.add(Duration(minutes: totalMinutes));
    } catch (e) {
      estimatedTime.value = null;
      queueCount.value = 0;
    }
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
    if (hasActiveQueue.value) {
      await ConfirmationDialog.show(
        title: 'Tidak Bisa Mendaftar',
        message:
            'Anda masih memiliki antrian aktif: ${activeQueueNumber.value}. Selesaikan atau batalkan antrian tersebut sebelum mendaftar lagi.',
        type: ConfirmationType.warning,
        confirmText: 'Mengerti',
      );
      return;
    }

    // Check jam operasional terlebih dahulu
    final operatingHoursCheck = await _checkOperatingHours();
    if (!operatingHoursCheck['isOpen']) {
      await ConfirmationDialog.show(
        title: 'Puskesmas Tutup',
        message: operatingHoursCheck['message'],
        type: ConfirmationType.warning,
        confirmText: 'Mengerti',
      );
      return;
    }
    
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Mohon lengkapi form dengan benar');
      return;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      SnackbarHelper.showError('Sesi tidak valid, silakan login kembali');
      Get.offAllNamed(Routes.pasienLogin);
      return;
    }

    isLoading.value = true;

    try {
      final profile = await _profileService.getUserProfile();
      if (profile == null) {
        throw Exception('Profile tidak ditemukan');
      }

      // CRITICAL: Check lagi sebelum create (prevent race condition)
      final activeAntrian = await _antrianService.getActiveAntrian();
      
      if (activeAntrian != null) {
        isLoading.value = false;
        hasActiveQueue.value = true;
        activeQueueNumber.value = activeAntrian.queueNumber;
        
        SnackbarHelper.showError(
          'TIDAK BISA DAFTAR! Anda masih memiliki antrian aktif: ${activeAntrian.queueNumber}',
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          Get.back(result: false);
        });
        return;
      }

      // Create antrian (nomor antrian akan di-generate otomatis)
      final newAntrian = await _antrianService.createAntrian(
        namaLengkap: profile.namaLengkap,
        noRekamMedis: profile.noRekamMedis ?? 'RM-${userId.substring(0, 8)}',
        jenisLayanan: selectedLayanan.value,
        keluhan: keluhanController.text.trim(),
        nomorBPJS: useBPJS.value ? nomorBPJSController.text.trim() : null,
        tanggalLahir: profile.tanggalLahir,
        email: profile.email,
      );
      
      isLoading.value = false;

      try {
        final dashboardController = Get.find<PasienDashboardController>();
        dashboardController.hasActiveQueue.value = true;
        dashboardController.queueNumber.value = newAntrian.queueNumber;
      } catch (e) {
        // Dashboard controller belum ada, akan dibuat nanti
      }

      try {
        final dashboardController = Get.find<PasienDashboardController>();
        dashboardController.hasActiveQueue.value = true;
        dashboardController.queueNumber.value = newAntrian.queueNumber;
        await dashboardController.checkActiveQueue();
      } catch (e) {
        // Ignore
      }

      Get.back(result: true);
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      SnackbarHelper.showSuccess(
        'Pendaftaran Berhasil! Nomor Antrian: ${newAntrian.queueNumber}',
      );
      
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('Gagal mendaftar: ${e.toString()}');
    }
  }

  // Check jam operasional puskesmas
  Future<Map<String, dynamic>> _checkOperatingHours() async {
    try {
      // Get puskesmas data
      final puskesmasData = await _puskesmasService.getPuskesmasInfo();
      if (puskesmasData == null || puskesmasData.id == null) {
        return {
          'isOpen': false,
          'message': 'Data puskesmas belum tersedia. Silakan hubungi admin.',
        };
      }

      // Get today's day name in Indonesian
      final now = DateTime.now();
      final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final hariIni = hariList[now.weekday - 1];

      // Get jam operasional for today
      final jamOperasionalList = await _jamOperasionalService.getJamOperasional(puskesmasData.id!);
      final jadwalHariIni = jamOperasionalList.firstWhereOrNull(
        (jam) => jam.hari.toLowerCase() == hariIni.toLowerCase(),
      );

      // Check if schedule exists for today
      if (jadwalHariIni == null) {
        return {
          'isOpen': false,
          'message': 'Jadwal untuk hari $hariIni belum tersedia. Silakan hubungi puskesmas atau coba di hari lain.',
        };
      }

      // Check if puskesmas is closed today
      if (!jadwalHariIni.isBuka || jadwalHariIni.jamBuka.isEmpty || jadwalHariIni.jamTutup.isEmpty) {
        return {
          'isOpen': false,
          'message': 'Puskesmas tutup pada hari $hariIni.',
        };
      }

      // Parse jam buka dan jam tutup
      final jamBukaParts = jadwalHariIni.jamBuka.split(':');
      final jamTutupParts = jadwalHariIni.jamTutup.split(':');

      if (jamBukaParts.length != 2 || jamTutupParts.length != 2) {
        return {
          'isOpen': false,
          'message': 'Format jam operasional tidak valid. Silakan hubungi admin.',
        };
      }

      final jamBuka = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(jamBukaParts[0]),
        int.parse(jamBukaParts[1]),
      );

      final jamTutup = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(jamTutupParts[0]),
        int.parse(jamTutupParts[1]),
      );

      // Calculate batas pendaftaran (1 jam sebelum tutup)
      final batasPendaftaran = jamTutup.subtract(const Duration(hours: 1));

      // Format jam untuk message
      final formatJam = DateFormat('HH:mm');
      final jamBukaStr = formatJam.format(jamBuka);
      final jamTutupStr = formatJam.format(jamTutup);
      final batasPendaftaranStr = formatJam.format(batasPendaftaran);

      // Check if current time is before opening
      if (now.isBefore(jamBuka)) {
        return {
          'isOpen': false,
          'message': 'Puskesmas belum buka. Jam operasional: $jamBukaStr - $jamTutupStr WIB.\nSilakan datang kembali saat puskesmas sudah buka.',
        };
      }

      // Check if current time is after closing
      if (now.isAfter(jamTutup)) {
        return {
          'isOpen': false,
          'message': 'Puskesmas sudah tutup. Jam operasional: $jamBukaStr - $jamTutupStr WIB.\nSilakan datang kembali besok.',
        };
      }

      // Check if current time is within 1 hour before closing
      if (now.isAfter(batasPendaftaran)) {
        return {
          'isOpen': false,
          'message': 'Pendaftaran sudah ditutup.\n\nJam operasional: $jamBukaStr - $jamTutupStr WIB\nBatas pendaftaran terakhir: $batasPendaftaranStr WIB\n\nSilakan datang lebih awal besok.',
        };
      }

      // Puskesmas is open and registration is still accepted
      return {
        'isOpen': true,
        'message': 'Puskesmas buka',
      };

    } catch (e) {
      // Handle error gracefully
      return {
        'isOpen': false,
        'message': 'Gagal memeriksa jam operasional: ${e.toString()}\nSilakan hubungi admin atau coba lagi.',
      };
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
