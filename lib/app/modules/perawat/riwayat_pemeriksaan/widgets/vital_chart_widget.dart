import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pemeriksaan_controller.dart';

class VitalChartWidget extends GetView<RiwayatPemeriksaanController> {
  const VitalChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.chartDataTekananDarah.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada data untuk grafik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grafik akan muncul setelah ada riwayat pemeriksaan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          // Tekanan Darah Chart
          _buildChartSection(
            title: 'Tekanan Darah',
            icon: Icons.favorite,
            color: Colors.red,
            data: controller.chartDataTekananDarah,
            chartBuilder: (data) => _buildTekananDarahChart(data),
          ),
          const SizedBox(height: 24),
          
          // Suhu Tubuh Chart
          _buildChartSection(
            title: 'Suhu Tubuh',
            icon: Icons.thermostat,
            color: Colors.orange,
            data: controller.chartDataSuhuTubuh,
            chartBuilder: (data) => _buildSuhuTubuhChart(data),
          ),
          const SizedBox(height: 24),
          
          // Berat Badan Chart
          _buildChartSection(
            title: 'Berat Badan',
            icon: Icons.monitor_weight,
            color: Colors.indigo,
            data: controller.chartDataBeratBadan,
            chartBuilder: (data) => _buildBeratBadanChart(data),
          ),
        ],
      );
    });
  }

  Widget _buildChartSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> data,
    required Widget Function(List<Map<String, dynamic>>) chartBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Title
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Chart
        chartBuilder(data),
      ],
    );
  }

  /// Tekanan Darah Chart (Sistolik & Diastolik)
  Widget _buildTekananDarahChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();

    // Find max value for scaling
    double maxSistolik = 0;
    for (var item in data) {
      final sistolik = (item['sistolik'] as num).toDouble();
      if (sistolik > maxSistolik) maxSistolik = sistolik;
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(Colors.red, 'Sistolik'),
              const SizedBox(width: 16),
              _buildLegend(Colors.blue, 'Diastolik'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Chart Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.map((item) {
                final sistolik = (item['sistolik'] as num).toDouble();
                final diastolik = (item['diastolik'] as num).toDouble();
                final tanggal = item['tanggal'] as String;
                
                return _buildTekananDarahBar(
                  tanggal: tanggal,
                  sistolik: sistolik,
                  diastolik: diastolik,
                  maxValue: maxSistolik + 20,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTekananDarahBar({
    required String tanggal,
    required double sistolik,
    required double diastolik,
    required double maxValue,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Sistolik bar
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Sistolik
                  Container(
                    width: double.infinity,
                    height: (sistolik / maxValue) * 150,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  // Diastolik (inside sistolik bar)
                  Container(
                    width: double.infinity,
                    height: (diastolik / maxValue) * 150,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Values
          Text(
            '${sistolik.toInt()}/${diastolik.toInt()}',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Date label
          Text(
            tanggal,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Suhu Tubuh Chart
  Widget _buildSuhuTubuhChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();

    // Normal range: 36.5 - 37.5°C
    const double minTemp = 35.0;
    const double maxTemp = 40.0;
    const double normalMin = 36.5;
    const double normalMax = 37.5;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Normal range indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              'Normal: $normalMin - $normalMax°C',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Chart Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.map((item) {
                final suhu = (item['suhu'] as num).toDouble();
                final tanggal = item['tanggal'] as String;
                final isNormal = suhu >= normalMin && suhu <= normalMax;
                
                return _buildSuhuBar(
                  tanggal: tanggal,
                  suhu: suhu,
                  minValue: minTemp,
                  maxValue: maxTemp,
                  isNormal: isNormal,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuhuBar({
    required String tanggal,
    required double suhu,
    required double minValue,
    required double maxValue,
    required bool isNormal,
  }) {
    final normalizedHeight = ((suhu - minValue) / (maxValue - minValue)) * 120;
    
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          Container(
            width: double.infinity,
            height: normalizedHeight,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isNormal
                    ? [Colors.green.shade300, Colors.green.shade600]
                    : [Colors.orange.shade300, Colors.orange.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              suhu.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Date label
          Text(
            tanggal,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Berat Badan Chart
  Widget _buildBeratBadanChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();

    // Find min and max for scaling
    double minBerat = double.infinity;
    double maxBerat = 0;
    
    for (var item in data) {
      final berat = (item['berat'] as num).toDouble();
      if (berat < minBerat) minBerat = berat;
      if (berat > maxBerat) maxBerat = berat;
    }

    // Add padding to range
    minBerat = (minBerat - 5).clamp(0, double.infinity);
    maxBerat = maxBerat + 5;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.map((item) {
          final berat = (item['berat'] as num).toDouble();
          final tanggal = item['tanggal'] as String;
          
          return _buildBeratBar(
            tanggal: tanggal,
            berat: berat,
            minValue: minBerat,
            maxValue: maxBerat,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBeratBar({
    required String tanggal,
    required double berat,
    required double minValue,
    required double maxValue,
  }) {
    final normalizedHeight = ((berat - minValue) / (maxValue - minValue)) * 130;
    
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          Container(
            width: double.infinity,
            height: normalizedHeight,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade300, Colors.indigo.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              berat.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Date label
          Text(
            tanggal,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
