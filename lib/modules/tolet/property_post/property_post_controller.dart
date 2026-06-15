import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../services/property_service.dart';

/// Controller for property posting (create/edit) workflow.
class PropertyPostController extends GetxController {
  final PropertyService _propertyService = PropertyService();

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
  }

  /// Save as draft.
  Future<bool> saveDraft(String userId, String userName, String userPhone) async {
    error.value = '';
    isSubmitting.value = true;

    try {
      final property = PropertyModel(
        id: editingPropertyId.value,
        ownerId: userId,
        ownerName: userName,
        ownerPhone: userPhone,
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
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await _propertyService.updateProperty(
            editingPropertyId.value, property.toFirestore());
      } else {
        await _propertyService.createProperty(property);
      }

      isSubmitting.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSubmitting.value = false;
      return false;
    }
  }

  /// Submit for admin review.
  Future<bool> submitForReview() async {
    if (!isEditing) {
      error.value = 'Please save as draft first';
      return false;
    }

    error.value = '';
    isSubmitting.value = true;

    try {
      await _propertyService.submitForReview(editingPropertyId.value);
      isSubmitting.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSubmitting.value = false;
      return false;
    }
  }

  /// Load user's properties.
  void loadUserProperties(String userId) {
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
    error.value = '';
  }

  @override
  void onClose() {
    super.onClose();
  }
}