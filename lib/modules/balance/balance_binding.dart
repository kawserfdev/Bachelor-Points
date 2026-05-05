import 'package:get/get.dart';
import 'balance_controller.dart';

class BalanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BalanceController>(() => BalanceController());
  }
}
