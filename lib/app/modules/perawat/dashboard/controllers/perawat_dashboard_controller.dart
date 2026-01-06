import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../rekam_medis/views/form_rekam_medis_view.dart';
import '../../detail_pemeriksaan/views/detail_pemeriksaan_view.dart';

class PerawatDashboardController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription? _antrianSubscription;

  final userId = ''.obs;
  final userName = ''.obs;
  final userRole = ''.obs;
  final antrianList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  
  // Search & Filter
  final searchQuery = ''.obs;
  final selectedFilter = 'semua'.obs; // semua, menunggu_verifikasi, terverifikasi

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadAntrian();
    // Start listening to real-time updates
    _startAntrianListener();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data setiap kali view siap ditampilkan
    forceReloadAntrian();
  }

  @override
  void onClose() {
    _antrianSubscription?.cancel();
    super.onClose();
  }

  /// Force reload - cancel stream lama dan mulai baru
  Future<void> forceReloadAntrian() async {
    // Cancel stream lama
    await _antrianSubscription?.cancel();
    _antrianSubscription = null;
    
    // Load data fresh
    await loadAntrian();
    
    // Restart stream
    _startAntrianListener();
  }

  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
    
    if (userData != null) {
      userId.value = userData['uid'] ?? '';
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
    }
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'perawat':
        return 'Perawat';
      default:
        return role;
    }
  }

  void _startAntrianListener() {
    // Subscribe to real-time updates menggunakan stream
    _antrianSubscription?.cancel();
    
    _antrianSubscription = _antrianService.watchAllAntrianToday().listen(
      (data) {
        antrianList.value = data;
        isLoading.value = false;
      },
      onError: (error) {
        SnackbarHelper.showError('Gagal memuat data antrian');
        isLoading.value = false;
      },
    );
  }

  Future<void> loadAntrian() async {
    isLoading.value = true;
    
    try {
      List<Map<String, dynamic>> data = await _antrianService.getAllAntrianToday();
      antrianList.value = data;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data antrian');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered list berdasarkan search & filter
  /// SORTING: Aktif (terlama dulu) → Dibatalkan (terbaru dulu di bawah)
  List<Map<String, dynamic>> get filteredAntrianList {
    var filtered = antrianList.toList();
    
    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((antrian) {
        final nama = (antrian['namaLengkap'] ?? '').toLowerCase();
        final noAntrian = (antrian['queueNumber'] ?? '').toLowerCase();
        final noRM = (antrian['noRekamMedis'] ?? '').toLowerCase();
        return nama.contains(query) || 
               noAntrian.contains(query) || 
               noRM.contains(query);
      }).toList();
    }
    
    // Apply status filter
    if (selectedFilter.value == 'menunggu_verifikasi') {
      filtered = filtered.where((a) => 
        a['status'] == 'menunggu' || a['status'] == 'menunggu_verifikasi'
      ).toList();
    } else if (selectedFilter.value == 'terverifikasi') {
      // ✅ FIX: Tambahkan semua status yang sudah terverifikasi termasuk selesai
      filtered = filtered.where((a) => 
        a['status'] == 'menunggu_dokter' || 
        a['status'] == 'sedang_dilayani' || 
        a['status'] == 'dilayani_dokter' ||
        a['status'] == 'selesai_diperiksa' ||
        a['status'] == 'siap_ambil_obat' ||
        a['status'] == 'menunggu_apoteker' ||
        a['status'] == 'dilayani_apoteker' ||
        a['status'] == 'selesai' ||
        a['status'] == 'dipanggil'
      ).toList();
    }
    
    // SORT: Aktif (terlama dulu) → Dilewati → Selesai → Dibatalkan
    final aktif = filtered.where((a) => 
      a['status'] != 'dibatalkan' && 
      a['status'] != 'dilewati' && 
      a['status'] != 'selesai'
    ).toList();
    final dilewati = filtered.where((a) => a['status'] == 'dilewati').toList();
    final selesai = filtered.where((a) => a['status'] == 'selesai').toList();
    final dibatalkan = filtered.where((a) => a['status'] == 'dibatalkan').toList();
    
    // Sort aktif: terlama dulu (createdAt ASC)
    aktif.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return aTime.compareTo(bTime); // ASC - terlama dulu
    });
    
    // Sort dilewati: terlama dulu (createdAt ASC)
    dilewati.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return aTime.compareTo(bTime); // ASC - terlama dulu
    });
    
    // Sort dibatalkan: terbaru dulu (createdAt DESC)
    dibatalkan.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return bTime.compareTo(aTime); // DESC - terbaru dulu
    });
    
    // Sort selesai: terbaru dulu (createdAt DESC)
    selesai.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return bTime.compareTo(aTime); // DESC - terbaru dulu
    });
    
    // Gabung: aktif → dilewati → selesai → dibatalkan
    return [...aktif, ...dilewati, ...selesai, ...dibatalkan];
  }

  List<Map<String, dynamic>> get antrianMenungguVerifikasi {
    return antrianList
        .where((a) => a['status'] == 'menunggu' || a['status'] == 'menunggu_verifikasi')
        .toList();
  }

  List<Map<String, dynamic>> get antrianTerverifikasi {
    // ✅ FIX: Tambahkan status selesai ke daftar terverifikasi
    return antrianList
        .where((a) => 
          a['status'] == 'menunggu_dokter' || 
          a['status'] == 'sedang_dilayani' || 
          a['status'] == 'dilayani_dokter' ||
          a['status'] == 'selesai_diperiksa' ||
          a['status'] == 'siap_ambil_obat' ||
          a['status'] == 'menunggu_apoteker' ||
          a['status'] == 'dilayani_apoteker' ||
          a['status'] == 'selesai' ||
          a['status'] == 'dipanggil'
        )
        .toList();
  }
  
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  void clearSearch() {
    searchQuery.value = '';
  }

  int getTotalAntrianHariIni() {
    return antrianList.length;
  }

  int getMenungguVerifikasiCount() {
    return antrianMenungguVerifikasi.length;
  }

  int getTerverifikasiCount() {
    return antrianTerverifikasi.length;
  }

  void refreshData() {
    // ✅ Tidak perlu manual refresh karena sudah ada stream real-time
    // Stream akan otomatis update ketika ada perubahan data di Firestore
    // Hanya perlu trigger manual jika stream belum aktif
    if (_antrianSubscription == null || _antrianSubscription!.isPaused) {
      _startAntrianListener();
    }
  }

  void navigateToFormRekamMedis(Map<String, dynamic> antrian) {
    final status = antrian['status'] as String?;
    
    // Jika sudah diverifikasi, arahkan ke halaman readonly detail
    if (status == 'menunggu_dokter' || status == 'sedang_dilayani' || status == 'selesai') {
      Get.to(() => const DetailPemeriksaanView(), arguments: antrian);
    } else {
      // Jika belum diverifikasi, arahkan ke form input
      Get.to(() => FormRekamMedisView(pasienData: antrian));
    }
  }

  Future<void> ubahStatusAntrian({
    required String antrianId,
    required String newStatus,
    required Map<String, dynamic> antrian,
  }) async {
    // Validasi input
    if (antrianId.isEmpty) {
      SnackbarHelper.showError('ID antrian tidak valid');
      return;
    }

    // Prevent double-click
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      
      // Update status di Firestore
      await _firestore.collection('antrian').doc(antrianId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });


      // Close dialog jika ada
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show success message
      SnackbarHelper.showSuccess('Status berhasil diubah ke: ${_formatStatusText(newStatus)}');

      // Stream akan otomatis update data, tidak perlu manual refresh
      
    } catch (e) {
      
      // Close dialog jika ada
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      SnackbarHelper.showError('Gagal mengubah status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatStatusText(String status) {
    switch (status) {
      case 'menunggu':
        return 'Menunggu Verifikasi';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'menunggu_dokter':
        return 'Menunggu Dokter';
      case 'dipanggil':
        return 'Dipanggil';
      case 'sedang_dilayani':
        return 'Sedang Dilayani';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
  
  // ✅ Batalkan antrian dengan kirim notifikasi ke pasien
  // MEKANISME PEMBATALAN:
  // 1. Pasien bisa batalkan sendiri dari app pasien
  // 2. Perawat bisa batalkan jika:
  //    - Pasien tidak datang setelah dipanggil berkali-kali
  //    - Pasien tidak membawa persyaratan
  //    - Kondisi darurat/force majeure
  // 3. Alasan pembatalan WAJIB diisi (akan ditampilkan ke pasien & perawat)
  // 4. Antrian dibatalkan akan muncul di bawah list (diasingkan)
  //
  // FUTURE: Tambah fitur "Lewati Sementara" (skip) untuk pasien yang terlambat
  //         tapi masih bisa dilayani setelah antrian aktif selesai
  Future<void> batalkanAntrian({
    required String antrianId,
    required String alasan,
  }) async {
    try {
      isLoading.value = true;
      
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      
      final success = await _antrianService.batalkanAntrian(
        antrianId: antrianId,
        alasan: alasan,
        dibatalkanOleh: 'perawat',
        dibatalkanOlehNama: userName.value,
        dibatalkanOlehId: userId.value,
      );
      
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      if (success) {
        SnackbarHelper.showSuccess('Antrian berhasil dibatalkan');
        // Stream akan otomatis update data
      } else {
        SnackbarHelper.showError('Gagal membatalkan antrian');
      }
    } catch (e) {
      
      // Close dialog jika ada
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      SnackbarHelper.showError('Gagal membatalkan antrian: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Lewati antrian sementara (pasien terlambat tapi masih bisa dilayani)
  // Status 'dilewati' akan muncul setelah antrian aktif, sebelum yang dibatalkan
  Future<void> lewatiAntrian({required String antrianId}) async {
    try {
      isLoading.value = true;
      
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );


      // Get perawat info
      final userData = await AuthHelper.currentUserData;
      final perawatId = userData?['uid'] ?? '';
      final perawatNama = userData?['namaLengkap'] ?? userName.value;

      await _antrianService.updateAntrianStatus(
        antrianId: antrianId,
        newStatus: 'dilewati',
        additionalData: {
          'dilewatiAt': FieldValue.serverTimestamp(),
          'dilewatiOleh': 'perawat',
          'dilewatiOlehNama': perawatNama,
          'dilewatiOlehId': perawatId,
        },
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      SnackbarHelper.showSuccess('Antrian dilewati sementara');
    } catch (e) {
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      SnackbarHelper.showError('Gagal melewati antrian: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
