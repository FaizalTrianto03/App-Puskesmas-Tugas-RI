import 'package:flutter/material.dart';

import '../../../../utils/snackbar_helper.dart';
import '../../../../widgets/quarter_circle_background.dart';

class PasienRegisterView extends StatefulWidget {
  const PasienRegisterView({Key? key}) : super(key: key);

  @override
  State<PasienRegisterView> createState() => _PasienRegisterViewState();
}

class _PasienRegisterViewState extends State<PasienRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _namaLengkapController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _kataSandiController = TextEditingController();
  final _konfirmasiKataSandiController = TextEditingController();
  String _jenisKelamin = '';
  bool _isPasswordVisible = false;
  bool _isKonfirmasiPasswordVisible = false;
  
  // Error messages
  String? namaError;
  String? nikError;
  String? alamatError;
  String? noHpError;
  String? tanggalLahirError;
  String? jenisKelaminError;
  String? kataSandiError;
  String? konfirmasiKataSandiError;

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _tanggalLahirController.dispose();
    _kataSandiController.dispose();
    _konfirmasiKataSandiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF02B1BA),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        tanggalLahirError = null;
      });
    }
  }

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
              
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                _namaLengkapController, 
                'Isi nama lengkap Anda...',
                errorText: namaError,
                onChanged: (value) {
                  if (namaError != null && value.isNotEmpty) {
                    setState(() => namaError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              _buildLabel('NIK'),
              const SizedBox(height: 8),
              _buildTextField(
                _nikController, 
                'Isi NIK Anda...', 
                keyboardType: TextInputType.number,
                errorText: nikError,
                onChanged: (value) {
                  if (nikError != null && value.isNotEmpty) {
                    setState(() => nikError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Alamat'),
              const SizedBox(height: 8),
              _buildTextField(
                _alamatController, 
                'Isi alamat Anda', 
                maxLines: 3,
                errorText: alamatError,
                onChanged: (value) {
                  if (alamatError != null && value.isNotEmpty) {
                    setState(() => alamatError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Nomor HP'),
              const SizedBox(height: 8),
              _buildTextField(
                _noHpController, 
                'Isi nomor HP Anda...', 
                keyboardType: TextInputType.phone,
                errorText: noHpError,
                onChanged: (value) {
                  if (noHpError != null && value.isNotEmpty) {
                    setState(() => noHpError = null);
                  }
                },
              ),
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
                            Expanded(child: _buildGenderButton('L')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildGenderButton('P')),
                          ],
                        ),
                        if (jenisKelaminError != null) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              jenisKelaminError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              _tanggalLahirController, 
                              'dd/mm/yyyy',
                              errorText: tanggalLahirError,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _buildPasswordField(
                _kataSandiController, 
                'Silahkan isi kata sandi Anda...', 
                _isPasswordVisible, 
                () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                errorText: kataSandiError,
                onChanged: (value) {
                  if (kataSandiError != null && value.isNotEmpty) {
                    setState(() => kataSandiError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Konfirmasi Kata Sandi'),
              const SizedBox(height: 8),
              _buildPasswordField(
                _konfirmasiKataSandiController, 
                'Silahkan isi kata sandi Anda...', 
                _isKonfirmasiPasswordVisible, 
                () {
                  setState(() => _isKonfirmasiPasswordVisible = !_isKonfirmasiPasswordVisible);
                },
                errorText: konfirmasiKataSandiError,
                onChanged: (value) {
                  if (konfirmasiKataSandiError != null && value.isNotEmpty) {
                    setState(() => konfirmasiKataSandiError = null);
                  }
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    bool isValid = true;
                    
                    if (_namaLengkapController.text.trim().isEmpty) {
                      setState(() => namaError = 'Nama lengkap harus diisi');
                      isValid = false;
                    }
                    
                    if (_nikController.text.trim().isEmpty) {
                      setState(() => nikError = 'NIK harus diisi');
                      isValid = false;
                    } else if (_nikController.text.trim().length != 16) {
                      setState(() => nikError = 'NIK harus 16 digit');
                      isValid = false;
                    }
                    
                    if (_alamatController.text.trim().isEmpty) {
                      setState(() => alamatError = 'Alamat harus diisi');
                      isValid = false;
                    }
                    
                    if (_noHpController.text.trim().isEmpty) {
                      setState(() => noHpError = 'Nomor HP harus diisi');
                      isValid = false;
                    }
                    
                    if (_tanggalLahirController.text.trim().isEmpty) {
                      setState(() => tanggalLahirError = 'Tanggal lahir harus diisi');
                      isValid = false;
                    }
                    
                    if (_jenisKelamin.isEmpty) {
                      setState(() => jenisKelaminError = 'Jenis kelamin harus dipilih');
                      isValid = false;
                    }
                    
                    if (_kataSandiController.text.trim().isEmpty) {
                      setState(() => kataSandiError = 'Kata sandi harus diisi');
                      isValid = false;
                    } else if (_kataSandiController.text.length < 8) {
                      setState(() => kataSandiError = 'Kata sandi minimal 8 karakter');
                      isValid = false;
                    }
                    
                    if (_konfirmasiKataSandiController.text.trim().isEmpty) {
                      setState(() => konfirmasiKataSandiError = 'Konfirmasi kata sandi harus diisi');
                      isValid = false;
                    } else if (_konfirmasiKataSandiController.text != _kataSandiController.text) {
                      setState(() => konfirmasiKataSandiError = 'Kata sandi tidak cocok');
                      isValid = false;
                    }
                    
                    if (!isValid) {
                      return;
                    }
                    
                    SnackbarHelper.showSuccess('Pendaftaran berhasil! Selamat datang.');
                    
                    Navigator.of(context).pushNamedAndRemoveUntil('/pasien/dashboard', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'DAFTAR SEKARANG',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF02B1BA)),
        children: [
          TextSpan(text: text),
          const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String hint, 
    {
      int maxLines = 1, 
      TextInputType? keyboardType,
      String? errorText,
      Function(String)? onChanged,
    }
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFF02B1BA),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller, 
    String hint, 
    bool isVisible, 
    VoidCallback onToggle,
    {
      String? errorText,
      Function(String)? onChanged,
    }
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFF02B1BA),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _jenisKelamin == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _jenisKelamin = gender;
          jenisKelaminError = null;
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: jenisKelaminError != null ? Colors.red : const Color(0xFF02B1BA),
            width: 2,
          ),
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
