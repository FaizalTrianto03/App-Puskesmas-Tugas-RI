import 'package:get/get.dart';

class PasienProfileController extends GetxController {
  // Observable user data
  final userName = 'Anisa Ayu'.obs;
  final userNIK = '20221037031009'.obs;
  final userRekamMedis = 'RM-2025-001234'.obs;
  final cardValidUntil = '31 Desember 2026'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load user data from session/database if needed
  }

  void navigateToSettings() {
    Get.toNamed('/pasien-settings');
  }
}
