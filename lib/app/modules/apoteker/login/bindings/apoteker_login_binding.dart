import 'package:get/get.dart';

import '../controllers/apoteker_login_controller.dart';

class ApotekerLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApotekerLoginController>(
      () => ApotekerLoginController(),
    );
  }
}
