import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../settings/views/admin_settings_view.dart';
import '../../kelola_pengguna/views/kelola_pengguna_list_view.dart';
import '../../kelola_pengguna/bindings/kelola_pengguna_binding.dart';
import '../../laporan_statistik/views/laporan_statistik_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

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
            'Dashboard Admin',
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
                      _buildEmptyStateCard(context),
                      const SizedBox(height: 24),
                      _buildMenuCards(context),
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
          MaterialPageRoute(builder: (_) => const AdminSettingsView()),
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
                    'dr. Trianto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Administrator',
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
  
  Widget _buildEmptyStateCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Review Statistik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02B1BA),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LaporanStatistikView(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Lihat Semua'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF02B1BA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Container(
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
              // Statistik Dokter
              _buildStatListItem(
                icon: Icons.medical_services,
                title: 'Dokter',
                items: [
                  {'label': 'Pasien', 'value': '45', 'color': const Color(0xFF02B1BA)},
                  {'label': 'Rekam Medis', 'value': '38', 'color': const Color(0xFF4CAF50)},
                ],
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              
              // Statistik Perawat
              _buildStatListItem(
                icon: Icons.local_hospital,
                title: 'Perawat',
                items: [
                  {'label': 'Tindakan', 'value': '28', 'color': const Color(0xFF9C27B0)},
                  {'label': 'Ruang Rawat', 'value': '12/20', 'color': const Color(0xFF3F51B5)},
                ],
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              
              // Statistik Apoteker
              _buildStatListItem(
                icon: Icons.medication,
                title: 'Apoteker',
                items: [
                  {'label': 'Obat Habis', 'value': '12', 'color': const Color(0xFFFF4242)},
                  {'label': 'Stok Aman', 'value': '156', 'color': const Color(0xFF4CAF50)},
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatListItem({
    required IconData icon,
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                child: Icon(icon, color: const Color(0xFF02B1BA), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: items.map((item) {
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            item['value'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: item['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuCards(BuildContext context) {
    final List<Map<String, dynamic>> menus = [
      {
        'icon': Icons.people_outline,
        'title': 'Kelola Pengguna',
        'onTap': () {
          KelolaPenggunaBinding().dependencies();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KelolaPenggunaListView()),
          );
        },
      },
      {
        'icon': Icons.bar_chart_outlined,
        'title': 'Laporan & Statistik',
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LaporanStatistikView()),
          );
        },
      },
    ];
    
    return Column(
      children: menus.map((menu) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: menu['onTap'],
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF02B1BA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF02B1BA).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    menu['icon'],
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    menu['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

