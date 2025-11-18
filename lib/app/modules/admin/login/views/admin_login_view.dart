import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_login_controller.dart';

class AdminLoginView extends GetView<AdminLoginController> {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: const Center(
        child: Text('Admin Login Page'),
      ),
    );
  }
}
