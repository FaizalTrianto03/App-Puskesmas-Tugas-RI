import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/pasien_register_controller.dart';

class PasienRegisterView extends GetView<PasienRegisterController> {
  const PasienRegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PasienRegisterViewContent();
  }
}

class _PasienRegisterViewContent extends StatefulWidget {
  @override
  State<_PasienRegisterViewContent> createState() => _PasienRegisterViewContentState();
}

class _PasienRegisterViewContentState extends State<_PasienRegisterViewContent> {
  late final PasienRegisterController controller;
  final _namaLengkapController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _kataSandiController = TextEditingController();
  final _konfirmasiKataSandiController = TextEditingController();
  
  final _namaLengkapFocus = FocusNode();
  final _nikFocus = FocusNode();
  final _alamatFocus = FocusNode();
  final _noHpFocus = FocusNode();
  final _tanggalLahirFocus = FocusNode();
  final _kataSandiFocus = FocusNode();
  final _konfirmasiKataSandiFocus = FocusNode();
  
  final _namaLengkapKey = GlobalKey();
  final _nikKey = GlobalKey();
  final _alamatKey = GlobalKey();
  final _noHpKey = GlobalKey();
  final _tanggalLahirKey = GlobalKey();
  final _kataSandiKey = GlobalKey();
  final _konfirmasiKataSandiKey = GlobalKey();
  
  final ScrollController _scrollController = ScrollController();
  
  String _jenisKelamin = '';
  bool _isPasswordVisible = false;
  bool _isKonfirmasiPasswordVisible = false;
  bool _isLoading = false;

  bool _isNamaLengkapFocused = false;
  bool _isNikFocused = false;
  bool _isAlamatFocused = false;
  bool _isNoHpFocused = false;
  bool _isTanggalLahirFocused = false;
  bool _isKataSandiFocused = false;
  bool _isKonfirmasiKataSandiFocused = false;
  
  String? namaError;
  String? nikError;
  String? alamatError;
  String? noHpError;
  String? tanggalLahirError;
  String? jenisKelaminError;
  String? kataSandiError;
  String? konfirmasiKataSandiError;

