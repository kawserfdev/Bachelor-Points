import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  void logout() {
    authService.signOut();
  }
}
