import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';

class KelolaDataDiriView extends StatefulWidget {
  const KelolaDataDiriView({Key? key}) : super(key: key);

  @override
  State<KelolaDataDiriView> createState() => _KelolaDataDiriViewState();
}

class _KelolaDataDiriViewState extends State<KelolaDataDiriView> {
  final _namaController = TextEditingController(text: 'g');
  final _nikController = TextEditingController(text: '2');
  final _alamatController = TextEditingController(text: 'g');
  final _nomorHpController = TextEditingController(text: '081234567899');
  final _emailController = TextEditingController(text: 'anisaayu09@gmail.com');
  final _tanggalLahirController = TextEditingController(text: '09/09/2003');
  String _jenisKelamin = 'L';

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
          'Kelola Data Diri',
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
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(_namaController, 'Nama Lengkap'),
              const SizedBox(height: 16),
              
              _buildLabel('NIK'),
              const SizedBox(height: 8),
              _buildTextField(_nikController, 'NIK'),
              const SizedBox(height: 16),
              
              _buildLabel('Alamat'),
              const SizedBox(height: 8),
              _buildTextField(_alamatController, 'Alamat', maxLines: 3),
              const SizedBox(height: 16),
              
              _buildLabel('Nomor HP'),
              const SizedBox(height: 8),
              _buildTextField(_nomorHpController, 'Nomor HP'),
              const SizedBox(height: 16),
              
              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 16),
              
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
                              child: _buildGenderButton('L'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildGenderButton('P'),
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
                        _buildTextField(_tanggalLahirController, 'dd/mm/yyyy'),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF02B1BA), width: 2),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _jenisKelamin == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _jenisKelamin = gender;
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF02B1BA), width: 2),
        ),
        child: Center(
          child: Text(
            gender,
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
