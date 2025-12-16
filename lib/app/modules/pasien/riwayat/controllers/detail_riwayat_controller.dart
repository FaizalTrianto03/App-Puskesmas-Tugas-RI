import 'package:get/get.dart';

class DetailRiwayatController extends GetxController {
  late final Map<String, dynamic> data;

  @override
  void onInit() {
    super.onInit();
    // Get data from arguments
    data = Get.arguments as Map<String, dynamic>;
  }
}
