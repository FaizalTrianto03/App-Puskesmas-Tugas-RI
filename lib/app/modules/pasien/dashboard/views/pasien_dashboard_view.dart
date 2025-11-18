import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pasien_dashboard_controller.dart';

class PasienDashboardView extends GetView<PasienDashboardController> {
  const PasienDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasien Dashboard'),
      ),
      body: const Center(
        child: Text('Pasien Dashboard Page'),
      ),
    );
  }
}
