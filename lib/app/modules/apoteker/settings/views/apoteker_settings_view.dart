import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/notification_toggle_tile.dart';
import '../controllers/apoteker_settings_controller.dart';

class ApotekerSettingsView extends GetView<ApotekerSettingsController> {
  const ApotekerSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    Get.lazyPut(() => ApotekerSettingsController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pengaturan',
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
                    // Profile Card
                    Container(
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
                          Expanded(
                            child: Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.userName.value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.userRole.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu Section
                    const Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Kelola Data Diri',
                      onTap: () {
                        Get.toNamed(Routes.apotekerKelolaDataDiri);
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.vpn_key_outlined,
                      title: 'Kelola Kata Sandi',
                      onTap: () {
                        Get.toNamed(Routes.apotekerKelolaKataSandi);
                      },
                    ),
                    const NotificationToggleTile(role: 'apoteker'),
                    const SizedBox(height: 24),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      textColor: Colors.red,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    ConfirmationDialog.show(
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun?',
      type: ConfirmationType.danger,
      confirmText: 'Keluar',
      cancelText: 'Batal',
      onConfirm: () {
        controller.logout();
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (textColor ?? const Color(0xFF02B1BA)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: textColor ?? const Color(0xFF02B1BA),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: textColor ?? const Color(0xFF02B1BA),
        ),
      ),
    );
  }
}
