// ─────────────────────────────────────────────────────────────────────────────
// AppRoutes — mirrors GoRoutes for use inside widget/controller files.
// Always navigate via these constants, never hardcode path strings.
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppRoutes {
  // ── Auth ──
  static const login          = '/login';
  static const signup         = '/signup';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail    = '/verify-email';
  static const createProfile  = '/create-profile';

  // ── Main Shell (bottom nav tabs) ──
  static const home    = '/home';
  static const explore = '/explore';
  static const profile = '/profile';

  // ── Profile sub-pages ──
  static const profileDetail = '/profile/detail';
  static const editProfile   = '/profile/edit';

  // ── Mess Management ──
  static const createMess = '/create-mess';
  static const joinMess   = '/join-mess';
  static const members    = '/members';

  // ── Core Features ──
  static const mealEntry      = '/meal-entry';
  static const expenses       = '/expenses';
  static const addExpense     = '/add-expense';
  static const balanceSummary = '/balance-summary';
  static const addDeposit     = '/add-deposit';
  static const approvals      = '/approvals';
  static const notifications  = '/notifications';
  static const chat           = '/chat';
  static const report         = '/report';
  static const settings       = '/settings';

  // ── Tolet Feature ──
  static const toletHome         = '/tolet';
  static const propertySearch    = '/tolet/search';
  static const propertyMapSearch = '/tolet/map-search';
  static const propertyDetail    = '/tolet/property';
  static const propertyPost      = '/tolet/post';
  static const myListings        = '/tolet/my-listings';
  static const needBasedPost     = '/tolet/need-based';
  static const toletChat         = '/tolet/chat';
  static const creditBalance     = '/tolet/credits';
  static const referral          = '/tolet/referral';
}
