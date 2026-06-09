import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mess_controller.dart';
import '../member_controller.dart';
import '../../../services/auth_service.dart';

class MemberListView extends StatelessWidget {
  const MemberListView({super.key});

  @override
  Widget build(BuildContext context) {
    final messController = Get.find<MessController>();
    final memberController = Get.find<MemberController>();
    final currentUserId = Get.find<AuthService>().currentUser.value?.uid;

    return Obx(() {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messController.members.length,
        itemBuilder: (context, index) {
          final member = messController.members[index];
          final isMe = member.userId == currentUserId;

          return Card(
            elevation: 0,
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  member.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                member.fullName ?? member.email ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(member.role.toUpperCase()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'YOU',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  // Only show popup menu if the current user is an admin and it's not their own card
                  if (memberController.isAdmin && !isMe)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'remove') {
                          _showRemoveDialog(
                            context,
                            member.id,
                            memberController,
                          );
                        } else {
                          memberController.changeRole(member.id, value);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            if (member.role != 'admin')
                              const PopupMenuItem<String>(
                                value: 'admin',
                                child: Text('Make Admin'),
                              ),
                            if (member.role != 'manager')
                              const PopupMenuItem<String>(
                                value: 'manager',
                                child: Text('Make Manager'),
                              ),
                            if (member.role != 'member')
                              const PopupMenuItem<String>(
                                value: 'member',
                                child: Text('Make Member'),
                              ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(
                              value: 'remove',
                              child: Text(
                                'Remove Member',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showRemoveDialog(
    BuildContext context,
    String memberId,
    MemberController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: const Text(
            'Are you sure you want to remove this member from the mess?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
              onPressed: () {
                controller.removeMember(memberId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
