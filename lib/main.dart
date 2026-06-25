import 'package:bachelorpoints/firebase_options.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:get_storage/get_storage.dart';
import 'services/auth_service.dart';

import 'services/storage_service.dart';
import 'services/realtime_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/notifications/notification_service.dart';
import 'core/routes/go_router_config.dart';
import 'core/localization/locale_controller.dart';

/// Global navigator key for use outside the widget tree (e.g., FCM)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Initialize Local Storage
  await GetStorage.init();

  // 3. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed (maybe no config provided): $e");
  }

  // 4. Initialize Firebase App Check
  try {
    await FirebaseAppCheck.instance.activate(
      // Debug providers for development — allows Firebase to work on
      // emulators and non-distribution builds without real attestation.
      // Switch to AndroidProvider.playIntegrity / AppleProvider.appAttest
      // for production.
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider(
        '6Lf-TiQrAAAAAMjFh0k6sDgMZ7dYPZ0gUvo0GVmI',
      ),
    );
    debugPrint('Firebase App Check activated');
  } catch (e) {
    debugPrint("Firebase App Check init failed: $e");
  }

  // 5. Inject Global Services (GetX-based during migration)
  await initServices();

  // 6. Run app wrapped with Riverpod ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> initServices() async {
  debugPrint('Starting services initialization...');

  final storageService = StorageService();
  // permanent: true — survives logout so ThemeController can still read
  Get.put<StorageService>(storageService, permanent: true);
  try {
    await storageService.init();
  } catch (e) {
    debugPrint("StorageService init failed: $e");
  }

  final authService = AuthService();
  Get.put<AuthService>(authService, permanent: true);
  try {
    await authService.init();
  } catch (e) {
    debugPrint("AuthService init failed: $e");
  }

  // FcmService has been removed. Riverpod-managed NotificationService takes its place.

  final realtimeService = RealtimeService();
  Get.put<RealtimeService>(realtimeService, permanent: true);
  try {
    await realtimeService.init();
  } catch (e) {
    debugPrint("RealtimeService init failed: $e");
  }

  // ThemeController is now managed by Riverpod and initialized on demand.

  debugPrint('All services started...');
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Notification Service on startup
    ref.read(notificationServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MyApp...');
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Bachelor Points',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// GoRouter provider — must be defined here because it depends on
/// the ProviderScope from main.dart for ref access
final goRouterProvider = Provider<GoRouter>((ref) {
  return buildGoRouter(ref);
});
