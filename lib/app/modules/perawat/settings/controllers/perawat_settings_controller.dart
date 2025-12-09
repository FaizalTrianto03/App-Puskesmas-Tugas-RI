import 'package:get/get.dart';
import '../../../../data/services/auth/session_service.dart';
import '../../../../routes/app_pages.dart';

class PerawatSettingsController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> logout() async {
    isLoading.value = true;
    await _sessionService.clearSession();
    isLoading.value = false;
    Get.offAllNamed(Routes.splash);
  }
}
