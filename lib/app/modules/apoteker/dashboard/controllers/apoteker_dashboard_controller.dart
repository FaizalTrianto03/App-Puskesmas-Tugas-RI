import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/obat_firestore_service.dart';
import '../../../../utils/auth_helper.dart';
import '../../settings/views/apoteker_settings_view.dart' as apoteker_settings;
import '../../resep_obat/views/resep_obat_view.dart';
import '../../resep_obat/bindings/resep_obat_binding.dart';

class ApotekerDashboardController extends GetxController {
  // Services
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final ObatFirestoreService _obatService = ObatFirestoreService();

  // Observable states
  final userName = ''.obs;
  final userRole = ''.obs;
  final isLoading = false.obs;
  
  // User ID untuk filter
  String? _apotekerId;

  // Statistik resep observables
  final totalResep = 0.obs;
  final resepMenunggu = 0.obs;
  final resepSiapDiambil = 0.obs;
  final resepSelesai = 0.obs;

  // Statistik stok obat observables
  final totalObat = 0.obs;
  final stokAman = 0.obs;
  final stokHampirHabis = 0.obs;
  final stokKritis = 0.obs;
  final stokHabis = 0.obs;
  final obatKadaluarsa = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadStatistik();
  }

  /// Load user data from AuthHelper
  Future<void> loadUserData() async {
    try {
      final userData = await AuthHelper.currentUserData;
      if (userData != null) {
        userName.value = userData['namaLengkap'] as String? ?? 'Apoteker';
        userRole.value = userData['role'] as String? ?? 'apoteker';
        _apotekerId = userData['id'] as String?;
      } else {
        userName.value = 'Apoteker';
        userRole.value = 'apoteker';
      }
    } catch (e) {
      userName.value = 'Apoteker';
      userRole.value = 'apoteker';
    }
  }

  /// Load statistik resep dan stok obat
  Future<void> loadStatistik() async {
    isLoading.value = true;

    try {
      // Pastikan userData sudah ter-load untuk mendapatkan apotekerId
      if (_apotekerId == null) {
        final userData = await AuthHelper.currentUserData;
        _apotekerId = userData?['id'] as String?;
      }
      
      await Future.wait([
        _loadStatistikResep(),
        _loadStatistikStok(),
      ]);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Load statistik resep - COPY LOGIC dari resep_obat_controller
  Future<void> _loadStatistikResep() async {
    try {
      // Get today's date range
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      // Get antrian menunggu (status: selesai_diperiksa)
      final menunggu = await _antrianService.getAntrianUntukApoteker();
      
      // Get semua antrian
      final allAntrian = await _antrianService.getAllAntrian();
      
      // Filter selesai (siap_ambil_obat + selesai) yang disiapkan oleh apoteker ini
      final selesaiList = allAntrian
          .map((data) => AntrianModel.fromMap(data))
          .where((a) {
            final hasResep = a.adaResepObat;
            final statusOk = a.status == 'siap_ambil_obat' || a.status == 'selesai';
            final sudahDisiapkan = a.sudahDisiapkanApoteker;
            final apotekerIdMatch = a.apotekerData?['apotekerId'] == _apotekerId;
            
            // Filter by date (hari ini)
            final dateOk = a.createdAt.isAfter(startOfDay) || 
                           a.createdAt.isAtSameMomentAs(startOfDay);
            
            return hasResep && statusOk && sudahDisiapkan && apotekerIdMatch && dateOk;
          })
          .toList();
      
      // Hitung siap diambil dan selesai
      final siapDiambil = selesaiList.where((a) => a.status == 'siap_ambil_obat').length;
      final selesai = selesaiList.where((a) => a.status == 'selesai').length;
      
      // Update values
      totalResep.value = menunggu.length + selesaiList.length;
      resepMenunggu.value = menunggu.length;
      resepSiapDiambil.value = siapDiambil;
      // Selesai = siap_ambil_obat + selesai (sama seperti tab Selesai di resep obat)
      resepSelesai.value = selesaiList.length;
    } catch (e) {
      _resetResepStats();
    }
  }

  /// Load statistik stok obat
  Future<void> _loadStatistikStok() async {
    try {
      final stokStats = await _obatService.getStatistikStok();
      totalObat.value = stokStats['total'] ?? 0;
      stokAman.value = stokStats['aman'] ?? 0;
      stokHampirHabis.value = stokStats['hampirHabis'] ?? 0;
      stokKritis.value = stokStats['kritis'] ?? 0;
      stokHabis.value = stokStats['habis'] ?? 0;
      obatKadaluarsa.value = stokStats['kadaluarsa'] ?? 0;
    } catch (e) {
      _resetStokStats();
    }
  }

  /// Reset resep statistics to zero
  void _resetResepStats() {
    totalResep.value = 0;
    resepMenunggu.value = 0;
    resepSiapDiambil.value = 0;
    resepSelesai.value = 0;
  }

  /// Reset stok statistics to zero
  void _resetStokStats() {
    totalObat.value = 0;
    stokAman.value = 0;
    stokHampirHabis.value = 0;
    stokKritis.value = 0;
    stokHabis.value = 0;
    obatKadaluarsa.value = 0;
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadStatistik();
  }

  /// Check if there are critical alerts
  bool get hasCriticalAlerts => stokKritis.value > 0 || stokHabis.value > 0;

  /// Check if there are warning alerts
  bool get hasWarningAlerts => stokHampirHabis.value > 0;

  /// Check if there are any alerts
  bool get hasAnyAlerts => hasCriticalAlerts || hasWarningAlerts;

  /// Get total critical items (kritis + habis)
  int get totalCriticalItems => stokKritis.value + stokHabis.value;

  /// Get alert message for critical items
  String getCriticalAlertMessage() {
    final habis = stokHabis.value;
    final kritis = stokKritis.value;
    final total = totalCriticalItems;

    if (habis > 0 && kritis > 0) {
      return '$total obat habis/kritis dan perlu segera direstock';
    } else if (habis > 0) {
      return '$habis obat habis dan perlu segera direstock';
    } else if (kritis > 0) {
      return '$kritis obat kritis dan perlu segera direstock';
    }
    return '';
  }

  /// Get alert message for warning items
  String getWarningAlertMessage() {
    return '${stokHampirHabis.value} obat hampir habis';
  }

  /// Get stat card color based on label
  Color getStatCardColor(String label) {
    switch (label.toLowerCase()) {
      case 'total':
        return const Color(0xFF02B1BA);
      case 'menunggu':
        return const Color(0xFFFF9800);
      case 'selesai':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  /// Get stok card colors
  Map<String, Color> getStokCardColors(String label) {
    switch (label.toLowerCase()) {
      case 'stok aman':
        return {
          'color': const Color(0xFF4CAF50),
          'backgroundColor': const Color(0xFFE8F5E9),
        };
      case 'hampir habis':
        return {
          'color': const Color(0xFF9C27B0),
          'backgroundColor': const Color(0xFFF3E5F5),
        };
      case 'stok kritis':
        return {
          'color': const Color(0xFFFF4242),
          'backgroundColor': const Color(0xFFFFEBEE),
        };
      case 'stok habis':
        return {
          'color': const Color(0xFFFF9800),
          'backgroundColor': const Color(0xFFFFF3E0),
        };
      default:
        return {
          'color': Colors.grey,
          'backgroundColor': Colors.grey.shade100,
        };
    }
  }

  /// Navigation methods
  void navigateToSettings() {
    Get.to(() => const apoteker_settings.ApotekerSettingsView());
  }

  void navigateToResepObat() {
    ResepObatBinding().dependencies();
    Get.to(() => const ResepObatView());
  }

  void navigateToStokObat() {
    Get.toNamed('/apoteker/stok-obat');
  }

  void navigateToPeringatanObat() {
    Get.toNamed('/apoteker/peringatan-obat');
  }

  /// Menu items configuration
  List<Map<String, dynamic>> getMenuItems() {
    return [
      {
        'icon': Icons.medication,
        'title': 'Resep Obat',
        'subtitle': 'Kelola resep masuk',
        'color': const Color(0xFF02B1BA),
        'onTap': navigateToResepObat,
      },
      {
        'icon': Icons.inventory_2,
        'title': 'Stok Obat',
        'subtitle': 'Manajemen persediaan',
        'color': const Color(0xFF4CAF50),
        'onTap': navigateToStokObat,
      },
    ];
  }

  /// Get stok status data
  List<Map<String, dynamic>> getStokStatusData() {
    return [
      {
        'value': stokAman.value.toString(),
        'label': 'Stok Aman',
        'color': const Color(0xFF4CAF50),
        'backgroundColor': const Color(0xFFE8F5E9),
      },
      {
        'value': stokHampirHabis.value.toString(),
        'label': 'Hampir Habis',
        'color': const Color(0xFF9C27B0),
        'backgroundColor': const Color(0xFFF3E5F5),
      },
      {
        'value': stokKritis.value.toString(),
        'label': 'Stok Kritis',
        'color': const Color(0xFFFF4242),
        'backgroundColor': const Color(0xFFFFEBEE),
      },
      {
        'value': stokHabis.value.toString(),
        'label': 'Stok Habis',
        'color': const Color(0xFFFF9800),
        'backgroundColor': const Color(0xFFFFF3E0),
      },
      {
        'value': obatKadaluarsa.value.toString(),
        'label': 'Kadaluarsa',
        'color': const Color(0xFFE91E63),
        'backgroundColor': const Color(0xFFFCE4EC),
      },
      {
        'value': totalObat.value.toString(),
        'label': 'Total Obat',
        'color': const Color(0xFF02B1BA),
        'backgroundColor': const Color(0xFFE0F7FA),
      },
    ];
  }
}
