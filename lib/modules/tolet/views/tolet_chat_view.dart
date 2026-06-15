import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat/tolet_chat_controller.dart';

/// Real-time chat view between tenant and landlord.
class ToletChatView extends GetView<ToletChatController> {
  const ToletChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), actions: [
        IconButton(icon: const Icon(Icons.report_outlined), tooltip: 'Report', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat reported')))),
      ]),
      body: Column(children: [
        Expanded(child: Obx(() {
          if (controller.messages.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]), const SizedBox(height: 12), Text('No messages yet', style: TextStyle(color: Colors.grey[600]))]));
          return ListView.builder(padding: const EdgeInsets.all(12), itemCount: controller.messages.length, itemBuilder: (context, i) {
            final msg = controller.messages[i];
            final isMe = msg.senderId == 'currentUser'; // Replace with actual
            return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: isMe ? Theme.of(context).colorScheme.primaryContainer : Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: Text(msg.text ?? '', style: TextStyle(color: isMe ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.black87))));
          });
        })),
        const Divider(height: 1),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          IconButton(icon: const Icon(Icons.image), onPressed: () {}),
          IconButton(icon: const Icon(Icons.location_on_outlined), onPressed: () {}),
          Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none))),
          IconButton(icon: const Icon(Icons.send), color: Theme.of(context).colorScheme.primary, onPressed: () {}),
        ])),
      ]),
    );
  }
}