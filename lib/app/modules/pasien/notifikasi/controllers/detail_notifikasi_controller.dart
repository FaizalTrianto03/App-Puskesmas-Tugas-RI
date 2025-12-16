import 'package:get/get.dart';

class DetailNotifikasiController extends GetxController {
  late final Map<String, dynamic> notification;

  @override
  void onInit() {
    super.onInit();
    // Get notification data from arguments
    notification = Get.arguments as Map<String, dynamic>;
  }
}
