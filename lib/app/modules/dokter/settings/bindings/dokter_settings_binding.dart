import 'package:get/get.dart';

import '../controllers/dokter_settings_controller.dart';

class DokterSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterSettingsController>(
      () => DokterSettingsController(),
    );
  }
}
