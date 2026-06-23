import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../../shared/helpers/navigation_helper.dart';

class EditProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final nidController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[EditProfileController] Initialized');
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    try {
      final doc = await _firestore.collection('profiles').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        nameController.text = data['full_name'] as String? ?? user.displayName ?? '';
        phoneController.text = data['phone_number'] as String? ?? '';
        addressController.text = data['address'] as String? ?? '';
        bioController.text = data['bio'] as String? ?? '';
        nidController.text = data['nid_number'] as String? ?? '';
      } else {
        nameController.text = user.displayName ?? '';
      }
    } catch (e) {
      debugPrint('[EditProfileController] Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    nidController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> saveProfile(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final user = _authService.currentUser.value;
    if (user == null) {
      AppNavigation.showSnackBar('Error', 'User not found. Please login again.');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[EditProfileController] Saving profile for ${user.uid}');

      await _firestore.collection('profiles').doc(user.uid).set({
        'full_name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'bio': bioController.text.trim(),
        'nid_number': nidController.text.trim(),
        'updated_at': FirestoreTime.serverTimestamp,
      }, SetOptions(merge: true));

      // Also update Firebase Auth display name if not already
      if (user.displayName == null || user.displayName != nameController.text.trim()) {
        await user.updateDisplayName(nameController.text.trim());
      }

      debugPrint('[EditProfileController] Profile updated successfully');
      
      if (!context.mounted) return;

      if (context.canPop()) {
        context.pop();
      }
    } catch (e) {
      debugPrint('[EditProfileController] Error updating profile: $e');
      AppNavigation.showSnackBar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
