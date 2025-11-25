import 'package:flutter/material.dart';

import '../../../admin/login/views/admin_login_view.dart';
import '../../../dokter/login/views/dokter_login_view.dart';
import '../../../perawat/login/views/perawat_login_view.dart';
import 'pasien_login_view.dart';

class StaffSelectorView extends StatelessWidget {
  const StaffSelectorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF84F3EE),
              Color(0xFF02B1BA),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                // Puskesmas App
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Puskesmas ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'App',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4242),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Selamat Datang
                const Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih role Anda untuk mengakses sistem',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // Staff Cards
                _buildStaffCard(
                  context: context,
                  icon: Icons.medical_services,
                  title: 'Dokter',
                  description: 'Riwayat Pasien Terintegrasi',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DokterLoginView()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildStaffCard(
                  context: context,
                  icon: Icons.healing,
                  title: 'Perawat',
                  description: 'Rekam Medis Digital',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PerawatLoginView()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildStaffCard(
                  context: context,
                  icon: Icons.medication,
                  title: 'Apoteker',
                  description: 'Manajemen Stok Obat',
                  onTap: () {
                    // Tanpa navigasi - bukan jobdesk
                  },
                ),
                const SizedBox(height: 16),
                _buildStaffCard(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin',
                  description: 'Kelola Sistem Puskesmas',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminLoginView()),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Masuk sebagai Pasien
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Masuk sebagai Pasien? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PasienLoginView()),
                            );
                          },
                          child: const Text(
                            'Klik di sini',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFF02B1BA),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02B1BA),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF02B1BA),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF02B1BA),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
