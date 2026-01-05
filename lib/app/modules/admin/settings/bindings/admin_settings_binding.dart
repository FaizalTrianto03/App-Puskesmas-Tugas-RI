import 'package:get/get.dart';
import '../controllers/admin_settings_controller.dart';
import '../controllers/kelola_data_diri_controller.dart';
import '../controllers/kelola_kata_sandi_controller.dart';

class AdminSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminSettingsController>(
      () => AdminSettingsController(),
    );
    Get.lazyPut<AdminKelolaDataDiriController>(
      () => AdminKelolaDataDiriController(),
    );
    Get.lazyPut<KelolaKataSandiController>(
      () => KelolaKataSandiController(),
    );
  }
}
