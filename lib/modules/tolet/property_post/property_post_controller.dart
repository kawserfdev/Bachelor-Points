import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/property_service.dart';
import '../../../shared/helpers/navigation_helper.dart';

/// Controller for property posting (create/edit) workflow.
class PropertyPostController extends GetxController {
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form fields
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString propertyType = 'bachelor'.obs;
  final RxDouble price = 0.0.obs;

  // Location
  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString upazila = ''.obs;
  final RxString union = ''.obs;
  final RxString area = ''.obs;
  final RxString road = ''.obs;
  final RxString mapLat = ''.obs;
  final RxString mapLng = ''.obs;

  // Details
  final RxInt bedrooms = 1.obs;
  final RxInt bathrooms = 1.obs;
  final RxInt floor = 1.obs;
  final RxDouble areaSqft = 0.0.obs;

  // Amenities
  final RxList<String> amenities = <String>[].obs;

  // Media
  final RxList<String> images = <String>[].obs;
  final RxList<String> videos = <String>[].obs;
  final RxBool has360View = false.obs;

  // Status
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxString editingPropertyId = ''.obs;

  // User properties
  final RxList<PropertyModel> userProperties = <PropertyModel>[].obs;
  final RxBool isLoadingProperties = false.obs;

  bool get isEditing => editingPropertyId.value.isNotEmpty;

  static const List<String> propertyTypes = [
    'bachelor',
    'family',
    'hostel',
    'mess',
    'office',
    'shop',
    'land',
  ];

  static const List<String> availableAmenities = [
    'WiFi',
    'Parking',
    'Generator',
    'Gas',
    'Water 24h',
    'Elevator',
    'Security',
    'CCTV',
    'Rooftop',
    'AC',
  ];

  static const List<String> divisions = [
    'Dhaka', 'Chattogram', 'Rajshahi', 'Khulna',
    'Sylhet', 'Barishal', 'Rangpur', 'Mymensingh',
  ];

  void toggleAmenity(String amenity) {
    if (amenities.contains(amenity)) {
      amenities.remove(amenity);
    } else {
      amenities.add(amenity);
    }
  }

  /// Load existing property for editing.
  void loadProperty(PropertyModel property) {
    editingPropertyId.value = property.id;
    title.value = property.title;
    description.value = property.description;
    propertyType.value = property.propertyType;
    price.value = property.price;
    division.value = property.division;
    district.value = property.district;
    upazila.value = property.upazila;
    union.value = property.union;
    area.value = property.area;
    road.value = property.road;
    mapLat.value = property.mapLat ?? '';
    mapLng.value = property.mapLng ?? '';
    bedrooms.value = property.bedrooms;
    bathrooms.value = property.bathrooms;
    floor.value = property.floor;
    areaSqft.value = property.areaSqft;
    images.value = List.from(property.images);
    videos.value = List.from(property.videos);
    has360View.value = property.has360View;
    amenities.value = List<String>.from(property.amenities);
  }

  /// Get current authenticated user info from Firestore profile.
  Future<Map<String, String>> _getCurrentUserInfo() async {
    final userId = _authService.currentUser.value?.uid ?? '';
    if (userId.isEmpty) return {'id': '', 'name': '', 'phone': ''};

    try {
      final profileDoc = await _firestore.collection('profiles').doc(userId).get();
      final data = profileDoc.data() ?? {};
      final name = data['full_name'] as String? ?? data['name'] as String? ?? '';
      final phone = data['phone'] as String? ?? data['phone_number'] as String? ?? '';
      return {'id': userId, 'name': name, 'phone': phone};
    } catch (e) {
      debugPrint('[PropertyPostController] Error fetching user info: $e');
      return {'id': userId, 'name': '', 'phone': ''};
    }
  }

  /// Validate form before saving.
  String? validate() {
    if (title.value.trim().isEmpty) return 'Please enter a title';
    if (area.value.trim().isEmpty) return 'Please enter the area';
    if (district.value.trim().isEmpty) return 'Please enter the district';
    if (price.value <= 0) return 'Please enter a valid price';
    return null;
  }

  /// Save as draft.
  Future<bool> saveDraft() async {
    final validationError = validate();
    if (validationError != null) {
      AppNavigation.showSnackBar('Validation Error', validationError);
      return false;
    }

    error.value = '';
    isSubmitting.value = true;

    try {
      final userInfo = await _getCurrentUserInfo();

      final property = PropertyModel(
        id: editingPropertyId.value,
        ownerId: userInfo['id']!,
        ownerName: userInfo['name']!,
        ownerPhone: userInfo['phone']!,
        title: title.value.trim(),
        description: description.value.trim(),
        propertyType: propertyType.value,
        price: price.value,
        division: division.value.trim(),
        district: district.value.trim(),
        upazila: upazila.value.trim(),
        union: union.value.trim(),
        area: area.value.trim(),
        road: road.value.trim(),
        mapLat: mapLat.value.isEmpty ? null : mapLat.value,
        mapLng: mapLng.value.isEmpty ? null : mapLng.value,
        bedrooms: bedrooms.value,
        bathrooms: bathrooms.value,
        floor: floor.value,
        areaSqft: areaSqft.value,
        images: List.from(images),
        videos: List.from(videos),
        has360View: has360View.value,
        amenities: List.from(amenities),
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await _propertyService.updateProperty(
            editingPropertyId.value, property.toFirestore());
      } else {
        final id = await _propertyService.createProperty(property);
        editingPropertyId.value = id;
      }

      isSubmitting.value = false;
      AppNavigation.showSnackBar('Saved', 'Property saved as draft', backgroundColor: const Color(0xFF22C55E));
      return true;
    } catch (e) {
      error.value = e.toString();
      isSubmitting.value = false;
      AppNavigation.showSnackBar('Error', 'Failed to save: $e');
      return false;
    }
  }

  /// Submit for admin review.
  Future<bool> submitForReview() async {
    if (!isEditing) {
      AppNavigation.showSnackBar('Error', 'Please save as draft first');
      return false;
    }

    error.value = '';
    isSubmitting.value = true;

    try {
      await _propertyService.submitForReview(editingPropertyId.value);
      isSubmitting.value = false;
      AppNavigation.showSnackBar('Submitted', 'Your property is under review', backgroundColor: const Color(0xFF6366F1));
      return true;
    } catch (e) {
      error.value = e.toString();
      isSubmitting.value = false;
      AppNavigation.showSnackBar('Error', 'Failed to submit: $e');
      return false;
    }
  }

  /// Load user's properties.
  void loadUserProperties() {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return;

    isLoadingProperties.value = true;
    _propertyService.getUserProperties(userId).listen((props) {
      userProperties.value = props;
      isLoadingProperties.value = false;
    });
  }

  /// Delete a draft property.
  Future<void> deleteProperty(String propertyId) async {
    await _propertyService.deleteProperty(propertyId);
  }

  /// Reset form.
  void resetForm() {
    editingPropertyId.value = '';
    title.value = '';
    description.value = '';
    propertyType.value = 'bachelor';
    price.value = 0.0;
    division.value = '';
    district.value = '';
    upazila.value = '';
    union.value = '';
    area.value = '';
    road.value = '';
    mapLat.value = '';
    mapLng.value = '';
    bedrooms.value = 1;
    bathrooms.value = 1;
    floor.value = 1;
    areaSqft.value = 0.0;
    images.value = [];
    videos.value = [];
    has360View.value = false;
    amenities.value = [];
    error.value = '';
  }

  @override
  void onClose() {
    super.onClose();
  }
}