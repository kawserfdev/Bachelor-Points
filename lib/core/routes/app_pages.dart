import 'package:get/get.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/signup/signup_binding.dart';
import '../../modules/auth/signup/signup_view.dart';
import '../../modules/auth/forgot_password/forgot_password_binding.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/mess/create_mess_view.dart';
import '../../modules/mess/join_mess_view.dart';
import '../../modules/meal/meal_entry_view.dart';
import '../../modules/meal/meal_binding.dart';
import '../../modules/expense/views/expense_list_view.dart';
import '../../modules/expense/views/add_expense_view.dart';
import '../../modules/expense/expense_binding.dart';
import '../../modules/balance/views/balance_summary_view.dart';
import '../../modules/balance/views/add_deposit_view.dart';
import '../../modules/balance/balance_binding.dart';
import '../../modules/requests/request_binding.dart';
import '../../modules/requests/views/approval_view.dart';
import '../../modules/notifications/notification_binding.dart';
import '../../modules/notifications/views/notification_view.dart';
import '../../modules/chat/chat_binding.dart';
import '../../modules/chat/views/chat_view.dart';
import '../../modules/report/report_binding.dart';
import '../../modules/report/views/report_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/auth/verify_email/verify_email_view.dart';
import '../../modules/profile/create_profile_view.dart';
import '../../modules/profile/create_profile_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.createMess,
      page: () => const CreateMessView(),
    ),
    GetPage(
      name: AppRoutes.joinMess,
      page: () => const JoinMessView(),
    ),
    GetPage(
      name: AppRoutes.mealEntry,
      page: () => const MealEntryView(),
      binding: MealBinding(),
    ),
    GetPage(
      name: AppRoutes.expenses,
      page: () => const ExpenseListView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddExpenseView(),
    ),
    GetPage(
      name: AppRoutes.balanceSummary,
      page: () => const BalanceSummaryView(),
      binding: BalanceBinding(),
    ),
    GetPage(
      name: AppRoutes.addDeposit,
      page: () => const AddDepositView(),
    ),

    GetPage(
      name: AppRoutes.approvals,
      page: () => const ApprovalView(),
      binding: RequestBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
    ),
    GetPage(
      name: AppRoutes.createProfile,
      page: () => const CreateProfileView(),
      binding: CreateProfileBinding(),
    ),
  ];
}
