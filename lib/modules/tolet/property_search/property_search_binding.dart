import 'package:get/get.dart';
import '../property_search/property_search_controller.dart';

class PropertySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertySearchController>(() => PropertySearchController());
  }
}