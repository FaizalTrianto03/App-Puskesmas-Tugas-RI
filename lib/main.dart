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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print('ℹ️ Firebase already initialized - this is OK during hot reload');
    } else {
      print('❌ Firebase error: $e');
      rethrow;
    }
  
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    rethrow;
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