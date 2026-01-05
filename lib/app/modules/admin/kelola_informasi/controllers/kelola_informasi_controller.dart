import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';

import '../../../../data/models/puskesmas_model.dart';
import '../../../../data/models/jam_operasional_model.dart';
import '../../../../data/services/firestore/puskesmas_firestore_service.dart';
import '../../../../data/services/firestore/jam_operasional_firestore_service.dart';
import '../../../../utils/confirmation_dialog.dart';

class KelolaInformasiController extends GetxController {
  final PuskesmasFirestoreService _service = PuskesmasFirestoreService();
  final JamOperasionalFirestoreService _jamService = JamOperasionalFirestoreService();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final puskesmasData = Rxn<PuskesmasModel>();
  final locationPermissionGranted = false.obs;

  // Form controllers (nama dihapus karena fixed "Puskesmas Dau")
  final alamatController = TextEditingController();
  final teleponController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  // Map controller for programmatic control
  final mapController = MapController();

  // Jam operasional - list of models
  final jamOperasionalList = <JamOperasionalModel>[].obs;

  // Map center for preview
  final mapCenter = Rxn<LatLng>();
  final selectedLocation = Rxn<LatLng>();
  final userCurrentLocation = Rxn<Position>();
  final isLoadingAddress = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set default map center ke Puskesmas Dau, Malang
    mapCenter.value = const LatLng(-7.9247, 112.5889);
    _requestLocationPermission();
    loadPuskesmasData();
  }

  @override
  void onClose() {
    alamatController.dispose();
    teleponController.dispose();
    emailController.dispose();
    websiteController.dispose();
    super.onClose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      locationPermissionGranted.value = status.isGranted;
      if (status.isGranted) {
        await _getUserCurrentLocation();
      }
    } catch (e) {
      locationPermissionGranted.value = false;
    }
  }

  Future<void> _getUserCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userCurrentLocation.value = position;
      
      // Update map center to user location if no data selected yet
      if (puskesmasData.value == null && selectedLocation.value == null) {
        mapCenter.value = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      // Silent fail - map center tetap di Puskesmas Dau default
    }
  }

  Future<void> loadPuskesmasData() async {
    try {
      isLoading.value = true;
      final data = await _service.getPuskesmasInfo();
      
      if (data != null) {
        puskesmasData.value = data;
        _fillFormFromData(data);
        await loadJamOperasional();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data puskesmas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _fillFormFromData(PuskesmasModel data) {
    alamatController.text = data.alamat;
    teleponController.text = data.telepon ?? '';
    emailController.text = data.email ?? '';
    websiteController.text = data.website ?? '';
    
    final location = LatLng(data.latitude, data.longitude);
    mapCenter.value = location;
    selectedLocation.value = location;
  }

  Future<void> useCurrentLocation() async {
    if (!locationPermissionGranted.value || userCurrentLocation.value == null) {
      Get.snackbar(
        'Permission Denied',
        'Izin lokasi diperlukan untuk fitur ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
      return;
    }

    final position = userCurrentLocation.value!;
    final location = LatLng(position.latitude, position.longitude);
    
    selectedLocation.value = location;
    mapCenter.value = location;
    
    // Auto-center map to user location
    mapController.move(location, 16.0);

    Get.snackbar(
      'Berhasil',
      'Lokasi saat ini berhasil digunakan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }

  void onMapTap(LatLng location) {
    selectedLocation.value = location;
    
    Get.snackbar(
      'Lokasi Dipilih',
      'Koordinat: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> addJamOperasional(JamOperasionalModel jamOperasional) async {
    try {
      // Auto-create puskesmas if not exists
      if (puskesmasData.value == null || puskesmasData.value!.id == null) {
        // Create minimal puskesmas data first
        final model = PuskesmasModel(
          nama: 'Puskesmas Dau',
          alamat: alamatController.text.trim().isEmpty ? 'Belum diatur' : alamatController.text.trim(),
          latitude: selectedLocation.value?.latitude ?? -7.9247,
          longitude: selectedLocation.value?.longitude ?? 112.5889,
          telepon: teleponController.text.trim().isEmpty ? null : teleponController.text.trim(),
          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          website: websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
          jamOperasional: {},
          createdAt: DateTime.now(),
        );
        
        final id = await _service.createPuskesmas(model);
        if (id == null) {
          throw Exception('Gagal membuat data puskesmas');
        }
        
        // Reload to get the created puskesmas
        await loadPuskesmasData();
      }

      await _jamService.addJamOperasional(
        puskesmasData.value!.id!,
        jamOperasional,
      );
      await loadJamOperasional();
      Get.snackbar(
        'Berhasil',
        'Jam operasional berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan jam operasional: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateJamOperasional(
    String id,
    JamOperasionalModel jamOperasional,
  ) async {
    if (puskesmasData.value?.id == null) return;

    try {
      await _jamService.updateJamOperasional(
        puskesmasData.value!.id!,
        id,
        jamOperasional,
      );
      await loadJamOperasional();
      Get.snackbar(
        'Berhasil',
        'Jam operasional berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui jam operasional',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeJamOperasional(String id) async {
    if (puskesmasData.value?.id == null) return;

    final confirmed = await ConfirmationDialog.show(
      title: 'Hapus Jam Operasional',
      message: 'Apakah Anda yakin ingin menghapus jam operasional ini?',
      type: ConfirmationType.danger,
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );

    if (confirmed != true) return;

    try {
      await _jamService.deleteJamOperasional(
        puskesmasData.value!.id!,
        id,
      );
      await loadJamOperasional();
      Get.snackbar(
        'Berhasil',
        'Jam operasional berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus jam operasional',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadJamOperasional() async {
    if (puskesmasData.value?.id == null) return;
    
    try {
      final jamList = await _jamService.getJamOperasional(
        puskesmasData.value!.id!,
      );
      
      // Sort berdasarkan urutan hari (Senin - Minggu)
      final hariOrder = {
        'Senin': 1,
        'Selasa': 2,
        'Rabu': 3,
        'Kamis': 4,
        'Jumat': 5,
        'Sabtu': 6,
        'Minggu': 7,
      };
      
      jamList.sort((a, b) {
        final orderA = hariOrder[a.hari] ?? 999;
        final orderB = hariOrder[b.hari] ?? 999;
        return orderA.compareTo(orderB);
      });
      
      jamOperasionalList.value = jamList;
    } catch (e) {
      jamOperasionalList.clear();
    }
  }

  Future<void> savePuskesmasData() async {
    // Validation
    if (alamatController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Alamat harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedLocation.value == null) {
      Get.snackbar(
        'Error',
        'Pilih lokasi di peta terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;

      final model = PuskesmasModel(
        id: puskesmasData.value?.id,
        nama: 'Puskesmas Dau',
        alamat: alamatController.text.trim(),
        latitude: selectedLocation.value!.latitude,
        longitude: selectedLocation.value!.longitude,
        telepon: teleponController.text.trim().isEmpty ? null : teleponController.text.trim(),
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        website: websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
        jamOperasional: {}, // Empty map - jam operasional now in subcollection
        createdAt: puskesmasData.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (puskesmasData.value != null && puskesmasData.value!.id != null) {
        // Update existing
        success = await _service.updatePuskesmas(puskesmasData.value!.id!, model);
      } else {
        // Create new
        final id = await _service.createPuskesmas(model);
        success = id != null;
      }

      if (success) {
        Get.snackbar(
          'Berhasil',
          'Data puskesmas berhasil disimpan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
        await loadPuskesmasData();
      } else {
        Get.snackbar(
          'Error',
          'Gagal menyimpan data puskesmas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF4242),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
