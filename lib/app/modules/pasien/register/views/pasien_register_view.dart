import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/pasien_register_controller.dart';

class PasienRegisterView extends GetView<PasienRegisterController> {
  const PasienRegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Pasien Baru',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi Data Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02B1BA),
                ),
              ),
              const SizedBox(height: 24),
              
              // Nama Lengkap
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.namaLengkapController,
                hintText: 'Isi nama lengkap Anda...',
              ),
              const SizedBox(height: 16),
              
              // NIK
              _buildLabel('NIK'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.nikController,
                hintText: 'Isi NIK Anda...',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Alamat
              _buildLabel('Alamat'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.alamatController,
                hintText: 'Isi alamat Anda',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Nomor HP
              _buildLabel('Nomor HP'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.noHpController,
                hintText: 'Isi nomor HP Anda...',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Jenis Kelamin & Tanggal Lahir
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Jenis Kelamin'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() => _buildGenderButton(
                                'L',
                                controller.jenisKelamin.value == 'L',
                                () => controller.setJenisKelamin('L'),
                              )),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Obx(() => _buildGenderButton(
                                'P',
                                controller.jenisKelamin.value == 'P',
                                () => controller.setJenisKelamin('P'),
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Lahir'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => controller.selectDate(context),
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: controller.tanggalLahirController,
                              hintText: 'dd/mm/yyyy',
                              readOnly: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Kata Sandi
              _buildLabel('Kata Sandi'),
              const SizedBox(height: 8),
              Obx(() => _buildTextField(
                controller: controller.kataSandiController,
                hintText: 'Silahkan isi kata sandi Anda...',
                obscureText: !controller.isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),
              const SizedBox(height: 16),
              
              // Konfirmasi Kata Sandi
              _buildLabel('Konfirmasi Kata Sandi'),
              const SizedBox(height: 8),
              Obx(() => _buildTextField(
                controller: controller.konfirmasiKataSandiController,
                hintText: 'Silahkan isi kata sandi Anda...',
                obscureText: !controller.isKonfirmasiPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isKonfirmasiPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: controller.toggleKonfirmasiPasswordVisibility,
                ),
              )),
              const SizedBox(height: 32),
              
              // Button Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'DAFTAR SEKARANG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF02B1BA),
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildGenderButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF02B1BA),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF02B1BA),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
