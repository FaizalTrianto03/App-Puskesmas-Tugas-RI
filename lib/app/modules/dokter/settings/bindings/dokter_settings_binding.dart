import 'package:get/get.dart';
import '../controllers/dokter_settings_controller.dart';
import '../controllers/kelola_data_diri_controller.dart';
import '../controllers/kelola_kata_sandi_controller.dart';

class DokterSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterSettingsController>(
      () => DokterSettingsController(),
    );
    Get.lazyPut<KelolaDataDiriController>(
      () => KelolaDataDiriController(),
    );
    Get.lazyPut<KelolaKataSandiController>(
      () => KelolaKataSandiController(),
    );
  }
}
