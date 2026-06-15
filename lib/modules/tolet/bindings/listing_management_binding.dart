import 'package:get/get.dart';
import '../listing_management/listing_management_controller.dart';

class ListingManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingManagementController>(() => ListingManagementController());
  }
}