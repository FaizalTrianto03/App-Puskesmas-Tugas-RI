import 'package:get/get.dart';

import '../controllers/pasien_profile_controller.dart';

class PasienProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasienProfileController>(
      () => PasienProfileController(),
    );
  }
}
