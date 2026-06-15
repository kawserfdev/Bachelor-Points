import 'package:get/get.dart';
import '../need_based_post/need_based_post_controller.dart';

class NeedBasedPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NeedBasedPostController>(() => NeedBasedPostController());
  }
}