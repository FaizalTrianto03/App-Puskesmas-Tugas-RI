import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../pasien/login/views/pasien_login_view.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    // Manual navigation tanpa GetX routing
    final context = Get.context;
    if (context != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PasienLoginView()),
      );
    }
  }
}
