import 'package:get/get.dart';
import '../controllers/verifikasi_antrian_controller.dart';

class VerifikasiAntrianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifikasiAntrianController>(
      () => VerifikasiAntrianController(),
    );
  }
}
