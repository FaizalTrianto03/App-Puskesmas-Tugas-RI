import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pasien_login_controller.dart';

class PasienLoginView extends GetView<PasienLoginController> {
  const PasienLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasien Login'),
      ),
      body: const Center(
        child: Text('Pasien Login Page'),
      ),
    );
  }
}
