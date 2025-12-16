import 'package:get/get.dart';

import '../controllers/apoteker_settings_controller.dart';

class ApotekerSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApotekerSettingsController>(
      () => ApotekerSettingsController(),
    );
  }
}
