import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../modules/mess/mess_controller.dart';
import '../../data/models/user_profile_detail_model.dart';

/// Controller for the detailed user profile page.
///
/// Subscribes to the Firestore `profiles/{uid}` document snapshot so any
/// change (e.g. from the edit profile page) is reflected immediately.
/// Also exposes mess membership info via [MessController].
class UserProfileDetailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Observable state ──
  final Rx<UserProfileDetail?> profile = Rx<UserProfileDetail?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  String get _uid => _authService.currentUser.value?.uid ?? '';
  String get _email => _authService.currentUser.value?.email ?? '';

  // ── Mess info (read from MessController) ──
  String get messName {
    try {
      return Get.find<MessController>().activeMess.value?.name ?? '';
    } catch (_) {
      return '';
    }
  }

  String get userRole {
    try {
      final mc = Get.find<MessController>();
      final member = mc.members
          .cast<dynamic>()
          .firstWhere((m) => m.userId == _uid, orElse: () => null);
      if (member == null) return '';
      final role = member.role as String;
      return role.isNotEmpty
          ? role[0].toUpperCase() + role.substring(1)
          : '';
    } catch (_) {
      return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('[UserProfileDetailController] onInit uid=$_uid');
    if (_uid.isNotEmpty) {
      _subscribeToProfile();
    } else {
      isLoading.value = false;
      errorMessage.value = 'User not logged in.';
    }
  }

  /// Subscribe to the Firestore profile document so updates (e.g. from the
  /// edit profile page) reflect here without a manual refresh.
  void _subscribeToProfile() {
    isLoading.value = true;
    _profileSub = _firestore
        .collection('profiles')
        .doc(_uid)
        .snapshots()
        .listen((snapshot) {
      debugPrint('[UserProfileDetailController] profile snapshot received: '
          'exists=${snapshot.exists}');
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Merge auth email into Firestore data if not stored there.
        if (!data.containsKey('email') || (data['email'] as String?)!.isEmpty) {
          data['email'] = _email;
        }
        profile.value = UserProfileDetail.fromFirestore(_uid, data);
      } else {
        profile.value = UserProfileDetail.empty(_uid)
            ..toString(); // keep observable non-null
        profile.value = UserProfileDetail(
          uid: _uid,
          fullName: _authService.currentUser.value?.displayName ?? '',
          email: _email,
          phoneNumber: '',
          address: '',
          avatarUrl: '',
          nidNumber: '',
          bio: '',
        );
      }
      isLoading.value = false;
      errorMessage.value = '';
    }, onError: (Object e) {
      debugPrint('[UserProfileDetailController] error: $e');
      isLoading.value = false;
      errorMessage.value = e.toString();
    });
  }

  /// Force a manual refresh (pull-to-refresh).
  @override
  Future<void> refresh() async {
    debugPrint('[UserProfileDetailController] refresh()');
    isLoading.value = true;
    await _profileSub?.cancel();
    _subscribeToProfile();
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }
}
