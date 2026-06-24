import 'package:bachelorpoints/core/theme/app_theme.dart';
import 'package:bachelorpoints/data/models/tolet_chat_model.dart';
import 'package:bachelorpoints/modules/tolet/chat/tolet_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ToletChatView extends StatefulWidget {
  const ToletChatView({super.key});

  @override
  State<ToletChatView> createState() => _ToletChatViewState();
}

class _ToletChatViewState extends State<ToletChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ToletChatController controller;
  late final String propertyId;
  late final String landlordId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ToletChatController>();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    final success = await controller.sendTextMessage(text);
    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = GoRouterState.of(context).uri.queryParameters;
    propertyId = params['propertyId'] ?? '';
    landlordId = params['landlordId'] ?? '';

    // Init chat once if not already initialised
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentChatId.value.isEmpty) {
        controller.initChat(propertyId, landlordId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report',
            onPressed: () {
              // TODO: implement report
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final messages = controller.messages;

      if (messages.isNotEmpty) {
        controller.markAsSeen();
        _scrollToBottom();
      }

      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Start the conversation',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isMe = msg.senderId == controller.currentUserId;
          return _MessageBubble(
            message: msg,
            isMe: isMe,
          );
        },
      );
    });
  }

  Widget _buildInputRow() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              if (controller.isSending.value) {
                return const SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.send_rounded),
                color: AppTheme.primary,
                onPressed: _handleSend,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ToletMessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name for others
          if (!isMe && message.senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                message.senderName!,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primary : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                  ),
                  child: _buildContent(isMe),
                ),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
          // Time + seen indicator
          Padding(
            padding: EdgeInsets.only(
              top: 3,
              left: isMe ? 0 : 8,
              right: isMe ? 8 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                if (isMe && message.isSeen == true) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMe) {
    final textColor = isMe ? Colors.white : Colors.black87;

    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              message.imageUrl!,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          if (message.text != null && message.text!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message.text!,
              style: TextStyle(color: textColor, fontSize: 14.5),
            ),
          ],
        ],
      );
    }

    return Text(
      message.text ?? '',
      style: TextStyle(color: textColor, fontSize: 14.5),
    );
  }
}