import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/mess_model.dart';
import '../../../data/models/member_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import 'dart:math';
import 'dart:async';

class MessController extends GetxController {
  final _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();
  final RealtimeService _realtime = Get.find<RealtimeService>();

  final Rx<MessModel?> activeMess = Rx<MessModel?>(null);
  final RxList<MemberModel> members = <MemberModel>[].obs;
  final RxBool isLoading = false.obs;
  
  final Map<String, Map<String, dynamic>> _profileCache = {};
  StreamSubscription? _membersSub;

  @override
  void onInit() {
    super.onInit();
    _fetchUserMess();
  }

Future<void> _fetchUserMess() async {
  final userId = _authService.currentUser.value?.id;
  debugPrint('[_fetchUserMess] userId: $userId');

  if (userId == null) {
    debugPrint('[_fetchUserMess] No user found');
    return;
  }

  try {
    isLoading.value = true;
    debugPrint('[_fetchUserMess] Fetching mess for user...');

    final response = await _supabase
        .from('mess_members')
        .select('mess_id')
        .eq('user_id', userId)
        .maybeSingle();

    debugPrint('[_fetchUserMess] Response: $response');

    if (response != null) {
      final messId = response['mess_id'] as String;
      debugPrint('[_fetchUserMess] Found messId: $messId');

      await _loadMessDetails(messId);
      _listenToMembers(messId);
    } else {
      debugPrint('[_fetchUserMess] No mess found for user');
    }
  } catch (e) {
    debugPrint('[_fetchUserMess] Error: $e');
  } finally {
    isLoading.value = false;
  }
}
Future<void> _loadMessDetails(String messId) async {
  debugPrint('[_loadMessDetails] messId: $messId');

  final response = await _supabase
      .from('messes')
      .select()
      .eq('id', messId)
      .single();

  debugPrint('[_loadMessDetails] response: $response');

  activeMess.value = MessModel.fromJson(response);
}
void _listenToMembers(String messId) {
  debugPrint('[_listenToMembers] Listening for messId: $messId');

  _membersSub?.cancel();

  _membersSub = _realtime.streamMembers(messId).listen((data) async {
    debugPrint('[_listenToMembers] Raw stream data: $data');

    final List<MemberModel> updatedMembers = [];

    for (var row in data) {
      final userId = row['user_id'] as String;
      debugPrint('[_listenToMembers] Processing userId: $userId');

      if (!_profileCache.containsKey(userId)) {
        debugPrint('[_listenToMembers] Fetching profile for: $userId');

        final profileResponse = await _supabase
            .from('profiles')
            .select('full_name, email')
            .eq('id', userId)
            .maybeSingle();

        debugPrint('[_listenToMembers] Profile response: $profileResponse');

        if (profileResponse != null) {
          _profileCache[userId] = profileResponse;
        }
      } else {
        debugPrint('[_listenToMembers] Using cached profile for: $userId');
      }

      row['profiles'] = _profileCache[userId];
      updatedMembers.add(MemberModel.fromJson(row));
    }

    debugPrint('[_listenToMembers] Total members: ${updatedMembers.length}');
    members.value = updatedMembers;
  }, onError: (error) {
    debugPrint('[_listenToMembers] Stream Error: $error');
  });
}
  
  Map<String, dynamic>? getProfileCached(String userId) => _profileCache[userId];

  @override
  void onClose() {
    _membersSub?.cancel();
    super.onClose();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

 Future<void> createMess(String name) async {
  final userId = _authService.currentUser.value?.id;
  debugPrint('[createMess] userId: $userId, name: $name');

  if (userId == null) return;

  try {
    isLoading.value = true;

    final inviteCode = _generateInviteCode();
    debugPrint('[createMess] Generated inviteCode: $inviteCode');

    final messResponse = await _supabase.from('messes').insert({
      'name': name,
      'invite_code': inviteCode,
      'created_by': userId,
    }).select().single();

    debugPrint('[createMess] messResponse: $messResponse');

    final messId = messResponse['id'] as String;

    await _supabase.from('mess_members').insert({
      'mess_id': messId,
      'user_id': userId,
      'role': 'admin',
    });

    debugPrint('[createMess] Member inserted as admin');

    await _loadMessDetails(messId);
    _listenToMembers(messId);

    Get.back();
    Get.snackbar('Success', 'Mess created successfully!');
  } catch (e) {
    debugPrint('[createMess] Error: $e');
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}
  Future<void> joinMess(String inviteCode) async {
  final userId = _authService.currentUser.value?.id;
  debugPrint('[joinMess] userId: $userId, inviteCode: $inviteCode');

  if (userId == null) return;

  try {
    isLoading.value = true;

    final messResponse = await _supabase
        .from('messes')
        .select('id')
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();

    debugPrint('[joinMess] messResponse: $messResponse');

    if (messResponse == null) {
      throw 'Invalid invite code';
    }

    final messId = messResponse['id'] as String;

    final memberCheck = await _supabase
        .from('mess_members')
        .select('id')
        .eq('mess_id', messId)
        .eq('user_id', userId)
        .maybeSingle();

    debugPrint('[joinMess] memberCheck: $memberCheck');

    if (memberCheck != null) {
      throw 'Already a member';
    }

    await _supabase.from('mess_members').insert({
      'mess_id': messId,
      'user_id': userId,
      'role': 'viewer',
    });

    debugPrint('[joinMess] Member inserted successfully');

    await _loadMessDetails(messId);
    _listenToMembers(messId);

    Get.back();
    Get.snackbar('Success', 'Joined mess successfully!');
  } catch (e) {
    debugPrint('[joinMess] Error: $e');
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}
}
