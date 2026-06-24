import 'package:get/get.dart';
import '../../../data/models/toletItem_model.dart';

class ToletController extends GetxController {
  // Toggles visibility for expanded feature sets
  final RxBool isExpandedFeatures = false.obs;

  // Filter state for tolet listings
  final RxString selectedToletFilter = 'All'.obs;

  // Track property listings state dynamically
  final RxList<ToletItem> featuredListings = <ToletItem>[].obs;
  final RxBool isLoadingListings = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedListings();
  }

  /// Toggles the feature menu display
  void toggleFeatures() => isExpandedFeatures.toggle();

  /// Simulates fetching tailored properties based on real-time data requirements
  void fetchFeaturedListings() async {
    try {
      isLoadingListings.value = true;
      // Simulating a minor network latency delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Load data from your source/mock model configuration
      featuredListings.assignAll(mockTolets);
    } catch (e) {
      Get.log("Error loading listings: $e");
    } finally {
      isLoadingListings.value = false;
    }
  }
}