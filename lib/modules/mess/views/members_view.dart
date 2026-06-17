import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../mess_controller.dart';
import '../member_controller.dart';
import '../../../data/models/member_model.dart';
import '../../../core/routes/app_routes.dart';

class MembersView extends GetView<MemberController> {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final messController = Get.find<MessController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (controller.isManager)
            IconButton(
              icon: const Icon(Icons.checklist_rounded),
              tooltip: 'Approvals',
              onPressed: () => context.push(AppRoutes.approvals),
            ),
        ],
      ),
      body: Obx(() {
        if (messController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = messController.members;
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No members yet',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        // Group members by role
        final admins = members.where((m) => m.role == 'admin').toList();
        final managers = members.where((m) => m.role == 'manager').toList();
        final regularMembers =
            members.where((m) => m.role == 'member' || m.role == 'viewer').toList();

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (admins.isNotEmpty) ...[
                _buildSectionHeader(context, 'Owner', Icons.admin_panel_settings_rounded,
                    Colors.amber),
                ...admins.map((m) => _buildMemberCard(context, m)),
                const SizedBox(height: 16),
              ],
              if (managers.isNotEmpty) ...[
                _buildSectionHeader(
                    context, 'Managers', Icons.manage_accounts_rounded, Colors.indigo),
                ...managers.map((m) => _buildMemberCard(context, m)),
                const SizedBox(height: 16),
              ],
              if (regularMembers.isNotEmpty) ...[
                _buildSectionHeader(
                    context, 'Members', Icons.group_rounded, Colors.teal),
                ...regularMembers.map((m) => _buildMemberCard(context, m)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MemberModel member) {
    final theme = Theme.of(context);
    final canManage = controller.isManager && member.role != 'admin';
    final dateStr = DateFormat('MMM dd, yyyy').format(member.joinedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _roleColor(member.role).withAlpha(30),
              child: Text(
                (member.fullName ?? member.email ?? '?')
                    .substring(0, 1)
                    .toUpperCase(),
                style: TextStyle(
                  color: _roleColor(member.role),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (member.email != null)
                    Text(
                      member.email!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Joined $dateStr',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Role badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _roleColor(member.role).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _roleColor(member.role),
                ),
              ),
            ),
            // Actions menu (only for non-admin members, by admin/manager)
            if (canManage) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (action) {
                  if (action == 'change_role') {
                    _showRoleChangeDialog(context, member);
                  } else if (action == 'remove') {
                    _showRemoveConfirmDialog(context, member);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        Icon(Icons.manage_accounts_rounded,
                            size: 18, color: Colors.teal),
                        SizedBox(width: 8),
                        Text('Change Role'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove Member'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(BuildContext context, MemberModel member) {
    String newRole = member.role == 'manager' ? 'member' : 'manager';
    final isManager = member.role == 'manager';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change role for ${member.fullName ?? member.email}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Current role: ${member.role.capitalizeFirst}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: newRole,
                decoration: const InputDecoration(
                  labelText: 'New Role',
                  border: OutlineInputBorder(),
                ),
                items: [
                  if (isManager)
                    const DropdownMenuItem(
                        value: 'member', child: Text('Member')),
                  if (!isManager)
                    const DropdownMenuItem(
                        value: 'manager', child: Text('Manager')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => newRole = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                'This will create a role change request for approval.',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                controller.changeRole(member.userId, newRole);
              },
              child: const Text('Submit Request',
                  style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmDialog(BuildContext context, MemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.fullName ?? member.email}?\n\n'
          'This will create a removal request for approval.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.removeMember(member.userId);
            },
            child:
                const Text('Submit Request', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.amber;
      case 'manager':
        return Colors.indigo;
      case 'member':
        return Colors.teal;
      case 'viewer':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}