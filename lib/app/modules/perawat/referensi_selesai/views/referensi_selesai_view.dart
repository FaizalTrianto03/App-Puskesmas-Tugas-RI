import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/referensi_selesai_controller.dart';

class ReferensiSelesaiView extends GetView<ReferensiSelesaiController> {
  const ReferensiSelesaiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF02B1BA)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF02B1BA),
          onRefresh: () => controller.refreshData(),
          child: Column(
            children: [
              _buildStatistikCard(),
              _buildSearchAndFilter(),
              Expanded(child: _buildRiwayatList()),
            ],
          ),
        );
      }),
    );
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  /// Widget Statistik Card
  Widget _buildStatistikCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.folder_shared, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Statistik Data Pasien',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.today,
                label: 'Hari Ini',
                value: controller.selesaiHariIni.value.toString(),
              ),
              _buildStatItem(
                icon: Icons.date_range,
                label: 'Minggu Ini',
                value: controller.selesaiMingguIni.value.toString(),
              ),
              _buildStatItem(
                icon: Icons.calendar_month,
                label: 'Bulan Ini',
                value: controller.selesaiBulanIni.value.toString(),
              ),
              _buildStatItem(
                icon: Icons.all_inclusive,
                label: 'Total',
                value: controller.totalSelesai.value.toString(),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Search and Filter
  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: controller.searchController,
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Cari pasien, no. RM, diagnosa, perawat, dokter...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF02B1BA)),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                    )
                  : const SizedBox.shrink()),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF02B1BA)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Row
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
              const SizedBox(width: 12),
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
          const SizedBox(height: 8),
          // Clear filter button
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty ||
                controller.selectedPeriod.value != 'bulan_ini' ||
                controller.selectedPoli.value != 'Semua') {
              return Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Reset Filter'),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(icon, size: 18, color: const Color(0xFF02B1BA)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
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
              Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data ditemukan',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba ubah filter atau kata kunci pencarian',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToDetail(data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nama + Queue Number
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: borderColor,
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
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
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'RM: ${data['noRekamMedis'] ?? '-'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(
                              '${controller.formatTanggal(tanggal)} ${controller.formatWaktu(tanggal)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              // Info Grid: Diagnosa + Dokter
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.medical_services,
                      label: 'Diagnosa',
                      value: data['diagnosa'] ?? data['diagnosis'] ?? '-',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'Dokter',
                      value: data['dokterNama'] ?? '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Info: Perawat + Tanda Vital
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.medical_information,
                      label: 'Perawat',
                      value: data['perawatNama'] ?? data['perawat_nama'] ?? '-',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.favorite,
                      label: 'TD/Nadi',
                      value: '${data['tekananDarahSistolik'] ?? 0}/${data['tekananDarahDiastolik'] ?? 0} | ${data['nadi'] ?? 0}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.navigateToDetail(data),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text(
                    'Lihat Detail Lengkap',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
