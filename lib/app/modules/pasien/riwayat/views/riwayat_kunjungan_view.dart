import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/riwayat_kunjungan_model.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/riwayat_kunjungan_controller.dart';
import 'detail_riwayat_view.dart';

class RiwayatKunjunganView extends GetView<RiwayatKunjunganController> {
  const RiwayatKunjunganView({Key? key}) : super(key: key);

  final List<String> poliOptions = const [
    'Semua',
    'Poli Umum',
    'Poli Gigi',
    'Poli KIA',
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(RiwayatKunjunganController());
    
    return Obx(() {
      final riwayatList = controller.riwayatList;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Riwayat Kunjungan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF02B1BA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Berikut adalah daftar riwayat kunjungan dan ringkasan pemeriksaan Anda di Puskesmas.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Filter Bulan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.availableBulan.map((bulan) {
                    final isSelected = controller.selectedBulan.value == bulan;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(bulan),
                        selected: isSelected,
                        onSelected: (selected) {
                          controller.setSelectedBulan(bulan);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF02B1BA).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFF64748B),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Filter Poli',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: poliOptions.map((poli) {
                    final isSelected = controller.selectedPoli.value == poli;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(poli),
                        selected: isSelected,
                        onSelected: (selected) {
                          controller.setSelectedPoli(poli);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF02B1BA).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFF64748B),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF02B1BA)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF02B1BA), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.assignment,
                      label: 'Total Kunjungan',
                      value: '${riwayatList.length}',
                      color: const Color(0xFF02B1BA),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                    _buildSummaryItem(
                      icon: Icons.calendar_month,
                      label: 'Periode',
                      value: controller.selectedBulan.value == 'Semua' ? '6 Bulan' : '1 Bulan',
                      color: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Daftar Kunjungan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(height: 12),

              if (riwayatList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada data kunjungan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...riwayatList.map((riwayat) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRiwayatCard(context, riwayat),
                    )),
            ],
          ),
        ),
      ),
    );
    });
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatCard(BuildContext context, RiwayatKunjunganModel riwayat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: Column(
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
                  Icons.medical_services,
                  color: Color(0xFF02B1BA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riwayat.poli,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMMM yyyy, HH:mm WIB').format(riwayat.tanggalKunjungan),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No: ${riwayat.noAntrean}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(riwayat.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(riwayat.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(riwayat.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Color(0xFF02B1BA)),
              const SizedBox(width: 8),
              Text(
                riwayat.dokter,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.email, size: 18, color: Color(0xFF02B1BA)),
              const SizedBox(width: 8),
              Text(
                riwayat.email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Ringkasan Pemeriksaan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            riwayat.keluhan,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          
          if (riwayat.resep != null && riwayat.resep!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Resep: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${riwayat.resep!.length} item',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          
          if (riwayat.kontrolDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Kontrol: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  DateFormat('dd MMMM yyyy').format(riwayat.kontrolDate!),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Get.to(() => const DetailRiwayatView(), arguments: riwayat);
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFF02B1BA),
                ),
                label: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: Color(0xFF02B1BA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFFFA500); // Orange
      case 'dipanggil':
        return const Color(0xFF2196F3); // Blue
      case 'sedang_dilayani':
        return const Color(0xFF9C27B0); // Purple
      case 'selesai':
        return const Color(0xFF4CAF50); // Green
      case 'dibatalkan':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return 'Menunggu';
      case 'dipanggil':
        return 'Dipanggil';
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
}
