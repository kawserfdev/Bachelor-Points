import 'package:get/get.dart';
import 'home_controller.dart';

import '../mess/mess_controller.dart';
import '../mess/member_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MessController>(() => MessController());
    Get.lazyPut<MemberController>(() => MemberController());
  }
}
