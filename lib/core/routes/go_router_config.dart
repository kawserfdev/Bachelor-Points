import 'package:bachelorpoints/modules/tolet/views/property_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../modules/tolet/views/credit_balance_view.dart';
import '../../modules/tolet/views/kyc_verification_view.dart';
import '../../modules/tolet/views/listing_management_view.dart';
import '../../modules/tolet/views/need_based_post_view.dart';
import '../../modules/tolet/views/property_detail_view.dart';
import '../../modules/tolet/views/property_map_search_view.dart';
import '../../modules/tolet/views/property_post_view.dart';
import '../../modules/tolet/views/referral_view.dart';
import '../../modules/tolet/views/tolet_chat_view.dart';
import '../../wrapper.dart';
import '../providers/auth_providers.dart';
import '../auth/auth_gate.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/signup/signup_view.dart';
import '../../modules/auth/signup/signup_binding.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';
import '../../modules/auth/forgot_password/forgot_password_binding.dart';
import '../../modules/auth/verify_email/verify_email_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/explore/explore_view.dart';
import '../../modules/explore/explore_binding.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/mess/create_mess_view.dart';
import '../../modules/mess/join_mess_view.dart';
import '../../modules/mess/mess_binding.dart';
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
import '../../modules/notifications/notification_binding.dart';
import '../../modules/chat/views/chat_view.dart';
import '../../modules/chat/chat_binding.dart';
import '../../modules/mess/views/members_view.dart';
import '../../modules/report/views/report_view.dart';
import '../../modules/report/report_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/create_profile_view.dart';
import '../../modules/profile/create_profile_binding.dart';
import '../../modules/tolet/property_search/property_search_binding.dart';
import '../../modules/tolet/bindings/property_post_binding.dart';
import '../../modules/tolet/bindings/property_detail_binding.dart';
import '../../modules/tolet/bindings/need_based_post_binding.dart';
import '../../modules/tolet/bindings/credit_binding.dart';
import '../../modules/tolet/bindings/tolet_chat_binding.dart';
import '../../modules/tolet/bindings/listing_management_binding.dart';
/// Route path constants
class GoRoutes {
  GoRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const createProfile = '/create-profile';
  static const home = '/home';
  static const explore = '/explore';
  static const profile = '/profile';
  static const createMess = '/create-mess';
  static const joinMess = '/join-mess';
  static const mealEntry = '/meal-entry';
  static const expenses = '/expenses';
  static const addExpense = '/add-expense';
  static const balanceSummary = '/balance-summary';
  static const addDeposit = '/add-deposit';
  static const approvals = '/approvals';
  static const notifications = '/notifications';
  static const chat = '/chat';
  static const report = '/report';
  static const settings = '/settings';
  static const members = '/members';
  static const toletHome = '/tolet';
  static const propertySearch = '/tolet/search';
  static const propertyMapSearch = '/tolet/map-search';
  static const propertyDetail = '/tolet/property';
  static const propertyPost = '/tolet/post';
  static const myListings = '/tolet/my-listings';
  static const needBasedPost = '/tolet/need-based';
  static const toletChat = '/tolet/chat';
  static const creditBalance = '/tolet/credits';
  static const referral = '/tolet/referral';
  static const kycVerification = '/tolet/kyc';
}

