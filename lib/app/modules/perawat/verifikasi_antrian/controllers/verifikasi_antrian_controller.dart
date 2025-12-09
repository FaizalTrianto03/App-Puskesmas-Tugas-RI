import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/antrian/antrian_service.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../utils/snackbar_helper.dart';

class VerifikasiAntrianController extends GetxController {
  final AntreanService _antreanService = Get.find<AntreanService>();
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

  void loadAntrian() {
    isLoading.value = true;
    
    antrianList.value = _antreanService.getAllAntrian()
      ..sort((a, b) {
        final dateA = DateTime.parse(a['tanggalDaftar']);
        final dateB = DateTime.parse(b['tanggalDaftar']);
        return dateA.compareTo(dateB);
      });
    
    isLoading.value = false;
  }

  List<Map<String, dynamic>> get filteredAntrianList {
    var filtered = antrianList.where((antrian) {
      if (selectedFilter.value == 'menunggu') {
        return antrian['status'] == 'menunggu_verifikasi';
      } else if (selectedFilter.value == 'diverifikasi') {
        return antrian['status'] == 'menunggu_dokter';
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
    final perawatId = _sessionService.getUserId();
    final perawatName = _sessionService.getNamaLengkap();

    if (perawatId == null || perawatName == null) {
      SnackbarHelper.showError('Sesi tidak valid');
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Verifikasi Antrian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pasien: ${antrian['namaLengkap']}'),
            SizedBox(height: 8),
            Text('No. Antrian: ${antrian['queueNumber']}'),
            SizedBox(height: 16),
            TextField(
              controller: catatanController,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
                hintText: 'Tambahkan catatan jika perlu',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              catatanController.clear();
              Get.back(result: false);
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Verifikasi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    final success = await _antreanService.verifikasiAntrian(
      antrianId: antrian['id'],
      perawatId: perawatId,
      perawatName: perawatName,
      catatan: catatanController.text.trim().isEmpty 
          ? null 
          : catatanController.text.trim(),
    );

    catatanController.clear();
    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess('Antrian berhasil diverifikasi');
      loadAntrian();
    } else {
      SnackbarHelper.showError('Gagal memverifikasi antrian');
    }
  }

  Future<void> tolakAntrian(Map<String, dynamic> antrian) async {
    final alasanController = TextEditingController();

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Tolak Antrian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pasien: ${antrian['namaLengkap']}'),
            SizedBox(height: 8),
            Text('No. Antrian: ${antrian['queueNumber']}'),
            SizedBox(height: 16),
            TextField(
              controller: alasanController,
              decoration: InputDecoration(
                labelText: 'Alasan Penolakan *',
                border: OutlineInputBorder(),
                hintText: 'Masukkan alasan penolakan',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              alasanController.dispose();
              Get.back(result: false);
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (alasanController.text.trim().isEmpty) {
                SnackbarHelper.showError('Alasan penolakan harus diisi');
                return;
              }
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    final success = await _antreanService.batalkanAntrian(
      antrian['id'],
      'Ditolak: ${alasanController.text.trim()}',
    );

    alasanController.dispose();
    isLoading.value = false;

    if (success) {
      SnackbarHelper.showSuccess('Antrian ditolak');
      loadAntrian();
    } else {
      SnackbarHelper.showError('Gagal menolak antrian');
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
              _buildDetailRow('Poliklinik', antrian['poliklinik']),
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
      .where((a) => a['status'] == 'menunggu_verifikasi').length;
  int get sudahDiverifikasi => antrianList
      .where((a) => a['status'] == 'menunggu_dokter').length;
}
