import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../mess_controller.dart';
import '../member_controller.dart';
import '../../../data/models/member_model.dart';
import '../../../core/routes/app_routes.dart';

class MembersView extends GetView<MemberController> {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messController = Get.find<MessController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.membersTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (controller.isManager)
            IconButton(
              icon: const Icon(Icons.checklist_rounded),
              tooltip: l10n.approvalsTooltip,
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
                  l10n.noMembersYet,
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
                _buildSectionHeader(context, l10n.roleOwner, Icons.admin_panel_settings_rounded,
                    Colors.amber),
                ...admins.map((m) => _buildMemberCard(context, m)),
                const SizedBox(height: 16),
              ],
              if (managers.isNotEmpty) ...[
                _buildSectionHeader(
                    context, l10n.roleManagers, Icons.manage_accounts_rounded, Colors.indigo),
                ...managers.map((m) => _buildMemberCard(context, m)),
                const SizedBox(height: 16),
              ],
              if (regularMembers.isNotEmpty) ...[
                _buildSectionHeader(
                    context, l10n.roleMembers, Icons.group_rounded, Colors.teal),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canManage = controller.isManager && member.role != 'admin';
    final langCode = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat('MMM dd, yyyy', langCode).format(member.joinedAt);

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
                    member.fullName ?? l10n.unknownMember,
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
                        l10n.joinedLabel(dateStr),
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
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
                  PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        const Icon(Icons.manage_accounts_rounded,
                            size: 18, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(l10n.changeRoleTitle),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.person_remove_rounded,
                            size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.removeMemberTitle),
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
    final l10n = AppLocalizations.of(context)!;
    String newRole = member.role == 'manager' ? 'member' : 'manager';
    final isManager = member.role == 'manager';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.changeRoleTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.changeRoleForLabel(member.fullName ?? member.email ?? ''),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.currentRoleLabel(member.role.capitalizeFirst ?? member.role),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: newRole,
                decoration: InputDecoration(
                  labelText: l10n.newRoleLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  if (isManager)
                    DropdownMenuItem(
                        value: 'member', child: Text(l10n.roleMember)),
                  if (!isManager)
                    DropdownMenuItem(
                        value: 'manager', child: Text(l10n.roleManager)),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => newRole = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                l10n.roleChangeRequestDesc,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                controller.changeRole(member.userId, newRole);
              },
              child: Text(l10n.submitRequest,
                  style: const TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmDialog(BuildContext context, MemberModel member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.removeMemberTitle),
        content: Text(
          l10n.removeMemberConfirm(member.fullName ?? member.email ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.removeMember(member.userId);
            },
            child:
                Text(l10n.submitRequest, style: const TextStyle(color: Colors.red)),
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