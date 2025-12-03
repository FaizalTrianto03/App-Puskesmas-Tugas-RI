import 'package:get/get.dart';

import '../../../utils/snackbar_helper.dart';

class LupaKataSandiResetController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final otpTimer = 60.obs;
  final canResendOTP = false.obs;
  
  // TODO: Implementasi logika bisnis untuk reset password dengan OTP
  
  @override
  void onInit() {
    super.onInit();
    startOTPTimer();
  }

  @override
  void onClose() {
    // Cleanup resources
    super.onClose();
  }
  
  // Method untuk memulai timer OTP
  void startOTPTimer() {
    otpTimer.value = 60;
    canResendOTP.value = false;
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      if (otpTimer.value > 0) {
        otpTimer.value--;
        return true;
      } else {
        canResendOTP.value = true;
        return false;
      }
    });
  }
  
  // Method untuk kirim ulang OTP
  Future<void> resendOTP() async {
    // TODO: Implementasi API call untuk kirim ulang OTP
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      startOTPTimer();
      
      SnackbarHelper.showSuccess('Kode OTP baru telah dikirim');
    } catch (e) {
      SnackbarHelper.showError('Terjadi kesalahan saat mengirim OTP');
    }
  }
  
  // Method untuk reset password
  Future<bool> resetPassword(String otp, String newPassword) async {
    // TODO: Implementasi API call untuk reset password
    try {
      isLoading.value = true;
      
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 2));
      
      isLoading.value = false;
      
      return true;
    } catch (e) {
      isLoading.value = false;
      
      SnackbarHelper.showError('Terjadi kesalahan saat mereset password');
      
      return false;
    }
  }
}
