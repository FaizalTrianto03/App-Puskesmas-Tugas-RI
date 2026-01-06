import 'package:get/get.dart';
import '../controllers/referensi_selesai_controller.dart';

class ReferensiSelesaiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferensiSelesaiController>(() => ReferensiSelesaiController());
  }
}
