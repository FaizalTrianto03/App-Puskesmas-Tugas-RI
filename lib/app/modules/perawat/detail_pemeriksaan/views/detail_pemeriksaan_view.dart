import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/quarter_circle_background.dart';

class DetailPemeriksaanView extends StatelessWidget {
  const DetailPemeriksaanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Terima data dari navigator
    final Map<String, dynamic> pasienData = Get.arguments as Map<String, dynamic>;
    final perawatData = pasienData['perawatData'] as Map<String, dynamic>? ?? {};

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Pasien
              _buildSection(
                title: 'Informasi Pasien',
                icon: Icons.person,
                children: [
                  _buildReadOnlyField('Nama Lengkap', pasienData['namaLengkap'] ?? '-'),
                  _buildReadOnlyField('No. Rekam Medis', pasienData['noRekamMedis'] ?? '-'),
                  _buildReadOnlyField('No. Antrian', pasienData['queueNumber'] ?? '-'),
                  _buildReadOnlyField('Poliklinik', pasienData['jenisLayanan'] ?? '-'),
                ],
              ),
              const SizedBox(height: 16),

              // Tanda Vital
              _buildSection(
                title: 'Tanda Vital',
                icon: Icons.favorite,
                children: [
                  _buildReadOnlyField(
                    'Tekanan Darah',
                    '${perawatData['tekananDarahSistolik'] ?? '-'}/${perawatData['tekananDarahDiastolik'] ?? '-'} mmHg',
                  ),
                  _buildReadOnlyField('Nadi', '${perawatData['nadi'] ?? '-'} bpm'),
                  _buildReadOnlyField('Suhu', '${perawatData['suhu'] ?? '-'} °C'),
                  if (perawatData['pernapasan'] != null)
                    _buildReadOnlyField('Pernapasan', '${perawatData['pernapasan']} x/menit'),
                ],
              ),
              const SizedBox(height: 16),

              // Antropometri
              _buildSection(
                title: 'Antropometri',
                icon: Icons.accessibility_new,
                children: [
                  _buildReadOnlyField('Berat Badan', '${perawatData['beratBadan'] ?? '-'} kg'),
                  _buildReadOnlyField('Tinggi Badan', '${perawatData['tinggiBadan'] ?? '-'} cm'),
                  _buildReadOnlyField('IMT', perawatData['imt']?.toString() ?? '-'),
                ],
              ),
              const SizedBox(height: 16),

              // Keluhan & Anamnesis
              _buildSection(
                title: 'Keluhan & Anamnesis',
                icon: Icons.note_alt,
                children: [
                  _buildReadOnlyField('Keluhan Utama', perawatData['keluhanUtama'] ?? pasienData['keluhan'] ?? '-', maxLines: 3),
                  _buildReadOnlyField('Riwayat Penyakit', perawatData['riwayatPenyakit'] ?? 'Tidak ada', maxLines: 3),
                  _buildReadOnlyField('Alergi', perawatData['alergi'] ?? 'Tidak ada', maxLines: 2),
                ],
              ),
              const SizedBox(height: 16),

              // Info Verifikasi
              _buildSection(
                title: 'Informasi Verifikasi',
                icon: Icons.verified,
                children: [
                  _buildReadOnlyField('Diverifikasi Oleh', perawatData['perawatName'] ?? '-'),
                  if (perawatData['verifiedAt'] != null)
                    _buildReadOnlyField(
                      'Waktu Verifikasi',
                      _formatTimestamp(perawatData['verifiedAt']),
                    ),
                  if (pasienData['dokterNama'] != null)
                    _buildReadOnlyField('Dokter Pemeriksa', pasienData['dokterNama'] ?? '-'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      DateTime dateTime;
      if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp.runtimeType.toString().contains('Timestamp')) {
        dateTime = (timestamp as dynamic).toDate();
      } else {
        return '-';
      }
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}
