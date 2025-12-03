import 'package:get/get.dart';

import '../../../utils/snackbar_helper.dart';

class LupaKataSandiEmailController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  
  // TODO: Implementasi logika bisnis untuk kirim OTP
  
  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller
  }

  @override
  void onClose() {
    // Cleanup resources
    super.onClose();
  }
  
  // Method untuk kirim OTP ke email
  Future<bool> kirimOTP(String email) async {
    // TODO: Implementasi API call untuk kirim OTP
    try {
      isLoading.value = true;
      
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 2));
      
      isLoading.value = false;
      
      // Success
      SnackbarHelper.showSuccess('Kode OTP telah dikirim ke email Anda');
      
      return true;
    } catch (e) {
      isLoading.value = false;
      
      // Error handling
      SnackbarHelper.showError('Terjadi kesalahan saat mengirim OTP');
      
      return false;
    }
  }
}
