import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../wrapper.dart';
import '../providers/auth_providers.dart';
import '../auth/auth_gate.dart';
import '../auth/auth_loading_view.dart';

// ── Auth Views & Bindings (Synchronous for fast auth) ──
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/signup/signup_view.dart';
import '../../modules/auth/signup/signup_binding.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';
import '../../modules/auth/forgot_password/forgot_password_binding.dart';
import '../../modules/auth/verify_email/verify_email_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/create_profile_view.dart';
import '../../modules/profile/create_profile_binding.dart';
import '../../modules/profile/user_profile_detail_binding.dart';
import '../../modules/profile/user_profile_detail_view.dart';
import '../../modules/profile/edit_profile_binding.dart';
import '../../modules/profile/edit_profile_view.dart';

// ── Core Mess & Features (Synchronous) ──
import '../../modules/mess/create_mess_view.dart';
import '../../modules/mess/join_mess_view.dart';
import '../../modules/mess/mess_binding.dart';
import '../../modules/mess/views/members_view.dart';
import '../../modules/meal/meal_entry_view.dart';
import '../../modules/meal/meal_binding.dart';
import '../../modules/expense/views/expense_list_view.dart';
import '../../modules/expense/views/add_expense_view.dart';
import '../../modules/expense/expense_binding.dart';
import '../../modules/balance/views/balance_summary_view.dart';
import '../../modules/balance/views/add_deposit_view.dart';
import '../../modules/balance/balance_binding.dart';
import '../../modules/requests/views/approval_view.dart';
import '../../modules/requests/request_binding.dart';
import '../../modules/notifications/views/notification_view.dart';

// ── Deferred Heavy Modules (Web Bundle Size Optimization) ──
import '../../modules/chat/views/chat_view.dart' deferred as chat_view;
import '../../modules/chat/chat_binding.dart' deferred as chat_binding;

import '../../modules/report/views/report_view.dart' deferred as report_view;
import '../../modules/report/report_binding.dart' deferred as report_binding;

import '../../modules/settings/views/settings_view.dart' deferred as settings_view;
import '../../modules/settings/settings_binding.dart' deferred as settings_binding;

import '../../modules/shopping/views/shopping_list_view.dart' deferred as shopping_list_view;
import '../../modules/shopping/views/add_shopping_item_view.dart' deferred as add_shopping_item_view;
import '../../modules/shopping/shopping_binding.dart' deferred as shopping_binding;

import '../../modules/tolet/views/tolet_view.dart' deferred as tolet_view;
import '../../modules/tolet/bindings/tolet_binding.dart' deferred as tolet_binding;
import '../../modules/tolet/views/property_search_view.dart' deferred as property_search_view;
import '../../modules/tolet/property_search/property_search_binding.dart' deferred as property_search_binding;
import '../../modules/tolet/views/property_map_search_view.dart' deferred as property_map_search_view;
import '../../modules/tolet/views/property_detail_view.dart' deferred as property_detail_view;
import '../../modules/tolet/bindings/property_detail_binding.dart' deferred as property_detail_binding;
import '../../modules/tolet/views/property_post_view.dart' deferred as property_post_view;
import '../../modules/tolet/bindings/property_post_binding.dart' deferred as property_post_binding;
import '../../modules/tolet/views/listing_management_view.dart' deferred as listing_management_view;
import '../../modules/tolet/bindings/listing_management_binding.dart' deferred as listing_management_binding;
import '../../modules/tolet/views/need_based_post_view.dart' deferred as need_based_post_view;
import '../../modules/tolet/bindings/need_based_post_binding.dart' deferred as need_based_post_binding;
import '../../modules/tolet/views/tolet_chat_view.dart' deferred as tolet_chat_view;
import '../../modules/tolet/bindings/tolet_chat_binding.dart' deferred as tolet_chat_binding;
import '../../modules/tolet/views/credit_balance_view.dart' deferred as credit_balance_view;
import '../../modules/tolet/bindings/credit_binding.dart' deferred as credit_binding;
import '../../modules/tolet/views/referral_view.dart' deferred as referral_view;

