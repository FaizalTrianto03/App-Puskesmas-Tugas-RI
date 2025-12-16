import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Instansiasi langsung agar SplashController.onInit dipanggil
    Get.put<SplashController>(SplashController());
  }
}