  @override
  void initState() {
    super.initState();
    
    // Get controller from binding
    controller = Get.find<PasienRegisterController>();
    
    _namaLengkapController.clear();
    _nikController.clear();
    _alamatController.clear();
    _noHpController.clear();
    _tanggalLahirController.clear();
    _kataSandiController.clear();
    _konfirmasiKataSandiController.clear();
    _jenisKelamin = '';
    _isPasswordVisible = false;
    _isKonfirmasiPasswordVisible = false;

    namaError = null;
    nikError = null;
    alamatError = null;
    noHpError = null;
    tanggalLahirError = null;
    jenisKelaminError = null;
    kataSandiError = null;
    konfirmasiKataSandiError = null;
    
    _namaLengkapFocus.addListener(() {
      setState(() => _isNamaLengkapFocused = _namaLengkapFocus.hasFocus);
    });
    _nikFocus.addListener(() {
      setState(() => _isNikFocused = _nikFocus.hasFocus);
    });
    _alamatFocus.addListener(() {
      setState(() => _isAlamatFocused = _alamatFocus.hasFocus);
    });
    _noHpFocus.addListener(() {
      setState(() => _isNoHpFocused = _noHpFocus.hasFocus);
    });
    _tanggalLahirFocus.addListener(() {
      setState(() => _isTanggalLahirFocused = _tanggalLahirFocus.hasFocus);
    });
    _kataSandiFocus.addListener(() {
      setState(() => _isKataSandiFocused = _kataSandiFocus.hasFocus);
    });
    _konfirmasiKataSandiFocus.addListener(() {
      setState(() => _isKonfirmasiKataSandiFocused = _konfirmasiKataSandiFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _tanggalLahirController.dispose();
    _kataSandiController.dispose();
    _konfirmasiKataSandiController.dispose();
    
    _scrollController.dispose();
    _namaLengkapFocus.dispose();
    _nikFocus.dispose();
    _alamatFocus.dispose();
    _noHpFocus.dispose();
    _tanggalLahirFocus.dispose();
    _kataSandiFocus.dispose();
    _konfirmasiKataSandiFocus.dispose();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02B1BA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
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
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: SingleChildScrollView(
            controller: _scrollController,
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
                focusNode: _namaLengkapFocus,
                isFocused: _isNamaLengkapFocused,
                fieldKey: _namaLengkapKey,
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
                focusNode: _nikFocus,
                isFocused: _isNikFocused,
                fieldKey: _nikKey,
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
                focusNode: _alamatFocus,
                isFocused: _isAlamatFocused,
                fieldKey: _alamatKey,
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
                focusNode: _noHpFocus,
                isFocused: _isNoHpFocused,
                fieldKey: _noHpKey,
                onChanged: (value) {
                  if (noHpError != null && value.isNotEmpty) {
                    setState(() => noHpError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Expanded(child: _buildGenderButton('P')),
                          ],
                        ),
                        SizedBox(
                          height: jenisKelaminError != null ? 24 : 0,
                          child: jenisKelaminError != null
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 4),
                                  child: Text(
                                    jenisKelaminError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                  ),
                                )
                              : null,
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
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              _tanggalLahirController, 
                              'dd/mm/yyyy',
                              errorText: tanggalLahirError,
                              focusNode: _tanggalLahirFocus,
                              isFocused: _isTanggalLahirFocused,
                              fieldKey: _tanggalLahirKey,
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
                focusNode: _kataSandiFocus,
                isFocused: _isKataSandiFocused,
                fieldKey: _kataSandiKey,
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
                focusNode: _konfirmasiKataSandiFocus,
                isFocused: _isKonfirmasiKataSandiFocused,
                fieldKey: _konfirmasiKataSandiKey,
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
                  onPressed: _isLoading ? null : () async {
                    // Get controller instance
                    final controller = Get.find<PasienRegisterController>();
                    
                    // Set values to controller
                    controller.namaLengkapController.text = _namaLengkapController.text;
                    controller.nikController.text = _nikController.text;
                    controller.alamatController.text = _alamatController.text;
                    controller.noHpController.text = _noHpController.text;
                    controller.tanggalLahirController.text = _tanggalLahirController.text;
                    controller.passwordController.text = _kataSandiController.text;
                    controller.konfirmasiPasswordController.text = _konfirmasiKataSandiController.text;
                    controller.selectedJenisKelamin.value = _jenisKelamin.isNotEmpty ? _jenisKelamin : null;
                    
                    // Set dummy values for fields not in current view
                    // Generate unique email using timestamp to avoid duplicates
                    final timestamp = DateTime.now().millisecondsSinceEpoch;
                    controller.emailController.text = 'pasien$timestamp@gmail.com';
                    controller.tempatLahirController.text = 'Malang';
                    
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
                    } else if (_alamatController.text.trim().length < 10) {
                      setState(() => alamatError = 'Alamat minimal 10 karakter');
                      isValid = false;
                    }
                    
                    if (_noHpController.text.trim().isEmpty) {
                      setState(() => noHpError = 'Nomor HP harus diisi');
                      isValid = false;
                    } else if (_noHpController.text.trim().length < 10 || _noHpController.text.trim().length > 13) {
                      setState(() => noHpError = 'Nomor HP tidak valid (10-13 digit)');
                      isValid = false;
                    } else if (!RegExp(r'^\d+$').hasMatch(_noHpController.text.trim())) {
                      setState(() => noHpError = 'Nomor HP hanya boleh angka');
                      isValid = false;
                    }
                    
                    if (_tanggalLahirController.text.trim().isEmpty) {
                      setState(() => tanggalLahirError = 'Tanggal lahir harus diisi');
                      isValid = false;
                    }
                    
                    if (_jenisKelamin.isEmpty) {
                      setState(() => jenisKelaminError = 'Pilih jenis kelamin');
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
                      // Show general error message
                      Get.snackbar(
                        'Validasi Gagal',
                        'Silakan isi semua field sesuai ketentuan',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        icon: const Icon(Icons.error_outline, color: Colors.white),
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 8,
                        duration: const Duration(seconds: 3),
                      );
                      return;
                    }
                    
                    setState(() => _isLoading = true);
                    
                    // Call controller register
                    await controller.register();
                    
                    setState(() => _isLoading = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02B1BA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'DAFTAR SEKARANG',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
            ),
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
      FocusNode? focusNode,
      bool isFocused = false,
      GlobalKey? fieldKey,
    }
  ) {
    return Container(
      key: fieldKey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFF02B1BA),
              width: isFocused ? 2.5 : 2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF02B1BA).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
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
      ),
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
      FocusNode? focusNode,
      bool isFocused = false,
      GlobalKey? fieldKey,
    }
  ) {
    return Container(
      key: fieldKey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFF02B1BA),
              width: isFocused ? 2.5 : 2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF02B1BA).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
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
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _jenisKelamin == gender;
    final isLeft = gender == 'L';
    final errorColor = jenisKelaminError != null ? Colors.red : const Color(0xFF02B1BA);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _jenisKelamin = gender;
          jenisKelaminError = null;
        });
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.white,
          borderRadius: isLeft 
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
          border: Border(
            top: BorderSide(color: errorColor, width: 2),
            bottom: BorderSide(color: errorColor, width: 2),
            left: isLeft ? BorderSide(color: errorColor, width: 2) : BorderSide(color: errorColor, width: 1),
            right: isLeft ? BorderSide(color: errorColor, width: 1) : BorderSide(color: errorColor, width: 2),
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
