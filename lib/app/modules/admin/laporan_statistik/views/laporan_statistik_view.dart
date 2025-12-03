import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../laporan/views/laporan_kunjungan_pasien_view.dart';
import '../../laporan/views/laporan_stok_obat_view.dart';
import '../../laporan/views/laporan_keuangan_view.dart';

class LaporanStatistikView extends StatelessWidget {
  const LaporanStatistikView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Laporan & Statistik',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistik Dokter Section
                    _buildSectionHeader(
                      'Statistik Dokter',
                      Icons.medical_services,
                      const Color(0xFF02B1BA),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid([
                      _StatData(
                        icon: Icons.people_outline,
                        title: 'Total Pasien',
                        value: '1,234',
                        subtitle: 'Bulan ini',
                        color: const Color(0xFF02B1BA),
                        trend: '+12%',
                        trendUp: true,
                      ),
                      _StatData(
                        icon: Icons.assignment_outlined,
                        title: 'Rekam Medis',
                        value: '856',
                        subtitle: 'Bulan ini',
                        color: const Color(0xFF4CAF50),
                        trend: '+8%',
                        trendUp: true,
                      ),
                      _StatData(
                        icon: Icons.event_available,
                        title: 'Jadwal Hari Ini',
                        value: '45',
                        subtitle: 'Pasien terdaftar',
                        color: const Color(0xFF9C27B0),
                      ),
                      _StatData(
                        icon: Icons.schedule,
                        title: 'Rata-rata Waktu',
                        value: '15',
                        subtitle: 'Menit/pasien',
                        color: const Color(0xFF3F51B5),
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    // Statistik Perawat Section
                    _buildSectionHeader(
                      'Statistik Perawat',
                      Icons.local_hospital,
                      const Color(0xFF9C27B0),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid([
                      _StatData(
                        icon: Icons.medical_services_outlined,
                        title: 'Total Tindakan',
                        value: '542',
                        subtitle: 'Bulan ini',
                        color: const Color(0xFF9C27B0),
                        trend: '+15%',
                        trendUp: true,
                      ),
                      _StatData(
                        icon: Icons.hotel,
                        title: 'Ruang Rawat',
                        value: '12/20',
                        subtitle: 'Terisi',
                        color: const Color(0xFF3F51B5),
                      ),
                      _StatData(
                        icon: Icons.healing,
                        title: 'Perawatan Luka',
                        value: '89',
                        subtitle: 'Bulan ini',
                        color: const Color(0xFF00BCD4),
                      ),
                      _StatData(
                        icon: Icons.volunteer_activism,
                        title: 'Vaksinasi',
                        value: '234',
                        subtitle: 'Bulan ini',
                        color: const Color(0xFF4CAF50),
                        trend: '+22%',
                        trendUp: true,
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    // Statistik Apoteker Section
                    _buildSectionHeader(
                      'Statistik Apoteker',
                      Icons.medication,
                      const Color(0xFFFFA726),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid([
                      _StatData(
                        icon: Icons.warning_amber_outlined,
                        title: 'Stok Menipis',
                        value: '12',
                        subtitle: 'Item obat',
                        color: const Color(0xFFFF4242),
                      ),
                      _StatData(
                        icon: Icons.inventory_2_outlined,
                        title: 'Stok Aman',
                        value: '156',
                        subtitle: 'Item obat',
                        color: const Color(0xFF4CAF50),
                      ),
                      _StatData(
                        icon: Icons.receipt_long,
                        title: 'Resep Diproses',
                        value: '423',
                        subtitle: 'Bulan ini',
                        color: const Color(0xFF02B1BA),
                        trend: '+10%',
                        trendUp: true,
                      ),
                      _StatData(
                        icon: Icons.alarm,
                        title: 'Expired Soon',
                        value: '8',
                        subtitle: '< 30 hari',
                        color: const Color(0xFFFFA726),
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    // Laporan Ringkasan
                    _buildSectionHeader(
                      'Laporan Ringkasan',
                      Icons.summarize,
                      const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      context,
                      'Laporan Kunjungan Pasien',
                      'Data kunjungan pasien bulan ini',
                      Icons.people,
                      const Color(0xFF02B1BA),
                      const LaporanKunjunganPasienView(),
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      context,
                      'Laporan Stok Obat',
                      'Inventaris obat dan alat kesehatan',
                      Icons.inventory,
                      const Color(0xFFFFA726),
                      const LaporanStokObatView(),
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      context,
                      'Laporan Keuangan',
                      'Pendapatan dan pengeluaran puskesmas',
                      Icons.account_balance_wallet,
                      const Color(0xFF4CAF50),
                      const LaporanKeuanganView(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(List<_StatData> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat.icon, color: stat.color, size: 20),
                  ),
                  const Spacer(),
                  if (stat.trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stat.trendUp!
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : const Color(0xFFFF4242).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stat.trendUp!
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 12,
                            color: stat.trendUp!
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF4242),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            stat.trend!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: stat.trendUp!
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF4242),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stat.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return InkWell(
      onTap: () {
        Get.to(() => destination);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
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
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final String? trend;
  final bool? trendUp;

  _StatData({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.trend,
    this.trendUp,
  });
}
