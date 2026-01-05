import 'package:get/get.dart';
import '../controllers/kelola_poli_controller.dart';

class KelolaPoliBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaPoliController>(() => KelolaPoliController());
  }
}
