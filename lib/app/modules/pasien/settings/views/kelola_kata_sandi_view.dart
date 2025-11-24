import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';

class KelolaKataSandiView extends StatefulWidget {
  const KelolaKataSandiView({Key? key}) : super(key: key);

  @override
  State<KelolaKataSandiView> createState() => _KelolaKataSandiViewState();
}

class _KelolaKataSandiViewState extends State<KelolaKataSandiView> {
  final _kataSandiLamaController = TextEditingController();
  final _kataSandiBaruController = TextEditingController();
  final _konfirmasiKataSandiController = TextEditingController();
  bool _showKataSandiLama = false;
  bool _showKataSandiBaru = false;
  bool _showKonfirmasi = false;

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
          'Kelola Kata Sandi',
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
              _buildLabel('Kata Sandi Saat Ini'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _kataSandiLamaController,
                hint: '•••••',
                isVisible: _showKataSandiLama,
                onToggle: () {
                  setState(() {
                    _showKataSandiLama = !_showKataSandiLama;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Kata Sandi Baru'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _kataSandiBaruController,
                hint: 'Silahkan isi kata sandi Anda...',
                isVisible: _showKataSandiBaru,
                onToggle: () {
                  setState(() {
                    _showKataSandiBaru = !_showKataSandiBaru;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Konfirmasi Kata Sandi Baru'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _konfirmasiKataSandiController,
                hint: '•••••',
                isVisible: _showKonfirmasi,
                onToggle: () {
                  setState(() {
                    _showKonfirmasi = !_showKonfirmasi;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN PERUBAHAN',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
