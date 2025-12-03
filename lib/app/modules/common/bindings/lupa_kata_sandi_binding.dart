import 'package:get/get.dart';
import '../controllers/lupa_kata_sandi_controller.dart';

class LupaKataSandiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LupaKataSandiController>(
      () => LupaKataSandiController(),
    );
  }
}
