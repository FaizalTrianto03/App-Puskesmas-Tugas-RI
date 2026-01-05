import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../widgets/quarter_circle_background.dart';

/// Detail Pemeriksaan - Readonly view of completed visit
/// Displays all examination data without any action buttons
class DetailPemeriksaanView extends StatelessWidget {
  const DetailPemeriksaanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final antrian = Get.arguments as AntrianModel;
    
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
          'Detail Pemeriksaan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Selesai Card
              _buildStatusCard(antrian),
              const SizedBox(height: 16),

              // Progress Timeline
              _buildProgressTimeline(antrian),
              const SizedBox(height: 24),

              // Detail Pemeriksaan Perawat
              _buildPemeriksaanPerawatSection(antrian.perawatData),
              const SizedBox(height: 24),

              // Detail Pemeriksaan Dokter
              _buildPemeriksaanDokterSection(antrian),
              const SizedBox(height: 24),

              // Resep Obat
              _buildResepObatSection(antrian.resepObat),
              const SizedBox(height: 24),

              // Status Apoteker
              _buildApotekerSection(antrian.apotekerData),
              const SizedBox(height: 24),

              // Pembayaran Summary
              _buildPembayaranSummary(antrian),
              const SizedBox(height: 24),

              // Detail Pendaftaran
              _buildDetailPendaftaran(antrian),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(AntrianModel antrian) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF66BB6A),
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    antrian.queueNumber,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PELAYANAN SELESAI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDate(antrian.createdAt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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

  Widget _buildProgressTimeline(AntrianModel antrian) {
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

          // Timeline Steps - All completed
          _buildTimelineStep(
            icon: Icons.person_outline,
            title: 'Pendaftaran',
            subtitle: 'Antrian terdaftar',
            timestamp: antrian.createdAt,
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.health_and_safety,
            title: 'Pemeriksaan Perawat',
            subtitle: antrian.perawatData?['perawatName'] != null
                ? 'Selesai dilayani oleh ${antrian.perawatData?['perawatName']}'
                : 'Selesai dilayani',
            timestamp: antrian.perawatData?['verifiedAt'],
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.medical_services,
            title: 'Pemeriksaan Dokter',
            subtitle: antrian.dokterData?['dokterNama'] != null
                ? 'Selesai dilayani oleh ${antrian.dokterData?['dokterNama']}'
                : 'Selesai dilayani',
            timestamp: antrian.dokterData?['completedAt'] ?? antrian.dokterData?['startedAt'],
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.medication,
            title: 'Pengambilan Obat',
            subtitle: antrian.apotekerData?['apotekerNama'] != null
                ? 'Obat disiapkan oleh ${antrian.apotekerData?['apotekerNama']}'
                : 'Selesai dilayani',
            timestamp: antrian.apotekerData?['waktuSiap'],
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.check_circle,
            title: 'Selesai',
            subtitle: 'Pelayanan selesai',
            timestamp: antrian.updatedAt,
            isCompleted: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    dynamic timestamp,
    required bool isCompleted,
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

    const indicatorColor = Color(0xFF02B1BA);
    const iconColor = Colors.white;
    const textColor = Color(0xFF1E293B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: const Color(0xFF02B1BA).withOpacity(0.5),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (timeText.isNotEmpty)
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF02B1BA),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPemeriksaanPerawatSection(Map<String, dynamic>? perawatData) {
    final hasData = perawatData != null &&
        perawatData.values.any((value) => value != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasData
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
                  color: hasData
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
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Data pemeriksaan tidak tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
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
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['nadi'] != null) ...[
              _buildDetailRow('Nadi:', '${perawatData['nadi']} x/menit'),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['suhu'] != null) ...[
              _buildDetailRow('Suhu:', '${perawatData['suhu']}°C'),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['pernapasan'] != null) ...[
              _buildDetailRow('Pernapasan:', '${perawatData['pernapasan']} x/menit'),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
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
              _buildDetailRow('Berat Badan:', '${perawatData['beratBadan']} kg'),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['tinggiBadan'] != null) ...[
              _buildDetailRow('Tinggi Badan:', '${perawatData['tinggiBadan']} cm'),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['imt'] != null) ...[
              _buildDetailRow('IMT:', '${perawatData['imt']} kg/m²'),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
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
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['riwayatPenyakit'] != null) ...[
              _buildDetailRow('Riwayat Penyakit:', perawatData['riwayatPenyakit']),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            if (perawatData['alergi'] != null) ...[
              _buildDetailRow('Alergi:', perawatData['alergi']),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPemeriksaanDokterSection(AntrianModel antrian) {
    final dokterData = antrian.dokterData;
    final dokterNama = antrian.dokterNama ?? 'Dokter';

    final hasResultData = dokterData != null &&
        (dokterData['diagnosis'] != null ||
            dokterData['tindakan'] != null ||
            dokterData['catatanDokter'] != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasResultData
              ? const Color(0xFF2196F3).withOpacity(0.5)
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
                  color: hasResultData
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: hasResultData ? const Color(0xFF2196F3) : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hasil Pemeriksaan Dokter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasResultData)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Data pemeriksaan tidak tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Info dokter yang memeriksa
            _buildDetailRow('Dokter:', dokterData?['dokterNama'] ?? dokterNama),
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),

            // Waktu pemeriksaan
            if (dokterData?['startedAt'] != null || dokterData?['completedAt'] != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu Mulai',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dokterData?['startedAt'] != null
                              ? _formatTimestamp(dokterData?['startedAt'])
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
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dokterData?['completedAt'] != null
                                ? _formatTimestamp(dokterData?['completedAt'])
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
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            // Anamnesis
            if (dokterData?['anamnesis'] != null) ...[
              _buildDetailRow('Anamnesis:', dokterData?['anamnesis']),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            // Diagnosis
            if (dokterData?['diagnosis'] != null) ...[
              _buildDetailRow('Diagnosis:', dokterData?['diagnosis']),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            // Tindakan
            if (dokterData?['tindakan'] != null) ...[
              _buildDetailRow('Tindakan:', dokterData?['tindakan']),
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            ],
            // Catatan dokter
            if (dokterData?['catatanDokter'] != null) ...[
              _buildDetailRow('Catatan:', dokterData?['catatanDokter']),
            ],
            // Perlu rawat inap indicator
            if (antrian.perluRawatInap == true) ...[
              const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_hospital, color: Color(0xFFFF5722), size: 20),
                    SizedBox(width: 8),
                    Expanded(
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
    final hasData = resepObat != null && resepObat.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasData
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
                  color: hasData
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
              Text(
                hasData ? 'Resep Obat (${resepObat!.length} item)' : 'Resep Obat',
                style: const TextStyle(
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
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Tidak ada resep obat',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...resepObat!.asMap().entries.map((entry) {
              final index = entry.key;
              final obat = entry.value as Map<String, dynamic>;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
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
                        _buildDetailRow('Jumlah:', obat['jumlah']?.toString() ?? '-'),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      ),
      child: Column(
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
                  Icons.local_pharmacy,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
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
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Obat Sudah Diambil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info apoteker jika sudah ada
          if (apotekerData != null && apotekerData['apotekerNama'] != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            _buildDetailRow('Apoteker:', apotekerData['apotekerNama']),
          ],
          if (apotekerData != null && apotekerData['waktuSiap'] != null) ...[
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
            _buildDetailRow('Siap pada:', _formatTimestamp(apotekerData['waktuSiap'])),
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
        ],
      ),
    );
  }

  Widget _buildPembayaranSummary(AntrianModel antrian) {
    final isBPJS = antrian.nomorBPJS != null && antrian.nomorBPJS!.isNotEmpty;
    final pembayaranData = antrian.pembayaranData;
    
    // Ambil biaya dari pembayaranData atau default 0
    final totalObat = pembayaranData?['totalObat'] ?? 0;
    final totalLayanan = pembayaranData?['totalLayanan'] ?? 0;
    final total = pembayaranData?['totalBayar'] ?? (totalObat + totalLayanan);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 2,
        ),
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
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Lunas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (isBPJS)
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
                          'No. BPJS: ${antrian.nomorBPJS ?? '-'}',
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
            )
          else ...[
            // Detail Biaya
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
                        _formatCurrency(totalLayanan),
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
                        _formatCurrency(totalObat),
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
                        _formatCurrency(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Metode pembayaran
          if (pembayaranData?['metodePembayaran'] != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Metode:', pembayaranData?['metodePembayaran']),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailPendaftaran(AntrianModel antrian) {
    return Container(
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
          _buildDetailRow('Poli Tujuan:', antrian.jenisLayanan),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
          _buildDetailRow('Dokter:', antrian.dokterNama ?? '-'),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
          _buildDetailRow('Tanggal:', _formatDate(antrian.createdAt)),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
          _buildDetailRow('Waktu Daftar:', _formatTime(antrian.createdAt)),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
          _buildDetailRow(
            'Pembayaran:',
            antrian.nomorBPJS != null && antrian.nomorBPJS!.isNotEmpty
                ? 'BPJS (${antrian.nomorBPJS})'
                : 'Umum',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
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
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dt;
      if (timestamp is DateTime) {
        dt = timestamp;
      } else if (timestamp is Timestamp) {
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

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
