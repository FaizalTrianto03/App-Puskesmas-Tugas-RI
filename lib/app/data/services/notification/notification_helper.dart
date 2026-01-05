import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/notifikasi_model.dart';

/// Helper class for notification-related operations
class NotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Get notification icon based on type
  static IconData getIconForType(String type) {
    switch (type) {
      case 'Antrian':
        return Icons.people;
      case 'Obat':
      case 'Pengingat Obat':
        return Icons.medication;
      case 'Jadwal Kontrol':
        return Icons.event_note;
      case 'Info Puskesmas':
        return Icons.info;
      case 'Resep':
        return Icons.receipt_long;
      case 'Stok Obat':
        return Icons.inventory;
      case 'Laporan':
        return Icons.analytics;
      case 'Pengguna':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }
  
  /// Get notification color based on type
  static Color getColorForType(String type) {
    switch (type) {
      case 'Antrian':
        return const Color(0xFF02B1BA);
      case 'Obat':
      case 'Pengingat Obat':
        return const Color(0xFFFF4242);
      case 'Jadwal Kontrol':
        return const Color(0xFF4CAF50);
      case 'Info Puskesmas':
        return const Color(0xFF02B1BA);
      case 'Resep':
        return const Color(0xFF9C27B0);
      case 'Stok Obat':
        return const Color(0xFFFF9800);
      case 'Laporan':
        return const Color(0xFF02B1BA);
      case 'Pengguna':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF02B1BA);
    }
  }
  
  /// Get relative time string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    } else {
      return '${(difference.inDays / 365).floor()} tahun yang lalu';
    }
  }
  
  /// Check if user has notification subscription enabled
  static Future<bool> isSubscriptionEnabled() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['notificationSubscription'] != false;
    } catch (e) {
      return true; // Default enabled
    }
  }
  
  /// Update notification subscription status
  static Future<void> updateSubscriptionStatus(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _firestore.collection('users').doc(user.uid).update({
      'notificationSubscription': enabled,
    });
  }
  
  /// Get filter options for role
  static List<String> getFilterOptionsForRole(String role) {
    switch (role) {
      case 'admin':
        return ['Semua', 'Laporan', 'Pengguna', 'Stok Obat'];
      case 'dokter':
        return ['Semua', 'Antrian', 'Rekam Medis', 'Resep'];
      case 'perawat':
        return ['Semua', 'Antrian', 'Pemeriksaan'];
      case 'apoteker':
        return ['Semua', 'Resep', 'Stok Obat'];
      case 'pasien':
      default:
        return ['Semua', 'Antrian', 'Obat', 'Info Puskesmas'];
    }
  }
  
  /// Create a local notification model from data
  static NotifikasiModel createNotificationModel({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    return NotifikasiModel(
      userId: userId,
      type: type,
      title: title,
      message: message,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }
  
  /// Get notification title based on antrian status
  static String getTitleForAntrianStatus(String status) {
    switch (status) {
      case 'pending':
      case 'menunggu':
        return 'Pendaftaran Berhasil! 🎉';
      case 'pemeriksaan_perawat':
        return 'Giliran Anda! 🏥';
      case 'menunggu_dokter':
        return 'Pemeriksaan Awal Selesai ✅';
      case 'pemeriksaan_dokter':
        return 'Pemeriksaan Dokter 👨‍⚕️';
      case 'menunggu_obat':
        return 'Resep Sedang Disiapkan 💊';
      case 'obat_siap':
        return 'Obat Siap Diambil! 💊';
      case 'selesai':
        return 'Kunjungan Selesai ✅';
      case 'dibatalkan':
        return 'Antrian Dibatalkan ❌';
      default:
        return 'Update Antrian';
    }
  }
  
  /// Get notification body based on antrian status
  static String getBodyForAntrianStatus(String status, {String? nomorAntrian}) {
    switch (status) {
      case 'pending':
      case 'menunggu':
        return 'Nomor antrian Anda: ${nomorAntrian ?? '-'}. Silakan tunggu panggilan.';
      case 'pemeriksaan_perawat':
        return 'Silakan menuju ruang perawat untuk pemeriksaan awal.';
      case 'menunggu_dokter':
        return 'Silakan menunggu panggilan dokter.';
      case 'pemeriksaan_dokter':
        return 'Anda sedang diperiksa oleh dokter.';
      case 'menunggu_obat':
        return 'Obat Anda sedang disiapkan oleh apoteker.';
      case 'obat_siap':
        return 'Silakan ambil obat Anda di apotek.';
      case 'selesai':
        return 'Terima kasih telah berkunjung. Semoga lekas sembuh!';
      case 'dibatalkan':
        return 'Antrian Anda telah dibatalkan.';
      default:
        return 'Status antrian Anda telah diperbarui.';
    }
  }
}
