import 'package:get/get.dart';
import '../../../data/models/tolet_chat_model.dart';

/// Controller for property owner-tenant real-time chat.
class ToletChatController extends GetxController {
  final RxList<ToletMessageModel> messages = <ToletMessageModel>[].obs;
  final RxString currentChatId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString error = ''.obs;
  final RxBool isTyping = false.obs;

  /// Start a new chat or load existing.
  void loadChat(String chatId) {
    currentChatId.value = chatId;
    isLoading.value = true;
    // Messages would be loaded from Firestore stream
    isLoading.value = false;
  }

  /// Send a text message.
  Future<bool> sendTextMessage({
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    if (text.trim().isEmpty) return false;
    isSending.value = true;
    try {
      // In production, write to Firestore
      isSending.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSending.value = false;
      return false;
    }
  }

  /// Send an image message.
  Future<bool> sendImageMessage({
    required String imageUrl,
    required String senderId,
    required String senderName,
  }) async {
    isSending.value = true;
    try {
      // In production, write to Firestore
      isSending.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSending.value = false;
      return false;
    }
  }

  /// Send location message.
  Future<bool> sendLocationMessage({
    required double latitude,
    required double longitude,
    required String senderId,
    required String senderName,
  }) async {
    isSending.value = true;
    try {
      // In production, write to Firestore
      isSending.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSending.value = false;
      return false;
    }
  }

  /// Mark messages as seen.
  void markAsSeen() {
    // In production, update Firestore
  }

  /// Set typing indicator.
  void setTyping(bool typing) {
    isTyping.value = typing;
  }

  /// Report a message.
  Future<bool> reportMessage(String messageId, String userId, String reason) async {
    try {
      // In production, update Firestore
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}