import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/perawat_dashboard_controller.dart';

class PerawatDashboardView extends GetView<PerawatDashboardController> {
  const PerawatDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perawat Dashboard'),
      ),
      body: const Center(
        child: Text('Perawat Dashboard Page'),
      ),
    );
  }
}
