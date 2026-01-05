import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/data_pasien_controller.dart';

class DataPasienView extends GetView<DataPasienController> {
  const DataPasienView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DataPasienController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Data Pasien',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: const Color(0xFF02B1BA),
        child: Column(
          children: [
            _buildStatisticCards(),
            _buildSearchAndFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF02B1BA)),
                  );
                }
                return _buildRiwayatList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Statistik Cards - Compact Version
  Widget _buildStatisticCards() {
    return Obx(() => Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildCompactStatItem(
            controller.selesaiHariIni.value.toString(),
            'Hari Ini',
          )),
          Container(width: 1, height: 30, color: Colors.white30),
          Expanded(child: _buildCompactStatItem(
            controller.selesaiMingguIni.value.toString(),
            'Minggu Ini',
          )),
          Container(width: 1, height: 30, color: Colors.white30),
          Expanded(child: _buildCompactStatItem(
            controller.selesaiBulanIni.value.toString(),
            'Bulan Ini',
          )),
          Container(width: 1, height: 30, color: Colors.white30),
          Expanded(child: _buildCompactStatItem(
            controller.totalSelesai.value.toString(),
            'Total',
          )),
        ],
      ),
    ));
  }

  Widget _buildCompactStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Search Bar dan Filters
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Cari pasien, no. RM, diagnosa...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchQuery.value = '';
                        },
                      )
                    : const SizedBox.shrink()),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDropdownFilter(
                  value: controller.selectedPeriod.value,
                  items: const [
                    DropdownMenuItem(value: 'hari_ini', child: Text('Hari Ini')),
                    DropdownMenuItem(value: 'minggu_ini', child: Text('Minggu Ini')),
                    DropdownMenuItem(value: 'bulan_ini', child: Text('Bulan Ini')),
                    DropdownMenuItem(value: 'tahun_ini', child: Text('Tahun Ini')),
                    DropdownMenuItem(value: 'semua', child: Text('Semua Waktu')),
                  ],
                  onChanged: (value) => controller.selectedPeriod.value = value!,
                  icon: Icons.calendar_today,
                )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => _buildDropdownFilter(
                  value: controller.selectedPoli.value,
                  items: controller.poliList.map((poli) => 
                    DropdownMenuItem(value: poli, child: Text(poli, overflow: TextOverflow.ellipsis))
                  ).toList(),
                  onChanged: (value) => controller.selectedPoli.value = value!,
                  icon: Icons.local_hospital,
                )),
              ),
            ],
          ),
          // Clear filter button
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty ||
                controller.selectedPeriod.value != 'bulan_ini' ||
                controller.selectedPoli.value != 'Semua') {
              return Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear_all, size: 14),
                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(icon, size: 16, color: const Color(0xFF02B1BA)),
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }

  /// List Riwayat
  Widget _buildRiwayatList() {
    return Obx(() {
      if (controller.filteredRiwayatList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Tidak ada data ditemukan',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                'Coba ubah filter atau kata kunci',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.filteredRiwayatList.length,
        itemBuilder: (context, index) {
          final data = controller.filteredRiwayatList[index];
          return _buildRiwayatItem(data);
        },
      );
    });
  }

  /// Build item card
  Widget _buildRiwayatItem(Map<String, dynamic> data) {
    final tanggal = data['tanggal'] as DateTime;
    final status = data['status']?.toString() ?? 'selesai';
    
    // Border color berdasarkan status
    Color borderColor = const Color(0xFF4CAF50); // Default hijau untuk selesai
    if (status == 'selesai_diperiksa' || status == 'siap_ambil_obat' || status == 'menunggu_apoteker' || status == 'dilayani_apoteker') {
      borderColor = const Color(0xFF2196F3); // Biru
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToDetail(data),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nama + Queue Number
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: borderColor,
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['namaLengkap'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              'RM: ${data['noRekamMedis'] ?? '-'}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Text(
                              '${controller.formatTanggal(tanggal)} ${controller.formatWaktu(tanggal)}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      data['queueNumber'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Info Poli & Keluhan
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_hospital, size: 12, color: borderColor),
                        const SizedBox(width: 4),
                        Text(
                          data['jenisLayanan'] ?? '-',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: borderColor,
                          ),
                        ),
                      ],
                    ),
                    if ((data['keluhan'] ?? '-') != '-') ...[
                      const SizedBox(height: 4),
                      Text(
                        data['keluhan'] ?? '-',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Info Grid: Diagnosa + Dokter + Perawat + Tanda Vital
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.medical_services,
                      label: 'Diagnosa',
                      value: data['diagnosa'] ?? data['diagnosis'] ?? '-',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'Dokter',
                      value: data['dokterNama'] ?? '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.medical_information,
                      label: 'Perawat',
                      value: data['perawatNama'] ?? data['perawat_nama'] ?? '-',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.favorite,
                      label: 'TD/Nadi',
                      value: '${data['tekananDarahSistolik'] ?? 0}/${data['tekananDarahDiastolik'] ?? 0} | ${data['nadi'] ?? 0}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.navigateToDetail(data),
                  icon: const Icon(Icons.visibility, size: 14),
                  label: const Text(
                    'Lihat Detail Lengkap',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[400], fontSize: 9),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
