import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/credit_service.dart';
import '../../../services/tolet_services.dart';
import '../../../data/models/verification_model.dart';

/// Controller for the profile tab — loads profile data, KYC status,
/// credit balance, and referral info from Firestore.
class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CreditService _creditService = CreditService();
  final VerificationService _verificationService = VerificationService();
  final ReferralService _referralService = ReferralService();

  // ── Profile fields ──
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString address = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxString nidNumber = ''.obs;

  // ── Completion ──
  final RxDouble completionPercent = 0.0.obs;
  final RxBool isLoading = true.obs;

  // ── Badges ──
  final RxList<VerificationBadge> badges = <VerificationBadge>[].obs;

  // ── Credits ──
  final RxInt creditBalance = 0.obs;

  // ── Referral ──
  final RxString referralCode = ''.obs;
  final RxInt pendingCommission = 0.obs;

  String get userId => _authService.currentUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      loadProfile(userId);
    }
  }

  /// Load everything from Firestore.
  void loadProfile(String uid) {
    isLoading.value = true;

    // Auth user basics
    final user = _authService.currentUser.value;
    email.value = user?.email ?? '';
    referralCode.value = uid;

    // Firestore profile document
    _firestore.collection('profiles').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        fullName.value = data['full_name'] as String? ?? '';
        phoneNumber.value = data['phone_number'] as String? ?? '';
        address.value = data['address'] as String? ?? '';
        avatarUrl.value = data['avatar_url'] as String? ?? '';
        nidNumber.value = data['nid_number'] as String? ?? '';
      }
      _computeCompletion();
    });

    // Credit balance
    _creditService.balanceStream(uid).listen((b) {
      creditBalance.value = b;
    });



    // Badges
    _verificationService.getUserBadges(uid).listen((b) {
      badges.value = b;
    });

    // Referral commission
    _referralService.getPendingCommission(uid).then((commission) {
      pendingCommission.value = commission;
    });

    isLoading.value = false;
  }

  /// Compute profile completion percentage.
  void _computeCompletion() {
    int filled = 0;
    const total = 5; // name, phone, address, avatar, nid
    if (fullName.value.isNotEmpty) filled++;
    if (phoneNumber.value.isNotEmpty) filled++;
    if (address.value.isNotEmpty) filled++;
    if (avatarUrl.value.isNotEmpty) filled++;
    if (nidNumber.value.isNotEmpty) filled++;
    completionPercent.value = filled / total;
  }

  /// Get referral share link.
  String getReferralLink() {
    return _referralService.generateReferralLink(userId);
  }

  @override
  void onClose() {
    super.onClose();
  }
}