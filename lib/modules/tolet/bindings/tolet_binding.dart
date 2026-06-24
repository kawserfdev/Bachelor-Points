import 'package:get/get.dart';
import '../property_search/tolet_controller.dart';

class ToletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ToletController>(() => ToletController());
  }
}