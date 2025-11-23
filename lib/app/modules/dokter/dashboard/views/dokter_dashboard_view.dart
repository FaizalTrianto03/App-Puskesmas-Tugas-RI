import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../settings/views/dokter_settings_view.dart';
import '../../rekam_medis/views/rekam_medis_detail_view.dart';
import '../../pemeriksaan/views/form_pemeriksaan_view.dart';

class DokterDashboardView extends StatelessWidget {
  const DokterDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Dashboard Dokter',
            style: TextStyle(
              color: Color(0xFF02B1BA),
              fontSize: 20,
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
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildStatisticCards(),
                      const SizedBox(height: 24),
                      _buildRekamMedisList(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokterSettingsView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
          ),
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dr. Faizal Qadri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Poli Umum',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticCards() {
    return Row(
      children: [
        _buildStatCard('7', 'Total', const Color(0xFF02B1BA)),
        const SizedBox(width: 12),
        _buildStatCard('2', 'Sisa', const Color(0xFFFF9800)),
        const SizedBox(width: 12),
        _buildStatCard('5', 'Selesai', const Color(0xFF4CAF50)),
      ],
    );
  }
  
  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRekamMedisList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekam Medis Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF02B1BA),
          ),
        ),
        const SizedBox(height: 12),
        
        _buildRekamMedisCard(
          context: context,
          nama: 'Anisa Ayu',
          umur: '22 Tahun',
          antrian: 'A-012',
          keluhan: 'Demam dan pusing',
          status: 'Menunggu Pemeriksaan',
          statusColor: const Color(0xFFFF9800),
          alergi: 'Tidak ada',
          jenisLayanan: 'Rawat Jalan',
          golDarah: 'A+',
          tinggiBerat: '160 cm / 55 kg',
        ),
        const SizedBox(height: 12),
        
        _buildRekamMedisCard(
          context: context,
          nama: 'Dias Aditama',
          umur: '25 Tahun',
          antrian: 'A-014',
          keluhan: 'Batuk berdarah',
          status: 'Menunggu',
          statusColor: const Color(0xFFFF9800),
          alergi: 'Penisilin',
          jenisLayanan: 'Rawat Jalan',
          golDarah: 'B+',
          tinggiBerat: '170 cm / 68 kg',
        ),
        const SizedBox(height: 12),
        
        _buildRekamMedisCard(
          context: context,
          nama: 'Faisal Qadri',
          umur: '21 Tahun',
          antrian: 'A-011',
          keluhan: 'Sakit kepala',
          status: 'Selesai',
          statusColor: const Color(0xFF4CAF50),
          alergi: 'Tidak ada',
          jenisLayanan: 'Rawat Jalan',
          golDarah: 'O+',
          tinggiBerat: '175 cm / 70 kg',
        ),
      ],
    );
  }
  
  Widget _buildRekamMedisCard({
    required BuildContext context,
    required String nama,
    required String umur,
    required String antrian,
    required String keluhan,
    required String status,
    required Color statusColor,
    required String alergi,
    required String jenisLayanan,
    required String golDarah,
    required String tinggiBerat,
  }) {
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
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF02B1BA),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      umur,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Antrian',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      antrian,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4242),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluhan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      keluhan,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final pasienData = {
                  'nama': nama,
                  'umur': umur,
                  'antrian': antrian,
                  'keluhan': keluhan,
                  'status': status,
                  'alergi': alergi,
                  'jenisLayanan': jenisLayanan,
                  'golDarah': golDarah,
                  'tinggiBerat': tinggiBerat,
                };

                // Jika status Menunggu Pemeriksaan, buka form isi hasil
                if (status == 'Menunggu Pemeriksaan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPemeriksaanView(
                        pasienData: pasienData,
                      ),
                    ),
                  );
                } else {
                  // Jika sudah selesai, buka detail rekam medis
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RekamMedisDetailView(
                        pasienData: pasienData,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'Menunggu Pemeriksaan' 
                    ? const Color(0xFFFF9800) 
                    : const Color(0xFF02B1BA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == 'Menunggu Pemeriksaan' 
                        ? Icons.edit_note 
                        : Icons.visibility,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status == 'Menunggu Pemeriksaan' 
                        ? 'Isi Hasil Pemeriksaan' 
                        : 'Lihat Detail Medis',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
