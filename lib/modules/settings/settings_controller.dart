import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../data/models/mess_settings_model.dart';
import '../../data/models/bazar_schedule_model.dart';
import '../../data/models/member_model.dart';
import '../../services/auth_service.dart';
class SettingsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
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
    final userId = _authService.currentUser.value?.id;

    debugPrint('[checkAdmin] userId: $userId');

    if (userId == null) return;

    try {
      isLoading.value = true;

      final memberResponse = await _supabase
          .from('members')
          .select('mess_id, role')
          .eq('user_id', userId)
          .maybeSingle();

      debugPrint('[checkAdmin] response: $memberResponse');

      if (memberResponse == null) {
        debugPrint('[checkAdmin] No membership found');
        return;
      }

      _messId = memberResponse['mess_id'] as String;
      final role = memberResponse['role'] as String;

      debugPrint('[checkAdmin] messId: $_messId | role: $role');

      isAdmin.value = (role == 'admin' || role == 'manager');

      debugPrint('[checkAdmin] isAdmin: ${isAdmin.value}');

      if (isAdmin.value) {
        await _loadAllSettingsData();
      } else {
        debugPrint('[checkAdmin] Access denied');

        Get.snackbar(
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
      final settingsRes = await _supabase
          .from('mess_settings')
          .select()
          .eq('mess_id', _messId!)
          .maybeSingle();

      debugPrint('[loadSettings] settings: $settingsRes');

      if (settingsRes != null) {
        messSettings.value =
            MessSettingsModel.fromJson(settingsRes);
      } else {
        messSettings.value = MessSettingsModel(
          messId: _messId!,
          mealCutoffTime: '22:00',
        );
      }

      // MEMBERS
      final membersRes = await _supabase
          .from('members')
          .select('*, profiles(full_name, email)')
          .eq('mess_id', _messId!);

      debugPrint(
          '[loadSettings] members count: ${(membersRes as List).length}');

      members.assignAll(
        membersRes
            .map((e) => MemberModel.fromJson(e))
            .toList(),
      );

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

      final scheduleRes = await _supabase
          .from('bazar_schedules')
          .select('*, profiles(full_name)')
          .eq('mess_id', _messId!)
          .order('date', ascending: true);

      debugPrint(
          '[fetchSchedules] count: ${(scheduleRes as List).length}');

      schedules.assignAll(
        scheduleRes
            .map((e) => BazarScheduleModel.fromJson(e))
            .toList(),
      );
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

      await _supabase.from('mess_settings').upsert({
        'mess_id': _messId,
        'meal_cutoff_time': newTime,
      });

      messSettings.value = MessSettingsModel(
        messId: _messId!,
        mealCutoffTime: newTime,
      );

      debugPrint('[updateCutoff] success');

      Get.snackbar('Success', 'Cutoff time updated to $newTime');
    } catch (e) {
      debugPrint('[updateCutoff] Error: $e');

      Get.snackbar('Error', 'Failed to update time');
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

      await _supabase
          .from('members')
          .update({'role': newRole})
          .eq('id', memberId);

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

      Get.snackbar('Success', 'Role updated to $newRole');
    } catch (e) {
      debugPrint('[changeRole] Error: $e');

      Get.snackbar('Error', 'Failed to update role');
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

      await _supabase.from('bazar_schedules').insert({
        'mess_id': _messId,
        'user_id': userId,
        'date': formattedDate,
      });

      await fetchSchedules();

      Get.snackbar('Success', 'Bazar duty assigned');
    } catch (e) {
      debugPrint('[assignBazar] Error: $e');

      Get.snackbar('Error', 'Failed to assign bazar duty');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBazarDuty(String scheduleId) async {
    debugPrint('[deleteBazar] scheduleId: $scheduleId');

    try {
      isLoading.value = true;

      await _supabase
          .from('bazar_schedules')
          .delete()
          .eq('id', scheduleId);

      schedules
          .removeWhere((s) => s.id == scheduleId);

      debugPrint('[deleteBazar] deleted successfully');

      Get.snackbar('Success', 'Duty removed');
    } catch (e) {
      debugPrint('[deleteBazar] Error: $e');

      Get.snackbar('Error', 'Failed to remove duty');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    debugPrint('[logout] Triggered');
    try {
      isLoading.value = true;
      await _authService.signOut();
      debugPrint('[logout] Sign out successful');
    } catch (e) {
      debugPrint('[logout] Error: $e');
      Get.snackbar('Error', 'Failed to logout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}