/// Helper widget to lazy-load deferred Dart libraries and display a loading indicator.
class DeferredLoader extends StatefulWidget {
  final Future<void> Function() loader;
  final Widget Function() builder;

  const DeferredLoader({
    super.key,
    required this.loader,
    required this.builder,
  });

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load module: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return widget.builder();
        }

        return const Scaffold(
          body: Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route path constants — single source of truth for all route strings.
// Always use these constants; never hardcode a path string in navigation calls.
// ─────────────────────────────────────────────────────────────────────────────
class GoRoutes {
  GoRoutes._();

  // ── Auth ──
  static const splash        = '/';
  static const login         = '/login';
  static const signup        = '/signup';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail   = '/verify-email';
  static const createProfile = '/create-profile';
  static const authLoading   = '/auth-loading';

  // ── Main Shell (bottom nav tabs) ──
  static const home    = '/home';
  static const tolet = '/tolet';
  static const profile = '/profile';

  // ── Profile sub-pages ──
  static const profileDetail = '/profile/detail';
  static const editProfile   = '/profile/edit';

  // ── Mess features ──
  static const createMess = '/create-mess';
  static const joinMess   = '/join-mess';
  static const members    = '/members';

  // ── Core features ──
  static const mealEntry     = '/meal-entry';
  static const expenses      = '/expenses';
  static const addExpense    = '/add-expense';
  static const balanceSummary = '/balance-summary';
  static const addDeposit    = '/add-deposit';
  static const approvals     = '/approvals';
  static const notifications = '/notifications';
  static const chat          = '/chat';
  static const report        = '/report';
  static const shoppingList  = '/shopping-list';
  static const addShoppingItem = '/shopping-list/add';
  static const settings      = '/settings';

  // ── Tolet feature ──
  static const toletHome        = '/tolet';          // entry point / redirect
  static const propertySearch   = '/tolet/search';
  static const propertyMapSearch = '/tolet/map-search';
  static const propertyDetail   = '/tolet/property';
  static const propertyPost     = '/tolet/post';
  static const myListings       = '/tolet/my-listings';
  static const needBasedPost    = '/tolet/need-based';
  static const toletChat        = '/tolet/chat';
  static const creditBalance    = '/tolet/credits';
  static const referral         = '/tolet/referral';
}

// ─────────────────────────────────────────────────────────────────────────────
// All routes that are part of the main authenticated app shell.
// Used by the redirect guard to decide whether a route needs a profile.
// ─────────────────────────────────────────────────────────────────────────────
const _protectedAppRoutes = {
  GoRoutes.home,
  GoRoutes.tolet,
  GoRoutes.profile,
  GoRoutes.profileDetail,
  GoRoutes.editProfile,
  GoRoutes.createMess,
  GoRoutes.joinMess,
  GoRoutes.members,
  GoRoutes.mealEntry,
  GoRoutes.expenses,
  GoRoutes.addExpense,
  GoRoutes.balanceSummary,
  GoRoutes.addDeposit,
  GoRoutes.approvals,
  GoRoutes.notifications,
  GoRoutes.chat,
  GoRoutes.report,
  GoRoutes.shoppingList,
  GoRoutes.addShoppingItem,
  GoRoutes.settings,
  //GoRoutes.toletHome,
  GoRoutes.propertySearch,
  GoRoutes.propertyMapSearch,
  GoRoutes.propertyDetail,
  GoRoutes.propertyPost,
  GoRoutes.myListings,
  GoRoutes.needBasedPost,
  GoRoutes.toletChat,
  GoRoutes.creditBalance,
  GoRoutes.referral,
};

/// Listenable bridging Riverpod auth/profile state changes to GoRouter's refreshListenable.
/// Triggers in-place redirect evaluation without destroying/recreating the GoRouter instance.
class RouterListenable extends ChangeNotifier {
  RouterListenable(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      notifyListeners();
    });
    ref.listen<AsyncValue<bool>>(hasProfileProvider, (previous, next) {
      notifyListeners();
    });
    ref.listen<AsyncValue<dynamic>>(authUserStreamProvider, (previous, next) {
      notifyListeners();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Build the GoRouter instance, wired to Riverpod auth + profile providers.
// ─────────────────────────────────────────────────────────────────────────────
GoRouter buildGoRouter(Ref ref) {
  final refreshListenable = RouterListenable(ref);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: GoRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState       = ref.read(authStateProvider);
      final hasProfileAsync = ref.read(hasProfileProvider);
      final authUserAsync   = ref.read(authUserStreamProvider);
      final location        = state.matchedLocation;

      debugPrint('══════════════════════════════════');
      debugPrint('[Router] location      : $location');
      debugPrint('[Router] authState     : $authState');
      debugPrint('[Router] profileLoading: ${hasProfileAsync.isLoading}');
      debugPrint('[Router] hasProfile    : ${hasProfileAsync.asData?.value}');

      // If the auth stream is still loading, stay on the splash screen / current page
      if (authUserAsync.isLoading) {
        debugPrint('[Router] Auth user stream is loading, staying on splash/current page');
        return null;
      }

      final isSplash        = location == GoRoutes.splash;
      final isAuthLoading   = location == GoRoutes.authLoading;
      final isPublicAuth    = location == GoRoutes.login ||
                              location == GoRoutes.signup ||
                              location == GoRoutes.forgotPassword;
      final isVerifyEmail   = location == GoRoutes.verifyEmail;
      final isCreateProfile = location == GoRoutes.createProfile;
      final isProtectedApp  = _protectedAppRoutes.any(
        (r) => location == r || location.startsWith('$r/'),
      );

      // ── 1. Unauthenticated ───────────────────────────────────────────────
      if (authState == AuthState.unauthenticated) {
        // Allow public auth pages; redirect everything else to login.
        if (isPublicAuth) return null;
        debugPrint('[Router] Unauthenticated → /login');
        return GoRoutes.login;
      }

      // ── 2. Email not verified ────────────────────────────────────────────
      if (authState == AuthState.emailNotVerified) {
        if (isVerifyEmail || isPublicAuth) return null;
        debugPrint('[Router] Email unverified → /verify-email');
        return GoRoutes.verifyEmail;
      }

      // ── 3. Fully authenticated ───────────────────────────────────────────
      // From here authState == AuthState.authenticated.

      // 3a. On public auth routes, splash, or verify-email → send to auth-loading or home
      if (isPublicAuth || isVerifyEmail || isSplash) {
        if (hasProfileAsync.isLoading) {
          debugPrint('[Router] Authenticated on auth route, profile loading → /auth-loading');
          return GoRoutes.authLoading;
        }
        final hasProfile = hasProfileAsync.asData?.value;
        if (hasProfile == null) return GoRoutes.authLoading;
        debugPrint('[Router] Authenticated on auth route → '
            '${hasProfile ? GoRoutes.home : GoRoutes.createProfile}');
        return hasProfile ? GoRoutes.home : GoRoutes.createProfile;
      }

      // 3b. On auth-loading page → wait for profile then send to home/create-profile
      if (isAuthLoading) {
        if (hasProfileAsync.isLoading) return null; // stay on /auth-loading while checking
        final hasProfile = hasProfileAsync.asData?.value;
        if (hasProfile == null) return null; // stay on /auth-loading
        debugPrint('[Router] Profile resolved on /auth-loading → '
            '${hasProfile ? GoRoutes.home : GoRoutes.createProfile}');
        return hasProfile ? GoRoutes.home : GoRoutes.createProfile;
      }

      // 3c. On create-profile but already has a profile → home.
      if (isCreateProfile) {
        final hasProfile = hasProfileAsync.asData?.value;
        if (hasProfile == true) {
          debugPrint('[Router] Has profile on /create-profile → /home');
          return GoRoutes.home;
        }
        return null; // still needs to create profile
      }

      // 3d. On a protected app route without a profile → create-profile.
      if (isProtectedApp) {
        if (hasProfileAsync.isLoading) return null; // don't block; wait
        final hasProfile = hasProfileAsync.asData?.value;
        if (hasProfile == false) {
          debugPrint('[Router] No profile on protected route → /create-profile');
          return GoRoutes.createProfile;
        }
        return null; // has profile → allow
      }

      // 3e. Tolet home redirect → property search (no dedicated tolet hub yet).
      if (location == GoRoutes.toletHome) {
        debugPrint('[Router] /tolet → /tolet/search');
        return GoRoutes.propertySearch;
      }

      debugPrint('[Router] No redirect → stay');
      debugPrint('══════════════════════════════════');
      return null;
    },

    routes: [
      // ── Splash / Auth Gate ────────────────────────────────────────────────
      GoRoute(
        path: GoRoutes.splash,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: GoRoutes.authLoading,
        builder: (context, state) => const AuthLoadingView(),
      ),

      // ── Auth Routes ───────────────────────────────────────────────────────
      GoRoute(
        path: GoRoutes.login,
        builder: (context, state) {
          LoginBinding().dependencies();
          return const LoginView();
        },
      ),
      GoRoute(
        path: GoRoutes.signup,
        builder: (context, state) {
          SignupBinding().dependencies();
          return const SignupView();
        },
      ),
      GoRoute(
        path: GoRoutes.forgotPassword,
        builder: (context, state) {
          ForgotPasswordBinding().dependencies();
          return const ForgotPasswordView();
        },
      ),
      GoRoute(
        path: GoRoutes.verifyEmail,
        builder: (context, state) => const VerifyEmailView(),
      ),
      GoRoute(
        path: GoRoutes.createProfile,
        builder: (context, state) {
          CreateProfileBinding().dependencies();
          return const CreateProfileView();
        },
      ),

      // ── Main App Shell (bottom nav tabs & core features) ────────────────
      // ShellRoute keeps the AppWrapper (which manages drawer and bottom bar) alive.
      ShellRoute(
        builder: (context, state, child) => AppWrapper(child: child),
        routes: [
          GoRoute(
            path: GoRoutes.home,
            builder: (context, state) {
              HomeBinding().dependencies();
              return const HomeView();
            },
          ),
          GoRoute(
            path: GoRoutes.tolet,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await tolet_binding.loadLibrary();
                await tolet_view.loadLibrary();
              },
              builder: () {
                tolet_binding.ToletBinding().dependencies();
                return tolet_view.ToletView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.profile,
            builder: (context, state) {
              ProfileBinding().dependencies();
              return const ProfileView();
            },
          ),

          // ── Profile Detail & Edit (now part of shell) ────────────────────────
          GoRoute(
            path: GoRoutes.profileDetail,
            builder: (context, state) {
              UserProfileDetailBinding().dependencies();
              return const UserProfileDetailView();
            },
          ),
          GoRoute(
            path: GoRoutes.editProfile,
            builder: (context, state) {
              EditProfileBinding().dependencies();
              return const EditProfileView();
            },
          ),

          // ── Mess Management (now part of shell) ──────────────────────────────
          GoRoute(
            path: GoRoutes.createMess,
            builder: (context, state) {
              MessBinding().dependencies();
              return const CreateMessView();
            },
          ),
          GoRoute(
            path: GoRoutes.joinMess,
            builder: (context, state) {
              MessBinding().dependencies();
              return const JoinMessView();
            },
          ),
          GoRoute(
            path: GoRoutes.members,
            builder: (context, state) {
              MessBinding().dependencies();
              RequestBinding().dependencies();
              return const MembersView();
            },
          ),

          // ── Core Features (now part of shell) ────────────────────────────────
          GoRoute(
            path: GoRoutes.mealEntry,
            builder: (context, state) {
              MealBinding().dependencies();
              return const MealEntryView();
            },
          ),
          GoRoute(
            path: GoRoutes.expenses,
            builder: (context, state) {
              ExpenseBinding().dependencies();
              return const ExpenseListView();
            },
          ),
          GoRoute(
            path: GoRoutes.addExpense,
            builder: (context, state) {
              ExpenseBinding().dependencies();
              return const AddExpenseView();
            },
          ),
          GoRoute(
            path: GoRoutes.balanceSummary,
            builder: (context, state) {
              BalanceBinding().dependencies();
              return const BalanceSummaryView();
            },
          ),
          GoRoute(
            path: GoRoutes.addDeposit,
            builder: (context, state) {
              BalanceBinding().dependencies();
              return const AddDepositView();
            },
          ),
          GoRoute(
            path: GoRoutes.approvals,
            builder: (context, state) {
              RequestBinding().dependencies();
              return const ApprovalView();
            },
          ),
          GoRoute(
            path: GoRoutes.notifications,
            builder: (context, state) => const NotificationView(),
          ),
          GoRoute(
            path: GoRoutes.chat,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await chat_binding.loadLibrary();
                await chat_view.loadLibrary();
              },
              builder: () {
                chat_binding.ChatBinding().dependencies();
                return chat_view.ChatView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.report,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await report_binding.loadLibrary();
                await report_view.loadLibrary();
              },
              builder: () {
                report_binding.ReportBinding().dependencies();
                return report_view.ReportView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.shoppingList,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await shopping_binding.loadLibrary();
                await shopping_list_view.loadLibrary();
              },
              builder: () {
                shopping_binding.ShoppingBinding().dependencies();
                return shopping_list_view.ShoppingListView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.addShoppingItem,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await shopping_binding.loadLibrary();
                await add_shopping_item_view.loadLibrary();
              },
              builder: () {
                shopping_binding.ShoppingBinding().dependencies();
                return add_shopping_item_view.AddShoppingItemView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.settings,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await settings_binding.loadLibrary();
                await settings_view.loadLibrary();
              },
              builder: () {
                settings_binding.SettingsBinding().dependencies();
                return settings_view.SettingsView();
              },
            ),
          ),

          // ── Tolet Feature (now part of shell) ────────────────────────────────
          GoRoute(
            path: GoRoutes.propertySearch,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await property_search_binding.loadLibrary();
                await property_search_view.loadLibrary();
              },
              builder: () {
                property_search_binding.PropertySearchBinding().dependencies();
                return property_search_view.PropertySearchView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.propertyMapSearch,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await property_search_binding.loadLibrary();
                await property_map_search_view.loadLibrary();
              },
              builder: () {
                property_search_binding.PropertySearchBinding().dependencies();
                return property_map_search_view.PropertyMapSearchView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.propertyDetail,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await property_detail_binding.loadLibrary();
                await property_detail_view.loadLibrary();
              },
              builder: () {
                property_detail_binding.PropertyDetailBinding().dependencies();
                return property_detail_view.PropertyDetailView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.propertyPost,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await property_post_binding.loadLibrary();
                await property_post_view.loadLibrary();
              },
              builder: () {
                property_post_binding.PropertyPostBinding().dependencies();
                return property_post_view.PropertyPostView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.myListings,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await listing_management_binding.loadLibrary();
                await listing_management_view.loadLibrary();
              },
              builder: () {
                listing_management_binding.ListingManagementBinding().dependencies();
                return listing_management_view.ListingManagementView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.needBasedPost,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await need_based_post_binding.loadLibrary();
                await need_based_post_view.loadLibrary();
              },
              builder: () {
                need_based_post_binding.NeedBasedPostBinding().dependencies();
                return need_based_post_view.NeedBasedPostView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.toletChat,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await tolet_chat_binding.loadLibrary();
                await tolet_chat_view.loadLibrary();
              },
              builder: () {
                tolet_chat_binding.ToletChatBinding().dependencies();
                return tolet_chat_view.ToletChatView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.creditBalance,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await credit_binding.loadLibrary();
                await credit_balance_view.loadLibrary();
              },
              builder: () {
                credit_binding.CreditBinding().dependencies();
                return credit_balance_view.CreditBalanceView();
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.referral,
            builder: (context, state) => DeferredLoader(
              loader: () async {
                await credit_binding.loadLibrary();
                await referral_view.loadLibrary();
              },
              builder: () {
                credit_binding.CreditBinding().dependencies();
                return referral_view.ReferralView();
              },
            ),
          ),
        ],
      ),

      // ── Tolet Feature Redirect ──────────────────────────────────────────
      // /tolet itself redirects to /tolet/search via the redirect guard.
      GoRoute(
        path: GoRoutes.toletHome,
        redirect: (context, state) => GoRoutes.propertySearch,
      ),
    ],
  );
}