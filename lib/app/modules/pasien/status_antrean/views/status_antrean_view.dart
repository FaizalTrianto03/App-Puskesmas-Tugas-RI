import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
        scrolledUnderElevation: 0,
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
              child: CircularProgressIndicator(color: Color(0xFF02B1BA)),
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
            border: Border.all(color: const Color(0xFF02B1BA), width: 2),
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
                    final result = await Get.to(
                      () => const PasienPendaftaranView(),
                    );
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
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Nomor Antrian Besar dengan Gradient Bubble
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF02B1BA), Color(0xFF4DD4DB)],
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
                          Obx(
                            () => Text(
                              controller.antrianData.value?.queueNumber ??
                                  'Loading...',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF4242),
                                letterSpacing: 4,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Obx(() => _buildStatusBadge()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Warning Section untuk status dilewati atau dibatalkan
            Obx(() => _buildWarningSection()),

            const SizedBox(height: 16),

            // Detail Pendaftaran - Dipindah ke atas karena penting
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF02B1BA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFF02B1BA),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Detail Pendaftaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _buildDetailRow(
                      'Nama:',
                      controller.userProfile.value?.namaLengkap ?? 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'NIK:',
                      controller.userProfile.value?.nik ?? 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'Tanggal Lahir:',
                      controller.userProfile.value?.tanggalLahir ?? 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'Jenis Kelamin:',
                      controller.userProfile.value?.jenisKelamin == 'L'
                          ? 'Laki-laki'
                          : 'Perempuan',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'No. HP:',
                      controller.userProfile.value?.noHp ?? 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'Poli Tujuan:',
                      controller.antrianData.value?.jenisLayanan ?? 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'Dokter:',
                      controller.antrianData.value?.dokterNama ?? 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'Tanggal:',
                      controller.antrianData.value != null
                          ? _formatDate(controller.antrianData.value!.createdAt)
                          : 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(
                    () => _buildDetailRow(
                      'Waktu Daftar:',
                      controller.antrianData.value != null
                          ? _formatTime(controller.antrianData.value!.createdAt)
                          : 'Memuat...',
                    ),
                  ),
                  const Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Color(0xFFE2E8F0),
                  ),
                  Obx(() {
                    final nomorBPJS = controller.antrianData.value?.nomorBPJS;
                    return _buildDetailRow(
                      'Pembayaran:',
                      nomorBPJS != null && nomorBPJS.isNotEmpty
                          ? 'BPJS ($nomorBPJS)'
                          : 'Umum',
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF02B1BA).withOpacity(0.3),
                  width: 1,
                ),
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
                          'Progress Pemeriksaan',
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
                        backgroundColor: const Color(
                          0xFF02B1BA,
                        ).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF02B1BA),
                        ),
                        minHeight: 8,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Obx(() {
                    final posisi = controller.queuePosition.value;
                    // Hanya tampilkan jika masih ada antrean di depan (posisi > 1)
                    if (posisi <= 1) {
                      return const SizedBox.shrink();
                    }

                    final sisaAntrean = (posisi - 1).toString();
                    final estStr = controller.estimatedTime.value;
                    final isSegera = estStr == '0' || estStr.isEmpty;
                    final estimasiValue = isSegera ? 'Segera' : estStr;
                    final estimasiSubtitle = isSegera ? '' : 'Menit';

                    return Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            'Sisa Antrean',
                            sisaAntrean,
                            '',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProgressCard(
                            'Estimasi',
                            estimasiValue,
                            estimasiSubtitle,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline Progress 5 Tahap
            _buildProgressTimeline(),
            const SizedBox(height: 24),

            // Detail Pemeriksaan Perawat
            Obx(
              () => _buildPemeriksaanPerawatSection(
                controller.antrianData.value?.perawatData,
              ),
            ),
            const SizedBox(height: 24),

            // Detail Pemeriksaan Dokter
            Obx(
              () => _buildPemeriksaanDokterSection(
                controller.antrianData.value?.dokterData,
              ),
            ),
            const SizedBox(height: 24),

            // Resep Obat
            Obx(
              () => _buildResepObatSection(
                controller.antrianData.value?.resepObat,
              ),
            ),
            const SizedBox(height: 24),

            // Status Apoteker
            Obx(
              () => _buildApotekerSection(
                controller.antrianData.value?.apotekerData,
              ),
            ),
            const SizedBox(height: 24),

            // Pembayaran Section
            Obx(() => _buildPembayaranSection()),
            const SizedBox(height: 24),
          ],
        ),
      ),
        ),
        // Bottom Navbar untuk Batalkan Antrian
        Obx(() {
          if (!controller.canCancelQueue()) {
            return const SizedBox.shrink();
          }
          
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: controller.showPembatalanModal,
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text(
                    'Batalkan Antrian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4242),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWarningSection() {
    final status = controller.antrianData.value?.status ?? '';

    if (status == 'dilewati') {
      final dilewatiOlehNama =
          controller.antrianData.value?.dilewatiOlehNama ?? 'Perawat';
      final dilewatiAt = controller.antrianData.value?.dilewatiAt;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5722).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF5722), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF5722),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Antrian Dilewati Sementara',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh: $dilewatiOlehNama',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anda akan dilayani setelah antrian aktif selesai.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                  if (dilewatiAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dilewati pada: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dilewatiAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else if (status == 'pending') {
      // Status pending - antrian tertunda tapi masih aktif
      // Gunakan data dari perawatData jika ada, atau default
      final pendingOlehNama =
          controller.antrianData.value?.perawatData?['perawatName'] ??
          'Petugas';
      final pendingAt = controller.antrianData.value?.updatedAt;
      final alasanPending = 'Menunggu antrian sebelumnya';
      final posisiAntrian = controller.queuePosition.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC107).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC107), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFFF57C00),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Antrian Tertunda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57C00),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh: $pendingOlehNama',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge posisi antrian
                if (posisiAntrian > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Posisi: $posisiAntrian',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alasan pending
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alasanPending,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Info waktu pending
                  if (pendingAt != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tertunda sejak: ${DateFormat('HH:mm', 'id_ID').format(pendingAt is DateTime ? pendingAt : (pendingAt as Timestamp).toDate())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Estimasi waktu
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: Color(0xFFF57C00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => Text(
                              controller.estimatedTime.value.isNotEmpty &&
                                      controller.estimatedTime.value != '0'
                                  ? 'Estimasi waktu: ~${controller.estimatedTime.value} menit'
                                  : 'Anda akan segera dipanggil',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF57C00),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tips
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Pastikan Anda tetap berada di area tunggu dan siap saat dipanggil.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF795548),
                            fontStyle: FontStyle.italic,
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
      );
    } else if (status == 'dibatalkan') {
      final dibatalkanOleh = controller.antrianData.value?.dibatalkanOleh ?? '';
      final dibatalkanOlehNama =
          controller.antrianData.value?.dibatalkanOlehNama ?? '';
      final alasanPembatalan =
          controller.antrianData.value?.alasanPembatalan ?? '-';
      final waktuPembatalan = controller.antrianData.value?.waktuPembatalan;

      final canceledBy =
          dibatalkanOleh == 'pasien'
              ? 'Anda'
              : (dibatalkanOlehNama.isNotEmpty
                  ? dibatalkanOlehNama
                  : 'Petugas');

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF44336), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cancel,
                    color: Color(0xFFF44336),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Antrian Dibatalkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF44336),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh: $canceledBy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alasan: $alasanPembatalan',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (waktuPembatalan != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dibatalkan pada: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(waktuPembatalan)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusBadge() {
    final status = controller.antrianData.value?.status ?? '';
    String label = 'PENDAFTARAN BERHASIL';
    Color bgColor = Colors.white.withOpacity(0.25);
    Color textColor = Colors.white;

    switch (status) {
      case 'menunggu':
        label = 'MENUNGGU VERIFIKASI';
        break;
      case 'menunggu_perawat':
        label = 'MENUNGGU PERAWAT';
        bgColor = const Color(0xFFFFB547).withOpacity(0.9);
        break;
      case 'dilayani_perawat':
        label = 'SEDANG DILAYANI PERAWAT';
        bgColor = const Color(0xFF4CAF50).withOpacity(0.9);
        break;
      case 'menunggu_dokter':
        label = 'MENUNGGU DOKTER';
        bgColor = const Color(0xFF2196F3).withOpacity(0.9);
        break;
      case 'sedang_dilayani':
      case 'dilayani_dokter':
        label = 'SEDANG DILAYANI DOKTER';
        bgColor = const Color(0xFF4CAF50).withOpacity(0.9);
        break;
      case 'selesai_diperiksa':
        label = 'SELESAI DIPERIKSA';
        bgColor = const Color(0xFF9C27B0).withOpacity(0.9);
        break;
      case 'menunggu_apoteker':
        label = 'MENUNGGU APOTEKER';
        bgColor = const Color(0xFFFFB547).withOpacity(0.9);
        break;
      case 'dilayani_apoteker':
        label = 'SEDANG DILAYANI APOTEKER';
        bgColor = const Color(0xFF4CAF50).withOpacity(0.9);
        break;
      case 'siap_ambil_obat':
        label = 'OBAT SIAP DIAMBIL';
        bgColor = const Color(0xFF00BCD4).withOpacity(0.9);
        break;
      case 'pending':
        label = 'ANTRIAN TERTUNDA';
        bgColor = const Color(0xFFFFC107).withOpacity(0.9);
        textColor = const Color(0xFF795548);
        break;
      case 'dilewati':
        label = 'ANTRIAN DILEWATI';
        bgColor = const Color(0xFFFF5722).withOpacity(0.9);
        break;
      case 'dibatalkan':
        label = 'DIBATALKAN';
        bgColor = const Color(0xFFF44336).withOpacity(0.9);
        break;
      case 'selesai':
        label = 'PELAYANAN SELESAI';
        bgColor = Colors.white;
        textColor = const Color(0xFF02B1BA);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProgressTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
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
                  Icons.timeline,
                  color: Color(0xFF02B1BA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progress Pelayanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline Steps
          Obx(
            () => _buildTimelineStep(
              icon: Icons.person_outline,
              title: 'Pendaftaran',
              subtitle: 'Antrian terdaftar',
              timestamp: controller.antrianData.value?.createdAt,
              isCompleted: true,
              isActive: false,
            ),
          ),
          Obx(
            () => _buildTimelineStep(
              icon: Icons.health_and_safety,
              title: 'Pemeriksaan Perawat',
              subtitle: _getSubtitle('perawat'),
              timestamp:
                  controller.antrianData.value?.perawatData?['verifiedAt'],
              isCompleted: _isStageCompleted('perawat'),
              isActive: _isStageActive('perawat'),
            ),
          ),
          Obx(
            () => _buildTimelineStep(
              icon: Icons.medical_services,
              title: 'Pemeriksaan Dokter',
              subtitle: _getSubtitle('dokter'),
              timestamp:
                  controller.antrianData.value?.dokterData?['completedAt'] ??
                  controller.antrianData.value?.dokterData?['startedAt'],
              isCompleted: _isStageCompleted('dokter'),
              isActive: _isStageActive('dokter'),
            ),
          ),
          Obx(
            () => _buildTimelineStep(
              icon: Icons.medication,
              title: 'Pengambilan Obat',
              subtitle: _getSubtitle('apoteker'),
              timestamp:
                  controller.antrianData.value?.apotekerData?['waktuSiap'] ??
                  controller.antrianData.value?.apotekerData?['confirmedAt'],
              isCompleted: _isStageCompleted('apoteker'),
              isActive: _isStageActive('apoteker'),
            ),
          ),
          Obx(
            () => _buildTimelineStep(
              icon: Icons.check_circle,
              title: 'Selesai',
              subtitle:
                  controller.antrianData.value?.status == 'selesai'
                      ? 'Pelayanan selesai'
                      : 'Menunggu proses',
              timestamp:
                  controller.antrianData.value?.status == 'selesai'
                      ? controller.antrianData.value?.updatedAt
                      : null,
              isCompleted: controller.antrianData.value?.status == 'selesai',
              isActive: controller.antrianData.value?.status == 'selesai',
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }

  bool _isStageCompleted(String stage) {
    final status = controller.antrianData.value?.status ?? '';
    switch (stage) {
      case 'perawat':
        // Perawat selesai jika sudah masuk tahap dokter atau setelahnya
        return status == 'menunggu_dokter' ||
            status == 'dilayani_dokter' ||
            status == 'sedang_dilayani' || // ✅ FIX: Tambahkan sedang_dilayani
            status == 'selesai_diperiksa' ||
            status == 'siap_ambil_obat' ||
            status == 'menunggu_apoteker' ||
            status == 'dilayani_apoteker' ||
            status == 'selesai';
      case 'dokter':
        return status == 'selesai_diperiksa' ||
            status == 'siap_ambil_obat' ||
            status == 'menunggu_apoteker' ||
            status == 'dilayani_apoteker' ||
            status == 'selesai';
      case 'apoteker':
        return status == 'siap_ambil_obat' || status == 'selesai';
      default:
        return false;
    }
  }

  bool _isStageActive(String stage) {
    final status = controller.antrianData.value?.status ?? '';
    switch (stage) {
      case 'perawat':
        return status == 'menunggu_perawat' ||
            status == 'dilayani_perawat' ||
            status == 'menunggu' ||
            status == 'menunggu_verifikasi';
      case 'dokter':
        return status == 'menunggu_dokter' ||
            status == 'dilayani_dokter' ||
            status == 'sedang_dilayani';
      case 'apoteker':
        return status == 'selesai_diperiksa' ||
            status == 'menunggu_apoteker' ||
            status == 'dilayani_apoteker';
      default:
        return false;
    }
  }

  String _getSubtitle(String stage) {
    final status = controller.antrianData.value?.status ?? '';
    final perawatData = controller.antrianData.value?.perawatData;
    final dokterData = controller.antrianData.value?.dokterData;
    final apotekerData = controller.antrianData.value?.apotekerData;

    switch (stage) {
      case 'perawat':
        if (status == 'dilayani_perawat') return 'Sedang dilayani';
        if (status == 'menunggu_perawat' ||
            status == 'menunggu' ||
            status == 'menunggu_verifikasi')
          return 'Menunggu giliran';
        if (_isStageCompleted(stage)) {
          final perawatName = perawatData?['perawatName'];
          return perawatName != null
              ? 'Selesai dilayani oleh $perawatName'
              : 'Selesai dilayani';
        }
        return 'Belum tersedia';
      case 'dokter':
        if (status == 'dilayani_dokter' || status == 'sedang_dilayani')
          return 'Sedang dilayani';
        if (status == 'menunggu_dokter') return 'Menunggu giliran';
        if (_isStageCompleted(stage)) {
          final dokterName = dokterData?['dokterNama'];
          return dokterName != null
              ? 'Selesai dilayani oleh $dokterName'
              : 'Selesai dilayani';
        }
        return 'Belum tersedia';
      case 'apoteker':
        if (status == 'dilayani_apoteker') return 'Sedang menyiapkan obat';
        if (status == 'selesai_diperiksa' || status == 'menunggu_apoteker')
          return 'Menunggu penyiapan obat';
        if (status == 'siap_ambil_obat') {
          final apotekerName = apotekerData?['apotekerNama'];
          return apotekerName != null
              ? 'Obat siap - Disiapkan oleh $apotekerName'
              : 'Obat siap diambil';
        }
        if (_isStageCompleted(stage)) {
          final apotekerName = apotekerData?['apotekerNama'];
          return apotekerName != null
              ? 'Obat disiapkan oleh $apotekerName'
              : 'Selesai dilayani';
        }
        return 'Belum tersedia';
      default:
        return 'Menunggu';
    }
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    dynamic timestamp,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    String timeText = '';
    if (timestamp != null) {
      try {
        DateTime dt;
        if (timestamp is DateTime) {
          dt = timestamp;
        } else if (timestamp is Timestamp) {
          dt = timestamp.toDate();
        } else {
          dt = DateTime.parse(timestamp.toString());
        }
        timeText = DateFormat('HH:mm').format(dt);
      } catch (e) {
        timeText = '';
      }
    }

    Color indicatorColor = Colors.grey.shade300;
    Color iconColor = Colors.grey.shade400;
    Color textColor = Colors.grey.shade600;
    List<BoxShadow>? shadow;

    if (isCompleted) {
      indicatorColor = const Color(0xFF02B1BA);
      iconColor = Colors.white;
      textColor = const Color(0xFF1E293B);
    } else if (isActive) {
      indicatorColor = const Color(0xFFFF4242);
      iconColor = Colors.white;
      textColor = const Color(0xFF1E293B);
      shadow = [
        BoxShadow(
          color: const Color(0xFFFF4242).withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                boxShadow: shadow,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color:
                    isCompleted
                        ? const Color(0xFF02B1BA).withOpacity(0.5)
                        : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (timeText.isNotEmpty)
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isCompleted
                                  ? const Color(0xFF02B1BA)
                                  : Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFFF4242),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sedang dalam proses...',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFFF4242),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(String label, String value, [String? subtitle]) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF84F3EE).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF02B1BA), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                  height: 1,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
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

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }

  Widget _buildPemeriksaanPerawatSection(Map<String, dynamic>? perawatData) {
    final status = controller.antrianData.value?.status ?? '';

    // Section hanya muncul setelah melewati tahap verifikasi/pendaftaran
    final showSection = [
      'menunggu_perawat',
      'dilayani_perawat',
      'menunggu_dokter',
      'sedang_dilayani',
      'dilayani_dokter',
      'selesai_diperiksa',
      'siap_ambil_obat',
      'menunggu_apoteker',
      'dilayani_apoteker',
      'selesai',
    ].contains(status);

    if (!showSection) {
      return const SizedBox.shrink();
    }

    // Cek apakah ada field yang benar-benar terisi (bukan null)
    final hasData =
        perawatData != null && perawatData.values.any((value) => value != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasData
                  ? const Color(0xFF4CAF50).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
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
                  color:
                      hasData
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.monitor_heart,
                  color: hasData ? const Color(0xFF4CAF50) : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hasil Pemeriksaan Perawat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Belum diperiksa perawat',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Perawat Info
            if (perawatData['perawatName'] != null) ...[
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade700, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Diperiksa oleh: ${perawatData['perawatName']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 12),
            ],

            // Tanda Vital Section
            const Text(
              'Tanda Vital',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            if (perawatData['tekananDarahSistolik'] != null &&
                perawatData['tekananDarahDiastolik'] != null) ...[
              _buildDetailRow(
                'Tekanan Darah:',
                '${perawatData['tekananDarahSistolik']}/${perawatData['tekananDarahDiastolik']} mmHg',
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['nadi'] != null) ...[
              _buildDetailRow('Nadi:', '${perawatData['nadi']} x/menit'),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['suhu'] != null) ...[
              _buildDetailRow('Suhu:', '${perawatData['suhu']}°C'),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['pernapasan'] != null) ...[
              _buildDetailRow(
                'Pernapasan:',
                '${perawatData['pernapasan']} x/menit',
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],

            const SizedBox(height: 12),

            // Antropometri Section
            const Text(
              'Antropometri',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            if (perawatData['beratBadan'] != null) ...[
              _buildDetailRow(
                'Berat Badan:',
                '${perawatData['beratBadan']} kg',
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['tinggiBadan'] != null) ...[
              _buildDetailRow(
                'Tinggi Badan:',
                '${perawatData['tinggiBadan']} cm',
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['imt'] != null) ...[
              _buildDetailRow('IMT:', '${perawatData['imt']} kg/m²'),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],

            const SizedBox(height: 12),

            // Keluhan & Anamnesis Section
            const Text(
              'Keluhan & Anamnesis',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            if (perawatData['keluhanUtama'] != null) ...[
              _buildDetailRow('Keluhan Utama:', perawatData['keluhanUtama']),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['riwayatPenyakit'] != null) ...[
              _buildDetailRow(
                'Riwayat Penyakit:',
                perawatData['riwayatPenyakit'],
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            if (perawatData['alergi'] != null) ...[
              _buildDetailRow('Alergi:', perawatData['alergi']),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPemeriksaanDokterSection(Map<String, dynamic>? dokterData) {
    final status = controller.antrianData.value?.status ?? '';
    final dokterNama = controller.antrianData.value?.dokterNama ?? 'Dokter';

    // Cek apakah sudah melewati tahap perawat
    final hasPelewatiPerawat = [
      'menunggu_dokter',
      'sedang_dilayani',
      'dilayani_dokter',
      'selesai_diperiksa',
      'siap_ambil_obat',
      'menunggu_apoteker',
      'dilayani_apoteker',
      'selesai',
    ].contains(status);

    // Jika belum sampai tahap dokter, jangan tampilkan section
    if (!hasPelewatiPerawat) {
      return const SizedBox.shrink();
    }

    // Cek apakah sedang dilayani dokter
    final isSedangDilayani =
        status == 'sedang_dilayani' || status == 'dilayani_dokter';

    // Cek apakah menunggu dokter
    final isMenungguDokter = status == 'menunggu_dokter';

    // Cek apakah ada field diagnosis/tindakan yang benar-benar terisi (bukan null)
    final hasResultData =
        dokterData != null &&
        (dokterData['diagnosis'] != null ||
            dokterData['tindakan'] != null ||
            dokterData['catatanDokter'] != null);

    // Tentukan warna border berdasarkan status
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color iconBgColor = Colors.grey.withOpacity(0.1);
    Color iconColor = Colors.grey;

    if (hasResultData) {
      borderColor = const Color(0xFF2196F3).withOpacity(0.5);
      iconBgColor = const Color(0xFF2196F3).withOpacity(0.1);
      iconColor = const Color(0xFF2196F3);
    } else if (isSedangDilayani) {
      borderColor = const Color(0xFF4CAF50).withOpacity(0.5);
      iconBgColor = const Color(0xFF4CAF50).withOpacity(0.1);
      iconColor = const Color(0xFF4CAF50);
    } else if (isMenungguDokter) {
      borderColor = const Color(0xFFFF9800).withOpacity(0.5);
      iconBgColor = const Color(0xFFFF9800).withOpacity(0.1);
      iconColor = const Color(0xFFFF9800);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medical_services, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                isSedangDilayani
                    ? 'Sedang Diperiksa Dokter'
                    : isMenungguDokter
                    ? 'Menunggu Pemeriksaan Dokter'
                    : 'Hasil Pemeriksaan Dokter',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status sedang dilayani
          if (isSedangDilayani)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Anda sedang diperiksa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dokter: $dokterNama',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          // Status menunggu dokter
          else if (isMenungguDokter)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Menunggu giliran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dokter: $dokterNama',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          // Sudah selesai tapi belum ada data hasil
          else if (!hasResultData)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Belum ada hasil pemeriksaan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          // Sudah ada hasil pemeriksaan
          else ...[
            // Info dokter yang memeriksa
            if (dokterData['dokterNama'] != null) ...[
              _buildDetailRow('Dokter:', dokterData['dokterNama']),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            // Waktu pemeriksaan
            if (dokterData['startedAt'] != null ||
                dokterData['completedAt'] != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu Mulai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dokterData['startedAt'] != null
                              ? _formatTimestamp(dokterData['startedAt'])
                              : '-',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu Selesai',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dokterData['completedAt'] != null
                                ? _formatTimestamp(dokterData['completedAt'])
                                : '-',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            // Anamnesis
            if (dokterData['anamnesis'] != null) ...[
              _buildDetailRow('Anamnesis:', dokterData['anamnesis']),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            // Diagnosis
            if (dokterData['diagnosis'] != null) ...[
              _buildDetailRow('Diagnosis:', dokterData['diagnosis']),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            // Tindakan
            if (dokterData['tindakan'] != null) ...[
              _buildDetailRow('Tindakan:', dokterData['tindakan']),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
            ],
            // Catatan dokter
            if (dokterData['catatanDokter'] != null) ...[
              _buildDetailRow('Catatan:', dokterData['catatanDokter']),
            ],
            // Perlu rawat inap indicator
            if (controller.antrianData.value?.perluRawatInap == true) ...[
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFE2E8F0),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF5722).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      color: Color(0xFFFF5722),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pasien memerlukan rawat inap',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResepObatSection(List<dynamic>? resepObat) {
    final status = controller.antrianData.value?.status ?? '';

    // Section hanya muncul setelah selesai diperiksa dokter
    final showSection = [
      'selesai_diperiksa',
      'siap_ambil_obat',
      'menunggu_apoteker',
      'dilayani_apoteker',
      'selesai',
    ].contains(status);

    if (!showSection) {
      return const SizedBox.shrink();
    }

    // Cek apakah ada data resep yang benar-benar terisi
    final hasData = resepObat != null && resepObat.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasData
                  ? const Color(0xFFFFB547).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
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
                  color:
                      hasData
                          ? const Color(0xFFFFB547).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  color: hasData ? const Color(0xFFFFB547) : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Resep Obat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Belum ada resep obat',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            ...resepObat.asMap().entries.map((entry) {
              final index = entry.key;
              final obat = entry.value as Map<String, dynamic>;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(
                      height: 16,
                      thickness: 0.5,
                      color: Color(0xFFE2E8F0),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obat['namaObat'] ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Jumlah:',
                          obat['jumlah']?.toString() ?? '-',
                        ),
                        if (obat['aturanPakai'] != null) ...[
                          const SizedBox(height: 4),
                          _buildDetailRow('Aturan Pakai:', obat['aturanPakai']),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildApotekerSection(Map<String, dynamic>? apotekerData) {
    final status = controller.antrianData.value?.status ?? '';

    // Section hanya muncul setelah selesai diperiksa dokter
    final showSection = [
      'selesai_diperiksa',
      'siap_ambil_obat',
      'menunggu_apoteker',
      'dilayani_apoteker',
      'selesai',
    ].contains(status);

    if (!showSection) {
      return const SizedBox.shrink();
    }

    // Status obat
    final statusObat = apotekerData?['statusObat'] as String?;
    final isMenungguVerifikasi =
        status == 'selesai_diperiksa' || statusObat == null;
    final isSedangDisiapkan =
        status == 'menunggu_apoteker' || status == 'dilayani_apoteker';
    final isSiapAmbil = status == 'siap_ambil_obat';
    final isSelesai = status == 'selesai';

    // Tentukan warna dan status
    Color borderColor;
    Color iconBgColor;
    Color iconColor;
    String statusText;
    IconData statusIcon;

    if (isSelesai) {
      borderColor = const Color(0xFF4CAF50);
      iconBgColor = const Color(0xFF4CAF50).withOpacity(0.1);
      iconColor = const Color(0xFF4CAF50);
      statusText = 'Obat Sudah Diambil';
      statusIcon = Icons.check_circle;
    } else if (isSiapAmbil) {
      borderColor = const Color(0xFF00BCD4);
      iconBgColor = const Color(0xFF00BCD4).withOpacity(0.1);
      iconColor = const Color(0xFF00BCD4);
      statusText = 'Obat Siap Diambil';
      statusIcon = Icons.check_circle_outline;
    } else if (isSedangDisiapkan) {
      borderColor = const Color(0xFF9C27B0);
      iconBgColor = const Color(0xFF9C27B0).withOpacity(0.1);
      iconColor = const Color(0xFF9C27B0);
      statusText = 'Obat Sedang Disiapkan';
      statusIcon = Icons.hourglass_top;
    } else {
      // Menunggu verifikasi apoteker
      borderColor = const Color(0xFFFF9800).withOpacity(0.5);
      iconBgColor = const Color(0xFFFF9800).withOpacity(0.1);
      iconColor = const Color(0xFFFF9800);
      statusText = 'Menunggu Verifikasi Apoteker';
      statusIcon = Icons.schedule;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.local_pharmacy, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Status Apotek',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child:
                      isSedangDisiapkan
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                iconColor,
                              ),
                            ),
                          )
                          : Icon(statusIcon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      if (isMenungguVerifikasi) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Resep obat akan diverifikasi oleh apoteker',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Button Ambil Obat - hanya aktif setelah bayar
          const SizedBox(height: 16),
          Obx(() {
            final bisaAmbil = controller.bisaAmbilObat;
            final sudahSelesai =
                controller.antrianData.value?.status == 'selesai';

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        bisaAmbil
                            ? () {
                              controller.konfirmasiAmbilObat();
                            }
                            : null,
                    icon: Icon(
                      sudahSelesai ? Icons.check_circle : Icons.medication,
                      size: 20,
                    ),
                    label: Text(
                      sudahSelesai
                          ? 'Obat Telah Diambil'
                          : bisaAmbil
                          ? 'Konfirmasi Sudah Ambil Obat'
                          : 'Ambil Obat',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          bisaAmbil
                              ? const Color(0xFF4CAF50)
                              : sudahSelesai
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: bisaAmbil ? 2 : 0,
                    ),
                  ),
                ),
                // Info ketika tombol disabled
                if (!bisaAmbil && !sudahSelesai && isSiapAmbil) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selesaikan pembayaran terlebih dahulu',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),

          // Keterangan ketika menunggu apoteker
          if (!isSiapAmbil && !isSelesai) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  isMenungguVerifikasi
                      ? 'Menunggu verifikasi apoteker'
                      : 'Obat sedang disiapkan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],

          // Info apoteker jika sudah ada
          if (apotekerData != null && apotekerData['apotekerNama'] != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            _buildDetailRow('Apoteker:', apotekerData['apotekerNama']),
          ],
          if (apotekerData != null && apotekerData['waktuSiap'] != null) ...[
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow(
              'Siap pada:',
              _formatTimestamp(apotekerData['waktuSiap']),
            ),
          ],

          // Catatan dari apoteker
          if (apotekerData != null &&
              apotekerData['catatan'] != null &&
              (apotekerData['catatan'] as String).isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 16,
                        color: const Color(0xFF9C27B0).withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pesan dari Apoteker',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9C27B0).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    apotekerData['catatan'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Ringkasan Biaya - muncul ketika obat siap
          if (isSiapAmbil || isSelesai) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            _buildBiayaRingkasan(),
          ],
        ],
      ),
    );
  }

  Widget _buildBiayaRingkasan() {
    final isBPJS = controller.isBPJS;
    final totalObat = controller.totalBiayaObat;
    final totalLayanan = controller.totalBiayaLayanan;
    final total = totalObat + totalLayanan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isBPJS
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isBPJS
                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                  : const Color(0xFFFF9800).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBPJS ? Icons.verified_user : Icons.receipt_long,
                color:
                    isBPJS ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isBPJS ? 'Ditanggung BPJS' : 'Ringkasan Biaya',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      isBPJS
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          if (!isBPJS) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biaya Layanan',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  controller.formatCurrency(totalLayanan),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biaya Obat',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  controller.formatCurrency(totalObat),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Bayar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  controller.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silakan bayar di kasir saat mengambil obat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Biaya layanan dan obat ditanggung oleh BPJS Kesehatan',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPembayaranSection() {
    // Hanya tampilkan jika sudah siap bayar atau selesai
    if (!controller.siapBayar) {
      return const SizedBox.shrink();
    }

    final isBPJS = controller.isBPJS;
    final sudahDibayar = controller.sudahDibayar;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              sudahDibayar
                  ? const Color(0xFF4CAF50)
                  : (isBPJS
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (sudahDibayar
                    ? const Color(0xFF4CAF50)
                    : (isBPJS
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800)))
                .withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      sudahDibayar
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : (isBPJS
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF9800))
                              .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  sudahDibayar
                      ? Icons.check_circle
                      : (isBPJS ? Icons.verified_user : Icons.payment),
                  color:
                      sudahDibayar
                          ? const Color(0xFF4CAF50)
                          : (isBPJS
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF9800)),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBPJS ? 'Pembayaran BPJS' : 'Pembayaran',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      sudahDibayar
                          ? 'Lunas - Silahkan ambil obat'
                          : 'Menunggu Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            sudahDibayar
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Detail Biaya
          if (!isBPJS) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biaya Layanan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        controller.formatCurrency(controller.totalBiayaLayanan),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biaya Obat',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        controller.formatCurrency(controller.totalBiayaObat),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        controller.formatCurrency(controller.totalPembayaran),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            // BPJS Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ditanggung BPJS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No. BPJS: ${controller.antrianData.value?.nomorBPJS ?? '-'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tombol Bayar/Konfirmasi
          if (!sudahDibayar)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final bisaBayar = controller.bisaBayar;
                    return ElevatedButton(
                      onPressed:
                          (controller.isLoading.value || !bisaBayar)
                              ? null
                              : () => _showKonfirmasiPembayaran(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isBPJS
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: bisaBayar ? 2 : 0,
                      ),
                      child:
                          controller.isLoading.value
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isBPJS ? Icons.verified : Icons.payment,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBPJS
                                        ? 'Konfirmasi Selesai'
                                        : 'Bayar Sekarang',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    );
                  }),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Pembayaran Selesai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showKonfirmasiPembayaran() {
    final isBPJS = controller.isBPJS;
    final totalObat = controller.totalBiayaObat;
    final totalLayanan = controller.totalBiayaLayanan;
    final totalPembayaran = controller.totalPembayaran;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (isBPJS
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800))
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isBPJS ? Icons.verified_user : Icons.payment,
                        color:
                            isBPJS
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      isBPJS ? 'Konfirmasi BPJS' : 'Konfirmasi Pembayaran',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      isBPJS
                          ? 'Layanan Anda ditanggung oleh BPJS Kesehatan.'
                          : 'Pastikan Anda sudah membayar di kasir.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content - Biaya
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoDialogRow(
                        'Biaya Layanan',
                        controller.formatCurrency(totalLayanan),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ),
                      _buildInfoDialogRow(
                        'Biaya Obat',
                        controller.formatCurrency(totalObat),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ),
                      _buildInfoDialogRow(
                        'Total Pembayaran',
                        isBPJS
                            ? 'Gratis (BPJS)'
                            : controller.formatCurrency(totalPembayaran),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info BPJS / Non-BPJS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child:
                    isBPJS
                        ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Ditanggung BPJS Kesehatan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pembayaran di kasir',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.konfirmasiPembayaranSaja();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isBPJS
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isBPJS ? 'Konfirmasi' : 'Sudah Bayar',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildInfoDialogRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF02B1BA) : null,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dt;
      if (timestamp is DateTime) {
        dt = timestamp;
      } else if (timestamp is Timestamp) {
        // Handle Firestore Timestamp
        dt = timestamp.toDate();
      } else if (timestamp is String) {
        dt = DateTime.parse(timestamp);
      } else {
        return '-';
      }
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}
