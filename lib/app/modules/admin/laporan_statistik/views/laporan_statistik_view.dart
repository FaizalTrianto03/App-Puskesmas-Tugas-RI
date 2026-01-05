import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../laporan/views/laporan_kunjungan_pasien_view.dart';
import '../../laporan/views/laporan_stok_obat_view.dart';
import '../../laporan/views/laporan_keuangan_view.dart';
import '../controllers/laporan_statistik_controller.dart';

class LaporanStatistikView extends StatelessWidget {
  const LaporanStatistikView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LaporanStatistikController());
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF02B1BA),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              Obx(() => controller.isRefreshing.value
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => controller.refreshStatistics(),
                    ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.analytics_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        monthYear,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Laporan & Statistik',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monitoring kinerja Puskesmas secara real-time',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 400,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF02B1BA),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mengambil data dari server...',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Overview Cards
                    _buildOverviewSection(controller),
                    
                    const SizedBox(height: 24),
                    
                    // Statistik Per Role
                    _buildRoleStatsSection(controller),
                    
                    const SizedBox(height: 24),
                    
                    // Laporan Detail Navigation
                    _buildDetailReportsSection(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(LaporanStatistikController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF02B1BA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Color(0xFF02B1BA),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Overview Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Big stat card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02B1BA).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      icon: Icons.people_alt_rounded,
                      value: controller.jadwalHariIni.value.toString(),
                      label: 'Pasien Hari Ini',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildOverviewItem(
                      icon: Icons.check_circle_rounded,
                      value: controller.totalPasienDilayani.value.toString(),
                      label: 'Sudah Dilayani',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      icon: Icons.hourglass_top_rounded,
                      value: controller.verifikasiHariIni.value.toString(),
                      label: 'Menunggu Verifikasi',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildOverviewItem(
                      icon: Icons.timer_rounded,
                      value: '${controller.rataRataWaktu.value} mnt',
                      label: 'Rata-rata Tunggu',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleStatsSection(LaporanStatistikController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Color(0xFF9C27B0),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Statistik Per Peran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Dokter Card
        _buildRoleCard(
          title: 'Dokter',
          icon: Icons.medical_services_rounded,
          color: const Color(0xFF02B1BA),
          stats: [
            _RoleStat('Pasien Dilayani', controller.totalPasienDilayani.value.toString(), Icons.people),
            _RoleStat('Rekam Medis', controller.totalRekamMedis.value.toString(), Icons.assignment),
            _RoleStat('Jadwal Hari Ini', controller.jadwalHariIni.value.toString(), Icons.event),
            _RoleStat('Rata-rata Waktu', '${controller.rataRataWaktu.value} mnt', Icons.timer),
          ],
          trend: controller.trendPasien.value,
        ),
        
        const SizedBox(height: 12),
        
        // Perawat Card
        _buildRoleCard(
          title: 'Perawat',
          icon: Icons.local_hospital_rounded,
          color: const Color(0xFF9C27B0),
          stats: [
            _RoleStat('Total Verifikasi', controller.totalTindakan.value.toString(), Icons.fact_check),
            _RoleStat('Verifikasi Hari Ini', controller.verifikasiHariIni.value.toString(), Icons.today),
            _RoleStat('Ruang Terisi', '${controller.ruanganTerisi.value}/${controller.totalRuangan.value}', Icons.hotel),
            _RoleStat('Total Ruangan', controller.totalRuangan.value.toString(), Icons.meeting_room),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Apoteker Card
        _buildRoleCard(
          title: 'Apoteker',
          icon: Icons.medication_rounded,
          color: const Color(0xFFFFA726),
          stats: [
            _RoleStat('Resep Diproses', controller.resepDiproses.value.toString(), Icons.receipt_long),
            _RoleStat('Stok Aman', controller.stokAman.value.toString(), Icons.check_circle),
            _RoleStat('Stok Menipis', controller.stokMenipis.value.toString(), Icons.warning, isWarning: true),
            _RoleStat('Expired Soon', controller.expiredSoon.value.toString(), Icons.alarm, isWarning: controller.expiredSoon.value > 0),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<_RoleStat> stats,
    String? trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (trend != null && trend.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Stats Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: stats.map((stat) {
                return Expanded(
                  child: _buildStatItem(stat, color),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(_RoleStat stat, Color color) {
    final displayColor = stat.isWarning ? const Color(0xFFFF4242) : color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: displayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(stat.icon, color: displayColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.summarize_rounded,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Laporan Detail',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildReportTile(
          title: 'Laporan Kunjungan Pasien',
          subtitle: 'Analisis kunjungan, tren, dan statistik pasien',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF02B1BA),
          features: ['Grafik Kunjungan', 'Per Poli', 'BPJS vs Umum'],
          destination: const LaporanKunjunganPasienView(),
        ),
        
        const SizedBox(height: 12),
        
        _buildReportTile(
          title: 'Laporan Stok Obat',
          subtitle: 'Monitoring inventaris dan status obat',
          icon: Icons.medication_rounded,
          color: const Color(0xFFFFA726),
          features: ['Stok Real-time', 'Alert Menipis', 'Expired Soon'],
          destination: const LaporanStokObatView(),
        ),
        
        const SizedBox(height: 12),
        
        _buildReportTile(
          title: 'Laporan Keuangan',
          subtitle: 'Pendapatan dari penjualan obat',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF4CAF50),
          features: ['Total Pendapatan', 'BPJS vs Umum', 'Transaksi'],
          destination: const LaporanKeuanganView(),
        ),
      ],
    );
  }

  Widget _buildReportTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> features,
    required Widget destination,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => destination),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: features.map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleStat {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  _RoleStat(this.label, this.value, this.icon, {this.isWarning = false});
}
