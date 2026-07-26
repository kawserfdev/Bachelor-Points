import 'dart:async';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure that imperative navigation (context.push) updates the browser URL on web
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Run app wrapped with Riverpod ProviderScope and BootShell immediately
  runApp(const ProviderScope(child: BootShell()));
}

/// Lightweight startup shell widget.
/// Shows an instant splash UI while heavy async initialization tasks run in the background.
class BootShell extends StatefulWidget {
  const BootShell({super.key});

  @override
  State<BootShell> createState() => _BootShellState();
}

class _BootShellState extends State<BootShell> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      await AppInitializer.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Startup error: $e\n$stackTrace");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return const MyApp();
    }

    if (_errorMessage != null) {
      return MaterialApp(
        title: 'Bachelor Points',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _startInitialization,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Bachelor Points',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Bachelor Points',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Service and environment initializer that parallelizes independent tasks.
class AppInitializer {
  static Future<void> initialize() async {
    debugPrint('Starting optimized background initialization...');

    // Execute independent tracks concurrently via Future.wait()
    await Future.wait([
      _initEnvironmentAndStorage(),
      _initFirebaseAndServices(),
    ]);

    debugPrint('All background services started successfully.');
  }

  /// Track 1: Environment variables & Local Storage initialization
  static Future<void> _initEnvironmentAndStorage() async {
    await Future.wait([
      _initDotenv(),
      _initStorage(),
    ]);
  }

  static Future<void> _initDotenv() async {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('Dotenv loaded successfully');
    } catch (e) {
      debugPrint("dotenv load failed (non-fatal): $e");
    }
  }

  static Future<void> _initStorage() async {
    try {
      await GetStorage.init();
      final storageService = StorageService();
      // permanent: true — survives logout so ThemeController can still read
      storageService.init();
      Get.put<StorageService>(storageService, permanent: true);
      debugPrint('StorageService initialized successfully');
    } catch (e) {
      debugPrint("StorageService init failed: $e");
    }
  }

  /// Track 2: Firebase core, App Check, and dependent services
  static Future<void> _initFirebaseAndServices() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase Core initialized successfully');
    } catch (e) {
      debugPrint("Firebase init failed: $e");
    }

    // Launch App Check attestation in background (fire-and-forget) immediately after Firebase Core init
    // so reCAPTCHA/attestation network loading does not block the critical startup path.
    unawaited(_initAppCheck());

    // Synchronously register AuthService & lazy-register RealtimeService (0ms startup overhead)
    _initAuthService();
    _initRealtimeService();
  }

  static Future<void> _initAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
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
  }

  static void _initAuthService() {
    try {
      final authService = AuthService();
      authService.init();
      Get.put<AuthService>(authService, permanent: true);
      debugPrint('AuthService initialized successfully');
    } catch (e) {
      debugPrint("AuthService init failed: $e");
    }
  }

  static void _initRealtimeService() {
    try {
      // Lazy-registered on first access when mess/meal/balance features open
      Get.lazyPut<RealtimeService>(() => RealtimeService()..init(), fenix: true);
      debugPrint('RealtimeService lazy-registered');
    } catch (e) {
      debugPrint("RealtimeService init failed: $e");
    }
  }
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
    // Initialize Notification Service post-frame to avoid blocking initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).init();
    });
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


