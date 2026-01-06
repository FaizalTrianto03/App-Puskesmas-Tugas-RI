import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../utils/snackbar_helper.dart';

/// Controller untuk halaman Data Pasien (Apoteker)
/// Menampilkan SEMUA antrean yang sudah selesai sebagai referensi riwayat obat pasien
class DataPasienController extends GetxController {
  // TextEditingController untuk SearchBar
  late final TextEditingController searchController;
  
  // Observable variables
  final riwayatList = <Map<String, dynamic>>[].obs;
  final filteredRiwayatList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedPeriod = 'bulan_ini'.obs;
  final selectedPoli = 'Semua'.obs;
  final poliList = <String>['Semua'].obs;

  // Statistik
  final totalSelesai = 0.obs;
  final selesaiBulanIni = 0.obs;
  final selesaiMingguIni = 0.obs;
  final selesaiHariIni = 0.obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadPoliList();
    _loadAllSelesai();
    
    // Listen to search and filter changes
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedPeriod, (_) => _applyFilters());
    ever(selectedPoli, (_) => _applyFilters());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load daftar poli dari Firestore
  Future<void> loadPoliList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('poli')
          .orderBy('namaPoli')
          .get();
      
      final poliNames = snapshot.docs
          .map((doc) => doc.data()['namaPoli'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      
      poliList.value = ['Semua', ...poliNames];
    } catch (e) {
      poliList.value = ['Semua'];
    }
  }

  /// Load SEMUA antrean yang sudah selesai
  Future<void> _loadAllSelesai() async {
    try {
      isLoading.value = true;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('antrian')
          .where('status', isEqualTo: 'selesai')
          .get();

      riwayatList.clear();
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final perawatData = data['perawatData'] != null 
            ? Map<String, dynamic>.from(data['perawatData'] as Map) 
            : <String, dynamic>{};
        final dokterData = data['dokterData'] != null 
            ? Map<String, dynamic>.from(data['dokterData'] as Map) 
            : <String, dynamic>{};
        final apotekerData = data['apotekerData'] != null 
            ? Map<String, dynamic>.from(data['apotekerData'] as Map) 
            : <String, dynamic>{};
        
        final verifiedAt = perawatData['verifiedAt'];
        
        riwayatList.add(_mapAntrianData(doc.id, data, perawatData, dokterData, apotekerData, verifiedAt));
      }
      
      // Sort manual di memory (terbaru dulu)
      riwayatList.sort((a, b) {
        final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
        final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      _calculateStatistik();
      _applyFilters();
      
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data pasien: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Map data antrian ke format yang dibutuhkan
  Map<String, dynamic> _mapAntrianData(
    String docId,
    Map<String, dynamic> data,
    Map<String, dynamic> perawatData,
    Map<String, dynamic> dokterData,
    Map<String, dynamic> apotekerData,
    dynamic verifiedAt,
  ) {
    final createdAt = data['createdAt'];
    final tanggal = verifiedAt != null 
        ? (verifiedAt as Timestamp).toDate() 
        : createdAt != null 
            ? (createdAt as Timestamp).toDate()
            : DateTime.now();

    // Hitung total obat
    final resepObat = data['resepObat'] as List<dynamic>? ?? [];
    final totalItemObat = resepObat.length;
    int totalHargaObat = 0;
    for (var obat in resepObat) {
      if (obat is Map) {
        totalHargaObat += (obat['totalHarga'] as int?) ?? 0;
      }
    }

    return {
      ...data,
      'id': docId,
      'pasienId': data['pasienId'] ?? '',
      'namaLengkap': data['namaLengkap'] ?? 'Tidak Diketahui',
      'noRekamMedis': data['noRekamMedis'] ?? '-',
      'jenisLayanan': data['jenisLayanan'] ?? '-',
      'tanggal': tanggal,
      'keluhan': data['keluhan'] ?? '-',
      'queueNumber': data['queueNumber'] ?? '-',
      'status': data['status'] ?? 'selesai',
      // Diagnosa
      'diagnosa': dokterData['diagnosis'] ?? dokterData['diagnosa'] ?? data['diagnosis'] ?? '-',
      'dokterNama': dokterData['dokterNama'] ?? data['dokterNama'] ?? '-',
      // Perawat
      'perawatNama': perawatData['perawatName'] ?? perawatData['perawatNama'] ?? '-',
      // Apoteker
      'apotekerNama': apotekerData['apotekerNama'] ?? '-',
      // Resep Obat
      'resepObat': resepObat,
      'totalItemObat': totalItemObat,
      'totalHargaObat': totalHargaObat,
      // Nested data
      'perawatData': perawatData,
      'dokterData': dokterData,
      'apotekerData': apotekerData,
      'pembayaranData': data['pembayaranData'] ?? {},
    };
  }

  /// Hitung statistik
  void _calculateStatistik() {
    totalSelesai.value = riwayatList.length;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);

    selesaiHariIni.value = _countByPeriod(startOfToday);
    selesaiMingguIni.value = _countByPeriod(startOfWeek);
    selesaiBulanIni.value = _countByPeriod(startOfMonth);
  }

  int _countByPeriod(DateTime startDate) {
    return riwayatList.where((item) {
      final tanggal = item['tanggal'] as DateTime;
      final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
      return !tanggalDate.isBefore(startDate);
    }).length;
  }

  /// Apply search and filter
  void _applyFilters() {
    var filtered = riwayatList.toList();

    if (searchQuery.value.isNotEmpty) {
      filtered = _applySearchFilter(filtered);
    }

    filtered = _applyPeriodFilter(filtered);

    if (selectedPoli.value != 'Semua') {
      filtered = _applyPoliFilter(filtered);
    }
    
    filtered.sort((a, b) {
      final aTime = a['tanggal'] as DateTime? ?? DateTime(2000);
      final bTime = b['tanggal'] as DateTime? ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    
    filteredRiwayatList.value = filtered;
  }

  List<Map<String, dynamic>> _applySearchFilter(List<Map<String, dynamic>> list) {
    final query = searchQuery.value.toLowerCase();
    return list.where((item) {
      return (item['namaLengkap']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['noRekamMedis']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['queueNumber']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['diagnosa']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['dokterNama']?.toString().toLowerCase() ?? '').contains(query) ||
             (item['apotekerNama']?.toString().toLowerCase() ?? '').contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _applyPeriodFilter(List<Map<String, dynamic>> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (selectedPeriod.value) {
      case 'hari_ini':
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          return !tanggalDate.isBefore(today);
        }).toList();
      
      case 'minggu_ini':
        final daysToSubtract = now.weekday - 1;
        final mondayThisWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          return !tanggalDate.isBefore(mondayThisWeek);
        }).toList();
      
      case 'bulan_ini':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          return !tanggalDate.isBefore(startOfMonth);
        }).toList();
      
      case 'tahun_ini':
        final startOfYear = DateTime(now.year, 1, 1);
        return list.where((item) {
          final tanggal = item['tanggal'] as DateTime;
          final tanggalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
          return !tanggalDate.isBefore(startOfYear);
        }).toList();
      
      default:
        return list;
    }
  }

  List<Map<String, dynamic>> _applyPoliFilter(List<Map<String, dynamic>> list) {
    return list.where((item) => item['jenisLayanan'].toString() == selectedPoli.value).toList();
  }

  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedPeriod.value = 'bulan_ini';
    selectedPoli.value = 'Semua';
  }

  Future<void> refreshData() async {
    await _loadAllSelesai();
  }

  String formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(tanggal);
  }

  String formatWaktu(DateTime tanggal) {
    return DateFormat('HH:mm', 'id_ID').format(tanggal);
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }
  
  /// Navigate ke detail - show bottom sheet dengan riwayat obat
  void showDetailResep(Map<String, dynamic> data) {
    Get.bottomSheet(
      _buildDetailBottomSheet(data),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailBottomSheet(Map<String, dynamic> data) {
    final resepObat = data['resepObat'] as List<dynamic>? ?? [];
    final tanggal = data['tanggal'] as DateTime;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF02B1BA),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['namaLengkap'] ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RM: ${data['noRekamMedis'] ?? '-'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${formatTanggal(tanggal)} ${formatWaktu(tanggal)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02B1BA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['queueNumber'] ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Poli', data['jenisLayanan'] ?? '-', Icons.local_hospital),
                const SizedBox(height: 8),
                _buildInfoRow('Diagnosa', data['diagnosa'] ?? '-', Icons.medical_services),
                const SizedBox(height: 8),
                _buildInfoRow('Dokter', data['dokterNama'] ?? '-', Icons.person_outline),
                const SizedBox(height: 8),
                _buildInfoRow('Apoteker', data['apotekerNama'] ?? '-', Icons.medication),
              ],
            ),
          ),
          const Divider(height: 1),
          // Resep Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF02B1BA), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Resep Obat',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02B1BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${resepObat.length} item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF02B1BA),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List Obat
          Flexible(
            child: resepObat.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.medication_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada resep obat',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: resepObat.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final obat = resepObat[index] as Map<dynamic, dynamic>;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF02B1BA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.medication,
                                color: Color(0xFF02B1BA),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    obat['namaObat'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${obat['dosis'] ?? '-'} • ${obat['aturanPakai'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${obat['jumlah'] ?? 0} ${obat['satuan'] ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  formatCurrency((obat['totalHarga'] as int?) ?? 0),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Footer Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF02B1BA).withOpacity(0.1),
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Obat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  formatCurrency(data['totalHargaObat'] ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF02B1BA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
