import 'package:get/get.dart';
import '../controllers/data_pasien_controller.dart';

class DataPasienBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataPasienController>(() => DataPasienController());
  }
}
