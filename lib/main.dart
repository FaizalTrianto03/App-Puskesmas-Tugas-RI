import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/services/antrian/antrian_service.dart';
import 'app/data/services/auth/session_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== APP INITIALIZATION ===');
  
  // Initialize GetStorage
  print('Initializing GetStorage...');
  await StorageService.init();
  print('GetStorage initialized');
  
  // Initialize Services
  final storage = StorageService();
  print('Initializing dummy data...');
  await storage.initDummyUsers();
  await storage.initDummyRiwayat();
  print('Dummy data initialized');
  
  // Register Services to GetX DI
  print('Registering services...');
  final sessionService = Get.put(SessionService());
  Get.put(await AntreanService().init());
  print('Services registered');
  
  // Debug: Check if there's existing session
  print('Checking existing session...');
  print('Is logged in: ${sessionService.isLoggedIn()}');
  print('Role: ${sessionService.getRole()}');
  print('=========================');
  
  runApp(
    GetMaterialApp(
      title: "Aplikasi Puskesmas",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
