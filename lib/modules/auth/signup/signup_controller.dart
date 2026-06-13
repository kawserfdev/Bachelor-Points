import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/routes/app_routes.dart';

class SignupController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[SignupController] Initialized');
  }

  @override
  void onClose() {
    debugPrint('[SignupController] onClose called');
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    debugPrint('[validateName] input: $value');

    if (value == null || value.isEmpty) {
      debugPrint('[validateName] Name is empty');
      return 'Name is required';
    }

    return null;
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

    return null;
  }

  String? validatePassword(String? value) {
    debugPrint('[validatePassword] length: ${value?.length}');

    if (value == null || value.isEmpty) {
      debugPrint('[validatePassword] Password is empty');
      return 'Password is required';
    }

    if (value.length < 6) {
      debugPrint('[validatePassword] Password too short');
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  Future<void> signup() async {
    debugPrint('[signup] Triggered');

    if (!formKey.currentState!.validate()) {
      debugPrint('[signup] Form validation failed');
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    debugPrint('[signup] Name: $name');
    debugPrint('[signup] Email: $email');
    debugPrint('[signup] Password length: ${password.length}');

    try {
      isLoading.value = true;
      debugPrint('[signup] Calling AuthService.signUp');

      await _authService.signUp(
        email,
        password,
        name: name,
      );

      debugPrint('[signup] Signup success');

      Get.offAllNamed(AppRoutes.verifyEmail);
    } catch (e) {
      debugPrint('[signup] Error: $e');

      Get.snackbar(
        'Signup Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      debugPrint('[signup] Loading finished');
    }
  }

  Future<void> googleSignIn() async {
    debugPrint('[googleSignIn] Triggered');
    try {
      isLoading.value = true;
      await _authService.signInWithGoogle();
      debugPrint('[googleSignIn] Success');
    } catch (e) {
      debugPrint('[googleSignIn] Error: $e');
      Get.snackbar(
        'Google Sign-In Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    debugPrint('[Navigation] Back to Login');
    Get.back();
  }
}