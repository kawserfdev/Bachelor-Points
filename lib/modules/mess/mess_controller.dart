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
    if (userId == null) return;

    try {
      isLoading.value = true;
      // Find the mess the user is a part of
      final response = await _supabase
          .from('mess_members')
          .select('mess_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final messId = response['mess_id'] as String;
        await _loadMessDetails(messId);
        _listenToMembers(messId);
      }
    } catch (e) {
      debugPrint('Error fetching user mess: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMessDetails(String messId) async {
    final response = await _supabase
        .from('messes')
        .select()
        .eq('id', messId)
        .single();
    activeMess.value = MessModel.fromJson(response);
  }

  void _listenToMembers(String messId) {
    _membersSub?.cancel();
    _membersSub = _realtime.streamMembers(messId).listen((data) async {
      final List<MemberModel> updatedMembers = [];
      
      for (var row in data) {
        final userId = row['user_id'] as String;
        
        if (!_profileCache.containsKey(userId)) {
          final profileResponse = await _supabase
              .from('profiles')
              .select('full_name, email')
              .eq('id', userId)
              .maybeSingle();
          if (profileResponse != null) {
            _profileCache[userId] = profileResponse;
          }
        }

        row['profiles'] = _profileCache[userId];
        updatedMembers.add(MemberModel.fromJson(row));
      }
      
      members.value = updatedMembers;
    }, onError: (error) => debugPrint('Error in members stream: $error'));
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
    if (userId == null) return;

    try {
      isLoading.value = true;
      final inviteCode = _generateInviteCode();
      
      // Insert Mess
      final messResponse = await _supabase.from('messes').insert({
        'name': name,
        'invite_code': inviteCode,
        'created_by': userId,
      }).select().single();
      
      final messId = messResponse['id'] as String;

      // Insert Member as Admin
      await _supabase.from('mess_members').insert({
        'mess_id': messId,
        'user_id': userId,
        'role': 'admin',
      });

      await _loadMessDetails(messId);
      _listenToMembers(messId);
      
      Get.back(); // Navigate back to home
      Get.snackbar('Success', 'Mess created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinMess(String inviteCode) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      
      // Find Mess by Invite Code
      final messResponse = await _supabase
          .from('messes')
          .select('id')
          .eq('invite_code', inviteCode.toUpperCase())
          .maybeSingle();
          
      if (messResponse == null) {
        throw 'Invalid invite code';
      }
      
      final messId = messResponse['id'] as String;

      // Check if already a member
      final memberCheck = await _supabase
          .from('mess_members')
          .select('id')
          .eq('mess_id', messId)
          .eq('user_id', userId)
          .maybeSingle();
          
      if (memberCheck != null) {
        throw 'You are already a member of this mess';
      }

      // Insert Member as Viewer
      await _supabase.from('mess_members').insert({
        'mess_id': messId,
        'user_id': userId,
        'role': 'viewer',
      });

      await _loadMessDetails(messId);
      _listenToMembers(messId);
      
      Get.back(); // Navigate back to home
      Get.snackbar('Success', 'Joined mess successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
