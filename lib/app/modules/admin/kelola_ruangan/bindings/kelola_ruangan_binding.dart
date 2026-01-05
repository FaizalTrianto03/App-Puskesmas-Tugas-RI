import 'package:get/get.dart';
import '../controllers/kelola_ruangan_controller.dart';

class KelolaRuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaRuanganController>(
      () => KelolaRuanganController(),
    );
  }
}
