import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/staff_selector_controller.dart';
import 'pasien_login_view.dart';

class StaffSelectorView extends GetView<StaffSelectorController> {
  const StaffSelectorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(StaffSelectorController());
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
                Obx(() => _buildStaffCard(
                  context: context,
                  index: 0,
                  icon: Icons.medical_services,
                  title: 'Dokter',
                  description: 'Riwayat Pasien Terintegrasi',
                  onTap: () => Get.toNamed(Routes.dokterLogin),
                )),
                const SizedBox(height: 16),
                Obx(() => _buildStaffCard(
                  context: context,
                  index: 1,
                  icon: Icons.healing,
                  title: 'Perawat',
                  description: 'Rekam Medis Digital',
                  onTap: () => Get.toNamed(Routes.perawatLogin),
                )),
                const SizedBox(height: 16),
                Obx(() => _buildStaffCard(
                  context: context,
                  index: 2,
                  icon: Icons.medication,
                  title: 'Apoteker',
                  description: 'Manajemen Stok Obat',
                  onTap: () => Get.toNamed(Routes.apotekerLogin),
                )),
                const SizedBox(height: 16),
                Obx(() => _buildStaffCard(
                  context: context,
                  index: 3,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin',
                  description: 'Kelola Sistem Puskesmas',
                  onTap: () => Get.toNamed(Routes.adminLogin),
                )),
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
                          onTap: () => Get.toNamed(Routes.pasienLogin),
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
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isHovered = controller.hoveredIndex.value == index;
    final isPressed = controller.pressedIndex.value == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => controller.setHoveredIndex(index),
      onExit: (_) => controller.setHoveredIndex(null),
      child: GestureDetector(
        onTapDown: (_) => controller.setPressedIndex(index),
        onTapUp: (_) {
          controller.setPressedIndex(null);
          onTap();
        },
        onTapCancel: () => controller.setPressedIndex(null),
        child: Transform.scale(
          scale: isPressed ? 0.95 : (isHovered ? 1.02 : 1.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
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
        ),
      ),
    );
  }
}


