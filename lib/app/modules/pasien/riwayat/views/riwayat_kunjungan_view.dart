import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/riwayat_kunjungan_controller.dart';
import 'detail_pemeriksaan_view.dart';

class RiwayatKunjunganView extends GetView<RiwayatKunjunganController> {
  const RiwayatKunjunganView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(RiwayatKunjunganController());
    
    return Obx(() {
      final filteredList = controller.filteredAntrian;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                child: Obx(() => Row(
                  children: controller.availablePoliList.map((poli) {
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
                )),
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
                      value: '${filteredList.length}',
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

              if (filteredList.isEmpty)
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
                ...filteredList.map((antrian) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRiwayatCard(context, antrian),
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

  Widget _buildRiwayatCard(BuildContext context, AntrianModel antrian) {
    final isCompleted = antrian.status == 'selesai';
    final isCancelled = antrian.status == 'dibatalkan';
    final isDilewati = antrian.status == 'dilewati';
    
    String statusText;
    Color statusColor;
    
    if (isCancelled) {
      statusText = 'Dibatalkan';
      statusColor = const Color(0xFFFF4242);
    } else if (isDilewati) {
      statusText = 'Dilewati';
      statusColor = const Color(0xFFFF5722);
    } else if (isCompleted) {
      statusText = 'Selesai';
      statusColor = const Color(0xFF4CAF50);
    } else {
      statusText = 'Sedang Berlangsung';
      statusColor = const Color(0xFFF97316);
    }
    
    return InkWell(
      onTap: () {
        if (isCancelled) {
          // Jika dibatalkan, tidak bisa dibuka detail
          Get.snackbar(
            'Antrian Dibatalkan',
            'Antrian ini telah dibatalkan. ${antrian.alasanPembatalan != null ? "Alasan: ${antrian.alasanPembatalan}" : ""}',
            backgroundColor: const Color(0xFFFF4242),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.cancel, color: Colors.white),
          );
          return;
        }
        
        if (isDilewati) {
          // Jika dilewati, tampilkan info
          Get.snackbar(
            'Antrian Dilewati',
            'Dilewati oleh: ${antrian.dilewatiOlehNama ?? "Perawat"}. Akan dilayani setelah antrian aktif selesai.',
            backgroundColor: const Color(0xFFFF5722),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          );
          return;
        }
        
        if (isCompleted) {
          Get.to(() => const DetailPemeriksaanView(), arguments: antrian);
        } else {
          Get.snackbar(
            'Info',
            'Kunjungan masih berlangsung',
            backgroundColor: const Color(0xFFF97316),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCancelled 
              ? const Color(0xFFFF4242) 
              : (isCompleted ? const Color(0xFF02B1BA) : const Color(0xFFF97316)), 
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isCancelled ? const Color(0xFFFF4242) : const Color(0xFF02B1BA)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCancelled ? Icons.cancel_outlined : Icons.medical_services,
                    color: isCancelled ? const Color(0xFFFF4242) : const Color(0xFF02B1BA),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        antrian.jenisLayanan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm WIB').format(antrian.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No: ${antrian.queueNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (antrian.nomorBPJS != null && antrian.nomorBPJS!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              size: 12,
                              color: Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'BPJS: ${antrian.nomorBPJS}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
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
            if (isCancelled && antrian.alasanPembatalan != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4242).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF4242).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFFFF4242)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alasan Pembatalan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF4242),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            antrian.alasanPembatalan!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          if (antrian.waktuPembatalan != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 11, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text(
                                  'Dibatalkan: ${DateFormat('dd MMM yyyy, HH:mm').format(antrian.waktuPembatalan!)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (antrian.dibatalkanOleh != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  antrian.dibatalkanOleh == 'perawat' ? Icons.medical_services : Icons.person,
                                  size: 11,
                                  color: const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    antrian.dibatalkanOleh == 'perawat'
                                        ? 'Oleh: Perawat${antrian.dibatalkanOlehNama != null ? ' (${antrian.dibatalkanOlehNama})' : ''}'
                                        : 'Oleh: Anda',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
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
                ),
              ),
            ],
            if (!isCompleted && !isCancelled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFF97316)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 16, color: Color(0xFFF97316)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kunjungan ini masih dalam proses. Silakan cek status antrean untuk detail.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Button Lihat Detail untuk kunjungan yang selesai
            if (isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const DetailPemeriksaanView(), arguments: antrian);
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text(
                    'Lihat Detail Pemeriksaan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
