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
  ];
}
