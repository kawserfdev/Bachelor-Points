import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../settings_controller.dart';
import 'settings_card_shell.dart';

/// Desktop-only Account settings card.
///
/// Surfaces three account-level actions from the existing [SettingsController]:
///   1. **Default Meal Plan** — shows current portions + "Request Change" button
///      (opens the meal-plan request dialog).
///   2. **Exit Mess** — opens the exit-request dialog (`submitExitRequest`).
///   3. **Log Out** — calls `controller.logout()`.
///
/// It performs **no** business logic — every action delegates to the existing
/// controller methods. This is a pure UI redesign of the mobile
/// `_buildMembershipCard` + `_buildMealPlanRequestCard` + logout action.
class SettingsAccountCard extends StatelessWidget {
  const SettingsAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<SettingsController>();

    return SettingsCardShell(
      icon: Icons.manage_accounts_rounded,
      iconColor: cs.primary,
      title: local.settingsAccountTitle,
      description: local.settingsAccountDesc,
      child: Obx(() {
        final pending = controller.hasPendingMealPlanRequest.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Default Meal Plan section ---
            _SectionLabel(label: local.settingsAccountMealPlan),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.settingsAccountMealPlanDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: _PortionChip(
                              label: local.settingsMealPlanBreakfast,
                              value: controller
                                  .currentDefaultBreakfast.value,
                              icon: Icons.breakfast_dining_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PortionChip(
                              label: local.settingsMealPlanLunch,
                              value:
                                  controller.currentDefaultLunch.value,
                              icon: Icons.lunch_dining_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PortionChip(
                              label: local.settingsMealPlanDinner,
                              value: controller
                                  .currentDefaultDinner.value,
                              icon: Icons.dinner_dining_rounded,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: pending
                          ? null
                          : () => _showMealPlanRequestDialog(
                              context, controller),
                      icon: Icon(pending
                          ? Icons.hourglass_empty_rounded
                          : Icons.edit_calendar_rounded),
                      label: Text(pending
                          ? local.changeRequestPending
                          : local.settingsAccountRequestChange),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- Exit Mess section ---
            _SectionLabel(label: local.messMembership),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.exitMessInfo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: Text(local.settingsAccountExitMess),
                      onPressed: () =>
                          _showExitRequestDialog(context, controller),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- Log Out section ---
            _SectionLabel(label: local.settingsAccountLogout),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => controller.logout(),
                icon: const Icon(Icons.logout_rounded),
                label: Text(local.settingsAccountLogout),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showExitRequestDialog(
      BuildContext context, SettingsController controller) {
    final local = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(local.settingsExitDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.settingsExitDialogInfo,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: local.settingsExitDialogReason,
                  hintText: local.settingsExitDialogHint,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: const Color(0xFF365FF4),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(local.settingsAdminCancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      Get.snackbar(
                        'Validation',
                        local.settingsValidationReasonRequired,
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    controller.submitExitRequest(reason);
                  },
                  child: Text(local.settingsExitDialogSubmit),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showMealPlanRequestDialog(
      BuildContext context, SettingsController controller) {
    final local = AppLocalizations.of(context)!;
    final now = DateTime.now();
    DateTime tempStart = DateTime(now.year, now.month, now.day);
    DateTime tempEnd = DateTime(now.year, now.month, now.day);

    double reqBreakfast = controller.currentDefaultBreakfast.value;
    double reqLunch = controller.currentDefaultLunch.value;
    double reqDinner = controller.currentDefaultDinner.value;
    final reasonController = TextEditingController();
    final options = [0.0, 0.5, 1.0, 1.5, 2.0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(local.settingsMealPlanDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      local.settingsMealPlanDialogInfo,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempStart,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  tempStart = picked;
                                  if (tempEnd.isBefore(tempStart)) {
                                    tempEnd = tempStart;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(local.settingsMealPlanDialogStart,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${tempStart.day}/${tempStart.month}/${tempStart.year}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempEnd.isBefore(tempStart)
                                    ? tempStart
                                    : tempEnd,
                                firstDate: tempStart,
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => tempEnd = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(local.settingsMealPlanDialogEnd,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${tempEnd.day}/${tempEnd.month}/${tempEnd.year}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _DialogPortionSelector(
                      title: local.settingsMealPlanBreakfast,
                      icon: Icons.breakfast_dining,
                      currentValue: reqBreakfast,
                      options: options,
                      onChanged: (val) =>
                          setDialogState(() => reqBreakfast = val),
                    ),
                    const SizedBox(height: 12),
                    _DialogPortionSelector(
                      title: local.settingsMealPlanLunch,
                      icon: Icons.lunch_dining,
                      currentValue: reqLunch,
                      options: options,
                      onChanged: (val) =>
                          setDialogState(() => reqLunch = val),
                    ),
                    const SizedBox(height: 12),
                    _DialogPortionSelector(
                      title: local.settingsMealPlanDinner,
                      icon: Icons.dinner_dining,
                      currentValue: reqDinner,
                      options: options,
                      onChanged: (val) =>
                          setDialogState(() => reqDinner = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: local.settingsMealPlanDialogReason,
                        hintText: local.settingsMealPlanDialogHint,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(local.settingsAdminCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      Get.snackbar(
                        'Validation',
                        local.settingsValidationReasonRequired,
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    controller.submitMealPlanRequest(
                      breakfastVal: reqBreakfast,
                      lunchVal: reqLunch,
                      dinnerVal: reqDinner,
                      reason: reason,
                      startDate: tempStart,
                      endDate: tempEnd,
                    );
                  },
                  child: Text(local.settingsMealPlanDialogSubmit),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Small uppercase section label.
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Compact portion indicator chip for the meal plan display.
class _PortionChip extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _PortionChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: cs.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(1),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Portion selector with ChoiceChips for the meal plan dialog.
class _DialogPortionSelector extends StatelessWidget {
  final String title;
  final IconData icon;
  final double currentValue;
  final List<double> options;
  final ValueChanged<double> onChanged;

  const _DialogPortionSelector({
    required this.title,
    required this.icon,
    required this.currentValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((option) {
            final isSelected = currentValue == option;
            return ChoiceChip(
              label: Text(option.toString()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onChanged(option);
              },
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