/// Builds the GoRouter with Riverpod-powered auth redirect.
GoRouter buildGoRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final hasProfileAsync = ref.watch(hasProfileProvider);

  return GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: GoRoutes.splash,
  redirect: (context, state) {
    final location = state.matchedLocation;

    debugPrint("================================");
    debugPrint("GoRouter Redirect Called");
    debugPrint("Current Location: $location");
    debugPrint("Auth State: $authState");
    debugPrint("Profile Loading: ${hasProfileAsync.isLoading}");
    debugPrint("Profile Data: ${hasProfileAsync.asData?.value}");

    // Auth routes accessible without full authentication
    // login/signup/forgotPassword: anyone can visit
    // verifyEmail: accessible by emailNotVerified users
    final isPublicAuthRoute = location == GoRoutes.login ||
        location == GoRoutes.signup ||
        location == GoRoutes.forgotPassword;

    final isSplash = location == GoRoutes.splash;
    final isVerifyEmail = location == GoRoutes.verifyEmail;
    final isCreateProfile = location == GoRoutes.createProfile;

    debugPrint("isPublicAuthRoute: $isPublicAuthRoute");
    debugPrint("isSplash: $isSplash");
    debugPrint("isVerifyEmail: $isVerifyEmail");
    debugPrint("isCreateProfile: $isCreateProfile");

    // Splash route — check auth and route to the correct page
    if (isSplash) {
      debugPrint("Splash route -> Check auth state: $authState");

      if (authState == AuthState.unauthenticated) {
        debugPrint("Unauthenticated -> Redirect to Login");
        return GoRoutes.login;
      }

      if (authState == AuthState.emailNotVerified) {
        debugPrint("Email not verified -> Redirect to VerifyEmail");
        return GoRoutes.verifyEmail;
      }

      if (authState == AuthState.authenticated) {
        if (hasProfileAsync.isLoading) {
          debugPrint("Profile still loading -> Stay on splash");
          return null;
        }

        final hasProfile = hasProfileAsync.asData?.value;
        debugPrint("Profile check result: $hasProfile");

        if (hasProfile == true) {
          debugPrint("Has profile -> Home");
          return GoRoutes.home;
        }
        if (hasProfile == false) {
          debugPrint("No profile -> Create Profile");
          return GoRoutes.createProfile;
        }

        // Profile check returned error/null -> stay on splash
        debugPrint("Profile check error/null -> Stay on splash");
        return null;
      }

      // Unknown auth state -> stay
      debugPrint("Unknown auth state -> Stay on splash");
      return null;
    }

    final isAuthenticated = authState == AuthState.authenticated;
    debugPrint("isAuthenticated: $isAuthenticated");

    // emailNotVerified users: allow verify-email and public auth routes
    if (authState == AuthState.emailNotVerified) {
      if (isVerifyEmail || isPublicAuthRoute) {
        debugPrint("EmailNotVerified user on allowed route -> Stay");
        return null;
      }
      debugPrint("EmailNotVerified user on protected route -> Redirect to VerifyEmail");
      return GoRoutes.verifyEmail;
    }

    // If unauthenticated and trying to access a protected route
    if (!isAuthenticated && !isPublicAuthRoute) {
      debugPrint(
          "User NOT authenticated & Protected Route -> Redirect to Login");
      return GoRoutes.login;
    }

    // If authenticated and on a public auth route
    if (isAuthenticated && isPublicAuthRoute) {
      debugPrint("Authenticated user is on Auth Route");

      if (hasProfileAsync.isLoading) {
        debugPrint("Profile check loading -> Stay");
        return null;
      }

      final hasProfile = hasProfileAsync.asData?.value;
      debugPrint("hasProfile: $hasProfile");

      if (hasProfile == null) {
        debugPrint("Profile check error/null -> Stay");
        return null;
      }

      debugPrint(
          "Redirecting to: ${hasProfile ? GoRoutes.home : GoRoutes.createProfile}");

      return hasProfile
          ? GoRoutes.home
          : GoRoutes.createProfile;
    }

    // If authenticated but no profile yet
    if (isAuthenticated && !isCreateProfile) {
      final hasProfile = hasProfileAsync.asData?.value;
      debugPrint(
          "Authenticated user, checking profile completion: $hasProfile");

      if (hasProfile == false) {
        debugPrint("No profile found -> Redirect to Create Profile");
        return GoRoutes.createProfile;
      }
    }

    debugPrint("No Redirect -> Stay on current route");
    debugPrint("================================");

    return null;
  },
    routes: [
      // ── Splash / Auth Gate ──
      GoRoute(
        path: GoRoutes.splash,
        builder: (context, state) => const AuthGate(),
      ),

      // ── Auth Routes ──
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

      // ── Main App Shell (Bottom Navigation) ──
      // ShellRoute wraps the 3 tabs so the bottom nav bar persists
      // across Home, Explore, and Profile screens.
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
            path: GoRoutes.explore,
            builder: (context, state) {
              ExploreBinding().dependencies();
              return const ExploreView();
            },
          ),
          GoRoute(
            path: GoRoutes.profile,
            builder: (context, state) {
              ProfileBinding().dependencies();
              return const ProfileView();
            },
          ),
        ],
      ),

      // ── Feature Routes (pushed on top of shell) ──
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
        builder: (context, state) {
          NotificationBinding().dependencies();
          return const NotificationView();
        },
      ),
      GoRoute(
        path: GoRoutes.chat,
        builder: (context, state) {
          ChatBinding().dependencies();
          return const ChatView();
        },
      ),
      GoRoute(
        path: GoRoutes.report,
        builder: (context, state) {
          ReportBinding().dependencies();
          return const ReportView();
        },
      ),
      GoRoute(
        path: GoRoutes.settings,
        builder: (context, state) {
          SettingsBinding().dependencies();
          return const SettingsView();
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

      // ── Tolet Feature Routes ──
      GoRoute(
        path: GoRoutes.propertySearch,
        builder: (context, state) {
          PropertySearchBinding().dependencies();
          return const PropertySearchView();
        },
      ),
      GoRoute(
        path: GoRoutes.propertyMapSearch,
        builder: (context, state) {
          PropertySearchBinding().dependencies();
          return const PropertyMapSearchView();
        },
      ),
      GoRoute(
        path: GoRoutes.propertyDetail,
        builder: (context, state) {
          PropertyDetailBinding().dependencies();
          return const PropertyDetailView();
        },
      ),
      GoRoute(
        path: GoRoutes.propertyPost,
        builder: (context, state) {
          PropertyPostBinding().dependencies();
          return const PropertyPostView();
        },
      ),
      GoRoute(
        path: GoRoutes.myListings,
        builder: (context, state) {
          ListingManagementBinding().dependencies();
          return const ListingManagementView();
        },
      ),
      GoRoute(
        path: GoRoutes.needBasedPost,
        builder: (context, state) {
          NeedBasedPostBinding().dependencies();
          return const NeedBasedPostView();
        },
      ),
      GoRoute(
        path: GoRoutes.toletChat,
        builder: (context, state) {
          ToletChatBinding().dependencies();
          return const ToletChatView();
        },
      ),
      GoRoute(
        path: GoRoutes.creditBalance,
        builder: (context, state) {
          CreditBinding().dependencies();
          return const CreditBalanceView();
        },
      ),
      GoRoute(
        path: GoRoutes.referral,
        builder: (context, state) {
          CreditBinding().dependencies();
          return const ReferralView();
        },
      ),
      GoRoute(
        path: GoRoutes.kycVerification,
        builder: (context, state) {
          CreditBinding().dependencies();
          return const KycVerificationView();
        },
      ),
    ],
  );
}