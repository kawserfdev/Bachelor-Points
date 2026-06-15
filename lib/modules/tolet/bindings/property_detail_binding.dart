import 'package:get/get.dart';
import '../property_detail/property_detail_controller.dart';
import '../credit/credit_controller.dart';

class PropertyDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyDetailController>(() => PropertyDetailController());
    Get.lazyPut<CreditController>(() => CreditController());
  }
}