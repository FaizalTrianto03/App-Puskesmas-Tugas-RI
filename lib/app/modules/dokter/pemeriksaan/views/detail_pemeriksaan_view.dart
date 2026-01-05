import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// View readonly untuk melihat detail pemeriksaan yang sudah selesai
class DetailPemeriksaanView extends StatelessWidget {
  final Map<String, dynamic> pasienData;

  const DetailPemeriksaanView({
    super.key,
    required this.pasienData,
  });

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
          'Detail Pemeriksaan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 16),
            _buildAntrianSection(),
            const SizedBox(height: 16),
            _buildPoliSection(),
            const SizedBox(height: 16),
            _buildTandaVitalSection(),
            const SizedBox(height: 16),
            _buildRiwayatKesehatanSection(),
            const SizedBox(height: 16),
            _buildDiagnosaSection(),
            const SizedBox(height: 16),
            _buildTindakanSection(),
            const SizedBox(height: 16),
            _buildResepObatSection(),
            const SizedBox(height: 16),
            _buildCatatanSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Section Profile Pasien
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF02B1BA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasienData['namaLengkap'] ?? pasienData['nama'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No. RM: ${pasienData['noRekamMedis'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildPembayaranBadge(),
        ],
      ),
    );
  }

  Widget _buildPembayaranBadge() {
    final nomorBPJS = pasienData['nomorBPJS'];
    final isBPJS = nomorBPJS != null && nomorBPJS.toString().isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isBPJS ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isBPJS ? 'BPJS' : 'Umum',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isBPJS ? Colors.green.shade800 : Colors.orange.shade800,
        ),
      ),
    );
  }

  /// Section Nomor Antrian
  Widget _buildAntrianSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF02B1BA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: Color(0xFF02B1BA),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nomor Antrian',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pasienData['queueNumber'] ?? '-',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02B1BA),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Tanggal Periksa',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTanggal(pasienData['createdAt'] ?? pasienData['tanggal']),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section Poli dan Dokter
  Widget _buildPoliSection() {
    final dokterData = pasienData['dokterData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.local_hospital, 'Informasi Poli'),
          const SizedBox(height: 12),
          _buildInfoRow('Poli', pasienData['jenisLayanan'] ?? '-'),
          const Divider(height: 16),
          _buildInfoRow('Dokter', dokterData['dokterNama'] ?? pasienData['dokterNama'] ?? '-'),
          if (dokterData['startedAt'] != null) ...[
            const Divider(height: 16),
            _buildInfoRow('Waktu Periksa', _formatWaktu(dokterData['startedAt'])),
          ],
        ],
      ),
    );
  }

  /// Section Tanda Vital
  Widget _buildTandaVitalSection() {
    final perawatData = pasienData['perawatData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.favorite, 'Tanda Vital'),
          const SizedBox(height: 4),
          Text(
            'Diperiksa oleh: ${perawatData['perawatName'] ?? '-'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Tekanan Darah',
                  '${perawatData['tekananDarahSistolik'] ?? '-'}/${perawatData['tekananDarahDiastolik'] ?? '-'}',
                  'mmHg',
                  Icons.speed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'Suhu',
                  '${perawatData['suhu'] ?? '-'}',
                  '°C',
                  Icons.thermostat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Nadi',
                  '${perawatData['nadi'] ?? '-'}',
                  'x/menit',
                  Icons.favorite_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'Pernapasan',
                  '${perawatData['pernapasan'] ?? '-'}',
                  'x/menit',
                  Icons.air,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Berat Badan',
                  '${perawatData['beratBadan'] ?? '-'}',
                  'kg',
                  Icons.monitor_weight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'Tinggi Badan',
                  '${perawatData['tinggiBadan'] ?? '-'}',
                  'cm',
                  Icons.height,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVitalCard(
            'IMT',
            '${perawatData['imt'] ?? '-'}',
            'kg/m²',
            Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF02B1BA)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Riwayat Kesehatan dari Perawat
  Widget _buildRiwayatKesehatanSection() {
    final perawatData = pasienData['perawatData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.history, 'Riwayat Kesehatan'),
          const SizedBox(height: 12),
          _buildInfoRow('Keluhan Utama', perawatData['keluhanUtama'] ?? pasienData['keluhan'] ?? '-'),
          const Divider(height: 16),
          _buildInfoRow('Riwayat Penyakit', perawatData['riwayatPenyakit'] ?? '-'),
          const Divider(height: 16),
          _buildInfoRow('Alergi', perawatData['alergi'] ?? '-'),
        ],
      ),
    );
  }

  /// Section Diagnosa
  Widget _buildDiagnosaSection() {
    final dokterData = pasienData['dokterData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.medical_services, 'Diagnosa'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dokterData['diagnosis'] ?? dokterData['diagnosa'] ?? pasienData['diagnosis'] ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Tindakan
  Widget _buildTindakanSection() {
    final dokterData = pasienData['dokterData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.healing, 'Tindakan'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dokterData['tindakan'] ?? pasienData['tindakan'] ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Resep Obat
  Widget _buildResepObatSection() {
    final resepObat = pasienData['resepObat'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.medication, 'Resep Obat'),
          const SizedBox(height: 12),
          if (resepObat.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tidak ada resep obat',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...resepObat.asMap().entries.map((entry) {
              final index = entry.key;
              final obat = entry.value as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.only(bottom: index < resepObat.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF02B1BA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF02B1BA),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            obat['namaObat'] ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildObatInfoRow('Dosis', obat['dosis'] ?? '-'),
                    _buildObatInfoRow('Jumlah', '${obat['jumlah'] ?? '-'} ${obat['satuan'] ?? ''}'),
                    _buildObatInfoRow('Aturan Pakai', obat['aturanPakai'] ?? '-'),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildObatInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Catatan Dokter
  Widget _buildCatatanSection() {
    final dokterData = pasienData['dokterData'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.note, 'Catatan Dokter'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dokterData['catatanDokter'] ?? pasienData['catatan'] ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper Widgets
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF02B1BA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF02B1BA)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTanggal(dynamic tanggal) {
    if (tanggal == null) return '-';
    try {
      DateTime dt;
      if (tanggal is Timestamp) {
        dt = tanggal.toDate();
      } else if (tanggal is DateTime) {
        dt = tanggal;
      } else if (tanggal is String) {
        dt = DateTime.parse(tanggal);
      } else {
        return '-';
      }
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return '-';
    }
  }

  String _formatWaktu(dynamic waktu) {
    if (waktu == null) return '-';
    try {
      DateTime dt;
      if (waktu is Timestamp) {
        dt = waktu.toDate();
      } else if (waktu is DateTime) {
        dt = waktu;
      } else if (waktu is String) {
        dt = DateTime.parse(waktu);
      } else {
        return '-';
      }
      return DateFormat('HH:mm', 'id_ID').format(dt);
    } catch (e) {
      return '-';
    }
  }
}
