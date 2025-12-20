import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../../pendaftaran/views/pasien_pendaftaran_view.dart';
import '../controllers/status_antrean_controller.dart';

class StatusAntreanView extends GetView<StatusAntreanController> {
  const StatusAntreanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          'Status Pasien',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Obx(() {
          // Tampilkan loading saat initial loading
          if (controller.isInitialLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF02B1BA),
              ),
            );
          }
          
          final hasActiveQueue = controller.antrianData.value != null;
          return hasActiveQueue
              ? _buildActiveQueueContent(context)
              : _buildNoQueueContent(context);
        }),
      ),
    );
  }

  Widget _buildNoQueueContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF84F3EE).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF02B1BA),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Belum ada antrean aktif saat ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Silahkan daftar terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Get.to(() => const PasienPendaftaranView());
                    if (result == true && context.mounted) {
                      Get.back(result: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB547),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Daftar Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQueueContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF02B1BA),
                        const Color(0xFF4DD4DB),
                      ],
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -40,
                        right: -35,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: -45,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15,
                        left: -25,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),

                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Antrean Aktif',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(() => Text(
                              controller.antrianData.value?.queueNumber ?? 'Loading...',
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF4242),
                                letterSpacing: 8,
                                height: 1.1,
                              ),
                            )),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'PENDAFTARAN BERHASIL',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    Obx(() {
                      final progress = controller.progressPercentage.value;
                      final progressPercent = (progress * 100).toStringAsFixed(0);
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress Antrean',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Obx(() {
                      final progress = controller.progressPercentage.value;
                      
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFF02B1BA).withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF02B1BA)),
                          minHeight: 8,
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      final posisi = controller.queuePosition.value;
                      final sisaAntrean = posisi > 0 ? (posisi - 1).toString() : '0';

                      final estStr = controller.estimatedTime.value;
                      final isSegera = estStr == '0' || estStr.isEmpty;
                      final estimasiValue = isSegera ? 'Segera' : estStr;
                      final estimasiSubtitle = isSegera ? '' : 'Menit Lagi';

                      return Row(
                        children: [
                          Expanded(
                            child: _buildProgressCard('Sisa Antrean', sisaAntrean),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProgressCard('Estimasi', estimasiValue, estimasiSubtitle),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF02B1BA), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Pendaftaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => _buildDetailRow('Nama:', controller.userProfile.value?.namaLengkap ?? 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('NIK:', controller.userProfile.value?.nik ?? 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Tanggal Lahir:', controller.userProfile.value?.tanggalLahir ?? 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Jenis Kelamin:', controller.userProfile.value?.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('No. HP:', controller.userProfile.value?.noHp ?? 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Alamat:', controller.userProfile.value?.alamat ?? 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Poli Tujuan:', controller.antrianData.value?.jenisLayanan ?? 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Dokter:', _getDokterByPoli(controller.antrianData.value?.jenisLayanan ?? ''))),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Tanggal:', controller.antrianData.value != null ? _formatDate(controller.antrianData.value!.createdAt) : 'Memuat...')),
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    Obx(() => _buildDetailRow('Waktu Daftar:', controller.antrianData.value != null ? _formatTime(controller.antrianData.value!.createdAt) : 'Memuat...')),
                  ],
                ),
              ),
            ],
        ),
    );
  }

  Widget _buildProgressCard(String label, String value, [String? subtitle]) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF84F3EE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02B1BA),
              height: 1.1,
            ),
          ),
          if (subtitle != null)
            const SizedBox(height: 2),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDokterByPoli(String poli) {
    if (poli.contains('Umum')) return 'dr. Faizal Qadri';
    if (poli.contains('Gigi')) return 'drg. Nisa Ayu';
    if (poli.contains('KIA') || poli.contains('KB')) return 'dr. Siti Nurhaliza';
    if (poli.contains('Lansia')) return 'dr. Ahmad Dahlan';
    if (poli.contains('Imunisasi')) return 'dr. Kartini Wijaya';
    return '-';
  }
  
  String _formatDate(DateTime date) {
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                   'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }
}
