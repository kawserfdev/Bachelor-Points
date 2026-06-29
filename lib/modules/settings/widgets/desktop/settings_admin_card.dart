import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../settings_controller.dart';
import 'settings_card_shell.dart';

/// Desktop-only Administration settings card (managers only).
///
/// Surfaces two admin-only controls from the existing [SettingsController]:
///   1. **Meal Cutoff Time** — shows the current cutoff and opens a time
///      picker that calls `controller.updateCutoffTime(formatted)`.
///   2. **Bazar Schedule** — lists assigned duties with a delete action
///      (`controller.deleteBazarDuty`) and an "Assign New Duty" button that
///      opens the assign-duty dialog (`controller.assignBazarDuty`).
///
/// It performs **no** business logic — every action delegates to the existing
/// controller methods. This is a pure UI redesign of the mobile
/// `_buildGeneralSettings` + `_buildBazarScheduleCard` + `_showAssignDutyDialog`.
class SettingsAdminCard extends StatelessWidget {
  const SettingsAdminCard({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<SettingsController>();

    return SettingsCardShell(
      icon: Icons.admin_panel_settings_outlined,
      iconColor: Colors.deepOrange,
      title: local.settingsAdminTitle,
      description: local.settingsAdminDesc,
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Meal Cutoff Time section ---
            _SectionLabel(label: local.settingsAdminCutoff),
            const SizedBox(height: 4),
            Text(
              local.settingsAdminCutoffDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _buildCutoffTile(context, controller, cs),
            const SizedBox(height: 24),

            // --- Bazar Schedule section ---
            _SectionLabel(label: local.settingsAdminBazar),
            const SizedBox(height: 4),
            Text(
              local.settingsAdminBazarDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: () => _showAssignDutyDialog(context, controller),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                label: Text(local.settingsAdminAssignDuty),
              ),
            ),
            const SizedBox(height: 12),
            _buildScheduleList(context, controller, cs),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Meal Cutoff Time
  // ---------------------------------------------------------------------------
  Widget _buildCutoffTile(
    BuildContext context,
    SettingsController controller,
    ColorScheme cs,
  ) {
    final local = AppLocalizations.of(context)!;
    final current = controller.messSettings.value?.mealCutoffTime;

    return InkWell(
      onTap: () => _pickCutoffTime(context, controller),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Colors.deepOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.mealCutoffTime,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current ?? local.notSet,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCutoffTime(
    BuildContext context,
    SettingsController controller,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );
    if (time == null) return;
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    controller.updateCutoffTime(formatted);
  }

  // ---------------------------------------------------------------------------
  // Bazar Schedule list
  // ---------------------------------------------------------------------------
  Widget _buildScheduleList(
    BuildContext context,
    SettingsController controller,
    ColorScheme cs,
  ) {
    final local = AppLocalizations.of(context)!;
    final schedules = controller.schedules;

    if (schedules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 32,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              local.settingsAdminNoSchedules,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final schedule in schedules) ...[
          _ScheduleRow(
            name: schedule.userName ?? 'Unknown User',
            dateLabel: _formatDate(schedule.date),
            onDelete: () => controller.deleteBazarDuty(schedule.id),
          ),
          if (schedule != schedules.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  // ---------------------------------------------------------------------------
  // Assign Duty dialog (ported from mobile _showAssignDutyDialog)
  // ---------------------------------------------------------------------------
  void _showAssignDutyDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final local = AppLocalizations.of(context)!;
    String? selectedUserId;
    DateTime? selectedDate = DateTime.now();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(local.settingsAdminAssignDuty),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: local.settingsAdminSelectMember,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: selectedUserId,
                      items: controller.members.map((m) {
                        return DropdownMenuItem<String>(
                          value: m.userId,
                          child: Text(m.fullName ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => selectedUserId = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 60)),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined,
                            size: 18),
                        label: Text(
                          selectedDate == null
                              ? local.settingsAdminSelectDate
                              : _formatDate(selectedDate!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(local.settingsAdminCancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedUserId != null && selectedDate != null) {
                      Navigator.of(dialogContext).pop();
                      controller.assignBazarDuty(
                        selectedUserId!,
                        selectedDate!,
                      );
                    } else {
                      Get.snackbar(
                        'Validation',
                        local.settingsValidationMemberDate,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text(local.settingsAdminAssign),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.name,
    required this.dateLabel,
    required this.onDelete,
  });

  final String name;
  final String dateLabel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.deepOrange.withValues(alpha: 0.14),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 18,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
