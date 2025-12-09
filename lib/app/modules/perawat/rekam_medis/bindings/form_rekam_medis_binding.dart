import 'package:get/get.dart';
import '../controllers/form_rekam_medis_controller.dart';

class FormRekamMedisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormRekamMedisController>(
      () => FormRekamMedisController(),
    );
  }
}
