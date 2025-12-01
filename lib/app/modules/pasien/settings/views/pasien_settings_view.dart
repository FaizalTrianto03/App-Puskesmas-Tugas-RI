import 'package:flutter/material.dart';

import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../pasien/login/views/pasien_login_view.dart';
import 'kelola_data_diri_view.dart';
import 'kelola_kata_sandi_view.dart';

class PasienSettingsView extends StatefulWidget {
  const PasienSettingsView({Key? key}) : super(key: key);

  @override
  State<PasienSettingsView> createState() => _PasienSettingsViewState();
}

class _PasienSettingsViewState extends State<PasienSettingsView> {
  bool _isHoverDataDiri = false;
  bool _isHoverKataSandi = false;
  bool _isHoverKeluar = false;
  bool _isPressedDataDiri = false;
  bool _isPressedKataSandi = false;
  bool _isPressedKeluar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Navigator.of(context).pop(),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Color(0xFF02B1BA),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Anisa Ayu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                      isHover: _isHoverDataDiri,
                      isPressed: _isPressedDataDiri,
                      onHoverChange: (hover) {
                        setState(() {
                          _isHoverDataDiri = hover;
                        });
                      },
                      onPressedChange: (pressed) {
                        setState(() {
                          _isPressedDataDiri = pressed;
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KelolaDataDiriView(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.vpn_key_outlined,
                      title: 'Kelola Kata Sandi',
                      isHover: _isHoverKataSandi,
                      isPressed: _isPressedKataSandi,
                      onHoverChange: (hover) {
                        setState(() {
                          _isHoverKataSandi = hover;
                        });
                      },
                      onPressedChange: (pressed) {
                        setState(() {
                          _isPressedKataSandi = pressed;
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KelolaKataSandiView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      textColor: Colors.red,
                      isHover: _isHoverKeluar,
                      isPressed: _isPressedKeluar,
                      onHoverChange: (hover) {
                        setState(() {
                          _isHoverKeluar = hover;
                        });
                      },
                      onPressedChange: (pressed) {
                        setState(() {
                          _isPressedKeluar = pressed;
                        });
                      },
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
        SnackbarHelper.showSuccess('Berhasil keluar dari akun');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PasienLoginView()),
          (route) => false,
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isHover,
    required bool isPressed,
    required Function(bool) onHoverChange,
    required Function(bool) onPressedChange,
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
