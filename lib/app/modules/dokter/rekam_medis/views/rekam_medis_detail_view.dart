import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../data/services/pemeriksaan/pemeriksaan_service.dart';
import 'detail_pemeriksaan_view.dart';

class RekamMedisDetailView extends StatelessWidget {
  final Map<String, dynamic> pasienData;

  const RekamMedisDetailView({
    Key? key,
    required this.pasienData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pemeriksaanService = PemeriksaanService();
    final pemeriksaanTerbaru = pemeriksaanService.getPemeriksaanByPasienId(pasienData['id']);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Rekam Medis Terintegrasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: QuarterCircleBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientCard(),
                    const SizedBox(height: 16),
                    _buildInfoSection(),
                    const SizedBox(height: 16),
                    // Section Pemeriksaan Terbaru (jika ada)
                    _buildPemeriksaanTerbaru(),
                    const SizedBox(height: 16),
                    _buildRiwayatPenyakitSection(),
                    const SizedBox(height: 24),
                    _buildRekamMedisHistory(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF02B1BA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 35,
              color: Color(0xFF02B1BA),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasienData['nama'] ?? 'Nama Pasien',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Usia: ${pasienData['umur'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPemeriksaanTerbaru() {
    final pemeriksaanService = PemeriksaanService();
    final pemeriksaanTerbaru = pemeriksaanService.getPemeriksaanByPasienId(pasienData['id']);

    // Jika tidak ada pemeriksaan terbaru, return empty
    if (pemeriksaanTerbaru == null) {
      return const SizedBox.shrink();
    }

    final tandaVital = pemeriksaanTerbaru['tandaVital'] as Map<String, dynamic>?;
    final obatList = pemeriksaanTerbaru['obatList'] as List<dynamic>?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF8BC34A).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hasil Pemeriksaan Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BARU',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Diagnosa
          _buildPemeriksaanRow(
            'Diagnosa',
            pemeriksaanTerbaru['diagnosa'] ?? '-',
            Icons.assignment,
            const Color(0xFF4CAF50),
          ),
          const Divider(height: 24),
          
          // Dokter Pemeriksa
          _buildPemeriksaanRow(
            'Dokter Pemeriksa',
            pemeriksaanTerbaru['dokter'] ?? '-',
            Icons.medical_information,
            const Color(0xFF00ACC1),
          ),
          const Divider(height: 24),
          
          // Keluhan
          _buildPemeriksaanRow(
            'Keluhan',
            pemeriksaanTerbaru['keluhan'] ?? '-',
            Icons.sick,
            const Color(0xFFFF9800),
          ),
          const Divider(height: 24),
          
          // Tindakan
          _buildPemeriksaanRow(
            'Tindakan',
            pemeriksaanTerbaru['tindakan'] ?? '-',
            Icons.healing,
            const Color(0xFF2196F3),
          ),
          
          if (tandaVital != null) ...[
            const Divider(height: 24),
            _buildTandaVitalSection(tandaVital),
          ],
          
          if (obatList != null && obatList.isNotEmpty) ...[
            const Divider(height: 24),
            _buildObatSection(obatList),
          ],
          
          if (pemeriksaanTerbaru['catatan'] != null && pemeriksaanTerbaru['catatan'].toString().isNotEmpty) ...[
            const Divider(height: 24),
            _buildPemeriksaanRow(
              'Catatan',
              pemeriksaanTerbaru['catatan'],
              Icons.note_alt,
              const Color(0xFF9C27B0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPemeriksaanRow(String label, String value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTandaVitalSection(Map<String, dynamic> tandaVital) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 20),
            const SizedBox(width: 12),
            Text(
              'Tanda Vital',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
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
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildVitalItem('TD', tandaVital['tekananDarah'] ?? '-', 'mmHg'),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildVitalItem('Suhu', tandaVital['suhu'] ?? '-', '°C'),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildVitalItem('Nadi', tandaVital['nadi'] ?? '-', 'x/mnt'),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildVitalItem('RR', tandaVital['pernapasan'] ?? '-', 'x/mnt'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildObatSection(List<dynamic> obatList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication, color: Color(0xFFFF5722), size: 20),
            const SizedBox(width: 12),
            Text(
              'Obat yang Diberikan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...obatList.asMap().entries.map((entry) {
          final index = entry.key;
          final obat = entry.value as Map<String, dynamic>;
          return Container(
            margin: EdgeInsets.only(bottom: index < obatList.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5722),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obat['nama'] ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        obat['dosis'] ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFFC107),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alergi Obat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57C00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pasienData['alergi'] ?? 'Tidak ada',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatPenyakitSection() {
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
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF02B1BA),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Riwayat Penyakit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Jenis Layanan', pasienData['jenisLayanan'] ?? 'Rawat Jalan'),
          const SizedBox(height: 8),
          _buildInfoRow('Golongan Darah', pasienData['golDarah'] ?? 'B+'),
          const SizedBox(height: 8),
          _buildInfoRow('Tinggi / Berat', pasienData['tinggiBerat'] ?? '165 cm / 60 kg'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
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

  Widget _buildRekamMedisHistory(BuildContext context) {
    // Data dummy riwayat pemeriksaan lainnya (bukan yang terbaru)
    final List<Map<String, dynamic>> riwayatLainnya = [
      {
        'tanggal': '5 Desember 2025',
        'tanggalKunjungan': '5 Desember 2025',
        'dokter': 'dr. Sarah Amelia, Sp.S',
        'diagnosa': 'Migrain',
        'keluhan': 'Sakit kepala sebelah kiri, mual',
        'tindakan': 'Pemberian analgesik dan antiemetik',
        'obat': [
          {'nama': 'Paracetamol 500mg', 'dosis': '3x1 tablet/hari'},
          {'nama': 'Domperidone 10mg', 'dosis': '3x1 tablet sebelum makan'},
        ],
        'catatan': 'Istirahat cukup, hindari pemicu migrain',
      },
      {
        'tanggal': '28 November 2025',
        'tanggalKunjungan': '28 November 2025',
        'dokter': 'dr. Ahmad Hidayat, Sp.PD',
        'diagnosa': 'Gastritis Akut',
        'keluhan': 'Nyeri ulu hati, mual',
        'tindakan': 'Pemberian obat maag dan anjuran diet',
        'obat': [
          {'nama': 'Omeprazole 20mg', 'dosis': '2x1 kapsul/hari'},
          {'nama': 'Antasida Sirup', 'dosis': '3x1 sendok makan'},
        ],
        'catatan': 'Hindari makanan pedas dan asam, makan teratur',
      },
      {
        'tanggal': '15 November 2025',
        'tanggalKunjungan': '15 November 2025',
        'dokter': 'dr. Rina Kusuma, Sp.P',
        'diagnosa': 'Bronkitis Akut',
        'keluhan': 'Batuk berdahak, demam ringan',
        'tindakan': 'Pemberian antibiotik dan ekspektoran',
        'obat': [
          {'nama': 'Amoxicillin 500mg', 'dosis': '3x1 kapsul/hari'},
          {'nama': 'Bromhexine 8mg', 'dosis': '3x1 tablet/hari'},
        ],
        'catatan': 'Habiskan antibiotik, banyak minum air putih',
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.history,
              color: Color(0xFF02B1BA),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Riwayat Pemeriksaan Lainnya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...riwayatLainnya.map((rekamMedis) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRekamMedisCard(context, rekamMedis),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRekamMedisCard(BuildContext context, Map<String, dynamic> rekamMedis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF02B1BA).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF02B1BA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rekamMedis['tanggal'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => DetailPemeriksaanView(
                      rekamMedisData: rekamMedis,
                      pasienData: pasienData,
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Lihat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF02B1BA),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF02B1BA),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Tgl. Periksa', rekamMedis['tanggalKunjungan']),
                const SizedBox(height: 8),
                _buildDetailRow('Dokter', rekamMedis['dokter']),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F9FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnosa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF02B1BA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rekamMedis['diagnosa'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keluhan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57C00),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rekamMedis['keluhan'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Tindakan', rekamMedis['tindakan']),
                const SizedBox(height: 12),
                // Obat Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Obat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(rekamMedis['obat'] as List).map((obat) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: obat['nama'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' - ${obat['dosis']}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rekamMedis['catatan'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
