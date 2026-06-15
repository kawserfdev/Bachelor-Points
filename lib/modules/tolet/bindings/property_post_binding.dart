import 'package:get/get.dart';
import '../property_post/property_post_controller.dart';

class PropertyPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyPostController>(() => PropertyPostController());
  }
}