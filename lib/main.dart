import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/services/antrian/antrian_service.dart';
import 'app/data/services/auth/session_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/data/services/notification/fcm_service.dart';
import 'app/data/services/notification/local_notification_service.dart';
import 'app/data/services/notification/user_notification_service.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handler
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase (hanya jika belum diinisialisasi)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize GetStorage
  await StorageService.init();

  // Register Services to GetX DI
  Get.put(SessionService());
  Get.put(await AntreanService().init());
  
  // Initialize Notification Services
  Get.put(await LocalNotificationService().init());
  Get.put(UserNotificationService()); // New unified notification service
  Get.put(await FCMService().init());

  runApp(
    GetMaterialApp(
      title: "Aplikasi Puskesmas",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
