import 'package:get/get.dart';
import '../credit/credit_controller.dart';
import '../referral/referral_controller.dart';

class CreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreditController>(() => CreditController());
    Get.lazyPut<ReferralController>(() => ReferralController());
  }
}