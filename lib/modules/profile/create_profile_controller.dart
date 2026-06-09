import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class CreateProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final metadataName = _authService.currentUser.value?.displayName;
    if (metadataName != null) {
      nameController.text = metadataName;
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
      debugPrint('[CreateProfile] Saving profile for ${user.uid}');

      await _firestore.collection('profiles').doc(user.uid).set({
        'email': user.email,
        'full_name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Also update Firebase Auth display name if not already
      if (user.displayName == null) {
        await user.updateDisplayName(nameController.text.trim());
      }

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
