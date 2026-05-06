import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('[LoginController] Initialized');
  }

  @override
  void onClose() {
    debugPrint('[LoginController] onClose called');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    debugPrint('[validateEmail] input: $value');

    if (value == null || value.isEmpty) {
      debugPrint('[validateEmail] Email is empty');
      return 'Email is required';
    }

    if (!GetUtils.isEmail(value)) {
      debugPrint('[validateEmail] Invalid email format');
      return 'Please enter a valid email';
    }

    debugPrint('[validateEmail] Email is valid');
    return null;
  }

  String? validatePassword(String? value) {
    debugPrint('[validatePassword] input length: ${value?.length}');

    if (value == null || value.isEmpty) {
      debugPrint('[validatePassword] Password is empty');
      return 'Password is required';
    }

    return null;
  }

  Future<void> login() async {
    debugPrint('[login] Triggered');

    if (!formKey.currentState!.validate()) {
      debugPrint('[login] Form validation failed');
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    debugPrint('[login] Email: $email');
    debugPrint('[login] Password length: ${password.length}');

    try {
      isLoading.value = true;
      debugPrint('[login] Calling AuthService.signIn');

      await _authService.signIn(email, password);

      debugPrint('[login] Login success');

      // Optional (if navigation not handled inside AuthService)
      // Get.offAllNamed(AppRoutes.home);

    } catch (e) {
      debugPrint('[login] Error: $e');

      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      debugPrint('[login] Loading finished');
    }
  }

  void goToSignup() {
    debugPrint('[Navigation] Go to Signup');
    Get.toNamed(AppRoutes.signup);
  }

  void goToForgotPassword() {
    debugPrint('[Navigation] Go to ForgotPassword');
    Get.toNamed(AppRoutes.forgotPassword);
  }
}