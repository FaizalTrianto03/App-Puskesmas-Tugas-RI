/// Validation Helper Utilities
/// Provides reusable validation functions for forms
class ValidationHelper {
  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation regex (min 8 chars, at least 1 letter and 1 number)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // Phone number validation (Indonesia format)
  static final RegExp _phoneRegex = RegExp(
    r'^(\+62|62|0)[0-9]{9,12}$',
  );

  // NIK validation (16 digits)
  static final RegExp _nikRegex = RegExp(
    r'^[0-9]{16}$',
  );

  // Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int maxEmailLength = 100;
  static const int minNameLength = 3;
  static const int maxNameLength = 100;

  // ========== EMAIL VALIDATION ==========

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    
    if (value.length > maxEmailLength) {
      return 'Email maksimal $maxEmailLength karakter';
    }
    
    if (!_emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  /// Validate required email (cannot be null)
  static String? validateRequiredEmail(String? value) {
    return validateEmail(value);
  }

  // ========== PASSWORD VALIDATION ==========

  /// Validate password format
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    
    if (value.length < minPasswordLength) {
      return 'Password minimal $minPasswordLength karakter';
    }
    
    if (value.length > maxPasswordLength) {
      return 'Password maksimal $maxPasswordLength karakter';
    }
    
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf dan 1 angka';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  // ========== NAME VALIDATION ==========

  /// Validate name (full name)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama harus diisi';
    }
    
    if (value.length < minNameLength) {
      return 'Nama minimal $minNameLength karakter';
    }
    
    if (value.length > maxNameLength) {
      return 'Nama maksimal $maxNameLength karakter';
    }
    
    return null;
  }

  // ========== PHONE NUMBER VALIDATION ==========

  /// Validate phone number (Indonesia format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP harus diisi';
    }
    
    if (!_phoneRegex.hasMatch(value)) {
      return 'Format nomor HP tidak valid (contoh: 081234567890)';
    }
    
    return null;
  }

  // ========== NIK VALIDATION ==========

  /// Validate NIK (16 digits)
  static String? validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK harus diisi';
    }
    
    if (!_nikRegex.hasMatch(value)) {
      return 'NIK harus 16 digit angka';
    }
    
    return null;
  }

  // ========== ADDRESS VALIDATION ==========

  /// Validate address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat harus diisi';
    }
    
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    
    if (value.length > 200) {
      return 'Alamat maksimal 200 karakter';
    }
    
    return null;
  }

  // ========== GENERIC VALIDATION ==========

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    
    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for max length
    }
    
    if (value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    
    return null;
  }

  /// Validate range length
  static String? validateRangeLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    
    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    
    if (value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    
    return null;
  }

  /// Validate numeric only
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '$fieldName hanya boleh berisi angka';
    }
    
    return null;
  }

  /// Validate alphabetic only
  static String? validateAlphabetic(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName hanya boleh berisi huruf';
    }
    
    return null;
  }

  // ========== DATE VALIDATION ==========

  /// Validate date is not in future
  static String? validateNotFutureDate(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName harus diisi';
    }
    
    if (value.isAfter(DateTime.now())) {
      return '$fieldName tidak boleh di masa depan';
    }
    
    return null;
  }

  /// Validate minimum age
  static String? validateMinimumAge(DateTime? birthDate, int minAge) {
    if (birthDate == null) {
      return 'Tanggal lahir harus diisi';
    }
    
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      // Birthday hasn't occurred this year
      if (age - 1 < minAge) {
        return 'Umur minimal $minAge tahun';
      }
    } else {
      if (age < minAge) {
        return 'Umur minimal $minAge tahun';
      }
    }
    
    return null;
  }
}
