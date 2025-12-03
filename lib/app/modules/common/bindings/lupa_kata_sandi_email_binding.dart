import 'package:get/get.dart';
import '../controllers/lupa_kata_sandi_email_controller.dart';

class LupaKataSandiEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LupaKataSandiEmailController>(
      () => LupaKataSandiEmailController(),
    );
  }
}
