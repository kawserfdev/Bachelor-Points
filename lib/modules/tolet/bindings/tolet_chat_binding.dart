import 'package:get/get.dart';
import '../chat/tolet_chat_controller.dart';

class ToletChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ToletChatController>(() => ToletChatController());
  }
}