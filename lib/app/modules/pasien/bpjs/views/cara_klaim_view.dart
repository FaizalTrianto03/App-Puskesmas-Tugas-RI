import 'package:flutter/material.dart';

import '../../../../widgets/quarter_circle_background.dart';

class CaraKlaimView extends StatelessWidget {
  const CaraKlaimView({Key? key}) : super(key: key);

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cara Klaim BPJS',
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
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.fact_check,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Panduan Klaim BPJS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Di Puskesmas Dau',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Langkah-langkah Klaim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildStepCard(
                1,
                'Persiapan Dokumen',
                [
                  'Kartu BPJS Kesehatan asli',
                  'KTP/Kartu Keluarga asli',
                  'Surat rujukan (jika dari Faskes lain)',
                  'Pastikan iuran BPJS tidak menunggak',
                ],
                const Color(0xFF02B1BA),
              ),
              const SizedBox(height: 12),

              _buildStepCard(
                2,
                'Pendaftaran',
                [
                  'Datang ke loket pendaftaran puskesmas',
                  'Serahkan kartu BPJS dan identitas',
                  'Petugas akan memverifikasi data',
                  'Ambil nomor antrean',
                ],
                const Color(0xFF02B1BA),
              ),
              const SizedBox(height: 12),

              _buildStepCard(
                3,
                'Pemeriksaan',
                [
                  'Tunggu di ruang tunggu sesuai nomor antrean',
                  'Masuk ke ruang pemeriksaan saat dipanggil',
                  'Konsultasi dengan dokter',
                  'Dapatkan resep obat (jika perlu)',
                ],
                const Color(0xFF02B1BA),
              ),
              const SizedBox(height: 12),

              _buildStepCard(
                4,
                'Pengambilan Obat',
                [
                  'Serahkan resep ke apotek puskesmas',
                  'Tunggu panggilan untuk ambil obat',
                  'Dengarkan penjelasan cara minum obat',
                  'Obat didapat GRATIS dengan BPJS',
                ],
                const Color(0xFF02B1BA),
              ),
              const SizedBox(height: 24),

              const Text(
                'Hal yang Perlu Diperhatikan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF84F3EE).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF02B1BA),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFF02B1BA),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Catatan Penting',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF02B1BA),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCatatanItem('Pastikan iuran BPJS sudah dibayar sebelum berobat'),
                    _buildCatatanItem('Kartu BPJS yang menunggak tidak bisa digunakan'),
                    _buildCatatanItem('Datang sesuai jam operasional puskesmas'),
                    _buildCatatanItem('Untuk rujukan ke RS, minta surat rujukan dari dokter'),
                    _buildCatatanItem('Simpan struk/bukti kunjungan untuk arsip'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB547),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFFFFB547),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Tips Klaim Lancar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB547),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem('Datang pagi hari untuk menghindari antrean panjang'),
                    _buildTipItem('Cek status kepesertaan BPJS di aplikasi Mobile JKN'),
                    _buildTipItem('Bayar iuran via Mobile Banking untuk lebih praktis'),
                    _buildTipItem('Daftar online untuk hemat waktu'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(int number, String title, List<String> steps, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 2,
        ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: steps
                  .map((step) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_right,
            size: 20,
            color: Color(0xFF02B1BA),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.star,
            size: 18,
            color: Color(0xFFFFB547),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
