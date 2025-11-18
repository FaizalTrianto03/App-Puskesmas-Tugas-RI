import 'package:get/get.dart';

import '../controllers/pasien_login_controller.dart';

class PasienLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasienLoginController>(
      () => PasienLoginController(),
    );
  }
}
