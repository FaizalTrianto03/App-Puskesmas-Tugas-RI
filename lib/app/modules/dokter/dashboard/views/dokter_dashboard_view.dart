import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dokter_dashboard_controller.dart';

class DokterDashboardView extends GetView<DokterDashboardController> {
  const DokterDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokter Dashboard'),
      ),
      body: const Center(
        child: Text('Dokter Dashboard Page'),
      ),
    );
  }
}
