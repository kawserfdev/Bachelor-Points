import 'package:get/get.dart';
import 'mess_controller.dart';
import 'member_controller.dart';

class MessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessController>(() => MessController());
    Get.lazyPut<MemberController>(() => MemberController());
  }
}
