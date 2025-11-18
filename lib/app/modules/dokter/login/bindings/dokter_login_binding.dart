import 'package:get/get.dart';

import '../controllers/dokter_login_controller.dart';

class DokterLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterLoginController>(
      () => DokterLoginController(),
    );
  }
}
