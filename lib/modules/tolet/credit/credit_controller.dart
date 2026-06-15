import 'package:get/get.dart';
import '../../../services/credit_service.dart';
import '../../../services/property_service.dart';

/// Controller for credit economy (balance, transactions, unlock actions).
class CreditController extends GetxController {
  final CreditService _creditService = CreditService();
  final PropertyService _propertyService = PropertyService();

  final RxInt balance = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString error = ''.obs;

  /// Load credit balance for a user.
  void loadBalance(String userId) {
    _creditService.balanceStream(userId).listen((b) {
      balance.value = b;
    });
  }

  /// Unlock contact for a property (costs 5 credits).
  Future<bool> unlockContact(String propertyId, String userId) async {
    error.value = '';

    if (balance.value < CreditService.unlockContactCost) {
      error.value = 'Insufficient credits. Need ${CreditService.unlockContactCost} credits.';
      return false;
    }

    isProcessing.value = true;
    try {
      final alreadyUnlocked = !(await _propertyService.unlockContact(propertyId, userId));

      if (alreadyUnlocked) {
        isProcessing.value = false;
        return true; // already unlocked, no charge
      }

      final success = await _creditService.deductCredits(
        userId: userId,
        amount: CreditService.unlockContactCost,
        reason: 'unlock_contact',
        referenceId: propertyId,
      );

      isProcessing.value = false;
      if (!success) {
        error.value = 'Failed to deduct credits.';
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      isProcessing.value = false;
      return false;
    }
  }

  /// Unlock address for a property (costs 10 credits).
  Future<bool> unlockAddress(String propertyId, String userId) async {
    error.value = '';

    if (balance.value < CreditService.unlockAddressCost) {
      error.value = 'Insufficient credits. Need ${CreditService.unlockAddressCost} credits.';
      return false;
    }

    isProcessing.value = true;
    try {
      final alreadyUnlocked = !(await _propertyService.unlockAddress(propertyId, userId));

      if (alreadyUnlocked) {
        isProcessing.value = false;
        return true;
      }

      final success = await _creditService.deductCredits(
        userId: userId,
        amount: CreditService.unlockAddressCost,
        reason: 'unlock_address',
        referenceId: propertyId,
      );

      isProcessing.value = false;
      if (!success) {
        error.value = 'Failed to deduct credits.';
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      isProcessing.value = false;
      return false;
    }
  }

  /// Deduct credits for posting a property (20 credits).
  Future<bool> deductForPropertyPost(String userId, String propertyId) async {
    return _creditService.deductCredits(
      userId: userId,
      amount: CreditService.propertyPostCost,
      reason: 'property_post',
      referenceId: propertyId,
    );
  }

  /// Boost a listing (costs 50 credits).
  Future<bool> boostListing(String propertyId, String userId) async {
    error.value = '';

    if (balance.value < CreditService.boostListingCost) {
      error.value = 'Insufficient credits. Need ${CreditService.boostListingCost} credits.';
      return false;
    }

    isProcessing.value = true;
    try {
      await _propertyService.boostListing(propertyId);

      final success = await _creditService.deductCredits(
        userId: userId,
        amount: CreditService.boostListingCost,
        reason: 'boost_listing',
        referenceId: propertyId,
      );

      isProcessing.value = false;
      if (!success) {
        error.value = 'Failed to deduct credits.';
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      isProcessing.value = false;
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}