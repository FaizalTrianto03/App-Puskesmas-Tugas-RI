import 'package:get/get.dart';

import '../../../utils/snackbar_helper.dart';

class LupaKataSandiController extends GetxController {
  // TODO: Implementasi logika bisnis untuk lupa kata sandi
  // Contoh: validasi email, kirim request ke API, dll
  
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
  
  // Method untuk kirim link reset password
  Future<void> kirimLinkReset(String email) async {
    // TODO: Implementasi API call untuk kirim link reset
    try {
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Success handling
      SnackbarHelper.showSuccess('Link reset password telah dikirim ke email Anda');
    } catch (e) {
      // Error handling
      SnackbarHelper.showError('Terjadi kesalahan saat mengirim link reset');
    }
  }
}
