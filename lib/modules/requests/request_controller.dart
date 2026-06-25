import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/models/request_model.dart';
import '../../services/auth_service.dart';
import '../../shared/helpers/navigation_helper.dart';
import '../mess/mess_controller.dart';
import '../mess/member_controller.dart';
import '../../services/action_notification_service.dart';
import '../notifications/data/notification_repository.dart';

class RequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();
  final MemberController _memberController = Get.find<MemberController>();

  final RxList<RequestModel> allRequests = <RequestModel>[].obs;
  final RxBool isLoading = false.obs;

  // Filter state
  final RxString activeFilter = 'All'.obs;
  // All, Pending, Approved, Rejected, Expense, Deposit,
  // Join, Remove, RoleChange

  List<RequestModel> get filteredRequests {
    if (activeFilter.value == 'All') return allRequests;
    if (activeFilter.value == 'Expense') {
      return allRequests.where((r) => r.requestType == 'expense').toList();
    }
    if (activeFilter.value == 'Deposit') {
      return allRequests.where((r) => r.requestType == 'deposit').toList();
    }
    if (activeFilter.value == 'Join') {
      return allRequests.where((r) => r.requestType == 'JOIN_MESS').toList();
    }
    if (activeFilter.value == 'Remove') {
      return allRequests.where((r) => r.requestType == 'REMOVE_MEMBER').toList();
    }
    if (activeFilter.value == 'RoleChange') {
      return allRequests.where((r) => r.requestType == 'ROLE_CHANGE').toList();
    }
    return allRequests.where((r) => r.status == activeFilter.value).toList();
  }

  int get pendingCount =>
      allRequests.where((r) => r.status == 'Pending').length;
  int get approvedCount =>
      allRequests.where((r) => r.status == 'Approved').length;
  int get rejectedCount =>
      allRequests.where((r) => r.status == 'Rejected').length;

  bool get canApprove => _memberController.isManager;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[RequestController] Initialized');
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final messId = _messController.activeMess.value?.id;

    if (messId == null) {
      debugPrint('[fetchRequests] No messId');
      return;
    }

    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('requests')
          .where('mess_id', isEqualTo: messId)
          .get();

      final List<RequestModel> requests = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdBy = data['created_by'] as String?;
        if (createdBy != null && createdBy.isNotEmpty) {
          final profileDoc = await _firestore
              .collection('profiles')
              .doc(createdBy)
              .get();
          data['profiles'] = profileDoc.data();
        }
        requests.add(RequestModel.fromJson({'id': doc.id, ...data}));
      }

      // Sort client-side by created_at descending
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      allRequests.assignAll(requests);
      debugPrint('[fetchRequests] Loaded ${requests.length} requests');
    } catch (e) {
      debugPrint('[fetchRequests] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to load requests');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  // Submit helpers (called from other controllers)
  // ──────────────────────────────────────────────

  /// Submit a request to join a mess
  Future<bool> submitJoinRequest({
    required String messId,
    required String userName,
    required String userEmail,
    String? photoUrl,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return false;

    try {
      // Check for existing pending join request
      final existing = await _firestore
          .collection('requests')
          .where('mess_id', isEqualTo: messId)
          .where('created_by', isEqualTo: userId)
          .where('request_type', isEqualTo: 'JOIN_MESS')
          .where('status', isEqualTo: 'Pending')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        AppNavigation.showSnackBar(
          'Info',
          'You already have a pending join request for this mess.',
        );
        return false;
      }

      await _firestore.collection('requests').add({
        'mess_id': messId,
        'request_type': 'JOIN_MESS',
        'user_name': userName,
        'user_email': userEmail,
        'photo_url': photoUrl,
        'status': 'Pending',
        'created_by': userId,
        'created_at': FirestoreTime.serverTimestamp,
      });

      debugPrint('[submitJoinRequest] Join request submitted');
      return true;
    } catch (e) {
      debugPrint('[submitJoinRequest] Error: $e');
      return false;
    }
  }

  /// Submit a request to remove a member
  Future<bool> submitRemoveMemberRequest({
    required String memberId,
    required String memberName,
    required String currentRole,
    String? reason,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;
    if (userId == null || messId == null) return false;

    if (!canApprove) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only admins/managers can submit removal requests',
        backgroundColor: Colors.redAccent,
      );
      return false;
    }

    try {
      await _firestore.collection('requests').add({
        'mess_id': messId,
        'request_type': 'REMOVE_MEMBER',
        'member_id': memberId,
        'member_name': memberName,
        'current_role': currentRole,
        'reason': reason,
        'status': 'Pending',
        'created_by': userId,
        'created_at': FirestoreTime.serverTimestamp,
      });

      debugPrint('[submitRemoveMemberRequest] Removal request submitted');
      return true;
    } catch (e) {
      debugPrint('[submitRemoveMemberRequest] Error: $e');
      return false;
    }
  }

  /// Submit a request to change a member's role
  Future<bool> submitRoleChangeRequest({
    required String memberId,
    required String memberName,
    required String oldRole,
    required String newRole,
    String? reason,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;
    if (userId == null || messId == null) return false;

    if (!canApprove) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only admins/managers can submit role change requests',
        backgroundColor: Colors.redAccent,
      );
      return false;
    }

    try {
      await _firestore.collection('requests').add({
        'mess_id': messId,
        'request_type': 'ROLE_CHANGE',
        'member_id': memberId,
        'member_name': memberName,
        'old_role': oldRole,
        'new_role': newRole,
        'reason': reason,
        'status': 'Pending',
        'created_by': userId,
        'created_at': FirestoreTime.serverTimestamp,
      });

      debugPrint('[submitRoleChangeRequest] Role change request submitted');
      return true;
    } catch (e) {
      debugPrint('[submitRoleChangeRequest] Error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Approve / Reject
  // ──────────────────────────────────────────────

  /// Unified approve — dispatches to the correct handler
  Future<void> approveRequest(RequestModel request) async {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) return;
    if (!canApprove) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only admins/managers can approve requests',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      switch (request.requestType) {
        case 'expense':
          await _approveExpense(request, messId, userId);
          break;
        case 'deposit':
          await _approveDeposit(request, messId, userId);
          break;
        case 'JOIN_MESS':
          await _approveJoinMess(request, messId, userId);
          break;
        case 'REMOVE_MEMBER':
          await _approveRemoveMember(request, messId, userId);
          break;
        case 'ROLE_CHANGE':
          await _approveRoleChange(request, messId, userId);
          break;
        case 'MEAL_PLAN_CHANGE':
          await _approveMealPlanChange(request, messId, userId);
          break;
      }

      AppNavigation.showSnackBar(
        'Success',
        '${_requestLabel(request.requestType)} approved',
        backgroundColor: Colors.green,
      );

      fetchRequests();

      // Trigger notification for the creator of the request
      unawaited(() async {
        try {
          debugPrint('[RequestController] Dispatching approval notifications for request: ${request.id}');
          final notificationRepo = NotificationRepositoryImpl();
          final typeLabel = _requestLabel(request.requestType);
          String detail = '';
          if (request.requestType == 'expense' || request.requestType == 'deposit') {
            detail = ' of amount ${request.amount}';
          } else if (request.requestType == 'ROLE_CHANGE') {
            detail = ' to ${request.newRole}';
          } else if (request.requestType == 'MEAL_PLAN_CHANGE') {
            final startStr = request.startDate != null ? '${request.startDate!.day}/${request.startDate!.month}/${request.startDate!.year}' : '';
            final endStr = request.endDate != null ? '${request.endDate!.day}/${request.endDate!.month}/${request.endDate!.year}' : '';
            detail = ' (B:${request.breakfast}, L:${request.lunch}, D:${request.dinner}) from $startStr to $endStr';
          }

          // Notify the creator
          await ActionNotificationService.notifyRequestAccepted(
            targetUserId: request.createdBy,
            messId: messId,
            typeLabel: typeLabel,
            detail: detail,
          );

          // If it was a role change, notify the target member as well
          if (request.requestType == 'ROLE_CHANGE' && request.memberId != null && request.memberId != request.createdBy) {
            debugPrint('[RequestController] Dispatching role update notification to target member: ${request.memberId}');
            await notificationRepo.sendNotification(
              targetUserId: request.memberId!,
              messId: messId,
              title: 'Role Updated',
              body: 'Your role in the mess has been updated to ${request.newRole}.',
              type: 'manager',
              route: '/settings',
            );
          }
        } catch (ne) {
          debugPrint('Failed to send approval notification: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[approveRequest] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to approve request');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _approveExpense(
      RequestModel r, String messId, String userId) async {
    await _firestore.collection('expenses').add({
      'mess_id': messId,
      'request_id': r.id,
      'created_by': r.createdBy,
      'amount': r.amount,
      'category': r.category ?? 'other',
      'note': r.note,
      'date': _dateStr(r.requestDate),
      'status': 'Approved',
      'created_at': FirestoreTime.serverTimestamp,
    });
    await _firestore.collection('requests').doc(r.id).update({
      'status': 'Approved',
      'approved_by': userId,
      'approved_at': FirestoreTime.serverTimestamp,
    });
  }

  Future<void> _approveDeposit(
      RequestModel r, String messId, String userId) async {
    await _firestore.collection('deposits').add({
      'mess_id': messId,
      'request_id': r.id,
      'user_id': r.createdBy,
      'amount': r.amount,
      'payment_method': r.paymentMethod ?? 'cash',
      'note': r.note,
      'date': _dateStr(r.requestDate),
      'status': 'Approved',
      'received_by': userId,
      'created_at': FirestoreTime.serverTimestamp,
    });
    await _firestore.collection('requests').doc(r.id).update({
      'status': 'Approved',
      'approved_by': userId,
      'approved_at': FirestoreTime.serverTimestamp,
    });
  }

  Future<void> _approveJoinMess(
      RequestModel r, String messId, String userId) async {
    // Add user to mess_members
    await _firestore.collection('mess_members').add({
      'mess_id': messId,
      'user_id': r.createdBy,
      'role': 'member',
      'joined_at': FirestoreTime.serverTimestamp,
    });
    await _firestore.collection('requests').doc(r.id).update({
      'status': 'Approved',
      'approved_by': userId,
      'approved_at': FirestoreTime.serverTimestamp,
    });
  }

  Future<void> _approveRemoveMember(
      RequestModel r, String messId, String userId) async {
    // Remove the member from mess_members
    final memberId = r.memberId;
    if (memberId == null) return;

    // Find and delete the mess_members document
    final snapshot = await _firestore
        .collection('mess_members')
        .where('mess_id', isEqualTo: messId)
        .where('user_id', isEqualTo: memberId)
        .limit(1)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('requests').doc(r.id).update({
      'status': 'Approved',
      'approved_by': userId,
      'approved_at': FirestoreTime.serverTimestamp,
    });
  }

  Future<void> _approveRoleChange(
      RequestModel r, String messId, String userId) async {
    final memberId = r.memberId;
    final newRole = r.newRole;
    if (memberId == null || newRole == null) return;

    // Find the mess_members document and update role
    final snapshot = await _firestore
        .collection('mess_members')
        .where('mess_id', isEqualTo: messId)
        .where('user_id', isEqualTo: memberId)
        .limit(1)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'role': newRole});
    }

    await _firestore.collection('requests').doc(r.id).update({
      'status': 'Approved',
      'approved_by': userId,
      'approved_at': FirestoreTime.serverTimestamp,
    });
  }

  Future<void> _approveMealPlanChange(
      RequestModel r, String messId, String userId) async {
    // 1. Update default meal plan portions
    final docId = '${messId}_${r.createdBy}';
    await _firestore.collection('default_meal_plans').doc(docId).set({
      'mess_id': messId,
      'user_id': r.createdBy,
      'breakfast': r.breakfast ?? 1.0,
      'lunch': r.lunch ?? 1.0,
      'dinner': r.dinner ?? 1.0,
      'updated_at': FirestoreTime.serverTimestamp,
    }, SetOptions(merge: true));

    // 2. If start/end date range exists, apply to meals in range
    if (r.startDate != null && r.endDate != null) {
      final start = DateTime(r.startDate!.year, r.startDate!.month, r.startDate!.day);
      final end = DateTime(r.endDate!.year, r.endDate!.month, r.endDate!.day);
      final durationDays = end.difference(start).inDays + 1;

      if (durationDays > 0) {
        final batch = _firestore.batch();
        for (int i = 0; i < durationDays; i++) {
          final currentDate = start.add(Duration(days: i));
          final dateStr =
              "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
          final mealDocId = '${messId}_${r.createdBy}_$dateStr';
          final mealRef = _firestore.collection('meals').doc(mealDocId);

          batch.set(mealRef, {
            'mess_id': messId,
            'user_id': r.createdBy,
            'date': dateStr,
            'breakfast': r.breakfast ?? 1.0,
            'lunch': r.lunch ?? 1.0,
            'dinner': r.dinner ?? 1.0,
            'status': 'Approved',
            'updated_at': FirestoreTime.serverTimestamp,
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }
    }

    // 3. Mark request as Approved
    await _firestore.collection('requests').doc(r.id).update({
      'status': 'Approved',
      'approved_by': userId,
      'approved_at': FirestoreTime.serverTimestamp,
    });
  }

  /// Reject a request — only updates status, no data changes
  Future<void> rejectRequest(RequestModel request) async {
    final userId = _authService.currentUser.value?.uid;

    if (userId == null) return;
    if (!canApprove) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only admins/managers can reject requests',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _firestore.collection('requests').doc(request.id).update({
        'status': 'Rejected',
        'rejected_by': userId,
        'rejected_at': FirestoreTime.serverTimestamp,
      });

      AppNavigation.showSnackBar(
        'Success',
        '${_requestLabel(request.requestType)} rejected',
        backgroundColor: Colors.red,
      );

      fetchRequests();

      // Trigger notification for the creator of the request
      unawaited(() async {
        try {
          debugPrint('[RequestController] Dispatching rejection notifications for request: ${request.id}');
          final messId = _messController.activeMess.value?.id;
          if (messId != null) {
            final notificationRepo = NotificationRepositoryImpl();
            final typeLabel = _requestLabel(request.requestType);
            String detail = '';
            if (request.requestType == 'expense' || request.requestType == 'deposit') {
              detail = ' of amount ${request.amount}';
            }
            debugPrint('[RequestController] Dispatching rejection notification to request creator: ${request.createdBy}');
            await notificationRepo.sendNotification(
              targetUserId: request.createdBy,
              messId: messId,
              title: 'Request Rejected',
              body: 'Your request for $typeLabel$detail has been rejected.',
              type: 'request_status',
              route: '/approvals',
            );
          }
        } catch (ne) {
          debugPrint('Failed to send rejection notification: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[rejectRequest] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to reject request');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  // Edit financial requests
  // ──────────────────────────────────────────────

  Future<void> updateExpenseRequest({
    required String requestId,
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _firestore.collection('requests').doc(requestId).update({
        'title': title,
        'category': category,
        'amount': amount,
        'request_date': _dateStr(date),
        'note': note,
        'updated_by': userId,
        'updated_at': FirestoreTime.serverTimestamp,
      });
      AppNavigation.showSnackBar('Success', 'Request updated');
      fetchRequests();
    } catch (e) {
      debugPrint('[updateExpenseRequest] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to update request');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDepositRequest({
    required String requestId,
    required double amount,
    required String paymentMethod,
    required DateTime date,
    String? note,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _firestore.collection('requests').doc(requestId).update({
        'amount': amount,
        'payment_method': paymentMethod,
        'request_date': _dateStr(date),
        'note': note,
        'updated_by': userId,
        'updated_at': FirestoreTime.serverTimestamp,
      });
      AppNavigation.showSnackBar('Success', 'Request updated');
      fetchRequests();
    } catch (e) {
      debugPrint('[updateDepositRequest] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to update request');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ──

  String _dateStr(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _requestLabel(String type) {
    switch (type) {
      case 'expense':
        return 'Expense';
      case 'deposit':
        return 'Deposit';
      case 'JOIN_MESS':
        return 'Join request';
      case 'REMOVE_MEMBER':
        return 'Removal request';
      case 'ROLE_CHANGE':
        return 'Role change';
      case 'MEAL_PLAN_CHANGE':
        return 'Meal Plan Change';
      default:
        return type;
    }
  }
}