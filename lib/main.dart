import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

import 'core/config/env.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/fcm_service.dart';

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
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed (maybe no config provided): $e");
  }

  // 4. Initialize Supabase
  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint("Supabase init failed: $e");
  }

  // 5. Inject Global Services
  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  debugPrint('Starting services initialization...');
  await Get.putAsync(() => StorageService().init());
  
  // Only init AuthService and FcmService if Supabase/Firebase are ready, 
  // but for boilerplate we put them here.
  try {
    await Get.putAsync(() => AuthService().init());
  } catch (e) {
    debugPrint("AuthService init failed: $e");
  }

  try {
    await Get.putAsync(() => FcmService().init());
  } catch (e) {
    debugPrint("FcmService init failed: $e");
  }
  debugPrint('All services started...');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bachelor Points',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
