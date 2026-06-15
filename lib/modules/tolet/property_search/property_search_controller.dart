import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../services/property_service.dart';

/// Controller for property search, filtering, and listing.
class PropertySearchController extends GetxController {
  final PropertyService _propertyService = PropertyService();

  // Filters
  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString upazila = ''.obs;
  final RxString union = ''.obs;
  final RxString area = ''.obs;
  final RxString road = ''.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 100000.0.obs;
  final RxString propertyType = 'bachelor'.obs;
  final RxString searchQuery = ''.obs;

  // Results
  final RxList<PropertyModel> properties = <PropertyModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Map search
  final RxDouble mapLat = 23.8103.obs;
  final RxDouble mapLng = 90.4125.obs;
  final RxDouble searchRadius = 5.0.obs; // km
  final RxString nearbyPlaceFilter = ''.obs; // hospital, school, market, mosque

  static const List<String> propertyTypes = [
    'family',
    'bachelor',
    'hostel',
    'mess',
    'office',
    'shop',
    'land',
  ];

  static const List<String> divisions = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Sylhet',
    'Barishal',
    'Rangpur',
    'Mymensingh',
  ];

  static const List<double> radiusOptions = [2, 5, 10];
  static const List<String> nearbyPlaces = [
    'hospital',
    'school',
    'market',
    'mosque',
  ];

  /// Search properties with current filters.
  void search() {
    isLoading.value = true;
    error.value = '';

    final types = propertyType.value.isNotEmpty ? [propertyType.value] : null;

    _propertyService
        .searchProperties(
      division: division.value.isEmpty ? null : division.value,
      district: district.value.isEmpty ? null : district.value,
      upazila: upazila.value.isEmpty ? null : upazila.value,
      union: union.value.isEmpty ? null : union.value,
      area: area.value.isEmpty ? null : area.value,
      road: road.value.isEmpty ? null : road.value,
      minPrice: minPrice.value > 0 ? minPrice.value : null,
      maxPrice: maxPrice.value < 100000 ? maxPrice.value : null,
      propertyTypes: types,
      status: 'live',
    ).listen((results) {
      properties.value = results;
      isLoading.value = false;
    }, onError: (e) {
      error.value = e.toString();
      isLoading.value = false;
    });
  }

  /// Search nearby properties using map coordinates.
  void searchNearby() {
    isLoading.value = true;
    error.value = '';

    _propertyService
        .getNearbyProperties(
      lat: mapLat.value,
      lng: mapLng.value,
      radiusKm: searchRadius.value,
    ).listen((results) {
      properties.value = results;
      isLoading.value = false;
    }, onError: (e) {
      error.value = e.toString();
      isLoading.value = false;
    });
  }

  /// Reset all filters.
  void resetFilters() {
    division.value = '';
    district.value = '';
    upazila.value = '';
    union.value = '';
    area.value = '';
    road.value = '';
    minPrice.value = 0.0;
    maxPrice.value = 100000.0;
    propertyType.value = 'bachelor';
    searchQuery.value = '';
  }

  @override
  void onClose() {
    // Streams are cleaned up by listeners on dispose
    super.onClose();
  }
}