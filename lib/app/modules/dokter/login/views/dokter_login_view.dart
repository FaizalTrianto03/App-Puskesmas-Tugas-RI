import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dokter_login_controller.dart';

class DokterLoginView extends GetView<DokterLoginController> {
  const DokterLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokter Login'),
      ),
      body: const Center(
        child: Text('Dokter Login Page'),
      ),
    );
  }
}
