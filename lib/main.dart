import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/data/services/antrian/antrian_service.dart';
import 'app/data/services/auth/session_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase (hanya jika belum diinisialisasi)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } else {
      print('Firebase already initialized');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Firebase kemungkinan sudah terinisialisasi di level platform
  }

  // Initialize GetStorage
  await StorageService.init();

  // Register Services to GetX DI
  Get.put(SessionService());
  Get.put(await AntreanService().init());

  runApp(
    GetMaterialApp(
      title: "Aplikasi Puskesmas",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}