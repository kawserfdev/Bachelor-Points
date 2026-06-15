import 'package:get/get.dart';
import '../../../services/tolet_services.dart';
import '../../../data/models/verification_model.dart';

/// Controller for referral system and KYC verification.
class ReferralController extends GetxController {
  final ReferralService _referralService = ReferralService();
  final VerificationService _verificationService = VerificationService();

  // Referral
  final RxString referralCode = ''.obs;
  final RxInt pendingCommission = 0.obs;
  final RxBool isLoadingReferrals = false.obs;

  // Verification
  final RxBool isKycVerified = false.obs;
  final RxList<VerificationBadge> badges = <VerificationBadge>[].obs;
  final RxBool isLoadingVerification = false.obs;
  final RxString error = ''.obs;

  /// Load referral info for a user.
  void loadReferralInfo(String userId) {
    referralCode.value = userId;
    isLoadingReferrals.value = true;
    _referralService.getUserReferrals(userId).listen((_) {
      _loadPendingCommission(userId);
    });
  }

  Future<void> _loadPendingCommission(String userId) async {
    pendingCommission.value = await _referralService.getPendingCommission(userId);
    isLoadingReferrals.value = false;
  }

  /// Generate referral link.
  String getReferralLink(String userId) {
    return _referralService.generateReferralLink(userId);
  }

  /// Load verification status and badges.
  void loadVerificationStatus(String userId) {
    isLoadingVerification.value = true;
    _verificationService.isKycVerified(userId).then((verified) {
      isKycVerified.value = verified;
    });
    _verificationService.getUserBadges(userId).listen((b) {
      badges.value = b;
      isLoadingVerification.value = false;
    });
  }

  /// Submit KYC verification (NID).
  Future<bool> submitKycVerification({
    required String documentUrl,
    String? documentNumber,
  }) async {
    error.value = '';
    try {
      await _verificationService.submitVerification(
        type: 'user_nid',
        documentUrl: documentUrl,
        documentNumber: documentNumber,
      );
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  /// Submit property verification.
  Future<bool> submitPropertyVerification({
    required String documentUrl,
    required String documentNumber,
    required String propertyId,
    String type = 'property_utility_bill',
  }) async {
    error.value = '';
    try {
      await _verificationService.submitVerification(
        type: type,
        documentUrl: documentUrl,
        documentNumber: documentNumber,
        referencePropertyId: propertyId,
      );
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  /// Submit agency verification.
  Future<bool> submitAgencyVerification({
    required String documentUrl,
    required String documentNumber,
    String? agencyId,
  }) async {
    error.value = '';
    try {
      await _verificationService.submitVerification(
        type: 'agency_trade_license',
        documentUrl: documentUrl,
        documentNumber: documentNumber,
        referenceAgencyId: agencyId,
      );
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}