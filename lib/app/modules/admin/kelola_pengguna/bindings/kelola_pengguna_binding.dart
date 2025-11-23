import 'package:get/get.dart';
import '../controllers/kelola_pengguna_controller.dart';

class KelolaPenggunaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaPenggunaController>(
      () => KelolaPenggunaController(),
    );
  }
}
