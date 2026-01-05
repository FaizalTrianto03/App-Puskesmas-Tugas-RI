import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/models/puskesmas_model.dart';
import '../../../../data/models/jam_operasional_model.dart';
import '../../../../data/services/firestore/puskesmas_firestore_service.dart';
import '../../../../data/services/firestore/jam_operasional_firestore_service.dart';

class LokasiPuskesmasController extends GetxController {
  final PuskesmasFirestoreService _puskesmasService = PuskesmasFirestoreService();
  final JamOperasionalFirestoreService _jamService = JamOperasionalFirestoreService();

  final isLoading = true.obs;
  final puskesmasData = Rxn<PuskesmasModel>();
  final jamOperasionalList = <JamOperasionalModel>[].obs;
  final hasError = false.obs;
  final locationPermissionGranted = false.obs;
  final userLocation = Rxn<Position>();
  final distanceInKm = Rxn<double>();

  // Getter untuk akses mudah
  LatLng? get puskesmasLocation {
    if (puskesmasData.value == null) return null;
    return LatLng(
      puskesmasData.value!.latitude,
      puskesmasData.value!.longitude,
    );
  }

  String? get namaPuskesmas => puskesmasData.value?.nama;
  String? get alamatLengkap => puskesmasData.value?.alamat;
  String? get telepon => puskesmasData.value?.telepon;
  String? get email => puskesmasData.value?.email;
  String? get website => puskesmasData.value?.website;

  @override
  void onInit() {
    super.onInit();
    loadPuskesmasInfo();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        locationPermissionGranted.value = true;
        await _getUserLocation();
        _calculateDistance();
      } else {
        locationPermissionGranted.value = false;
      }
    } catch (e) {
      locationPermissionGranted.value = false;
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation.value = position;
    } catch (e) {
      // Silent fail
    }
  }

  void _calculateDistance() {
    if (userLocation.value == null || puskesmasLocation == null) {
      distanceInKm.value = null;
      return;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      userLocation.value!.latitude,
      userLocation.value!.longitude,
      puskesmasLocation!.latitude,
      puskesmasLocation!.longitude,
    );

    distanceInKm.value = distanceInMeters / 1000;
  }

  Future<void> loadPuskesmasInfo() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final data = await _puskesmasService.getPuskesmasInfo();
      if (data != null) {
        puskesmasData.value = data;
        await _loadJamOperasional(data.id!);
        _calculateDistance();
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadJamOperasional(String puskesmasId) async {
    try {
      final jamList = await _jamService.getJamOperasional(puskesmasId);
      
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
      jamOperasionalList.value = [];
    }
  }

  Future<void> openInGoogleMaps() async {
    if (puskesmasLocation == null) {
      Get.snackbar(
        'Lokasi Belum Diatur',
        'Admin belum mengatur lokasi puskesmas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
      return;
    }

    try {
      String googleMapsUrl;
      
      // Jika ada permission dan user location, buka dengan directions
      if (locationPermissionGranted.value && userLocation.value != null) {
        // URL untuk directions dari lokasi user ke puskesmas
        googleMapsUrl = 'https://www.google.com/maps/dir/?api=1'
            '&origin=${userLocation.value!.latitude},${userLocation.value!.longitude}'
            '&destination=${puskesmasLocation!.latitude},${puskesmasLocation!.longitude}'
            '&travelmode=driving';
      } else {
        // Jika tidak ada permission, hanya tampilkan lokasi puskesmas
        googleMapsUrl = 'https://www.google.com/maps/search/?api=1'
            '&query=${puskesmasLocation!.latitude},${puskesmasLocation!.longitude}';
      }

      final Uri uri = Uri.parse(googleMapsUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka Google Maps',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
      );
    }
  }

  Future<void> openPhone() async {
    if (telepon == null) return;
    final String cleanPhone = telepon!.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka aplikasi telepon',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> openEmail() async {
    if (email == null) return;
    final Uri emailUri = Uri(scheme: 'mailto', path: email!);
    try {
      await launchUrl(emailUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka aplikasi email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> openWebsite() async {
    if (website == null) return;
    final Uri websiteUri = Uri.parse('https://$website');
    try {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka browser web',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4242),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
