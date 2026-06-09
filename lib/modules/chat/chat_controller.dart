import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/message_model.dart';
import '../../services/auth_service.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    debugPrint('[ChatController] Initialized');
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userId = _authService.currentUser.value?.uid;
    debugPrint('[initializeChat] userId: $userId');

    if (userId == null) {
      debugPrint('[initializeChat] No user found');
      return;
    }

    try {
      debugPrint('[initializeChat] Fetching member + profile info');

      final memberData = await _firestore
          .collection('mess_members')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberData.docs.isNotEmpty) {
        _messId = memberData.docs.first.data()['mess_id'] as String;

        final profileDoc = await _firestore.collection('profiles').doc(userId).get();
        _userName = profileDoc.data()?['full_name'] as String? ?? 'Unknown';

        debugPrint('[initializeChat] messId: $_messId');
        debugPrint('[initializeChat] userName: $_userName');

        _subscribeToMessages(_messId!);
      } else {
        debugPrint('[initializeChat] User not in any mess');
        Get.snackbar('Error', 'You are not in a mess.');
      }
    } catch (e) {
      debugPrint('[initializeChat] Error: $e');
    } finally {
      isLoading.value = false;
      debugPrint('[initializeChat] Loading finished');
    }
  }

  void _subscribeToMessages(String messId) {
    debugPrint('[subscribeToMessages] messId: $messId');

    _messageSubscription?.cancel();

    _messageSubscription = _firestore
        .collection('messages')
        .where('mess_id', isEqualTo: messId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      debugPrint('[messages stream] received: ${snapshot.docs.length} messages');

      messages.assignAll(
        snapshot.docs.map((doc) => MessageModel.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>})).toList(),
      );

      _scrollToBottom();
    }, onError: (error) {
      debugPrint('[messages stream] Error: $error');
    });
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();

    debugPrint('[sendMessage] text: $text');
    debugPrint('[sendMessage] messId: $_messId');

    if (text.isEmpty) {
      debugPrint('[sendMessage] Empty message, skipping');
      return;
    }

    if (_messId == null) {
      debugPrint('[sendMessage] messId is null');
      return;
    }

    final userId = _authService.currentUser.value?.uid;

    if (userId == null) {
      debugPrint('[sendMessage] userId is null');
      return;
    }

    textController.clear(); // optimistic UI
    debugPrint('[sendMessage] Text cleared (optimistic)');

    try {
      debugPrint('[sendMessage] Sending message to Firestore');

      await _firestore.collection('messages').add({
        'mess_id': _messId,
        'user_id': userId,
        'sender_name': _userName,
        'message': text,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('[sendMessage] Message sent successfully');
    } catch (e) {
      debugPrint('[sendMessage] Error: $e');

      Get.snackbar('Error', 'Failed to send message');

      textController.text = text; // restore
      debugPrint('[sendMessage] Text restored after failure');
    }
  }

  void _scrollToBottom() {
    debugPrint('[scrollToBottom] Triggered');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        debugPrint('[scrollToBottom] Scrolling...');

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        debugPrint('[scrollToBottom] No scroll clients');
      }
    });
  }

  bool isMyMessage(String messageUserId) {
    final currentUserId = _authService.currentUser.value?.uid;
    final isMine = currentUserId == messageUserId;

    debugPrint('[isMyMessage] currentUser: $currentUserId, '
        'messageUser: $messageUserId → $isMine');

    return isMine;
  }

  @override
  void onClose() {
    debugPrint('[ChatController] onClose called');

    _messageSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();

    super.onClose();
  }
}