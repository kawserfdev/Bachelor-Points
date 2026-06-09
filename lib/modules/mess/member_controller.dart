import 'package:bachelorpoints/modules/mess/mess_controller.dart';
import 'package:bachelorpoints/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();

  bool get isAdmin {
    final currentUserId = _authService.currentUser.value?.uid;
    debugPrint('[isAdmin] currentUserId: $currentUserId');

    if (currentUserId == null) {
      debugPrint('[isAdmin] User is null');
      return false;
    }

    try {
      final myMember = _messController.members
          .firstWhere((m) => m.userId == currentUserId);

      debugPrint('[isAdmin] Found member role: ${myMember.role}');
      return myMember.role == 'admin';
    } catch (e) {
      debugPrint('[isAdmin] Member not found in list: $e');
      return false;
    }
  }

  Future<void> changeRole(String memberId, String newRole) async {
    debugPrint('[changeRole] memberId: $memberId, newRole: $newRole');

    if (!isAdmin) {
      debugPrint('[changeRole] Permission denied (not admin)');
      Get.snackbar(
        'Permission Denied',
        'Only admins can change roles.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      debugPrint('[changeRole] Sending update request to Firestore');
      debugPrint('[changeRole] memberId: $memberId, newRole: $newRole');

      await _firestore
          .collection('mess_members')
          .doc(memberId)
          .update({'role': newRole});

      debugPrint('[changeRole] Role updated successfully');

      Get.snackbar('Success', 'Role updated successfully.');
    } catch (e) {
      debugPrint('[changeRole] Error: $e');

      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeMember(String memberId) async {
    debugPrint('[removeMember] memberId: $memberId');

    if (!isAdmin) {
      debugPrint('[removeMember] Permission denied (not admin)');
      Get.snackbar(
        'Permission Denied',
        'Only admins can remove members.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      debugPrint('[removeMember] Sending delete request to Firestore');

      await _firestore
          .collection('mess_members')
          .doc(memberId)
          .delete();

      debugPrint('[removeMember] Member removed successfully');

      Get.snackbar('Success', 'Member removed successfully.');
    } catch (e) {
      debugPrint('[removeMember] Error: $e');

      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}