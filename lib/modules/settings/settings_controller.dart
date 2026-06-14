import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/mess_settings_model.dart';
import '../../data/models/bazar_schedule_model.dart';
import '../../data/models/member_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../shared/helpers/navigation_helper.dart';

class SettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxBool isAdmin = false.obs;

  String? _messId;

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

      if (isAdmin.value) {
        await _loadAllSettingsData();
      } else {
        debugPrint('[checkAdmin] Access denied');

        AppNavigation.showSnackBar(
          'Access Denied',
          'You do not have admin permissions.',
        );
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
}