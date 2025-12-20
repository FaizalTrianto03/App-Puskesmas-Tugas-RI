import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/snackbar_helper.dart';

class VerifikasiAntrianController extends GetxController {
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final SessionService _sessionService = Get.find<SessionService>();

  final antrianList = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'semua'.obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  final catatanController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAntrian();
  }

  @override
  void onClose() {
    catatanController.dispose();
    super.onClose();
  }

  Future<void> loadAntrian() async {
    isLoading.value = true;

    try {
      // Pakai data antrian hari ini dari Firestore, sama seperti dashboard perawat
      final data = await _antrianService.getAllAntrianToday();

      // Urutkan terbaru di atas (createdAt sudah descending di service, tapi kita pastikan lagi pakai tanggalDaftar)
      data.sort((a, b) {
        final dateA = DateTime.tryParse(a['tanggalDaftar'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['tanggalDaftar'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      antrianList.value = data;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data antrian');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredAntrianList {
    var filtered = antrianList.where((antrian) {
      if (selectedFilter.value == 'menunggu') {
        return antrian['status'] == 'menunggu' || antrian['status'] == 'menunggu_verifikasi';
      } else if (selectedFilter.value == 'diverifikasi') {
        return antrian['status'] == 'menunggu_dokter' || antrian['status'] == 'sedang_dilayani';
      }
      return true;
    }).toList();

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((antrian) {
        final query = searchQuery.value.toLowerCase();
        final nama = (antrian['namaLengkap'] ?? '').toLowerCase();
        final noAntrian = (antrian['queueNumber'] ?? '').toLowerCase();
        final noRM = (antrian['noRekamMedis'] ?? '').toLowerCase();
        
        return nama.contains(query) || 
               noAntrian.contains(query) || 
               noRM.contains(query);
      }).toList();
    }

    return filtered;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> verifikasiAntrian(Map<String, dynamic> antrian) async {
    if (antrian['id'] == null || antrian['id'].toString().isEmpty) {
      SnackbarHelper.showError('ID antrian tidak valid');
      return;
    }

    final perawatId = _sessionService.getUserId();
    final perawatName = _sessionService.getNamaLengkap();

    if (perawatId == null || perawatName == null) {
      SnackbarHelper.showError('Sesi tidak valid');
      return;
    }

    final confirm = await ConfirmationDialog.show(
      title: 'Verifikasi Antrian',
      message:
          'Apakah Anda yakin ingin memverifikasi antrian ${antrian['queueNumber']} atas nama ${antrian['namaLengkap']}?',
      type: ConfirmationType.confirmation,
      confirmText: 'Verifikasi',
      cancelText: 'Batal',
    );

    if (confirm != true) return;

    isLoading.value = true;

    try {
      final success = await _antrianService.verifikasiAntrian(
        antrianId: antrian['id'],
        perawatId: perawatId,
        perawatName: perawatName,
        catatan: catatanController.text.trim().isEmpty
            ? null
            : catatanController.text.trim(),
      );

      catatanController.clear();

      if (success) {
        SnackbarHelper.showSuccess('Antrian berhasil diverifikasi');
        await loadAntrian();
      } else {
        SnackbarHelper.showError('Gagal memverifikasi antrian');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tolakAntrian(Map<String, dynamic> antrian) async {
    if (antrian['id'] == null || antrian['id'].toString().isEmpty) {
      SnackbarHelper.showError('ID antrian tidak valid');
      return;
    }

    final alasanController = TextEditingController();

    final confirm = await ConfirmationDialog.show(
      title: 'Tolak Antrian',
      message:
          'Apakah Anda yakin ingin menolak antrian ${antrian['queueNumber']} atas nama ${antrian['namaLengkap']}?',
      type: ConfirmationType.danger,
      confirmText: 'Tolak',
      cancelText: 'Batal',
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: alasanController,
            decoration: const InputDecoration(
              labelText: 'Alasan Penolakan *',
              border: OutlineInputBorder(),
              hintText: 'Masukkan alasan penolakan',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );

    if (confirm != true) {
      alasanController.dispose();
      return;
    }

    if (alasanController.text.trim().isEmpty) {
      SnackbarHelper.showError('Alasan penolakan harus diisi');
      alasanController.dispose();
      return;
    }

    isLoading.value = true;

    try {
      final success = await _antrianService.batalkanAntrian(
        antrian['id'],
        'Ditolak: ${alasanController.text.trim()}',
      );

      if (success) {
        SnackbarHelper.showSuccess('Antrian ditolak');
        await loadAntrian();
      } else {
        SnackbarHelper.showError('Gagal menolak antrian');
      }
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      alasanController.dispose();
      isLoading.value = false;
    }
  }

  void lihatDetailPasien(Map<String, dynamic> antrian) {
    Get.dialog(
      AlertDialog(
        title: Text('Detail Pasien'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama', antrian['namaLengkap']),
              _buildDetailRow('No. Rekam Medis', antrian['noRekamMedis']),
              _buildDetailRow('No. Antrian', antrian['queueNumber']),
              _buildDetailRow('Poliklinik', antrian['jenisLayanan'] ?? antrian['poliklinik']),
              _buildDetailRow('Keluhan', antrian['keluhan']),
              if (antrian['nomorBPJS'] != null)
                _buildDetailRow('No. BPJS', antrian['nomorBPJS']),
              _buildDetailRow('Tanggal Daftar', 
                _formatDateTime(antrian['tanggalDaftar'])),
              _buildDetailRow('Status', _getStatusLabel(antrian['status'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(': '),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  String _formatDateTime(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'menunggu_dokter':
        return 'Sudah Diverifikasi';
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

    int get totalAntrian => antrianList.length;
    int get menungguVerifikasi => antrianList
      .where((a) => a['status'] == 'menunggu' || a['status'] == 'menunggu_verifikasi').length;
    int get sudahDiverifikasi => antrianList
      .where((a) => a['status'] == 'menunggu_dokter' || a['status'] == 'sedang_dilayani').length;
}
