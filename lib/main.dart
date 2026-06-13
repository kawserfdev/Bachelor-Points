import 'package:bachelorpoints/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'core/config/env.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/fcm_service.dart';
import 'services/realtime_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
//Read Existing Schema then plan it

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Initialize Local Storage
  await GetStorage.init();

  // 3. Initialize Firebase (for FCM)
  // NOTE: You need to run `flutterfire configure` to generate firebase_options.dart
  // and pass options: DefaultFirebaseOptions.currentPlatform if you are using it.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed (maybe no config provided): $e");
  }

  // 5. Inject Global Services
  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  debugPrint('Starting services initialization...');

  final storageService = StorageService();
  Get.put<StorageService>(storageService);
  try {
    await storageService.init();
  } catch (e) {
    debugPrint("StorageService init failed: $e");
  }

  final authService = AuthService();
  Get.put<AuthService>(authService);
  try {
    await authService.init();
  } catch (e) {
    debugPrint("AuthService init failed: $e");
  }

  final fcmService = FcmService();
  Get.put<FcmService>(fcmService);
  try {
    await fcmService.init();
  } catch (e) {
    debugPrint("FcmService init failed: $e");
  }

  final realtimeService = RealtimeService();
  Get.put<RealtimeService>(realtimeService);
  try {
    await realtimeService.init();
  } catch (e) {
    debugPrint("RealtimeService init failed: $e");
  }

  // Theme Controller uses GetStorage, so it must be initialized after StorageService
  Get.put(ThemeController());

  debugPrint('All services started...');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authService = Get.find<AuthService>();

    return GetMaterialApp(
      title: 'Bachelor Points',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      initialRoute: authService.isLoggedIn ? AppRoutes.home : AppRoutes.login,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
