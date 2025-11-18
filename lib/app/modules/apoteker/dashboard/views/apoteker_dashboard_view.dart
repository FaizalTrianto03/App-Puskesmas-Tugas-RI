import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/apoteker_dashboard_controller.dart';

class ApotekerDashboardView extends GetView<ApotekerDashboardController> {
  const ApotekerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoteker Dashboard'),
      ),
      body: const Center(
        child: Text('Apoteker Dashboard Page'),
      ),
    );
  }
}
