import 'package:get/get.dart';

import '../controllers/pasien_register_controller.dart';

class PasienRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasienRegisterController>(
      () => PasienRegisterController(),
    );
  }
}
