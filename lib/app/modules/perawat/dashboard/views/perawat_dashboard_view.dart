import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../settings/views/perawat_settings_view.dart';
import '../controllers/perawat_dashboard_controller.dart';

class PerawatDashboardView extends GetView<PerawatDashboardController> {
  const PerawatDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PerawatDashboardController());
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Dashboard Perawat',
            style: TextStyle(
              color: Color(0xFF02B1BA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: QuarterCircleBackground(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildStatisticCards(),
                      const SizedBox(height: 16),
                      _buildMenuSection(),
                      const SizedBox(height: 24),
                      _buildSearchAndFilter(),
                      const SizedBox(height: 16),
                      _buildPasienList(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const PerawatSettingsView());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 35,
                color: Color(0xFF02B1BA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userName.value.isEmpty 
                        ? 'Loading...' 
                        : controller.userName.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.userRole.value.isEmpty 
                        ? 'Loading...' 
                        : controller.userRole.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticCards() {
    return Obx(() => Row(
      children: [
        _buildStatCard(
          controller.getTotalAntrianHariIni().toString(),
          'Total',
          const Color(0xFF02B1BA),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          controller.getMenungguVerifikasiCount().toString(),
          'Menunggu',
          const Color(0xFFFF9800),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          controller.getTerverifikasiCount().toString(),
          'Selesai',
          const Color(0xFF4CAF50),
        ),
      ],
    ));
  }
  
  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.history,
                  label: 'Riwayat\nPemeriksaan',
                  color: const Color(0xFF0B4D3B),
                  onTap: () {
                    Get.toNamed('/perawat/riwayat-pemeriksaan');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.medical_services,
                  label: 'Rekam\nMedis',
                  color: const Color(0xFF02B1BA),
                  onTap: () {
                    Get.snackbar(
                      'Info',
                      'Silakan pilih pasien dari daftar antrean',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.assessment,
                  label: 'Laporan\nKinerja',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Get.snackbar(
                      'Info',
                      'Fitur laporan kinerja akan segera tersedia',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search Bar
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Cari nama, no. antrian, atau no. RM...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF02B1BA),
                size: 22,
              ),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: controller.clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        )),
        const SizedBox(height: 12),
        
        // Filter Chips
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Semua',
                value: 'semua',
                icon: Icons.list,
                count: controller.antrianList.length,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Menunggu Verifikasi',
                value: 'menunggu_verifikasi',
                icon: Icons.hourglass_empty,
                count: controller.getMenungguVerifikasiCount(),
                color: const Color(0xFFFF9800),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Terverifikasi',
                value: 'terverifikasi',
                icon: Icons.check_circle,
                count: controller.getTerverifikasiCount(),
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required int count,
    Color? color,
  }) {
    final isSelected = controller.selectedFilter.value == value;
    final chipColor = color ?? const Color(0xFF02B1BA);
    
    return GestureDetector(
      onTap: () => controller.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.3)
                    : chipColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasienList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final antrianMenunggu = controller.antrianMenungguVerifikasi;
      final antrianTerverifikasi = controller.antrianTerverifikasi;
      final showSeparateSections = controller.selectedFilter.value == 'semua';
      
      // Jika ada pencarian atau filter aktif, tampilkan hasil gabungan
      if (!showSeparateSections || controller.searchQuery.value.isNotEmpty) {
        final allFiltered = [...antrianMenunggu, ...antrianTerverifikasi];
        
        if (allFiltered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.searchQuery.value.isNotEmpty
                        ? 'Tidak ada hasil untuk "${controller.searchQuery.value}"'
                        : 'Tidak ada antrian',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (controller.searchQuery.value.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: controller.clearSearch,
                      icon: const Icon(Icons.clear),
                      label: const Text('Hapus Pencarian'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getListTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02B1BA),
              ),
            ),
            if (controller.searchQuery.value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${allFiltered.length} hasil ditemukan',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...allFiltered.map((antrian) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAntrianCard(
                  context: context,
                  antrian: antrian,
                ),
              );
            }).toList(),
          ],
        );
      }

      // Default view: tampilkan sections terpisah
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Antrian Menunggu Verifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(height: 12),
          if (antrianMenunggu.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Tidak ada antrian menunggu verifikasi'),
              ),
            )
          else
            ...antrianMenunggu.map((antrian) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAntrianCard(
                  context: context,
                  antrian: antrian,
                ),
              );
            }).toList(),
          const SizedBox(height: 24),
          const Text(
            'Antrian Terverifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(height: 12),
          if (antrianTerverifikasi.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Tidak ada antrian terverifikasi'),
              ),
            )
          else
            ...antrianTerverifikasi.map((antrian) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAntrianCard(
                  context: context,
                  antrian: antrian,
                ),
              );
            }).toList(),
        ],
      );
    });
  }
  
  String _getListTitle() {
    if (controller.searchQuery.value.isNotEmpty) {
      return 'Hasil Pencarian';
    }
    switch (controller.selectedFilter.value) {
      case 'menunggu_verifikasi':
        return 'Antrian Menunggu Verifikasi';
      case 'terverifikasi':
        return 'Antrian Terverifikasi';
      default:
        return 'Semua Antrian';
    }
  }
  
  Widget _buildAntrianCard({
    required BuildContext context,
    required Map<String, dynamic> antrian,
  }) {
    String getStatusText(String status) {
      switch (status) {
        case 'menunggu_verifikasi':
          return 'Menunggu Verifikasi';
        case 'menunggu_dokter':
          return 'Terverifikasi';
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

    Color getStatusColor(String status) {
      switch (status) {
        case 'menunggu_verifikasi':
          return const Color(0xFFFF9800);
        case 'menunggu_dokter':
          return const Color(0xFF2196F3);
        case 'sedang_dilayani':
          return const Color(0xFF9C27B0);
        case 'selesai':
          return const Color(0xFF4CAF50);
        case 'dibatalkan':
          return const Color(0xFFF44336);
        default:
          return const Color(0xFF9E9E9E);
      }
    }

    final status = antrian['status'] as String;
    final statusText = getStatusText(status);
    final statusColor = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF02B1BA),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      antrian['namaLengkap'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. RM: ${antrian['noRekamMedis'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Antrian',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      antrian['queueNumber'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4242),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluhan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      antrian['keluhan'] ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Dropdown Ubah Status (hanya untuk antrian menunggu verifikasi)
          if (status == 'menunggu_verifikasi') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFB020), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFF8C00),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ubah Status Antrian:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: status,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF02B1BA)),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: BorderRadius.circular(8),
                  items: const [
                    DropdownMenuItem(
                      value: 'menunggu_verifikasi',
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_empty, size: 18, color: Color(0xFFFF9800)),
                          SizedBox(width: 8),
                          Text('Menunggu Verifikasi'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'menunggu_dokter',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Color(0xFF4CAF50)),
                          SizedBox(width: 8),
                          Text('Verifikasi & Kirim ke Dokter'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dibatalkan',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 18, color: Color(0xFFF44336)),
                          SizedBox(width: 8),
                          Text('Batalkan Antrian'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newStatus) {
                    if (newStatus == null || newStatus == status) return;
                    
                    // Konfirmasi sebelum ubah status
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Konfirmasi Ubah Status'),
                        content: Text(
                          'Apakah Anda yakin ingin mengubah status antrian ${antrian['queueNumber']} menjadi "${_getStatusText(newStatus)}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.ubahStatusAntrian(
                                antrianId: antrian['id'],
                                newStatus: newStatus,
                                antrian: antrian,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02B1BA),
                            ),
                            child: const Text('Ya, Ubah'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ] else if (status == 'menunggu_dokter' || status == 'sedang_dilayani') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.navigateToFormRekamMedis(antrian);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Detail Rekam Medis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'menunggu_dokter':
        return 'Verifikasi & Kirim ke Dokter';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
