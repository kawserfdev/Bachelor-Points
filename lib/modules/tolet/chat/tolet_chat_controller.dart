import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/tolet_chat_model.dart';
import '../../../services/auth_service.dart';

/// Controller for property owner-tenant real-time chat.
class ToletChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxList<ToletMessageModel> messages = <ToletMessageModel>[].obs;
  final RxString currentChatId = ''.obs;
  final RxString propertyId = ''.obs;
  final RxString otherUserId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _messageSubscription;

  String get currentUserId => _authService.currentUser.value?.uid ?? '';

  @override
  void onClose() {
    _messageSubscription?.cancel();
    super.onClose();
  }

  /// Start or load a chat for a property between current user and landlord.
  Future<void> initChat(String propId, String landlordId) async {
    propertyId.value = propId;
    otherUserId.value = landlordId;
    isLoading.value = true;

    try {
      // Find or create a chat thread
      final chatId = await _getOrCreateChatId(propId, landlordId);
      currentChatId.value = chatId;
      _listenToMessages(chatId);
    } catch (e) {
      error.value = e.toString();
      debugPrint('[ToletChatController] initChat error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _getOrCreateChatId(String propId, String landlordId) async {
    final userId = currentUserId;

    // Check for existing chat
    final existingQuery = await _firestore
        .collection('tolet_chats')
        .where('property_id', isEqualTo: propId)
        .where('tenant_id', isEqualTo: userId)
        .where('landlord_id', isEqualTo: landlordId)
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      return existingQuery.docs.first.id;
    }

    // Create a new chat thread
    final docRef = await _firestore.collection('tolet_chats').add({
      'property_id': propId,
      'tenant_id': userId,
      'landlord_id': landlordId,
      'last_message': null,
      'last_message_at': null,
      'created_at': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  void _listenToMessages(String chatId) {
    _messageSubscription?.cancel();
    _messageSubscription = _firestore
        .collection('tolet_messages')
        .where('chat_id', isEqualTo: chatId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs.map((doc) {
        return ToletMessageModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    });
  }

  /// Send a text message.
  Future<bool> sendTextMessage(String text) async {
    if (text.trim().isEmpty || currentChatId.value.isEmpty) return false;

    isSending.value = true;
    try {
      final userId = currentUserId;
      final profileDoc = await _firestore.collection('profiles').doc(userId).get();
      final name = profileDoc.data()?['full_name'] as String? ?? 'User';

      final msgRef = _firestore.collection('tolet_messages').doc();
      await msgRef.set({
        'id': msgRef.id,
        'chat_id': currentChatId.value,
        'sender_id': userId,
        'sender_name': name,
        'text': text.trim(),
        'image_url': null,
        'latitude': null,
        'longitude': null,
        'is_seen': false,
        'is_typing': false,
        'reported_by': null,
        'report_reason': null,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update last message in chat thread
      await _firestore.collection('tolet_chats').doc(currentChatId.value).update({
        'last_message': text.trim(),
        'last_message_at': FieldValue.serverTimestamp(),
      });

      isSending.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSending.value = false;
      debugPrint('[ToletChatController] sendTextMessage error: $e');
      return false;
    }
  }

  /// Mark messages as seen.
  Future<void> markAsSeen() async {
    if (currentChatId.value.isEmpty) return;
    final userId = currentUserId;

    final unseenMessages = await _firestore
        .collection('tolet_messages')
        .where('chat_id', isEqualTo: currentChatId.value)
        .where('is_seen', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unseenMessages.docs) {
      if (doc.data()['sender_id'] != userId) {
        batch.update(doc.reference, {'is_seen': true});
      }
    }
    await batch.commit();
  }

  /// Report a message.
  Future<bool> reportMessage(String messageId, String reason) async {
    try {
      final userId = currentUserId;
      await _firestore.collection('tolet_messages').doc(messageId).update({
        'reported_by': userId,
        'report_reason': reason,
      });
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }
}