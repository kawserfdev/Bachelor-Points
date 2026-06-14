import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class HomeController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final StorageService storageService = Get.find<StorageService>();

  Future<void> logout() async {
    await storageService.clearAll();
    await authService.signOut();
  }
}
