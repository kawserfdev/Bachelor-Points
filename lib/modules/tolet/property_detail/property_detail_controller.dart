import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../services/property_service.dart';

/// Controller for viewing property details, gallery, and unlocking contacts.
class PropertyDetailController extends GetxController {
  final PropertyService _propertyService = PropertyService();

  final Rx<PropertyModel?> property = Rx<PropertyModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUnlockingContact = false.obs;
  final RxBool isUnlockingAddress = false.obs;
  final RxString error = ''.obs;

  /// Load property details by ID.
  Future<void> loadProperty(String propertyId) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _propertyService.getProperty(propertyId);
      property.value = result;
    } catch (e) {
      error.value = e.toString();
    }

    isLoading.value = false;
  }

  /// Check if current user has unlocked contact.
  bool hasUnlockedContact(String userId) {
    final prop = property.value;
    if (prop == null) return false;
    return prop.contactUnlockedBy.contains(userId);
  }

  /// Check if current user has unlocked address.
  bool hasUnlockedAddress(String userId) {
    final prop = property.value;
    if (prop == null) return false;
    return prop.addressUnlockedBy.contains(userId);
  }

  /// Get masked phone (only visible after unlock).
  String getPhoneNumber(String userId) {
    if (hasUnlockedContact(userId)) {
      return property.value?.ownerPhone ?? '';
    }
    // Mask the phone
    final phone = property.value?.ownerPhone ?? '01XXXXXXXXX';
    if (phone.length <= 4) return '****';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}';
  }

  /// Get address display (full or partial based on unlock).
  String getAddressDisplay(String userId) {
    final prop = property.value;
    if (prop == null) return '';

    if (hasUnlockedAddress(userId)) {
      return '${prop.road}, ${prop.area}, ${prop.upazila}, ${prop.district}';
    }
    return '${prop.area}, ${prop.district}';
  }

  @override
  void onClose() {
    super.onClose();
  }
}