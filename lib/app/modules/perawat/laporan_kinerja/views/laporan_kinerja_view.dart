import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_kinerja_controller.dart';

class LaporanKinerjaView extends GetView<LaporanKinerjaController> {
  const LaporanKinerjaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          'Laporan Kinerja',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF02B1BA)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF02B1BA),
          onRefresh: () => controller.refreshData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodFilter(),
                const SizedBox(height: 16),
                _buildStatisticsGrid(),
                const SizedBox(height: 16),
                _buildPerformanceSummary(),
                const SizedBox(height: 16),
                _buildPoliBreakdown(),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Widget Filter Periode
  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter Periode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Obx(
                () => Text(
                  controller.periodLabel,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip('Semua', 'semua'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Hari Ini', 'hari_ini'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Minggu Ini', 'minggu_ini'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Bulan Ini', 'bulan_ini'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Tahun Ini', 'tahun_ini'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = controller.selectedPeriod.value == value;
    return InkWell(
      onTap: () => controller.changePeriod(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _buildStatCard(
            icon: Icons.people,
            label: 'Total Pasien',
            value: controller.totalPasien.value.toString(),
            color: const Color(0xFF02B1BA),
          ),
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'Terverifikasi',
            value: controller.totalVerifikasi.value.toString(),
            color: const Color(0xFF4CAF50),
          ),
          _buildStatCard(
            icon: Icons.cancel,
            label: 'Dibatalkan',
            value: controller.totalDibatalkan.value.toString(),
            color: const Color(0xFFF44336),
          ),
          _buildStatCard(
            icon: Icons.skip_next,
            label: 'Dilewati',
            value: controller.totalDilewati.value.toString(),
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Kinerja',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02B1BA),
              ),
            ),
            const SizedBox(height: 20),
            _buildPerformanceItem(
              label: 'Tingkat Verifikasi',
              count: controller.totalVerifikasi.value,
              total: controller.totalPasien.value,
              percentage: controller.persentaseVerifikasi,
              color: const Color(0xFF4CAF50),
              icon: Icons.verified,
            ),
            const SizedBox(height: 16),
            _buildPerformanceItem(
              label: 'Tingkat Penyelesaian',
              count: controller.totalRekamMedis.value,
              total: controller.totalPasien.value,
              percentage: controller.persentaseSelesai,
              color: const Color(0xFF2196F3),
              icon: Icons.assignment_turned_in,
            ),
            const SizedBox(height: 16),
            _buildPerformanceItem(
              label: 'Tingkat Pembatalan',
              count: controller.totalDibatalkan.value,
              total: controller.totalPasien.value,
              percentage: controller.persentaseDibatalkan,
              color: const Color(0xFFF44336),
              icon: Icons.cancel_outlined,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF02B1BA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Color(0xFF02B1BA),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan semua pasien terverifikasi sebelum diperiksa dokter.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem({
    required String label,
    required int count,
    required int total,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '$count/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPoliBreakdown() {
    return Obx(() {
      final poliData = controller.poliBreakdown;

      if (poliData.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Belum ada data breakdown poli',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_hospital,
                  size: 22,
                  color: Color(0xFF02B1BA),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Breakdown Per Poli',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02B1BA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...poliData.entries.map((entry) {
              final percentage =
                  controller.totalPasien.value > 0
                      ? (entry.value / controller.totalPasien.value * 100)
                      : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPoliItem(
                  poliName: entry.key,
                  count: entry.value,
                  percentage: percentage,
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildPoliItem({
    required String poliName,
    required int count,
    required double percentage,
  }) {
    // Color rotation for different polis
    final colors = [
      const Color(0xFF02B1BA),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
    ];
    final color = colors[poliName.hashCode.abs() % colors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                poliName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              '$count pasien',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
