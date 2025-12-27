import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LokasiPuskesmasController extends GetxController {
  // Koordinat Puskesmas Dau berdasarkan OpenStreetMap link yang diberikan
  final LatLng puskesmasLocation = const LatLng(-7.913862, 112.585557);

  // Informasi lokasi
  final String namaPuskesmas = 'Puskesmas Dau';
  final String alamatLengkap = 'Jl. Raya Sengkaling No.212, Sengkaling, Mulyoagung, Kec. Dau, Kabupaten Malang, Jawa Timur 65151';
  final String telepon = '(0341) 462123';
  final String email = 'puskesmasdau212@gmail.com';
  final String website = 'puskesmasdau.malangkab.go.id';

  Future<void> openInGoogleMaps() async {
    // Gunakan URL Google Maps dengan pencarian spesifik untuk Puskesmas Dau
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=Puskesmas+Dau+Malang+Jawa+Timur';

    try {
      final Uri uri = Uri.parse(googleMapsUrl);
      // Coba buka dengan mode external application dulu
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        // Jika gagal, coba dengan koordinat langsung
        final String fallbackUrl = 'https://www.google.com/maps?q=-7.913862,112.585557&label=Puskesmas+Dau';
        final Uri fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (fallbackError) {
        // Jika masih gagal, tampilkan pesan dengan link untuk copy
        Get.snackbar(
          'Tidak dapat membuka Google Maps',
          'Silakan copy link berikut dan buka di browser:\nhttps://www.google.com/maps/search/?api=1&query=Puskesmas+Dau+Malang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF4242),
          colorText: Colors.white,
          duration: const Duration(seconds: 8),
        );
      }
    }
  }

  Future<void> openPhone() async {
    final String cleanPhone = telepon.replaceAll(RegExp(r'[^\d+]'), '');
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
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
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
