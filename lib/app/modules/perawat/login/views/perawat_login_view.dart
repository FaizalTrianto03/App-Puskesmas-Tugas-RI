import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/perawat_login_controller.dart';

class PerawatLoginView extends GetView<PerawatLoginController> {
  const PerawatLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perawat Login'),
      ),
      body: const Center(
        child: Text('Perawat Login Page'),
      ),
    );
  }
}
