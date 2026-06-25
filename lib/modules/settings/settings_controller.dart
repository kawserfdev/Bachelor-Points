import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/models/mess_settings_model.dart';
import '../../data/models/bazar_schedule_model.dart';
import '../../data/models/member_model.dart';
import '../../services/action_notification_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../shared/helpers/navigation_helper.dart';
import '../notifications/data/notification_repository.dart';

class SettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxBool isAdmin = false.obs;

  final RxDouble currentDefaultBreakfast = 0.0.obs;
  final RxDouble currentDefaultLunch = 0.0.obs;
  final RxDouble currentDefaultDinner = 0.0.obs;
  final RxBool hasPendingMealPlanRequest = false.obs;

  String? _messId;
  String? get messId => _messId;

  final Rx<MessSettingsModel?> messSettings =
      Rx<MessSettingsModel?>(null);

  final RxList<MemberModel> members = <MemberModel>[].obs;
  final RxList<BazarScheduleModel> schedules =
      <BazarScheduleModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    debugPrint('[SettingsController] Initialized');

    _checkAdminAndLoadData();
  }

  Future<void> _checkAdminAndLoadData() async {
    final userId = _authService.currentUser.value?.uid;

    debugPrint('[checkAdmin] userId: $userId');

    if (userId == null) return;

    try {
      isLoading.value = true;

      final memberResponse = await _firestore
          .collection('mess_members')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberResponse.docs.isEmpty) {
        debugPrint('[checkAdmin] No membership found');
        return;
      }

      final docData = memberResponse.docs.first.data();
      _messId = docData['mess_id'] as String;
      final role = docData['role'] as String;

      debugPrint('[checkAdmin] messId: $_messId | role: $role');

      isAdmin.value = (role == 'admin' || role == 'manager');

      debugPrint('[checkAdmin] isAdmin: ${isAdmin.value}');

      await fetchUserMealPlanAndRequestStatus();

      if (isAdmin.value) {
        await _loadAllSettingsData();
      } else {
        debugPrint('[checkAdmin] Non-admin access, skipped loading admin settings');
      }
    } catch (e) {
      debugPrint('[checkAdmin] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllSettingsData() async {
    if (_messId == null) {
      debugPrint('[loadSettings] messId is null');
      return;
    }

    try {
      debugPrint('[loadSettings] Loading all data...');

      // SETTINGS
      final settingsRes = await _firestore
          .collection('mess_settings')
          .where('mess_id', isEqualTo: _messId)
          .limit(1)
          .get();

      if (settingsRes.docs.isNotEmpty) {
        final doc = settingsRes.docs.first;
        messSettings.value = MessSettingsModel.fromJson({'id': doc.id, ...doc.data()});
      } else {
        messSettings.value = MessSettingsModel(
          messId: _messId!,
          mealCutoffTime: '22:00',
        );
      }

      // MEMBERS
      final membersRes = await _firestore
          .collection('mess_members')
          .where('mess_id', isEqualTo: _messId)
          .get();

      debugPrint(
          '[loadSettings] members count: ${membersRes.docs.length}');

      final membersList = <MemberModel>[];
      for (var doc in membersRes.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['user_id']).get();
          data['profiles'] = profileDoc.data();
          membersList.add(MemberModel.fromJson({'id': doc.id, ...data}));
      }

      members.assignAll(membersList);

      // SCHEDULES
      await fetchSchedules();

      debugPrint('[loadSettings] Completed');
    } catch (e) {
      debugPrint('[loadSettings] Error: $e');
    }
  }

  Future<void> fetchSchedules() async {
    if (_messId == null) return;

    try {
      debugPrint('[fetchSchedules] Fetching...');

      final scheduleRes = await _firestore
          .collection('bazar_schedules')
          .where('mess_id', isEqualTo: _messId)
          .orderBy('date', descending: false)
          .get();

      debugPrint(
          '[fetchSchedules] count: ${scheduleRes.docs.length}');

      final scheduleList = <BazarScheduleModel>[];
      for (var doc in scheduleRes.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['user_id']).get();
          data['profiles'] = profileDoc.data();
          scheduleList.add(BazarScheduleModel.fromJson({'id': doc.id, ...data}));
      }

      schedules.assignAll(scheduleList);
    } catch (e) {
      debugPrint('[fetchSchedules] Error: $e');
    }
  }

  // --- ACTIONS ---

  Future<void> updateCutoffTime(String newTime) async {
    debugPrint('[updateCutoff] newTime: $newTime');

    if (_messId == null) return;

    try {
      isLoading.value = true;

      // Check if setting document exists
      final settingsQuery = await _firestore.collection('mess_settings').where('mess_id', isEqualTo: _messId).limit(1).get();
      if (settingsQuery.docs.isNotEmpty) {
          await _firestore.collection('mess_settings').doc(settingsQuery.docs.first.id).update({
              'meal_cutoff_time': newTime,
              'updated_at': FirestoreTime.serverTimestamp,
          });
      } else {
          await _firestore.collection('mess_settings').add({
              'mess_id': _messId,
              'meal_cutoff_time': newTime,
              'created_at': FirestoreTime.serverTimestamp,
          });
      }

      messSettings.value = MessSettingsModel(
        messId: _messId!,
        mealCutoffTime: newTime,
      );

      debugPrint('[updateCutoff] success');
      AppNavigation.showSnackBar('Success', 'Cutoff time updated to $newTime');

      // Notify all members about the cutoff time change
      unawaited(() async {
        try {
          await ActionNotificationService.notifyCutoffTimeChanged(
            messId: _messId!,
            newTime: newTime,
            members: members,
          );
        } catch (ne) {
          debugPrint('[updateCutoff] Failed to dispatch notifications: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[updateCutoff] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to update time');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeMemberRole(
      String memberId, String newRole) async {
    debugPrint(
        '[changeRole] memberId: $memberId | newRole: $newRole');

    try {
      isLoading.value = true;

      await _firestore
          .collection('mess_members')
          .doc(memberId)
          .update({'role': newRole, 'updated_at': FirestoreTime.serverTimestamp});

      final index =
          members.indexWhere((m) => m.id == memberId);

      debugPrint('[changeRole] index: $index');

      if (index != -1) {
        final old = members[index];

        members[index] = MemberModel(
          id: old.id,
          messId: old.messId,
          userId: old.userId,
          role: newRole,
          joinedAt: old.joinedAt,
          fullName: old.fullName,
          email: old.email,
        );

        debugPrint('[changeRole] local updated');

        // Notify the target member about their new role
        unawaited(() async {
          try {
            await ActionNotificationService.notifyRoleChanged(
              targetUserId: old.userId,
              messId: _messId ?? '',
              newRole: newRole,
            );
          } catch (ne) {
            debugPrint('Failed to send role change notification: $ne');
          }
        }());
      }
  
      AppNavigation.showSnackBar('Success', 'Role updated to $newRole');
    } catch (e) {
      debugPrint('[changeRole] Error: $e');
  
      AppNavigation.showSnackBar('Error', 'Failed to update role');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignBazarDuty(
      String userId, DateTime date) async {
    debugPrint('[assignBazar] userId: $userId | date: $date');

    if (_messId == null) return;

    try {
      isLoading.value = true;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      debugPrint('[assignBazar] formattedDate: $formattedDate');

      await _firestore.collection('bazar_schedules').add({
        'mess_id': _messId,
        'user_id': userId,
        'date': formattedDate,
        'created_at': FirestoreTime.serverTimestamp,
      });

      await fetchSchedules();

      AppNavigation.showSnackBar('Success', 'Bazar duty assigned');

      // Notify the assigned member and schedule a local reminder
      unawaited(() async {
        try {
          // Push notification to assigned member
          await ActionNotificationService.notifyBazarAssigned(
            targetUserId: userId,
            messId: _messId!,
            formattedDate: formattedDate,
          );
          // Schedule a local reminder at 8 AM on duty day
          await ActionNotificationService.scheduleBazarReminder(
            dutyDate: date,
          );
        } catch (ne) {
          debugPrint('[assignBazar] Failed to dispatch bazar notifications: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[assignBazar] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to assign bazar duty');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBazarDuty(String scheduleId) async {
    debugPrint('[deleteBazar] scheduleId: $scheduleId');

    try {
      isLoading.value = true;

      await _firestore
          .collection('bazar_schedules')
          .doc(scheduleId)
          .delete();

      schedules
          .removeWhere((s) => s.id == scheduleId);

      debugPrint('[deleteBazar] deleted successfully');

      AppNavigation.showSnackBar('Success', 'Duty removed');
    } catch (e) {
      debugPrint('[deleteBazar] Error: $e');

      AppNavigation.showSnackBar('Error', 'Failed to remove duty');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    debugPrint('[logout] Triggered');
    try {
      isLoading.value = true;
      await Get.find<StorageService>().clearAll();
      await _authService.signOut();
      debugPrint('[logout] Sign out successful');
    } catch (e) {
      debugPrint('[logout] Error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit a request to leave/exit the current mess
  Future<void> submitExitRequest(String reason) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null || _messId == null) {
      AppNavigation.showSnackBar('Error', 'Unable to retrieve user or mess details.');
      return;
    }

    try {
      isLoading.value = true;

      // 1. Check if user already has a pending exit request
      final existingRequests = await _firestore
          .collection('requests')
          .where('mess_id', isEqualTo: _messId)
          .where('request_type', isEqualTo: 'REMOVE_MEMBER')
          .where('member_id', isEqualTo: userId)
          .where('status', isEqualTo: 'Pending')
          .limit(1)
          .get();

      if (existingRequests.docs.isNotEmpty) {
        AppNavigation.showSnackBar(
          'Already Submitted',
          'You have a pending exit request for this mess.',
          backgroundColor: Colors.orangeAccent,
        );
        return;
      }

      // 2. Fetch user role and name
      final memberResponse = await _firestore
          .collection('mess_members')
          .where('mess_id', isEqualTo: _messId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberResponse.docs.isEmpty) {
        AppNavigation.showSnackBar('Error', 'No membership record found.');
        return;
      }

      final docData = memberResponse.docs.first.data();
      final currentRole = docData['role'] as String? ?? 'member';

      final profileDoc = await _firestore.collection('profiles').doc(userId).get();
      final profileData = profileDoc.data();
      final fullName = profileData?['full_name'] as String? ?? profileData?['email'] as String? ?? 'Unknown';

      // 3. Submit request to requests collection
      await _firestore.collection('requests').add({
        'mess_id': _messId,
        'request_type': 'REMOVE_MEMBER',
        'member_id': userId,
        'member_name': fullName,
        'current_role': currentRole,
        'reason': reason.trim(),
        'status': 'Pending',
        'created_by': userId,
        'created_at': FirestoreTime.serverTimestamp,
      });

      AppNavigation.showSnackBar(
        'Submitted',
        'Your exit request has been submitted to the manager/admin.',
        backgroundColor: Colors.green,
      );

      // 4. Notify all managers/owners about the exit request
      unawaited(() async {
        try {
          final managersRes = await _firestore
              .collection('mess_members')
              .where('mess_id', isEqualTo: _messId)
              .where('role', whereIn: ['manager', 'admin', 'owner'])
              .get();

          final managers = managersRes.docs
              .where((doc) => doc.data()['user_id'] != userId)
              .map((doc) => {'userId': doc.data()['user_id'] as String})
              .toList();

          if (managers.isNotEmpty) {
            await ActionNotificationService.notifyExitRequested(
              messId: _messId!,
              memberName: fullName,
              reason: reason.trim(),
              managers: managers,
            );
          }
        } catch (ne) {
          debugPrint('[submitExitRequest] Failed to dispatch notifications: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[submitExitRequest] Error: $e');
      AppNavigation.showSnackBar(
        'Error',
        'Failed to submit exit request: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserMealPlanAndRequestStatus() async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null || _messId == null) return;

    try {
      final defaultPlanDoc = '${_messId}_$userId';
      final defaultSnap = await _firestore.collection('default_meal_plans').doc(defaultPlanDoc).get();
      final defaultData = defaultSnap.data();

      currentDefaultBreakfast.value = (defaultData?['breakfast'] as num?)?.toDouble() ?? 1.0;
      currentDefaultLunch.value = (defaultData?['lunch'] as num?)?.toDouble() ?? 1.0;
      currentDefaultDinner.value = (defaultData?['dinner'] as num?)?.toDouble() ?? 1.0;

      final pendingSnap = await _firestore
          .collection('requests')
          .where('mess_id', isEqualTo: _messId)
          .where('created_by', isEqualTo: userId)
          .where('request_type', isEqualTo: 'MEAL_PLAN_CHANGE')
          .where('status', isEqualTo: 'Pending')
          .limit(1)
          .get();

      hasPendingMealPlanRequest.value = pendingSnap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('[fetchUserMealPlanAndRequestStatus] Error: $e');
    }
  }

  Future<void> submitMealPlanRequest({
    required double breakfastVal,
    required double lunchVal,
    required double dinnerVal,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null || _messId == null) {
      AppNavigation.showSnackBar('Error', 'Unable to retrieve user or mess details.');
      return;
    }

    try {
      isLoading.value = true;

      final existingRequests = await _firestore
          .collection('requests')
          .where('mess_id', isEqualTo: _messId)
          .where('request_type', isEqualTo: 'MEAL_PLAN_CHANGE')
          .where('created_by', isEqualTo: userId)
          .where('status', isEqualTo: 'Pending')
          .limit(1)
          .get();

      if (existingRequests.docs.isNotEmpty) {
        AppNavigation.showSnackBar(
          'Already Submitted',
          'You already have a pending meal plan update request.',
          backgroundColor: Colors.orangeAccent,
        );
        return;
      }

      final profileDoc = await _firestore.collection('profiles').doc(userId).get();
      final profileData = profileDoc.data();
      final fullName = profileData?['full_name'] as String? ?? profileData?['email'] as String? ?? 'Unknown';

      await _firestore.collection('requests').add({
        'mess_id': _messId,
        'request_type': 'MEAL_PLAN_CHANGE',
        'breakfast': breakfastVal,
        'lunch': lunchVal,
        'dinner': dinnerVal,
        'reason': reason.trim(),
        'status': 'Pending',
        'created_by': userId,
        'member_id': userId,
        'member_name': fullName,
        'created_at': FirestoreTime.serverTimestamp,
        'start_date': "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        'end_date': "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        'request_date': "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
      });

      hasPendingMealPlanRequest.value = true;

      AppNavigation.showSnackBar(
        'Submitted',
        'Your meal plan request has been submitted to the manager.',
        backgroundColor: Colors.green,
      );

      unawaited(() async {
        try {
          final managersRes = await _firestore
              .collection('mess_members')
              .where('mess_id', isEqualTo: _messId)
              .where('role', whereIn: ['manager', 'admin', 'owner'])
              .get();

          final managers = managersRes.docs
              .where((doc) => doc.data()['user_id'] != userId)
              .map((doc) => {'userId': doc.data()['user_id'] as String})
              .toList();

          if (managers.isNotEmpty) {
            final notificationRepo = NotificationRepositoryImpl();
            final startStr = "${startDate.day}/${startDate.month}/${startDate.year}";
            final endStr = "${endDate.day}/${endDate.month}/${endDate.year}";
            for (var m in managers) {
              await notificationRepo.sendNotification(
                targetUserId: m['userId']!,
                messId: _messId!,
                title: 'New Meal Plan Request 🍳',
                body: '$fullName requested a default meal plan update (B:$breakfastVal, L:$lunchVal, D:$dinnerVal) from $startStr to $endStr.',
                type: 'meal',
                route: '/approvals',
              );
            }
          }
        } catch (ne) {
          debugPrint('[submitMealPlanRequest] Failed to dispatch notifications: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[submitMealPlanRequest] Error: $e');
      AppNavigation.showSnackBar(
        'Error',
        'Failed to submit request: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }
}