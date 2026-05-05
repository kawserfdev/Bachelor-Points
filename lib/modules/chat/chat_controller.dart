import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/message_model.dart';
import '../../services/auth_service.dart';

class ChatController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();

  final textController = TextEditingController();
  final scrollController = ScrollController();
  
  final messages = <MessageModel>[].obs;
  final isLoading = true.obs;
  
  StreamSubscription? _messageSubscription;
  String? _messId;
  String? _userName;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      // 1. Fetch user's mess_id and profile name
      final memberData = await _supabase
          .from('members')
          .select('mess_id, profiles(full_name)')
          .eq('user_id', userId)
          .single();
          
      _messId = memberData['mess_id'] as String?;
      _userName = memberData['profiles']?['full_name'] as String? ?? 'Unknown';

      if (_messId != null) {
        _subscribeToMessages(_messId!);
      } else {
        Get.snackbar('Error', 'You are not in a mess.');
      }
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToMessages(String messId) {
    _messageSubscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('mess_id', messId)
        .order('created_at', ascending: true) // oldest to newest
        .listen((List<Map<String, dynamic>> data) {
      messages.assignAll(data.map((json) => MessageModel.fromJson(json)).toList());
      _scrollToBottom();
    }, onError: (error) {
      debugPrint('Error listening to messages stream: $error');
    });
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || _messId == null) return;
    
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    textController.clear(); // Optimistic clear

    try {
      await _supabase.from('messages').insert({
        'mess_id': _messId,
        'user_id': userId,
        'sender_name': _userName,
        'message': text,
      });
      // Stream will automatically add the new message to the list
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
      textController.text = text; // restore on failure
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool isMyMessage(String messageUserId) {
    return _authService.currentUser.value?.id == messageUserId;
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
