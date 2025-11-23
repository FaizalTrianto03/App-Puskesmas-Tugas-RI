import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';
import 'detail_pemeriksaan_view.dart';

class RekamMedisDetailView extends StatelessWidget {
  final Map<String, dynamic> pasienData;

  const RekamMedisDetailView({
    Key? key,
    required this.pasienData,
  }) : super(key: key);

  // Data dummy rekam medis
  static final List<Map<String, dynamic>> dummyRekamMedis = [
    {
      'tanggal': '8 Oktober 2025',
      'tanggalKunjungan': '8 Oktober 2025',
      'dokter': 'dr. Faizal Qadri',
      'diagnosa': 'Infeksi Flu',
      'keluhan': 'Demam tinggi, batuk, pilek',
      'tindakan': 'Pemberian obat antipiretik dan istirahat',
      'obat': [
        {'nama': 'Paracetamol 500mg', 'dosis': '3x1 tablet/hari'},
        {'nama': 'Ambroxol 30mg', 'dosis': '3x1 tablet/hari'},
      ],
      'catatan': 'Kontrol kembali jika demam tidak turun dalam 3 hari',
    },
    {
      'tanggal': '5 Oktober 2025',
      'tanggalKunjungan': '5 Oktober 2025',
      'dokter': 'dr. Faizal Qadri',
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
      'tanggal': '8 Oktober 2025',
      'tanggalKunjungan': '8 Oktober 2025',
      'dokter': 'dr. Faizal Qadri',
      'diagnosa': 'Hipertensi Stage 1',
      'keluhan': 'Sakit kepala, tekanan darah tinggi',
      'tindakan': 'Pemberian obat antihipertensi dan konseling gaya hidup',
      'obat': [
        {'nama': 'Amlodipine 5mg', 'dosis': '1x1 tablet/hari'},
        {'nama': 'Captopril 25mg', 'dosis': '2x1 tablet/hari'},
      ],
      'catatan': 'Kurangi konsumsi garam, olahraga rutin 30 menit/hari',
    },
    {
      'tanggal': '6 Oktober 2025',
      'tanggalKunjungan': '6 Oktober 2025',
      'dokter': 'dr. Faizal Qadri',
      'diagnosa': 'Dermatitis Kontak',
      'keluhan': 'Gatal-gatal dan kemerahan pada kulit',
      'tindakan': 'Pemberian salep kortikosteroid dan antihistamin',
      'obat': [
        {'nama': 'Hydrocortisone Cream 1%', 'dosis': 'Oleskan 2x sehari'},
        {'nama': 'Cetirizine 10mg', 'dosis': '1x1 tablet/hari (malam)'},
      ],
      'catatan': 'Hindari kontak dengan bahan iritan, jaga kebersihan kulit',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rekam Medis Terintegrasi',
          style: TextStyle(
            color: Color(0xFF02B1BA),
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
                    const SizedBox(height: 24),
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
              'Hasil Laboratorium Terdahulu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...dummyRekamMedis.map((rekamMedis) {
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPemeriksaanView(
                          rekamMedisData: rekamMedis,
                          pasienData: pasienData,
                        ),
                      ),
                    );
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
