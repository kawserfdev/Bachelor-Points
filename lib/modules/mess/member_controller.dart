import 'package:bachelorpoints/modules/mess/mess_controller.dart';
import 'package:bachelorpoints/services/auth_service.dart';
import 'package:bachelorpoints/shared/helpers/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../requests/request_controller.dart';

class MemberController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();

  RequestController get _requestController =>
      Get.find<RequestController>();

  /// Returns true if the current user is an admin (owner) of the mess
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

  /// Returns true if the current user is a manager or admin (can approve/reject)
  bool get isManager {
    final currentUserId = _authService.currentUser.value?.uid;
    if (currentUserId == null) return false;

    try {
      final myMember = _messController.members
          .firstWhere((m) => m.userId == currentUserId);
      return myMember.role == 'admin' || myMember.role == 'manager';
    } catch (e) {
      return false;
    }
  }

  /// Submit a role change request (instead of directly updating)
  Future<void> changeRole(String memberId, String newRole) async {
    debugPrint('[changeRole] memberId: $memberId, newRole: $newRole');

    if (!isManager) {
      debugPrint('[changeRole] Permission denied (not admin/manager)');
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only admins/managers can change roles.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      // Find the member in the current members list
      final member = _messController.members
          .firstWhereOrNull((m) => m.userId == memberId);

      if (member == null) {
        AppNavigation.showSnackBar('Error', 'Member not found',
            backgroundColor: Colors.redAccent);
        return;
      }

      // Validate
      if (member.role == 'admin') {
        AppNavigation.showSnackBar('Error', 'Owner role cannot be changed',
            backgroundColor: Colors.redAccent);
        return;
      }
      if (member.role == newRole) {
        AppNavigation.showSnackBar('Error',
            'New role must be different from current role',
            backgroundColor: Colors.redAccent);
        return;
      }

      final success = await _requestController.submitRoleChangeRequest(
        memberId: memberId,
        memberName: member.fullName ?? member.email ?? 'Unknown',
        oldRole: member.role,
        newRole: newRole,
      );

      if (success) {
        AppNavigation.showSnackBar(
          'Success',
          'Role change request submitted for approval.',
        );
      } else {
        AppNavigation.showSnackBar('Error', 'Failed to submit request',
            backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      debugPrint('[changeRole] Error: $e');
      AppNavigation.showSnackBar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
      );
    }
  }

  /// Submit a remove member request (instead of directly deleting)
  Future<void> removeMember(String memberId) async {
    debugPrint('[removeMember] memberId: $memberId');

    if (!isManager) {
      debugPrint('[removeMember] Permission denied (not admin/manager)');
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only admins/managers can remove members.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      final member = _messController.members
          .firstWhereOrNull((m) => m.userId == memberId);

      if (member == null) {
        AppNavigation.showSnackBar('Error', 'Member not found',
            backgroundColor: Colors.redAccent);
        return;
      }

      // Validate
      if (member.role == 'admin') {
        AppNavigation.showSnackBar('Error', 'Owner cannot be removed',
            backgroundColor: Colors.redAccent);
        return;
      }

      final success = await _requestController.submitRemoveMemberRequest(
        memberId: memberId,
        memberName: member.fullName ?? member.email ?? 'Unknown',
        currentRole: member.role,
      );

      if (success) {
        AppNavigation.showSnackBar(
          'Success',
          'Member removal request submitted for approval.',
        );
      } else {
        AppNavigation.showSnackBar('Error', 'Failed to submit request',
            backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      debugPrint('[removeMember] Error: $e');
      AppNavigation.showSnackBar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
      );
    }
  }
}