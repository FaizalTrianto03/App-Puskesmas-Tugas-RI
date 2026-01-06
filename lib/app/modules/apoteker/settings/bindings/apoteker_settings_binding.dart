import 'package:get/get.dart';
import '../controllers/apoteker_settings_controller.dart';
import '../controllers/kelola_data_diri_controller.dart';
import '../controllers/kelola_kata_sandi_controller.dart';

class ApotekerSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApotekerSettingsController>(
      () => ApotekerSettingsController(),
    );
    Get.lazyPut<KelolaDataDiriController>(
      () => KelolaDataDiriController(),
    );
    Get.lazyPut<KelolaKataSandiController>(
      () => KelolaKataSandiController(),
    );
  }
}
