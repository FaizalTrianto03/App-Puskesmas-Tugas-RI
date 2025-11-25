import 'package:get/get.dart';
import '../controllers/perawat_settings_controller.dart';

class PerawatSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerawatSettingsController>(
      () => PerawatSettingsController(),
    );
  }
}
