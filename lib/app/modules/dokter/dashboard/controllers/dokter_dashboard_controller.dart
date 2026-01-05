import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../pemeriksaan/views/form_pemeriksaan_view.dart';

class DokterDashboardController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = Get.find<SessionService>();

  StreamSubscription? _antrianSubscription;

  final userName = ''.obs;
  final userRole = ''.obs;
  final dokterId = ''.obs;

  final antrianList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  final currentTabIndex = 0.obs;
  
  // Search functionality
  late final TextEditingController searchController;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadUserData();
    _startAntrianListener();
  }

  @override
  void onReady() {
    super.onReady();
    forceReloadAntrian();
  }

  @override
  void onClose() {
    _antrianSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? '';
      userRole.value = _formatRole(userData['role'] ?? '');
      dokterId.value = userData['uid'] ?? '';
    }
  }

  /// Force reload - cancel stream lama dan mulai baru
  Future<void> forceReloadAntrian() async {
    await _antrianSubscription?.cancel();
    _antrianSubscription = null;
    
    await loadAntrian();
    _startAntrianListener();
  }

  void _startAntrianListener() {
    _antrianSubscription?.cancel();

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Listen to antrian for today that are assigned to this dokter OR waiting for dokter
    _antrianSubscription = _firestore
        .collection('antrian')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        final currentDokterId = _sessionService.getFirebaseUid() ?? dokterId.value;
        
        antrianList.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).where((antrian) {
          final status = antrian['status'] ?? '';
          final antrianDokterId = antrian['dokterId'] ?? '';
          
          // Show antrian that:
          // 1. Status is menunggu_dokter (waiting for any dokter) AND assigned to this dokter
          // 2. Status is sedang_dilayani AND assigned to this dokter
          // 3. Status is selesai_diperiksa AND assigned to this dokter
          // 4. Status is siap_ambil_obat AND assigned to this dokter
          // 5. Status is selesai AND assigned to this dokter
          
          if (status == 'menunggu_dokter' && antrianDokterId == currentDokterId) {
            return true;
          }
          if (status == 'sedang_dilayani' && antrianDokterId == currentDokterId) {
            return true;
          }
          if (['selesai_diperiksa', 'siap_ambil_obat', 'selesai'].contains(status) && 
              antrianDokterId == currentDokterId) {
            return true;
          }
          return false;
        }).toList();
        
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
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final currentDokterId = _sessionService.getFirebaseUid() ?? dokterId.value;

      final snapshot = await _firestore
          .collection('antrian')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('createdAt', descending: false)
          .get();

      antrianList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).where((antrian) {
        final status = antrian['status'] ?? '';
        final antrianDokterId = antrian['dokterId'] ?? '';

        if (status == 'menunggu_dokter' && antrianDokterId == currentDokterId) {
          return true;
        }
        if (status == 'sedang_dilayani' && antrianDokterId == currentDokterId) {
          return true;
        }
        if (['selesai_diperiksa', 'siap_ambil_obat', 'selesai'].contains(status) && 
            antrianDokterId == currentDokterId) {
          return true;
        }
        return false;
      }).toList();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data antrian');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get antrianMenunggu {
    return _applySearchFilter(
      antrianList.where((a) => a['status'] == 'menunggu_dokter').toList()
    );
  }

  List<Map<String, dynamic>> get antrianSedangDilayani {
    return _applySearchFilter(
      antrianList.where((a) => a['status'] == 'sedang_dilayani').toList()
    );
  }

  List<Map<String, dynamic>> get antrianSelesai {
    return _applySearchFilter(
      antrianList.where((a) => ['selesai_diperiksa', 'siap_ambil_obat', 'selesai'].contains(a['status'])).toList()
    );
  }
  
  /// Apply search filter
  List<Map<String, dynamic>> _applySearchFilter(List<Map<String, dynamic>> list) {
    if (searchQuery.value.isEmpty) return list;
    
    final query = searchQuery.value.toLowerCase();
    return list.where((item) {
      return (item['namaLengkap']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['noRekamMedis']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['queueNumber']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['keluhan']?.toString().toLowerCase() ?? '').contains(query);
    }).toList();
  }
  
  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  Future<void> mulaiPelayanan(Map<String, dynamic> antrian) async {
    // Gunakan firebaseUid, fallback ke userId untuk backward compatibility
    final currentDokterId = _sessionService.getFirebaseUid() ?? _sessionService.getUserId();
    final dokterName = _sessionService.getNamaLengkap();

    if (currentDokterId == null || dokterName == null) {
      SnackbarHelper.showError('Sesi tidak valid, silakan login ulang');
      return;
    }

    if (antrianSedangDilayani.isNotEmpty) {
      SnackbarHelper.showWarning('Selesaikan pasien yang sedang dilayani terlebih dahulu');
      return;
    }

    isLoading.value = true;

    try {
      await _firestore.collection('antrian').doc(antrian['id']).update({
        'status': 'sedang_dilayani',
        'dokterData.dokterId': currentDokterId,
        'dokterData.dokterNama': dokterName,
        'dokterData.startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      SnackbarHelper.showSuccess('Pasien ${antrian['namaLengkap']} mulai dilayani');
    } catch (e) {
      SnackbarHelper.showError('Gagal memulai pelayanan');
    } finally {
      isLoading.value = false;
    }
  }

  int getTotalAntrianHariIni() {
    return antrianList.length;
  }

  int getAntrianMenungguCount() {
    return antrianMenunggu.length;
  }

  int getAntrianSelesaiCount() {
    return antrianSelesai.length;
  }

  void refreshData() {
    forceReloadAntrian();
  }

  void navigateToFormPemeriksaan(Map<String, dynamic> antrian) {
    Get.to(() => FormPemeriksaanView(pasienData: antrian));
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'dokter':
        return 'Dokter';
      case 'admin':
        return 'Admin';
      case 'perawat':
        return 'Perawat';
      case 'apoteker':
        return 'Apoteker';
      default:
        return 'Pasien';
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    await _sessionService.clearSession();
    isLoading.value = false;
    Get.offAllNamed(Routes.splash);
  }
}
