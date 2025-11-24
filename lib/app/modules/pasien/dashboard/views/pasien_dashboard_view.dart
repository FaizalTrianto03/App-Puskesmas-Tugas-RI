import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/pasien_dashboard_controller.dart';

class PasienDashboardView extends GetView<PasienDashboardController> {
  const PasienDashboardView({super.key});
  
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
            'Dashboard Pasien',
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
                      _buildNoActiveQueueCard(context),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.add_circle_outline,
                        title: 'Daftar Baru',
                        onTap: () {
                          Get.toNamed(Routes.pasienPendaftaran);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuButton(
                        context,
                        icon: Icons.receipt_long,
                        title: 'Status Antrean',
                        onTap: () {
                          // Navigate to status antrean (belum dibuat)
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuButton(
                        context,
                        icon: Icons.history,
                        title: 'Riwayat Kunjungan',
                        onTap: () {
                          Get.toNamed(Routes.pasienRiwayat);
                        },
                      ),
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
        Get.toNamed(Routes.pasienSettings);
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
                    'Selamat Datang,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Anisa Ayu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildNoActiveQueueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF84F3EE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF02B1BA),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Belum ada antrean aktif saat ini.\nSilahkan daftar terlebih dahulu.',
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
              onPressed: () {
                Get.toNamed(Routes.pasienPendaftaran);
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
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
