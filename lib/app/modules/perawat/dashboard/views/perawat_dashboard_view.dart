import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../widgets/notification/notification_button.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../settings/views/perawat_settings_view.dart';
import '../controllers/perawat_dashboard_controller.dart';
import '_sticky_header_delegate.dart';

// Custom clipper to cut top area for masking effect
class TopClipper extends CustomClipper<Rect> {
  final double clipHeight;
  TopClipper({required this.clipHeight});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, clipHeight, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

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
          elevation: 0,
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
          actions: const [
            NotificationButton(),
            SizedBox(width: 8),
          ],
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
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    // Profile & Menu - scrollable
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildProfileCard(context),
                            const SizedBox(height: 16),
                            _buildMenuSection(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    
                    // Sticky header - Daftar Antrian section (stats + search + filters)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: StickyHeaderDelegate(
                        height: 270,
                        child: Container(
                          color: const Color(0xFFF1F9FF),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: _buildSearchAndFilter(),
                        ),
                      ),
                    ),
                  ],
                  // List antrian - own scroll area
                  body: RefreshIndicator(
                    onRefresh: controller.loadAntrian,
                    color: const Color(0xFF02B1BA),
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _buildPasienListBody(context),
                    ),
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
              child: Icon(Icons.person, size: 35, color: Color(0xFF02B1BA)),
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
                      style: const TextStyle(fontSize: 13, color: Colors.white),
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
                child: _buildCompactMenuCard(
                  icon: Icons.history,
                  label: 'Riwayat Pasien',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    Get.toNamed('/perawat/riwayat-pemeriksaan');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactMenuCard(
                  icon: Icons.folder_shared,
                  label: 'Data Pasien',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Get.toNamed('/perawat/referensi-selesai');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactMenuCard(
                  icon: Icons.assessment,
                  label: 'Laporan Kinerja',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Get.toNamed('/perawat/laporan-kinerja');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Antrian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF02B1BA),
          ),
        ),
        const SizedBox(height: 8),
        
        // Statistics Cards (Compact)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildCompactStat('Total', controller.getTotalAntrianHariIni().toString(), Icons.list_alt),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildCompactStat('Menunggu', controller.getMenungguVerifikasiCount().toString(), Icons.hourglass_empty),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildCompactStat('Terverifikasi', controller.getTerverifikasiCount().toString(), Icons.check_circle),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Search Bar
        Container(
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
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
        ),
        const SizedBox(height: 8),

        // Filter Tabs (Horizontal)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterTab('Semua', 'semua', controller.antrianList.length),
              const SizedBox(width: 8),
              _buildFilterTab('Menunggu', 'menunggu_verifikasi', controller.getMenungguVerifikasiCount()),
              const SizedBox(width: 8),
              _buildFilterTab('Terverifikasi', 'terverifikasi', controller.getTerverifikasiCount()),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildCompactStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value, int count) {
    final isSelected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF02B1BA) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF02B1BA),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build list body for NestedScrollView (separate scroll area)
  Widget _buildPasienListBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF02B1BA)));
      }

      final antrianList = controller.filteredAntrianList;

      if (antrianList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
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

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: antrianList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAntrianCard(context: context, antrian: antrianList[index]),
          );
        },
      );
    });
  }

  Widget _buildAntrianCard({
    required BuildContext context,
    required Map<String, dynamic> antrian,
  }) {
    Color getBorderColor(String status) {
      switch (status) {
        case 'menunggu':
        case 'menunggu_verifikasi':
          return const Color(0xFFFF9800); // Orange - menunggu
        case 'menunggu_dokter':
        case 'sedang_dilayani':
        case 'dipanggil':
        case 'dilayani_dokter':
          return const Color(0xFF4CAF50); // Hijau - lanjut/terverifikasi
        case 'selesai':
        case 'selesai_diperiksa':
        case 'siap_ambil_obat':
        case 'menunggu_apoteker':
        case 'dilayani_apoteker':
          return const Color(0xFF2196F3); // Biru - selesai
        case 'dibatalkan':
          return const Color(0xFFF44336); // Merah - batal
        case 'dilewati':
          return const Color(0xFFFF9800); // Orange - dilewati
        default:
          return Colors.grey.shade300;
      }
    }

    final status = antrian['status'] as String;
    final borderColor = getBorderColor(status);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.12),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: borderColor,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      antrian['namaLengkap'] ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'RM: ${antrian['noRekamMedis'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (antrian['createdAt'] != null) ...[
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(
                            _formatTimestamp(antrian['createdAt']),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  antrian['queueNumber'] ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Info Grid
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poli
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 12, color: borderColor),
                    const SizedBox(width: 4),
                    Text(
                      antrian['jenisLayanan'] ?? '-',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Keluhan
                Text(
                  antrian['keluhan'] ?? '-',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Alasan Pembatalan (jika dibatalkan)
                if (status == 'dibatalkan' && antrian['alasanPembatalan'] != null && antrian['alasanPembatalan'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 12, color: Colors.red.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Alasan Pembatalan:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          antrian['alasanPembatalan'] ?? '-',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (antrian['waktuPembatalan'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 10, color: Colors.grey.shade600),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Dibatalkan: ${_formatTimestamp(antrian['waktuPembatalan'])}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (antrian['dibatalkanOleh'] != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                antrian['dibatalkanOleh'] == 'perawat' ? Icons.medical_services : Icons.person,
                                size: 10,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  antrian['dibatalkanOleh'] == 'perawat'
                                      ? 'Oleh: Perawat${antrian['dibatalkanOlehNama'] != null ? ' (${antrian['dibatalkanOlehNama']})' : ''}'
                                      : 'Oleh: Pasien',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Action Buttons
          if (status == 'menunggu' || status == 'menunggu_verifikasi') ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.navigateToFormRekamMedis(antrian);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Verifikasi',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirm = await ConfirmationDialog.show(
                        title: 'Lewati Sementara?',
                        message: 'Pasien ${antrian['namaLengkap']} akan dilewati dan dapat dilayani setelah antrian aktif selesai.',
                        type: ConfirmationType.warning,
                        confirmText: 'Ya, Lewati',
                        cancelText: 'Tidak',
                      );

                      if (confirm == true) {
                        controller.lewatiAntrian(antrianId: antrian['id']);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else if (status == 'dilewati') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.navigateToFormRekamMedis(antrian);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lanjutkan Verifikasi',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else if (status == 'dibatalkan') ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Tampilkan snackbar dengan info pembatalan
                  Get.snackbar(
                    'Antrian Dibatalkan',
                    antrian['alasanPembatalan'] != null 
                        ? 'Alasan: ${antrian['alasanPembatalan']}'
                        : 'Antrian ini telah dibatalkan',
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade900,
                    icon: Icon(Icons.info_outline, color: Colors.red.shade700),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    duration: const Duration(seconds: 4),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text(
                  'Lihat Detail Pembatalan',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ] else if (status == 'selesai' || status == 'selesai_diperiksa' || status == 'siap_ambil_obat' || status == 'menunggu_apoteker' || status == 'dilayani_apoteker') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.navigateToFormRekamMedis(antrian);
                },
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text(
                  'Lihat Detail',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
          
          // Tombol Batalkan Antrian (hanya untuk status menunggu/menunggu_verifikasi/dilewati)
          if (status == 'menunggu' || status == 'menunggu_verifikasi' || status == 'dilewati') ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await ConfirmationDialog.show(
                    title: 'Batalkan Antrian?',
                    message: 'Apakah Anda yakin ingin membatalkan antrian ${antrian['queueNumber']}?',
                    type: ConfirmationType.danger,
                    confirmText: 'Ya, Batalkan',
                    cancelText: 'Tidak',
                  );

                  if (confirm == true) {
                    // Minta alasan pembatalan dengan Modal yang clean
                    final alasanController = TextEditingController();
                    final formKey = GlobalKey<FormState>();
                    
                    final alasan = await Get.dialog<String>(
                      Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: MediaQuery.of(Get.context!).size.width * 0.9,
                          constraints: const BoxConstraints(maxWidth: 400),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header dengan gradient merah
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.shade400,
                                        Colors.red.shade600,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Batalkan Antrian',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Mohon isi alasan pembatalan',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Body - Form alasan
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alasan Pembatalan *',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: alasanController,
                                        decoration: InputDecoration(
                                          hintText: 'Contoh: Pasien tidak datang setelah dipanggil 3x',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF02B1BA),
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Colors.red),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          contentPadding: const EdgeInsets.all(16),
                                        ),
                                        maxLines: 4,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Alasan harus diisi';
                                          }
                                          if (value.trim().length < 10) {
                                            return 'Alasan minimal 10 karakter';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // Action buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => Get.back(result: null),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                                foregroundColor: Colors.grey.shade700,
                                              ),
                                              child: const Text(
                                                'Batal',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (formKey.currentState!.validate()) {
                                                  Get.back(result: alasanController.text.trim());
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: const Text(
                                                'Batalkan Antrian',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    if (alasan != null && alasan.isNotEmpty) {
                      controller.batalkanAntrian(
                        antrianId: antrian['id'],
                        alasan: alasan,
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return '-';
      }
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
}
