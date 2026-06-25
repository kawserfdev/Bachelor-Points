import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @mealCutoffTime.
  ///
  /// In en, this message translates to:
  /// **'Meal Cutoff Time'**
  String get mealCutoffTime;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeOptions.
  ///
  /// In en, this message translates to:
  /// **'Theme Options'**
  String get themeOptions;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean interface with high readability'**
  String get lightDesc;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @darkDesc.
  ///
  /// In en, this message translates to:
  /// **'Comfortable for low-light environments'**
  String get darkDesc;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @systemDesc.
  ///
  /// In en, this message translates to:
  /// **'Match system settings automatically'**
  String get systemDesc;

  /// No description provided for @languagePreferences.
  ///
  /// In en, this message translates to:
  /// **'Language Preferences'**
  String get languagePreferences;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @mealNotifications.
  ///
  /// In en, this message translates to:
  /// **'Meal Notifications'**
  String get mealNotifications;

  /// No description provided for @mealNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when meals are added or changed'**
  String get mealNotificationsDesc;

  /// No description provided for @expenseNotifications.
  ///
  /// In en, this message translates to:
  /// **'Expense Notifications'**
  String get expenseNotifications;

  /// No description provided for @expenseNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new expense is logged'**
  String get expenseNotificationsDesc;

  /// No description provided for @depositNotifications.
  ///
  /// In en, this message translates to:
  /// **'Deposit Notifications'**
  String get depositNotifications;

  /// No description provided for @depositNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when deposits are recorded or approved'**
  String get depositNotificationsDesc;

  /// No description provided for @shoppingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Shopping Notifications'**
  String get shoppingNotifications;

  /// No description provided for @shoppingNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive shopping duty reminders'**
  String get shoppingNotificationsDesc;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications to this device'**
  String get pushNotificationsDesc;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @bazarSchedule.
  ///
  /// In en, this message translates to:
  /// **'Bazar Schedule'**
  String get bazarSchedule;

  /// No description provided for @assignNewDuty.
  ///
  /// In en, this message translates to:
  /// **'Assign New Duty'**
  String get assignNewDuty;

  /// No description provided for @messMembership.
  ///
  /// In en, this message translates to:
  /// **'Mess Membership'**
  String get messMembership;

  /// No description provided for @exitMessInfo.
  ///
  /// In en, this message translates to:
  /// **'If you want to leave this mess, you can submit an exit request. The manager or admin will need to approve your request before you are removed.'**
  String get exitMessInfo;

  /// No description provided for @requestToExitMess.
  ///
  /// In en, this message translates to:
  /// **'Request to Exit Mess'**
  String get requestToExitMess;

  /// No description provided for @defaultMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Default Meal Plan'**
  String get defaultMealPlan;

  /// No description provided for @regularDailyPortions.
  ///
  /// In en, this message translates to:
  /// **'Your current regular daily portions:'**
  String get regularDailyPortions;

  /// No description provided for @requestMealPlanChange.
  ///
  /// In en, this message translates to:
  /// **'Request Meal Plan Change'**
  String get requestMealPlanChange;

  /// No description provided for @changeRequestPending.
  ///
  /// In en, this message translates to:
  /// **'Change Request Pending Manager Approval'**
  String get changeRequestPending;

  /// No description provided for @heyGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hey {greeting}! 👋'**
  String heyGreeting(String greeting);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @manageMessEfficiently.
  ///
  /// In en, this message translates to:
  /// **'Manage your bachelor mess efficiently'**
  String get manageMessEfficiently;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @bazar.
  ///
  /// In en, this message translates to:
  /// **'Bazar'**
  String get bazar;

  /// No description provided for @totalMeals.
  ///
  /// In en, this message translates to:
  /// **'Total Meals'**
  String get totalMeals;

  /// No description provided for @mealRate.
  ///
  /// In en, this message translates to:
  /// **'Meal Rate'**
  String get mealRate;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @addDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add Deposit'**
  String get addDeposit;

  /// No description provided for @balances.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get balances;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @postProperty.
  ///
  /// In en, this message translates to:
  /// **'Post Property'**
  String get postProperty;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @needBased.
  ///
  /// In en, this message translates to:
  /// **'Need Based'**
  String get needBased;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @referral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referral;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMoreFeatures.
  ///
  /// In en, this message translates to:
  /// **'Show More Features'**
  String get showMoreFeatures;

  /// No description provided for @notInMess.
  ///
  /// In en, this message translates to:
  /// **'You are not in a Mess'**
  String get notInMess;

  /// No description provided for @notInMessDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a new mess or join an existing one\nusing an invite code.'**
  String get notInMessDesc;

  /// No description provided for @createMess.
  ///
  /// In en, this message translates to:
  /// **'Create Mess'**
  String get createMess;

  /// No description provided for @joinMess.
  ///
  /// In en, this message translates to:
  /// **'Join Mess'**
  String get joinMess;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginBtn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started!'**
  String get signUpToGetStarted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @emailAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email is already verified.'**
  String get emailAlreadyVerified;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailTitle;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @verificationLinkSentDesc.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification link to your email address. Please check your inbox and click the link to verify your account.'**
  String get verificationLinkSentDesc;

  /// No description provided for @afterVerifyingDesc.
  ///
  /// In en, this message translates to:
  /// **'After verifying, click the button below to check your status.'**
  String get afterVerifyingDesc;

  /// No description provided for @iveVerifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iveVerifiedEmail;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Please check your email.'**
  String get resetLinkSent;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get forgotPasswordDesc;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'SEND RESET LINK'**
  String get sendResetLink;

  /// No description provided for @addDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Deposit'**
  String get addDepositTitle;

  /// No description provided for @depositAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount (৳)'**
  String get depositAmountLabel;

  /// No description provided for @depositAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5000'**
  String get depositAmountHint;

  /// No description provided for @enterAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get enterAmountError;

  /// No description provided for @enterValidNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumberError;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodLabel;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodBkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get paymentMethodBkash;

  /// No description provided for @paymentMethodNagad.
  ///
  /// In en, this message translates to:
  /// **'Nagad'**
  String get paymentMethodNagad;

  /// No description provided for @paymentMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentMethodBank;

  /// No description provided for @submitForApprovalBtn.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT FOR APPROVAL'**
  String get submitForApprovalBtn;

  /// No description provided for @messBalancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Mess Balances'**
  String get messBalancesTitle;

  /// No description provided for @noMembersOrError.
  ///
  /// In en, this message translates to:
  /// **'No members found or error calculating balances.'**
  String get noMembersOrError;

  /// No description provided for @totalMessMeals.
  ///
  /// In en, this message translates to:
  /// **'Total Mess Meals'**
  String get totalMessMeals;

  /// No description provided for @totalBazar.
  ///
  /// In en, this message translates to:
  /// **'Total Bazar'**
  String get totalBazar;

  /// No description provided for @totalFixedCosts.
  ///
  /// In en, this message translates to:
  /// **'Total Fixed Costs'**
  String get totalFixedCosts;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @mealCost.
  ///
  /// In en, this message translates to:
  /// **'Meal Cost'**
  String get mealCost;

  /// No description provided for @fixedCost.
  ///
  /// In en, this message translates to:
  /// **'Fixed Cost'**
  String get fixedCost;

  /// No description provided for @getsLabel.
  ///
  /// In en, this message translates to:
  /// **'Gets: ৳{amount}'**
  String getsLabel(String amount);

  /// No description provided for @owesLabel.
  ///
  /// In en, this message translates to:
  /// **'Owes: ৳{amount}'**
  String owesLabel(String amount);

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseTitle;

  /// No description provided for @expenseTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense Title'**
  String get expenseTitleLabel;

  /// No description provided for @expenseTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekly Bazar'**
  String get expenseTitleHint;

  /// No description provided for @enterTitleError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitleError;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryBazar.
  ///
  /// In en, this message translates to:
  /// **'Bazar'**
  String get categoryBazar;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get categoryWifi;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (৳)'**
  String get amountLabel;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500'**
  String get amountHint;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteOptionalLabel;

  /// No description provided for @noteOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken and Rice'**
  String get noteOptionalHint;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found for this month.'**
  String get noExpensesFound;

  /// No description provided for @addedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String addedByLabel(String name);

  /// No description provided for @unknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownMember;

  /// No description provided for @totalMonthlyExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Expense'**
  String get totalMonthlyExpense;

  /// No description provided for @yourEstimatedShare.
  ///
  /// In en, this message translates to:
  /// **'Your Estimated Share'**
  String get yourEstimatedShare;

  /// No description provided for @mealEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Entry'**
  String get mealEntryTitle;

  /// No description provided for @editingLockedCutoff.
  ///
  /// In en, this message translates to:
  /// **'Editing locked. The cutoff time has passed for this date.'**
  String get editingLockedCutoff;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @guestMeals.
  ///
  /// In en, this message translates to:
  /// **'Guest Meals'**
  String get guestMeals;

  /// No description provided for @guestMealsDesc.
  ///
  /// In en, this message translates to:
  /// **'Extra meals for guests (adds to your total)'**
  String get guestMealsDesc;

  /// No description provided for @saveMealsBtn.
  ///
  /// In en, this message translates to:
  /// **'SAVE MEALS'**
  String get saveMealsBtn;

  /// No description provided for @mealPlanBulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan & Bulk Actions'**
  String get mealPlanBulkTitle;

  /// No description provided for @mealPlanBulkDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your regular meal portions for a long duration, or close specific meals for one or more days.'**
  String get mealPlanBulkDesc;

  /// No description provided for @setPlanBtn.
  ///
  /// In en, this message translates to:
  /// **'Set Plan'**
  String get setPlanBtn;

  /// No description provided for @closeMealsBtn.
  ///
  /// In en, this message translates to:
  /// **'Close Meals'**
  String get closeMealsBtn;

  /// No description provided for @setRegularMealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Regular Meal Plan'**
  String get setRegularMealPlanTitle;

  /// No description provided for @setRegularMealPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Define your default daily portions and apply them for a set duration.'**
  String get setRegularMealPlanDesc;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @applyMealPlanBtn.
  ///
  /// In en, this message translates to:
  /// **'APPLY MEAL PLAN'**
  String get applyMealPlanBtn;

  /// No description provided for @closeMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Close Meals'**
  String get closeMealsTitle;

  /// No description provided for @closeMealsDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn off specific meals for a single day or a range of dates.'**
  String get closeMealsDesc;

  /// No description provided for @selectMealsToClose.
  ///
  /// In en, this message translates to:
  /// **'Select Meals to Close'**
  String get selectMealsToClose;

  /// No description provided for @allMeals.
  ///
  /// In en, this message translates to:
  /// **'All Meals'**
  String get allMeals;

  /// No description provided for @closeMealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close Breakfast, Lunch, and Dinner'**
  String get closeMealsSubtitle;

  /// No description provided for @closeSelectedMealsBtn.
  ///
  /// In en, this message translates to:
  /// **'CLOSE SELECTED MEALS'**
  String get closeSelectedMealsBtn;

  /// No description provided for @totalMealsSelected.
  ///
  /// In en, this message translates to:
  /// **'Total Meals Selected'**
  String get totalMealsSelected;

  /// No description provided for @dayCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get dayCountOne;

  /// No description provided for @dayCountThree.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get dayCountThree;

  /// No description provided for @dayCountSeven.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get dayCountSeven;

  /// No description provided for @dayCountThirty.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get dayCountThirty;

  /// No description provided for @monthCountThree.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get monthCountThree;

  /// No description provided for @monthCountSix.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get monthCountSix;

  /// No description provided for @yearCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get yearCountOne;

  /// No description provided for @createMessTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Mess'**
  String get createMessTitle;

  /// No description provided for @startNewMess.
  ///
  /// In en, this message translates to:
  /// **'Start a new Mess'**
  String get startNewMess;

  /// No description provided for @createMessAdminDesc.
  ///
  /// In en, this message translates to:
  /// **'You will become the Admin and can invite others.'**
  String get createMessAdminDesc;

  /// No description provided for @messNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mess Name'**
  String get messNameLabel;

  /// No description provided for @messNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Bachelor Point'**
  String get messNameHint;

  /// No description provided for @createMessBtn.
  ///
  /// In en, this message translates to:
  /// **'CREATE MESS'**
  String get createMessBtn;

  /// No description provided for @enterMessNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a mess name'**
  String get enterMessNameError;

  /// No description provided for @joinMessTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Mess'**
  String get joinMessTitle;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Invite Code'**
  String get enterInviteCode;

  /// No description provided for @askAdminCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask your Mess Admin for the 6-character code.'**
  String get askAdminCodeDesc;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCodeLabel;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., A1B2C3'**
  String get inviteCodeHint;

  /// No description provided for @joinMessBtn.
  ///
  /// In en, this message translates to:
  /// **'JOIN MESS'**
  String get joinMessBtn;

  /// No description provided for @enterValidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-character code'**
  String get enterValidCodeError;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTitle;

  /// No description provided for @approvalsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvalsTooltip;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersYet;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleManagers.
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get roleManagers;

  /// No description provided for @roleMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get roleMembers;

  /// No description provided for @joinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedLabel(String date);

  /// No description provided for @changeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRoleTitle;

  /// No description provided for @changeRoleForLabel.
  ///
  /// In en, this message translates to:
  /// **'Change role for {name}'**
  String changeRoleForLabel(String name);

  /// No description provided for @currentRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Current role: {role}'**
  String currentRoleLabel(String role);

  /// No description provided for @newRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'New Role'**
  String get newRoleLabel;

  /// No description provided for @roleChangeRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'This will create a role change request for approval.'**
  String get roleChangeRequestDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name}?\n\nThis will create a removal request for approval.'**
  String removeMemberConfirm(String name);

  /// No description provided for @removeMemberConfirmSimple.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member from the mess?'**
  String get removeMemberConfirmSimple;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdmin;

  /// No description provided for @makeManager.
  ///
  /// In en, this message translates to:
  /// **'Make Manager'**
  String get makeManager;

  /// No description provided for @makeMember.
  ///
  /// In en, this message translates to:
  /// **'Make Member'**
  String get makeMember;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get youLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllAsReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsReadTooltip;

  /// No description provided for @allMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allMarkedAsRead;

  /// No description provided for @notifDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification removed'**
  String get notifDeleted;

  /// No description provided for @notifFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifFilterAll;

  /// No description provided for @notifFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifFilterUnread;

  /// No description provided for @notifFilterRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notifFilterRead;

  /// No description provided for @noNotificationsFound.
  ///
  /// In en, this message translates to:
  /// **'No notifications found'**
  String get noNotificationsFound;

  /// No description provided for @notifActionGoToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to Page'**
  String get notifActionGoToPage;

  /// No description provided for @notifActionViewMeals.
  ///
  /// In en, this message translates to:
  /// **'View Meals'**
  String get notifActionViewMeals;

  /// No description provided for @notifActionViewRequest.
  ///
  /// In en, this message translates to:
  /// **'View Request'**
  String get notifActionViewRequest;

  /// No description provided for @notifActionGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get notifActionGoToSettings;

  /// No description provided for @notifCloseBtn.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get notifCloseBtn;

  /// No description provided for @notifErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications: {error}'**
  String notifErrorLoading(String error);

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfileTitle;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @completeProfileToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to continue.'**
  String get completeProfileToContinue;

  /// No description provided for @phoneNumberOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneNumberOptionalLabel;

  /// No description provided for @saveContinueBtn.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveContinueBtn;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @updateYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Your Profile'**
  String get updateYourProfile;

  /// No description provided for @keepInfoUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Keep your personal information up to date.'**
  String get keepInfoUpToDate;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @nidNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'NID Number'**
  String get nidNumberLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @saveChangesBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesBtn;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileSectionApp;

  /// No description provided for @myProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'My Profile Details'**
  String get myProfileDetails;

  /// No description provided for @profileCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion'**
  String get profileCompletionLabel;

  /// No description provided for @profileComplete.
  ///
  /// In en, this message translates to:
  /// **'Your profile is fully complete!'**
  String get profileComplete;

  /// No description provided for @profileAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost there — add your NID to finish!'**
  String get profileAlmostDone;

  /// No description provided for @profileAddAddressNid.
  ///
  /// In en, this message translates to:
  /// **'Add your address and NID for full completion.'**
  String get profileAddAddressNid;

  /// No description provided for @profileAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number and address.'**
  String get profileAddPhone;

  /// No description provided for @profileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to unlock all features.'**
  String get profileIncomplete;

  /// No description provided for @profileComplete2.
  ///
  /// In en, this message translates to:
  /// **'Your profile is fully complete 🎉'**
  String get profileComplete2;

  /// No description provided for @profileAlmostDone2.
  ///
  /// In en, this message translates to:
  /// **'Almost done — just a few more details.'**
  String get profileAlmostDone2;

  /// No description provided for @profileGoodStart.
  ///
  /// In en, this message translates to:
  /// **'Good start! Add your address & NID.'**
  String get profileGoodStart;

  /// No description provided for @profileAddPhoneAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your phone, address, and NID.'**
  String get profileAddPhoneAddress;

  /// No description provided for @badgeVerifiedUser.
  ///
  /// In en, this message translates to:
  /// **'Verified User'**
  String get badgeVerifiedUser;

  /// No description provided for @badgeVerifiedProperty.
  ///
  /// In en, this message translates to:
  /// **'Verified Property'**
  String get badgeVerifiedProperty;

  /// No description provided for @badgeVerifiedAgency.
  ///
  /// In en, this message translates to:
  /// **'Verified Agency'**
  String get badgeVerifiedAgency;

  /// No description provided for @logoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutBtn;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? All local data will be removed from this device.'**
  String get logoutConfirm;

  /// No description provided for @profileDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile Details'**
  String get profileDetailTitle;

  /// No description provided for @editProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTooltip;

  /// No description provided for @sectionPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get sectionPersonalInfo;

  /// No description provided for @sectionVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get sectionVerification;

  /// No description provided for @sectionAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get sectionAccountInfo;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fieldFullName;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get fieldBio;

  /// No description provided for @fieldNidNumber.
  ///
  /// In en, this message translates to:
  /// **'NID Number'**
  String get fieldNidNumber;

  /// No description provided for @fieldUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get fieldUserId;

  /// No description provided for @fieldMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get fieldMemberSince;

  /// No description provided for @fieldLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get fieldLastUpdated;

  /// No description provided for @fieldNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get fieldNotSet;

  /// No description provided for @fieldNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get fieldNotProvided;

  /// No description provided for @copiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedTitle;

  /// No description provided for @userIdCopied.
  ///
  /// In en, this message translates to:
  /// **'User ID copied to clipboard'**
  String get userIdCopied;

  /// No description provided for @editProfileBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileBtn;

  /// No description provided for @completeProfileBtn.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfileBtn;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retryBtn.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryBtn;

  /// No description provided for @cameraNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Camera/gallery not implemented yet.'**
  String get cameraNotImplemented;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get reportTitle;

  /// No description provided for @downloadPdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdfTooltip;

  /// No description provided for @printPdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdfTooltip;

  /// No description provided for @noDataForMonth.
  ///
  /// In en, this message translates to:
  /// **'No data found for selected month'**
  String get noDataForMonth;

  /// No description provided for @noDataForMember.
  ///
  /// In en, this message translates to:
  /// **'No data found for selected member'**
  String get noDataForMember;

  /// No description provided for @reportTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get reportTabOverview;

  /// No description provided for @reportTabMemberReport.
  ///
  /// In en, this message translates to:
  /// **'Member Report'**
  String get reportTabMemberReport;

  /// No description provided for @reportTabMyReport.
  ///
  /// In en, this message translates to:
  /// **'My Report'**
  String get reportTabMyReport;

  /// No description provided for @reportTotalMeals.
  ///
  /// In en, this message translates to:
  /// **'Total Meals'**
  String get reportTotalMeals;

  /// No description provided for @reportTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get reportTotalExpenses;

  /// No description provided for @reportMealRate.
  ///
  /// In en, this message translates to:
  /// **'Meal Rate'**
  String get reportMealRate;

  /// No description provided for @reportColMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get reportColMember;

  /// No description provided for @reportColMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get reportColMeals;

  /// No description provided for @reportColCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get reportColCost;

  /// No description provided for @reportColDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get reportColDeposits;

  /// No description provided for @reportColBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get reportColBalance;

  /// No description provided for @reportSelectMember.
  ///
  /// In en, this message translates to:
  /// **'Select Member'**
  String get reportSelectMember;

  /// No description provided for @reportMonthlySummary.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Monthly Summary'**
  String reportMonthlySummary(String name);

  /// No description provided for @reportMealCost.
  ///
  /// In en, this message translates to:
  /// **'Meal Cost'**
  String get reportMealCost;

  /// No description provided for @reportTotalDeposits.
  ///
  /// In en, this message translates to:
  /// **'Total Deposits'**
  String get reportTotalDeposits;

  /// No description provided for @reportFinalBalance.
  ///
  /// In en, this message translates to:
  /// **'Final Balance'**
  String get reportFinalBalance;

  /// No description provided for @reportDailyActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity Log'**
  String get reportDailyActivityLog;

  /// No description provided for @reportNoActivityThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded this month.'**
  String get reportNoActivityThisMonth;

  /// No description provided for @reportChipBreakfast.
  ///
  /// In en, this message translates to:
  /// **'B: {val}'**
  String reportChipBreakfast(String val);

  /// No description provided for @reportChipLunch.
  ///
  /// In en, this message translates to:
  /// **'L: {val}'**
  String reportChipLunch(String val);

  /// No description provided for @reportChipDinner.
  ///
  /// In en, this message translates to:
  /// **'D: {val}'**
  String reportChipDinner(String val);

  /// No description provided for @reportChipGuest.
  ///
  /// In en, this message translates to:
  /// **'G: {val}'**
  String reportChipGuest(String val);

  /// No description provided for @reportChipDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit: ৳{val}'**
  String reportChipDeposit(String val);

  /// No description provided for @reportChipExpense.
  ///
  /// In en, this message translates to:
  /// **'{category}: ৳{amount}'**
  String reportChipExpense(String category, String amount);

  /// No description provided for @reportMiniMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get reportMiniMeals;

  /// No description provided for @reportMiniExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get reportMiniExpense;

  /// No description provided for @reportMiniDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get reportMiniDeposit;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get requestFilterAll;

  /// No description provided for @requestFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestFilterPending;

  /// No description provided for @requestFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get requestFilterApproved;

  /// No description provided for @requestFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get requestFilterRejected;

  /// No description provided for @requestFilterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get requestFilterExpense;

  /// No description provided for @requestFilterDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get requestFilterDeposit;

  /// No description provided for @requestFilterJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get requestFilterJoin;

  /// No description provided for @requestFilterRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get requestFilterRemove;

  /// No description provided for @requestFilterRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get requestFilterRoleLabel;

  /// No description provided for @requestStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestStatusPending;

  /// No description provided for @requestStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get requestStatusApproved;

  /// No description provided for @requestStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get requestStatusRejected;

  /// No description provided for @requestNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No {filter} requests'**
  String requestNoRequests(String filter);

  /// No description provided for @requestTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get requestTypeExpense;

  /// No description provided for @requestTypeDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get requestTypeDeposit;

  /// No description provided for @requestTypeJoinMess.
  ///
  /// In en, this message translates to:
  /// **'Join Mess'**
  String get requestTypeJoinMess;

  /// No description provided for @requestTypeRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get requestTypeRemoveMember;

  /// No description provided for @requestTypeRoleChange.
  ///
  /// In en, this message translates to:
  /// **'Role Change'**
  String get requestTypeRoleChange;

  /// No description provided for @requestCategory.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String requestCategory(String category);

  /// No description provided for @requestPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment: {method}'**
  String requestPayment(String method);

  /// No description provided for @requestNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String requestNote(String note);

  /// No description provided for @requestRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by {name}'**
  String requestRequestedBy(String name);

  /// No description provided for @requestBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String requestBy(String name);

  /// No description provided for @requestUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get requestUnknown;

  /// No description provided for @requestEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get requestEdit;

  /// No description provided for @requestReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get requestReject;

  /// No description provided for @requestApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get requestApprove;

  /// No description provided for @requestCurrentRole.
  ///
  /// In en, this message translates to:
  /// **'Current Role: {role}'**
  String requestCurrentRole(String role);

  /// No description provided for @requestReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String requestReason(String reason);

  /// No description provided for @requestApprovedOn.
  ///
  /// In en, this message translates to:
  /// **'Approved on {date}'**
  String requestApprovedOn(String date);

  /// No description provided for @requestRejectedOn.
  ///
  /// In en, this message translates to:
  /// **'Rejected on {date}'**
  String requestRejectedOn(String date);

  /// No description provided for @requestUpdatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated on {date}'**
  String requestUpdatedOn(String date);

  /// No description provided for @requestConfirmApproval.
  ///
  /// In en, this message translates to:
  /// **'Confirm Approval'**
  String get requestConfirmApproval;

  /// No description provided for @requestConfirmRejection.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rejection'**
  String get requestConfirmRejection;

  /// No description provided for @requestApproveExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this expense request for ৳{amount}?\n\nThis will deduct from the balance.'**
  String requestApproveExpenseBody(String amount);

  /// No description provided for @requestApproveDepositBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this deposit request for ৳{amount}?\n\nThis will add to the balance.'**
  String requestApproveDepositBody(String amount);

  /// No description provided for @requestApproveJoinBody.
  ///
  /// In en, this message translates to:
  /// **'Approve join request for {name}?\n\nThey will be added as a Member.'**
  String requestApproveJoinBody(String name);

  /// No description provided for @requestApproveRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Approve removal of {name}?\n\nThey will be removed from the mess.'**
  String requestApproveRemoveBody(String name);

  /// No description provided for @requestApproveRoleBody.
  ///
  /// In en, this message translates to:
  /// **'Approve role change for {name} from {oldRole} to {newRole}?'**
  String requestApproveRoleBody(String name, String oldRole, String newRole);

  /// No description provided for @requestRejectBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject {label} request?\n\nThis will not affect any data.'**
  String requestRejectBody(String label);

  /// No description provided for @requestEditExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense Request'**
  String get requestEditExpenseTitle;

  /// No description provided for @requestEditDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Deposit Request'**
  String get requestEditDepositTitle;

  /// No description provided for @requestFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get requestFieldTitle;

  /// No description provided for @requestFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get requestFieldCategory;

  /// No description provided for @requestFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (৳)'**
  String get requestFieldAmount;

  /// No description provided for @requestFieldPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get requestFieldPaymentMethod;

  /// No description provided for @requestFieldNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get requestFieldNoteOptional;

  /// No description provided for @requestValidationTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title required'**
  String get requestValidationTitleRequired;

  /// No description provided for @requestValidationAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount required'**
  String get requestValidationAmountRequired;

  /// No description provided for @requestValidationAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get requestValidationAmountPositive;

  /// No description provided for @requestUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get requestUpdate;

  /// No description provided for @requestStatusBadge.
  ///
  /// In en, this message translates to:
  /// **'{label}: {count}'**
  String requestStatusBadge(String label, int count);

  /// No description provided for @requestCategoryBazar.
  ///
  /// In en, this message translates to:
  /// **'Bazar'**
  String get requestCategoryBazar;

  /// No description provided for @requestCategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get requestCategoryRent;

  /// No description provided for @requestCategoryWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get requestCategoryWifi;

  /// No description provided for @requestCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get requestCategoryOther;

  /// No description provided for @requestPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get requestPaymentCash;

  /// No description provided for @requestPaymentBkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get requestPaymentBkash;

  /// No description provided for @requestPaymentNagad.
  ///
  /// In en, this message translates to:
  /// **'Nagad'**
  String get requestPaymentNagad;

  /// No description provided for @requestPaymentBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get requestPaymentBank;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
