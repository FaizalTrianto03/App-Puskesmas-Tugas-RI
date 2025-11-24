import 'package:get/get.dart';
import '../controllers/pasien_settings_controller.dart';

class PasienSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasienSettingsController>(
      () => PasienSettingsController(),
    );
  }
}
