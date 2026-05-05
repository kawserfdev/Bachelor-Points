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
    fetchMyRequests();
    // In a real app, you might only fetch pending requests if the user is an admin
    fetchPendingRequests();
  }

  Future<void> fetchMyRequests() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      // Get the mess_id for this user from the members table
      final memberResponse = await _supabase
          .from('members')
          .select('mess_id')
          .eq('user_id', userId)
          .single();
      
      final messId = memberResponse['mess_id'] as String;

      final response = await _supabase
          .from('requests')
          .select('*, profiles(full_name)')
          .eq('user_id', userId)
          .eq('mess_id', messId)
          .order('created_at', ascending: false);

      myRequests.assignAll((response as List).map((e) => RequestModel.fromJson(e)).toList());
    } catch (e) {
      debugPrint('Error fetching my requests: $e');
      Get.snackbar('Error', 'Failed to load your requests');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingRequests() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      // Get the mess_id for this user from the members table
      final memberResponse = await _supabase
          .from('members')
          .select('mess_id, role')
          .eq('user_id', userId)
          .single();
      
      final messId = memberResponse['mess_id'] as String;
      final role = memberResponse['role'] as String;

      // Only admins should see pending requests for the mess
      if (role != 'admin' && role != 'manager') {
         isLoading.value = false;
         return;
      }

      final response = await _supabase
          .from('requests')
          .select('*, profiles(full_name)')
          .eq('mess_id', messId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      pendingRequests.assignAll((response as List).map((e) => RequestModel.fromJson(e)).toList());
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      Get.snackbar('Error', 'Failed to load pending requests');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRequest(String type, String details) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final memberResponse = await _supabase
          .from('members')
          .select('mess_id')
          .eq('user_id', userId)
          .single();
      
      final messId = memberResponse['mess_id'] as String;

      await _supabase.from('requests').insert({
        'mess_id': messId,
        'user_id': userId,
        'type': type,
        'status': 'pending',
        'details': details,
      });

      Get.back();
      Get.snackbar('Success', 'Request submitted successfully');
      fetchMyRequests();
    } catch (e) {
      debugPrint('Error submitting request: $e');
      Get.snackbar('Error', 'Failed to submit request');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      isLoading.value = true;
      await _supabase
          .from('requests')
          .update({'status': newStatus})
          .eq('id', requestId);
      
      Get.snackbar('Success', 'Request $newStatus');
      fetchPendingRequests();
    } catch (e) {
      debugPrint('Error updating request: $e');
      Get.snackbar('Error', 'Failed to update request');
    } finally {
      isLoading.value = false;
    }
  }
}
