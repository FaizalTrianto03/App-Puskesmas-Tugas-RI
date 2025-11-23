import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaKataSandiView extends StatefulWidget {
  const KelolaKataSandiView({Key? key}) : super(key: key);

  @override
  State<KelolaKataSandiView> createState() => _KelolaKataSandiViewState();
}

class _KelolaKataSandiViewState extends State<KelolaKataSandiView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _obscurePasswordLama = true;
  bool _obscurePasswordBaru = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelola Kata Sandi',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Kata sandi minimal 8 karakter untuk keamanan akun Anda',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Ubah Kata Sandi',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Kata Sandi Lama
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Kata Sandi Lama'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordLamaController,
                        hintText: 'Masukkan kata sandi lama',
                        obscureText: _obscurePasswordLama,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePasswordLama ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePasswordLama = !_obscurePasswordLama;
                            });
                          },
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi lama harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Kata Sandi Baru
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Kata Sandi Baru'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordBaruController,
                        hintText: 'Masukkan kata sandi baru',
                        obscureText: _obscurePasswordBaru,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePasswordBaru ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePasswordBaru = !_obscurePasswordBaru;
                            });
                          },
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi baru harus diisi';
                          }
                          if (value.length < 8) {
                            return 'Kata sandi minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Konfirmasi Kata Sandi
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(text: 'Konfirmasi Kata Sandi'),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _konfirmasiController,
                        hintText: 'Ulangi kata sandi baru',
                        obscureText: _obscureKonfirmasi,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKonfirmasi ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureKonfirmasi = !_obscureKonfirmasi;
                            });
                          },
                        ),
                        backgroundColor: AppColors.white,
                        textColor: Colors.black87,
                        hintColor: Colors.grey,
                        borderColor: AppColors.primary,
                        borderWidth: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi kata sandi harus diisi';
                          }
                          if (value != _passwordBaruController.text) {
                            return 'Kata sandi tidak cocok';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Button Simpan
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              SnackbarHelper.showSuccess('Kata sandi berhasil diubah');
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'SIMPAN PERUBAHAN',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
}
