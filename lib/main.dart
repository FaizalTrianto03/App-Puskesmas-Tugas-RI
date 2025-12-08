import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await StorageService.init();
  
  // Initialize dummy data
  final storage = StorageService();
  await storage.initDummyUsers();
  await storage.initDummyRiwayat();
  
  runApp(
    GetMaterialApp(
      title: "Aplikasi Puskesmas",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
