import 'package:get/get.dart';

import '../controllers/kelola_data_diri_controller.dart';
import '../controllers/kelola_kata_sandi_controller.dart';

class PasienSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaDataDiriController>(
      () => KelolaDataDiriController(),
    );
    Get.lazyPut<KelolaKataSandiController>(
      () => KelolaKataSandiController(),
    );
  }
}
