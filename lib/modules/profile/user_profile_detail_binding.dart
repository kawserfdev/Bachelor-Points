import 'package:get/get.dart';
import 'user_profile_detail_controller.dart';

class UserProfileDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileDetailController>(
      () => UserProfileDetailController(),
      fenix: true,
    );
  }
}
