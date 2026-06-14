import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/mess_model.dart';
import '../../../data/models/member_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../../../shared/helpers/navigation_helper.dart';
import 'dart:math';
import 'dart:async';

class MessController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final userId = _authService.currentUser.value?.uid;
    debugPrint('[_fetchUserMess] userId: $userId');

    if (userId == null) {
      debugPrint('[_fetchUserMess] No user found');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[_fetchUserMess] Fetching mess for user...');

      final snapshot = await _firestore
          .collection('mess_members')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final messId = snapshot.docs.first.data()['mess_id'] as String;
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

    final doc = await _firestore
        .collection('messes')
        .doc(messId)
        .get();

    if (doc.exists) {
      final rawData = doc.data()!;
      final data = _convertFirestoreTimestamps(rawData);
      activeMess.value = MessModel.fromJson({'id': doc.id, ...data});
    }
  }

  /// Converts Firestore [Timestamp] values in a map to ISO 8601 strings
  /// so that freezed-generated [fromJson] (which expects String for dates)
  /// can parse them without a type-cast error.
  Map<String, dynamic> _convertFirestoreTimestamps(Map<String, dynamic> raw) {
    final converted = Map<String, dynamic>.from(raw);
    for (final key in ['created_at', 'updated_at']) {
      final value = converted[key];
      if (value is Timestamp) {
        converted[key] = value.toDate().toIso8601String();
      }
    }
    return converted;
  }

  void _listenToMembers(String messId) {
    debugPrint('[_listenToMembers] Listening for messId: $messId');

    _membersSub?.cancel();

    _membersSub = _realtime.streamMembers(messId).listen((data) async {
      final List<MemberModel> updatedMembers = [];

      for (var row in data) {
        final userId = row['user_id'] as String;

        if (!_profileCache.containsKey(userId)) {
          final profileDoc = await _firestore
              .collection('profiles')
              .doc(userId)
              .get();

          if (profileDoc.exists) {
            _profileCache[userId] = {'id': profileDoc.id, ...profileDoc.data() as Map<String, dynamic>};
          }
        }

        row['profiles'] = _profileCache[userId];
        updatedMembers.add(MemberModel.fromJson(row));
      }

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
   
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final inviteCode = _generateInviteCode();

      final docRef = await _firestore.collection('messes').add({
        'name': name,
        'invite_code': inviteCode,
        'created_by': userId,
        'created_at': FirestoreTime.serverTimestamp,
      });

      final messId = docRef.id;

      await _firestore.collection('mess_members').add({
        'mess_id': messId,
        'user_id': userId,
        'role': 'admin',
        'joined_at': FirestoreTime.serverTimestamp,
      });

      await _loadMessDetails(messId);
      _listenToMembers(messId);

      AppNavigation.back();
      AppNavigation.showSnackBar('Success', 'Mess created successfully!');
    } catch (e) {
      debugPrint('[createMess] Error: $e');
      AppNavigation.showSnackBar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinMess(String inviteCode) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('messes')
          .where('invite_code', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw 'Invalid invite code';
      }

      final messId = snapshot.docs.first.id;

      final memberCheck = await _firestore
          .collection('mess_members')
          .where('mess_id', isEqualTo: messId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberCheck.docs.isNotEmpty) {
        throw 'Already a member';
      }

      await _firestore.collection('mess_members').add({
        'mess_id': messId,
        'user_id': userId,
        'role': 'viewer',
        'joined_at': FirestoreTime.serverTimestamp,
      });

      await _loadMessDetails(messId);
      _listenToMembers(messId);

      AppNavigation.back();
      AppNavigation.showSnackBar('Success', 'Joined mess successfully!');
    } catch (e) {
      debugPrint('[joinMess] Error: $e');
      AppNavigation.showSnackBar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
