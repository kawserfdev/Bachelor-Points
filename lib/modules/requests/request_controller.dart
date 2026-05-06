import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../data/models/request_model.dart';
import '../../services/auth_service.dart';
class RequestController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();

  final RxList<RequestModel> myRequests = <RequestModel>[].obs;
  final RxList<RequestModel> pendingRequests = <RequestModel>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    debugPrint('[RequestController] Initialized');

    fetchMyRequests();
    fetchPendingRequests();
  }

  Future<void> fetchMyRequests() async {
    final userId = _authService.currentUser.value?.id;

    debugPrint('[fetchMyRequests] userId: $userId');

    if (userId == null) return;

    try {
      isLoading.value = true;

      final memberResponse = await _supabase
          .from('members')
          .select('mess_id')
          .eq('user_id', userId)
          .single();

      debugPrint('[fetchMyRequests] memberResponse: $memberResponse');

      final messId = memberResponse['mess_id'] as String;

      debugPrint('[fetchMyRequests] messId: $messId');

      final response = await _supabase
          .from('requests')
          .select('*, profiles(full_name)')
          .eq('user_id', userId)
          .eq('mess_id', messId)
          .order('created_at', ascending: false);

      debugPrint(
          '[fetchMyRequests] raw count: ${(response as List).length}');

      final list = response
          .map((e) => RequestModel.fromJson(e))
          .toList();

      myRequests.assignAll(list);

      debugPrint('[fetchMyRequests] loaded: ${myRequests.length}');
    } catch (e) {
      debugPrint('[fetchMyRequests] Error: $e');
      Get.snackbar('Error', 'Failed to load your requests');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingRequests() async {
    final userId = _authService.currentUser.value?.id;

    debugPrint('[fetchPendingRequests] userId: $userId');

    if (userId == null) return;

    try {
      isLoading.value = true;

      final memberResponse = await _supabase
          .from('members')
          .select('mess_id, role')
          .eq('user_id', userId)
          .single();

      debugPrint('[fetchPendingRequests] memberResponse: $memberResponse');

      final messId = memberResponse['mess_id'] as String;
      final role = memberResponse['role'] as String;

      debugPrint('[fetchPendingRequests] role: $role');

      if (role != 'admin' && role != 'manager') {
        debugPrint('[fetchPendingRequests] Access denied (not admin/manager)');
        return;
      }

      final response = await _supabase
          .from('requests')
          .select('*, profiles(full_name)')
          .eq('mess_id', messId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      debugPrint(
          '[fetchPendingRequests] raw count: ${(response as List).length}');

      final list = response
          .map((e) => RequestModel.fromJson(e))
          .toList();

      pendingRequests.assignAll(list);

      debugPrint('[fetchPendingRequests] loaded: ${pendingRequests.length}');
    } catch (e) {
      debugPrint('[fetchPendingRequests] Error: $e');
      Get.snackbar('Error', 'Failed to load pending requests');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRequest(String type, String details) async {
    final userId = _authService.currentUser.value?.id;

    debugPrint('[submitRequest] type: $type | userId: $userId');

    if (userId == null) return;

    try {
      isLoading.value = true;

      final memberResponse = await _supabase
          .from('members')
          .select('mess_id')
          .eq('user_id', userId)
          .single();

      final messId = memberResponse['mess_id'] as String;

      debugPrint('[submitRequest] messId: $messId');

      await _supabase.from('requests').insert({
        'mess_id': messId,
        'user_id': userId,
        'type': type,
        'status': 'pending',
        'details': details,
      });

      debugPrint('[submitRequest] inserted successfully');

      Get.back();
      Get.snackbar('Success', 'Request submitted successfully');

      fetchMyRequests();
    } catch (e) {
      debugPrint('[submitRequest] Error: $e');
      Get.snackbar('Error', 'Failed to submit request');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRequestStatus(
      String requestId, String newStatus) async {
    debugPrint(
        '[updateRequestStatus] id: $requestId | status: $newStatus');

    try {
      isLoading.value = true;

      await _supabase
          .from('requests')
          .update({'status': newStatus})
          .eq('id', requestId);

      debugPrint('[updateRequestStatus] updated successfully');

      Get.snackbar('Success', 'Request $newStatus');

      fetchPendingRequests();
    } catch (e) {
      debugPrint('[updateRequestStatus] Error: $e');
      Get.snackbar('Error', 'Failed to update request');
    } finally {
      isLoading.value = false;
    }
  }
}