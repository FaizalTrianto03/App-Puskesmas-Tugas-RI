import 'package:flutter/material.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text_styles.dart';

class FormRekamMedisView extends StatefulWidget {
  final Map<String, dynamic> pasienData;

  const FormRekamMedisView({
    Key? key,
    required this.pasienData,
  }) : super(key: key);

  @override
  State<FormRekamMedisView> createState() => _FormRekamMedisViewState();
}

class _FormRekamMedisViewState extends State<FormRekamMedisView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers - Identitas Pasien (read-only from pasienData)
  late final TextEditingController _namaPasienController;
  late final TextEditingController _idPasienController;
  late final TextEditingController _usiaController;
  late final TextEditingController _poliTujuanController;
  
  // Controllers - Tanda Vital
  final _tekananDarahSistolikController = TextEditingController();
  final _tekananDarahDiastolikController = TextEditingController();
  final _nadiController = TextEditingController();
  final _suhuController = TextEditingController();
  final _pernapasanController = TextEditingController();
  
  // Controllers - Antropometri
  final _beratBadanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  final _imtController = TextEditingController();
  
  // Controllers - Keluhan & Anamnesis
  final _keluhanUtamaController = TextEditingController();
  final _riwayatPenyakitController = TextEditingController();
  final _alergiController = TextEditingController();

  // Error states untuk validasi
  String? _tekananDarahSistolikError;
  String? _tekananDarahDiastolikError;
  String? _nadiError;
  String? _suhuError;
  String? _beratBadanError;
  String? _tinggiBadanError;
  String? _keluhanUtamaError;
  String? _alergiError;

  @override
  void initState() {
    super.initState();
    // Initialize from pasienData
    _namaPasienController = TextEditingController(text: widget.pasienData['nama'] ?? 'Anisa Ayu');
    _idPasienController = TextEditingController(text: '202210370311009');
    _usiaController = TextEditingController(text: '21 Tahun');
    _poliTujuanController = TextEditingController(text: 'Poli umum');
    
    // Add listeners untuk auto-calculate IMT
    _beratBadanController.addListener(_calculateIMT);
    _tinggiBadanController.addListener(_calculateIMT);
  }

  void _calculateIMT() {
    final berat = double.tryParse(_beratBadanController.text);
    final tinggi = double.tryParse(_tinggiBadanController.text);
    
    if (berat != null && tinggi != null && tinggi > 0) {
      final tinggiMeter = tinggi / 100;
      final imt = berat / (tinggiMeter * tinggiMeter);
      _imtController.text = imt.toStringAsFixed(1);
    } else {
      _imtController.text = '';
    }
  }

  void _simpanData() {
    // Reset semua error
    setState(() {
      _tekananDarahSistolikError = null;
      _tekananDarahDiastolikError = null;
      _nadiError = null;
      _suhuError = null;
      _beratBadanError = null;
      _tinggiBadanError = null;
      _keluhanUtamaError = null;
      _alergiError = null;
    });

    // Validasi field wajib
    bool hasError = false;
    
    if (_tekananDarahSistolikController.text.trim().isEmpty) {
      _tekananDarahSistolikError = 'Tekanan darah sistolik wajib diisi';
      hasError = true;
    }
    
    if (_tekananDarahDiastolikController.text.trim().isEmpty) {
      _tekananDarahDiastolikError = 'Tekanan darah diastolik wajib diisi';
      hasError = true;
    }
    
    if (_nadiController.text.trim().isEmpty) {
      _nadiError = 'Nadi wajib diisi';
      hasError = true;
    }
    
    if (_suhuController.text.trim().isEmpty) {
      _suhuError = 'Suhu wajib diisi';
      hasError = true;
    }
    
    if (_beratBadanController.text.trim().isEmpty) {
      _beratBadanError = 'Berat badan wajib diisi';
      hasError = true;
    }
    
    if (_tinggiBadanController.text.trim().isEmpty) {
      _tinggiBadanError = 'Tinggi badan wajib diisi';
      hasError = true;
    }
    
    if (_keluhanUtamaController.text.trim().isEmpty) {
      _keluhanUtamaError = 'Keluhan utama wajib diisi';
      hasError = true;
    }
    
    if (_alergiController.text.trim().isEmpty) {
      _alergiError = 'Alergi wajib diisi';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    // TODO: Simpan ke database
    SnackbarHelper.showSuccess('Data rekam medis berhasil disimpan');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _namaPasienController.dispose();
    _idPasienController.dispose();
    _usiaController.dispose();
    _poliTujuanController.dispose();
    _tekananDarahSistolikController.dispose();
    _tekananDarahDiastolikController.dispose();
    _nadiController.dispose();
    _suhuController.dispose();
    _pernapasanController.dispose();
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    _imtController.dispose();
    _keluhanUtamaController.dispose();
    _riwayatPenyakitController.dispose();
    _alergiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Form Rekam Medis',
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identitas Pasien
              _buildSectionTitle('Identitas Pasien'),
              const SizedBox(height: 12),
              _buildLabel('Nama Pasien'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_namaPasienController),
              const SizedBox(height: 12),
              
              _buildLabel('Id Pasien'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_idPasienController),
              const SizedBox(height: 12),
              
              _buildLabel('Usia'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_usiaController),
              const SizedBox(height: 12),
              
              _buildLabel('Poli Tujuan'),
              const SizedBox(height: 8),
              _buildReadOnlyField(_poliTujuanController),
              const SizedBox(height: 24),
              
              // Tanda Vital
              _buildSectionTitle('Tanda Vital'),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Tekanan Darah'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _tekananDarahSistolikController,
                      hintText: '120',
                      errorText: _tekananDarahSistolikError,
                      onChanged: (value) {
                        if (_tekananDarahSistolikError != null && value.trim().isNotEmpty) {
                          setState(() {
                            _tekananDarahSistolikError = null;
                          });
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: _buildNumberFieldWithSuffix(
                      controller: _tekananDarahDiastolikController,
                      hintText: '80',
                      suffix: 'mmHg',
                      errorText: _tekananDarahDiastolikError,
                      onChanged: (value) {
                        if (_tekananDarahDiastolikError != null && value.trim().isNotEmpty) {
                          setState(() {
                            _tekananDarahDiastolikError = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Nadi'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _nadiController,
                hintText: '78',
                suffix: '/menit',
                errorText: _nadiError,
                onChanged: (value) {
                  if (_nadiError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _nadiError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Suhu'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _suhuController,
                hintText: '36',
                suffix: '°C',
                errorText: _suhuError,
                onChanged: (value) {
                  if (_suhuError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _suhuError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              _buildLabel('Pernapasan'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _pernapasanController,
                hintText: '18',
                suffix: '/menit',
              ),
              const SizedBox(height: 24),
              
              // Antropometri
              _buildSectionTitle('Antropometri'),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Berat Badan'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _beratBadanController,
                hintText: '60',
                suffix: 'kg',
                errorText: _beratBadanError,
                onChanged: (value) {
                  if (_beratBadanError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _beratBadanError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Tinggi Badan'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _tinggiBadanController,
                hintText: '170',
                suffix: 'cm',
                errorText: _tinggiBadanError,
                onChanged: (value) {
                  if (_tinggiBadanError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _tinggiBadanError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              _buildLabel('IMT'),
              const SizedBox(height: 8),
              _buildNumberFieldWithSuffix(
                controller: _imtController,
                hintText: '20.8',
                suffix: 'kg/m²',
                readOnly: true,
              ),
              const SizedBox(height: 12),
              
              // Info Box IMT
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Indeks Massa Tubuh (IMT) dihitung otomatis : Berat Badan (kg) dibagi Tinggi Badan (m)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Keluhan & Anamnesis
              _buildSectionTitle('Keluhan & Anamnesis'),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Keluhan Utama'),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _keluhanUtamaController,
                    hintText: 'Contoh : Demam sejak 3 hari yang lalu, dan flu',
                    maxLines: 3,
                    backgroundColor: AppColors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey,
                    borderColor: _keluhanUtamaError != null ? Colors.red : AppColors.primary,
                    borderWidth: 2,
                    onChanged: (value) {
                      if (_keluhanUtamaError != null && value.trim().isNotEmpty) {
                        setState(() {
                          _keluhanUtamaError = null;
                        });
                      }
                    },
                  ),
                  if (_keluhanUtamaError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        _keluhanUtamaError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildLabel('Riwayat Penyakit'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _riwayatPenyakitController,
                hintText: 'Contoh : Demam berdarah',
                maxLines: 2,
                backgroundColor: AppColors.white,
                textColor: Colors.black87,
                hintColor: Colors.grey,
                borderColor: AppColors.primary,
                borderWidth: 2,
              ),
              const SizedBox(height: 12),
              
              _buildLabelRequired('Alergi'),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _alergiController,
                    hintText: 'Contoh : Udang dan kacang tanah',
                    maxLines: 2,
                    backgroundColor: AppColors.white,
                    textColor: Colors.black87,
                    hintColor: Colors.grey,
                    borderColor: _alergiError != null ? Colors.red : AppColors.primary,
                    borderWidth: 2,
                    onChanged: (value) {
                      if (_alergiError != null && value.trim().isNotEmpty) {
                        setState(() {
                          _alergiError = null;
                        });
                      }
                    },
                  ),
                  if (_alergiError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        _alergiError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Warning Box - Permanen Visible
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFB020),
                    width: 1,
                  ),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF8C00),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peringatan',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFFFF8C00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pastikan semua data bertanda bintang merah (*) sudah terisi dengan benar sebelum disimpan',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF856404),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'BATAL',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'SIMPAN DATA',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLabelRequired(String label) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black87,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNumberFieldWithSuffix({
    required TextEditingController controller,
    required String hintText,
    required String suffix,
    bool readOnly = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          readOnly: readOnly,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black87,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffix,
            suffixStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: readOnly ? AppColors.backgroundLight : AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
