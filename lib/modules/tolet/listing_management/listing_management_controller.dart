import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/property_service.dart';

/// Controller for managing user's property listings (list, status management).
class ListingManagementController extends GetxController {
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<PropertyModel> activeListings = <PropertyModel>[].obs;
  final RxList<PropertyModel> pendingListings = <PropertyModel>[].obs;
  final RxList<PropertyModel> rejectedListings = <PropertyModel>[].obs;
  final RxList<PropertyModel> expiredListings = <PropertyModel>[].obs;
  final RxList<PropertyModel> archivedListings = <PropertyModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final userId = _authService.currentUser.value?.uid;
    if (userId != null && userId.isNotEmpty) {
      loadListings(userId);
    }
  }

  /// Load all user listings and categorize by status.
  void loadListings(String userId) {
    isLoading.value = true;
    _propertyService.getUserProperties(userId).listen((properties) {
      activeListings.value =
          properties.where((p) => p.status == 'live' || p.status == 'approved').toList();
      pendingListings.value = properties
          .where((p) => p.status == 'draft' || p.status == 'submitted' || p.status == 'under_review')
          .toList();
      rejectedListings.value = properties.where((p) => p.status == 'rejected').toList();
      expiredListings.value = properties.where((p) => p.status == 'expired').toList();
      archivedListings.value = properties.where((p) => p.status == 'archived').toList();
      isLoading.value = false;
    });
  }

  /// Archive a listing.
  Future<void> archiveListing(String propertyId) async {
    await _propertyService.archiveProperty(propertyId);
  }

  /// Delete a draft listing.
  Future<void> deleteListing(String propertyId) async {
    await _propertyService.deleteProperty(propertyId);
  }

  /// Boost a listing (requires CreditController to check/deduct credits).
  Future<void> boostListing(String propertyId) async {
    await _propertyService.boostListing(propertyId);
  }

  @override
  void onClose() {
    super.onClose();
  }
}