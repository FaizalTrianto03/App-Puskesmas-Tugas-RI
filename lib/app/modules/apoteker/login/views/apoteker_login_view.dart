import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/apoteker_login_controller.dart';

class ApotekerLoginView extends GetView<ApotekerLoginController> {
  const ApotekerLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoteker Login'),
      ),
      body: const Center(
        child: Text('Apoteker Login Page'),
      ),
    );
  }
}
