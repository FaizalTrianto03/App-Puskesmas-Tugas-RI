import 'package:get/get.dart';
import '../controllers/lupa_kata_sandi_reset_controller.dart';

class LupaKataSandiResetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LupaKataSandiResetController>(
      () => LupaKataSandiResetController(),
    );
  }
}