/*
when DeviceType is tablet or desktop then Bottom navigationbar  can hide
lib
lib/core
lib/core/auth
lib/core/auth/auth_gate.dart
lib/core/auth/auth_service.dart
lib/core/localization
lib/core/localization/locale_controller.dart
lib/core/notifications
lib/core/notifications/notification_service.dart
lib/core/providers
lib/core/providers/auth_providers.dart
lib/core/providers/firebase_providers.dart
lib/core/providers/service_providers.dart
lib/core/routes
lib/core/routes/app_routes.dart
lib/core/routes/go_router_config.dart
lib/core/theme
lib/core/theme/app_theme.dart
lib/core/theme/dark_theme.dart
lib/core/theme/light_theme.dart
lib/core/theme/theme_controller.dart
lib/core/theme/theme_repository.dart
lib/data/models
lib/data/models/bazar_schedule_model.dart
lib/data/models/credit_model.dart
lib/data/models/deposit_model.dart
lib/data/models/expense_model.dart
lib/data/models/meal_model.dart
lib/data/models/member_balance_model.dart
lib/data/models/member_model.dart
lib/data/models/mess_member_model.dart
lib/data/models/mess_member_model.freezed.dart
lib/data/models/mess_member_model.g.dart
lib/data/models/mess_model.dart
lib/data/models/mess_model.freezed.dart
lib/data/models/mess_model.g.dart
lib/data/models/mess_settings_model.dart
lib/data/models/message_model.dart
lib/data/models/need_based_post_model.dart
lib/data/models/notification_model.dart
lib/data/models/property_model.dart
lib/data/models/referral_model.dart
lib/data/models/report_summary_model.dart
lib/data/models/request_model.dart
lib/data/models/shopping_item_model.dart
lib/data/models/shopping_list_model.dart
lib/data/models/tolet_chat_model.dart
lib/data/models/toletItem_model.dart
lib/data/models/user_model.dart
lib/data/models/user_model.freezed.dart
lib/data/models/user_model.g.dart
lib/data/models/user_profile_detail_model.dart
lib/data/models/user_profile_model.dart
lib/data/models/user_profile_model.freezed.dart
lib/data/models/user_profile_model.g.dart
lib/data/models/verification_model.dart
lib/domain/enums
lib/domain/enums/auth_provider.dart
lib/domain/enums/expense_category.dart
lib/domain/enums/meal_status.dart
lib/domain/enums/mess_role.dart
lib/domain/enums/sync_status.dart
lib/l10n
lib/l10n/app_bn.arb
lib/l10n/app_en.arb
lib/l10n/app_hi.arb
lib/l10n/app_localizations_bn.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_hi.dart
lib/l10n/app_localizations.dart
lib/modules
lib/modules/auth
lib/modules/auth/forgot_password
lib/modules/auth/forgot_password/forgot_password_binding.dart
lib/modules/auth/forgot_password/forgot_password_controller.dart
lib/modules/auth/forgot_password/forgot_password_view.dart
lib/modules/auth/login
lib/modules/auth/login/login_binding.dart
lib/modules/auth/login/login_controller.dart
lib/modules/auth/login/login_view.dart
lib/modules/auth/signup
lib/modules/auth/signup/signup_binding.dart
lib/modules/auth/signup/signup_controller.dart
lib/modules/auth/signup/signup_view.dart
lib/modules/auth/verify_email
lib/modules/auth/verify_email/verify_email_view.dart
lib/modules/balance
lib/modules/balance/views
lib/modules/balance/views/add_deposit_view.dart
lib/modules/balance/views/balance_summary_view.dart
lib/modules/balance/balance_binding.dart
lib/modules/balance/balance_controller.dart
lib/modules/chat
lib/modules/chat/views
lib/modules/chat/views/chat_view.dart
lib/modules/chat/chat_binding.dart
lib/modules/chat/chat_controller.dart
lib/modules/expense
lib/modules/expense/views
lib/modules/expense/views/add_expense_view.dart
lib/modules/expense/views/expense_list_view.dart
lib/modules/expense/widgets
lib/modules/expense/widgets/expense_summary_card.dart
lib/modules/expense/expense_binding.dart
lib/modules/expense/expense_controller.dart
lib/modules/home
lib/modules/home/home_binding.dart
lib/modules/home/home_controller.dart
lib/modules/home/home_view.dart
lib/modules/meal
lib/modules/meal/widgets
lib/modules/meal/widgets/meal_preview_widget.dart
lib/modules/meal/meal_binding.dart
lib/modules/meal/meal_controller.dart
lib/modules/meal/meal_entry_view.dart
lib/modules/mess
lib/modules/mess/views
lib/modules/mess/views/members_view.dart
lib/modules/mess/widgets
lib/modules/mess/widgets/member_list_view.dart
lib/modules/mess/create_mess_view.dart
lib/modules/mess/join_mess_view.dart
lib/modules/mess/member_controller.dart
lib/modules/mess/mess_binding.dart
lib/modules/mess/mess_controller.dart
lib/modules/notifications
lib/modules/notifications/data
lib/modules/notifications/data/notification_repository.dart
lib/modules/notifications/domain
lib/modules/notifications/domain/notification_preferences.dart
lib/modules/notifications/providers
lib/modules/notifications/providers/notification_providers.dart
lib/modules/notifications/views
lib/modules/notifications/views/notification_view.dart
lib/modules/profile
lib/modules/profile/create_profile_binding.dart
lib/modules/profile/create_profile_controller.dart
lib/modules/profile/create_profile_view.dart
lib/modules/profile/edit_profile_binding.dart
lib/modules/profile/edit_profile_controller.dart
lib/modules/profile/edit_profile_view.dart
lib/modules/profile/profile_binding.dart
lib/modules/profile/profile_controller.dart
lib/modules/profile/profile_view.dart
lib/modules/profile/user_profile_detail_binding.dart
lib/modules/profile/user_profile_detail_controller.dart
lib/modules/profile/user_profile_detail_view.dart
lib/modules/report
lib/modules/report/views
lib/modules/report/views/report_view.dart
lib/modules/report/report_binding.dart
lib/modules/report/report_controller.dart
lib/modules/requests
lib/modules/requests/views
lib/modules/requests/views/approval_view.dart
lib/modules/requests/request_binding.dart
lib/modules/requests/request_controller.dart
lib/modules/settings
lib/modules/settings/views
lib/modules/settings/views/settings_view.dart
lib/modules/settings/settings_binding.dart
lib/modules/settings/settings_controller.dart
lib/modules/shopping
lib/modules/shopping/views
lib/modules/shopping/views/add_shopping_item_view.dart
lib/modules/shopping/views/shopping_list_view.dart
lib/modules/shopping/shopping_binding.dart
lib/modules/shopping/shopping_controller.dart
lib/modules/tolet
lib/modules/tolet/bindings
lib/modules/tolet/bindings/credit_binding.dart
lib/modules/tolet/bindings/listing_management_binding.dart
lib/modules/tolet/bindings/need_based_post_binding.dart
lib/modules/tolet/bindings/property_detail_binding.dart
lib/modules/tolet/bindings/property_post_binding.dart
lib/modules/tolet/bindings/tolet_binding.dart
lib/modules/tolet/bindings/tolet_chat_binding.dart
lib/modules/tolet/chat
lib/modules/tolet/chat/tolet_chat_controller.dart
lib/modules/tolet/credit
lib/modules/tolet/credit/credit_controller.dart
lib/modules/tolet/listing_management
lib/modules/tolet/listing_management/listing_management_controller.dart
lib/modules/tolet/need_based_post
lib/modules/tolet/need_based_post/need_based_post_controller.dart
lib/modules/tolet/property_detail
lib/modules/tolet/property_detail/property_detail_controller.dart
lib/modules/tolet/property_post
lib/modules/tolet/property_post/property_post_controller.dart
lib/modules/tolet/property_search
lib/modules/tolet/property_search/property_search_binding.dart
lib/modules/tolet/property_search/property_search_controller.dart
lib/modules/tolet/property_search/tolet_controller.dart
lib/modules/tolet/referral
lib/modules/tolet/referral/referral_controller.dart
lib/modules/tolet/views
lib/modules/tolet/views/credit_balance_view.dart
lib/modules/tolet/views/detailspage_view.dart
lib/modules/tolet/views/listing_management_view.dart
lib/modules/tolet/views/need_based_post_view.dart
lib/modules/tolet/views/property_detail_view.dart
lib/modules/tolet/views/property_map_search_view.dart
lib/modules/tolet/views/property_post_view.dart
lib/modules/tolet/views/property_search_view.dart
lib/modules/tolet/views/referral_view.dart
lib/modules/tolet/views/tolet_chat_view.dart
lib/modules/tolet/views/tolet_view.dart
lib/services
lib/services/action_notification_service.dart
lib/services/auth_service.dart
lib/services/credit_service.dart
lib/services/pdf_service.dart
lib/services/property_service.dart
lib/services/realtime_service.dart
lib/services/storage_service.dart
lib/services/tolet_services.dart
lib/shared
lib/shared/helpers
lib/shared/helpers/constraction_massage.dart
lib/shared/helpers/firestore_helpers.dart
lib/shared/helpers/navigation_helper.dart
lib/shared/widgets
lib/shared/widgets/custom_card.dart
lib/shared/widgets/custom_text_field.dart
lib/shared/widgets/primary_button.dart
lib/shared/widgets/responsive_layout.dart
lib/firebase_options.dart
lib/main.dart
lib/wrapper.dart

*/