import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class CreateProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[CreateProfileController] Initialized');
    // Pre-fill name if available from metadata
    final metadataName = _authService.currentUser.value?.userMetadata?['full_name'];
    if (metadataName != null) {
      nameController.text = metadataName.toString();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final user = _authService.currentUser.value;
    if (user == null) {
      Get.snackbar('Error', 'User not found. Please login again.');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[CreateProfile] Saving profile for ${user.id}');

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('[CreateProfile] Profile saved successfully');
      
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      debugPrint('[CreateProfile] Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
