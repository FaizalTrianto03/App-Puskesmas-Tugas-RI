import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../../notifikasi/views/dokter_notifikasi_list_view.dart';
import '../../rekam_medis/views/rekam_medis_detail_view.dart';
import '../../settings/views/dokter_settings_view.dart';
import '../controllers/dokter_dashboard_controller.dart';

class DokterDashboardView extends GetView<DokterDashboardController> {
  const DokterDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject controller
    Get.lazyPut(() => DokterDashboardController());
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
            'Dashboard Dokter',
            style: TextStyle(
              color: Color(0xFF02B1BA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF02B1BA),
                    size: 28,
                  ),
                  onPressed: () {
                    Get.to(() => const DokterNotifikasiListView());
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4242),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildStatisticCards(),
                      const SizedBox(height: 24),
                      _buildTabBar(),
                      const SizedBox(height: 16),
                      _buildTabContent(context),
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
        Get.to(() => const DokterSettingsView());
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
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.userRole.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
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
          const Color(0xFF02B1BA)
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          controller.getAntrianMenungguCount().toString(), 
          'Sisa', 
          const Color(0xFFFF9800)
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          controller.getAntrianSelesaiCount().toString(), 
          'Selesai', 
          const Color(0xFF4CAF50)
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
  
  Widget _buildTabBar() {
    return Obx(() => Container(
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.currentTabIndex.value == 0
                      ? const Color(0xFF02B1BA)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Saat Ini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: controller.currentTabIndex.value == 0
                        ? Colors.white
                        : const Color(0xFF02B1BA),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.currentTabIndex.value == 1
                      ? const Color(0xFF02B1BA)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Selesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: controller.currentTabIndex.value == 1
                        ? Colors.white
                        : const Color(0xFF02B1BA),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
  
  Widget _buildTabContent(BuildContext context) {
    return Obx(() {
      if (controller.currentTabIndex.value == 0) {
        // Tab "Saat Ini"
        return _buildSaatIniList(context);
      } else {
        // Tab "Selesai"
        return _buildSelesaiList(context);
      }
    });
  }
  
  Widget _buildSaatIniList(BuildContext context) {
    return Obx(() {
      final antrianMenunggu = controller.antrianMenunggu;
      final antrianSedangDilayani = controller.antrianSedangDilayani;
      
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (antrianMenunggu.isEmpty && antrianSedangDilayani.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Tidak ada antrian saat ini'),
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...antrianSedangDilayani.map((antrian) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAntrianCard(
                context: context,
                antrian: antrian,
                status: 'Sedang Dilayani',
                statusColor: const Color(0xFF2196F3),
              ),
            );
          }).toList(),
          ...antrianMenunggu.map((antrian) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAntrianCard(
                context: context,
                antrian: antrian,
                status: 'Menunggu',
                statusColor: const Color(0xFFFF9800),
              ),
            );
          }).toList(),
        ],
      );
    });
  }
  
  Widget _buildSelesaiList(BuildContext context) {
    return Obx(() {
      final antrianSelesai = controller.antrianSelesai;
      
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (antrianSelesai.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Belum ada pasien yang selesai'),
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: antrianSelesai.map((antrian) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAntrianCard(
              context: context,
              antrian: antrian,
              status: 'Selesai',
              statusColor: const Color(0xFF4CAF50),
              isSelesai: true,
            ),
          );
        }).toList(),
      );
    });
  }
  
  Widget _buildAntrianCard({
    required BuildContext context,
    required Map<String, dynamic> antrian,
    required String status,
    required Color statusColor,
    bool isSelesai = false,
  }) {
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
                  status,
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
          const SizedBox(height: 12),
          if (status == 'Menunggu') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.mulaiPelayanan(antrian);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B1BA),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.medical_services, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Mulai Pelayanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (status == 'Sedang Dilayani') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.navigateToFormPemeriksaan(antrian);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.medical_information, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Lihat Rekam Medis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isSelesai) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => RekamMedisDetailView(
                    pasienData: antrian,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B1BA),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.visibility, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}