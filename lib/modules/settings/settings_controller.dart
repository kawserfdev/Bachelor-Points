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
  
  // Settings
  final Rx<MessSettingsModel?> messSettings = Rx<MessSettingsModel?>(null);
  
  // Role Management
  final RxList<MemberModel> members = <MemberModel>[].obs;
  
  // Bazar Schedule
  final RxList<BazarScheduleModel> schedules = <BazarScheduleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkAdminAndLoadData();
  }

  Future<void> _checkAdminAndLoadData() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final memberResponse = await _supabase
          .from('members')
          .select('mess_id, role')
          .eq('user_id', userId)
          .single();
          
      _messId = memberResponse['mess_id'] as String;
      final role = memberResponse['role'] as String;
      
      isAdmin.value = (role == 'admin' || role == 'manager');

      if (isAdmin.value) {
        await _loadAllSettingsData();
      } else {
        Get.snackbar('Access Denied', 'You do not have admin permissions.');
      }
    } catch (e) {
      debugPrint("Error checking admin status: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllSettingsData() async {
    if (_messId == null) return;

    try {
      // 1. Fetch settings
      final settingsRes = await _supabase
          .from('mess_settings')
          .select()
          .eq('mess_id', _messId!)
          .maybeSingle();

      if (settingsRes != null) {
        messSettings.value = MessSettingsModel.fromJson(settingsRes);
      } else {
        messSettings.value = MessSettingsModel(messId: _messId!, mealCutoffTime: '22:00');
      }

      // 2. Fetch members
      final membersRes = await _supabase
          .from('members')
          .select('*, profiles(full_name, email)')
          .eq('mess_id', _messId!);
      members.assignAll((membersRes as List).map((e) => MemberModel.fromJson(e)).toList());

      // 3. Fetch bazar schedules
      await fetchSchedules();

    } catch (e) {
      debugPrint("Error loading settings data: $e");
    }
  }

  Future<void> fetchSchedules() async {
    if (_messId == null) return;
    try {
      final scheduleRes = await _supabase
          .from('bazar_schedules')
          .select('*, profiles(full_name)')
          .eq('mess_id', _messId!)
          .order('date', ascending: true);
          
      schedules.assignAll((scheduleRes as List).map((e) => BazarScheduleModel.fromJson(e)).toList());
    } catch (e) {
      debugPrint("Error fetching schedules: $e");
    }
  }

  // --- Actions ---

  Future<void> updateCutoffTime(String newTime) async {
    if (_messId == null) return;
    try {
      isLoading.value = true;
      await _supabase.from('mess_settings').upsert({
        'mess_id': _messId,
        'meal_cutoff_time': newTime,
      });
      messSettings.value = MessSettingsModel(messId: _messId!, mealCutoffTime: newTime);
      Get.snackbar('Success', 'Cutoff time updated to $newTime');
    } catch (e) {
      debugPrint("Error updating cutoff time: $e");
      Get.snackbar('Error', 'Failed to update time');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeMemberRole(String memberId, String newRole) async {
    try {
      isLoading.value = true;
      await _supabase
          .from('members')
          .update({'role': newRole})
          .eq('id', memberId);
          
      // Update local list
      final index = members.indexWhere((m) => m.id == memberId);
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
      }
      Get.snackbar('Success', 'Role updated to $newRole');
    } catch (e) {
      debugPrint("Error updating role: $e");
      Get.snackbar('Error', 'Failed to update role');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignBazarDuty(String userId, DateTime date) async {
    if (_messId == null) return;
    try {
      isLoading.value = true;
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      await _supabase.from('bazar_schedules').insert({
        'mess_id': _messId,
        'user_id': userId,
        'date': formattedDate,
      });
      
      await fetchSchedules();
      Get.snackbar('Success', 'Bazar duty assigned');
    } catch (e) {
      debugPrint("Error assigning bazar: $e");
      Get.snackbar('Error', 'Failed to assign bazar duty');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBazarDuty(String scheduleId) async {
    try {
      isLoading.value = true;
      await _supabase.from('bazar_schedules').delete().eq('id', scheduleId);
      schedules.removeWhere((s) => s.id == scheduleId);
      Get.snackbar('Success', 'Duty removed');
    } catch (e) {
      debugPrint("Error deleting duty: $e");
      Get.snackbar('Error', 'Failed to remove duty');
    } finally {
      isLoading.value = false;
    }
  }
}
