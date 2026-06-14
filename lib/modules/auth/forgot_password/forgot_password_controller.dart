import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/auth_service.dart';
import '../../../../shared/helpers/navigation_helper.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final isSuccess = false.obs;

  @override
  void onClose() {
    debugPrint('[ForgotPasswordController] onClose called');
    emailController.dispose();
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

  Future<void> resetPassword() async {
    debugPrint('[resetPassword] Triggered');

    if (!formKey.currentState!.validate()) {
      debugPrint('[resetPassword] Form validation failed');
      return;
    }

    final email = emailController.text.trim();
    debugPrint('[resetPassword] Email: $email');

    try {
      isLoading.value = true;
      debugPrint('[resetPassword] Calling AuthService.resetPassword');

      await _authService.resetPassword(email);

      debugPrint('[resetPassword] Reset link sent successfully');

      isSuccess.value = true;

      AppNavigation.showSnackBar(
        'Link Sent',
        'Password reset link has been sent to your email.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint('[resetPassword] Error: $e');

      AppNavigation.showSnackBar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
      debugPrint('[resetPassword] Loading finished');
    }
  }
}