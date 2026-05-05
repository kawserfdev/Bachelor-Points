import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import 'mess_controller.dart';

class MemberController extends GetxController {
  final _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();

  bool get isAdmin {
    final currentUserId = _authService.currentUser.value?.id;
    if (currentUserId == null) return false;

    // Check the current user's role in the members list
    try {
      final myMember = _messController.members.firstWhere((m) => m.userId == currentUserId);
      return myMember.role == 'admin';
    } catch (_) {
      return false; // Not found in list
    }
  }

  Future<void> changeRole(String memberId, String newRole) async {
    if (!isAdmin) {
      Get.snackbar('Permission Denied', 'Only admins can change roles.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      await _supabase
          .from('mess_members')
          .update({'role': newRole})
          .eq('id', memberId);
      Get.snackbar('Success', 'Role updated successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> removeMember(String memberId) async {
    if (!isAdmin) {
      Get.snackbar('Permission Denied', 'Only admins can remove members.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      await _supabase
          .from('mess_members')
          .delete()
          .eq('id', memberId);
      Get.snackbar('Success', 'Member removed successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
