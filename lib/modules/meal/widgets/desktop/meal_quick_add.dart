import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../meal_controller.dart';

/// Desktop-only "Quick Add" widget for the Meal module.
///
/// Renders preset portion buttons (Full, Half, Double, Clear) that apply the
/// chosen portion to Breakfast, Lunch, and Dinner simultaneously via the
/// existing [MealController.updatePortion]. No business logic is duplicated.
class MealQuickAdd extends StatelessWidget {
  const MealQuickAdd({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<MealController>();

    final presets = <_QuickAddPreset>[
      _QuickAddPreset(
        label: local.mealQuickAddFull,
        value: 1.0,
        icon: Icons.restaurant,
        color: cs.primary,
      ),
      _QuickAddPreset(
        label: local.mealQuickAddHalf,
        value: 0.5,
        icon: Icons.restaurant_menu,
        color: cs.tertiary,
      ),
      _QuickAddPreset(
        label: local.mealQuickAddDouble,
        value: 2.0,
        icon: Icons.local_dining,
        color: cs.secondary,
      ),
      _QuickAddPreset(
        label: local.mealQuickAddZero,
        value: 0.0,
        icon: Icons.remove_circle_outline,
        color: cs.error,
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: cs.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  local.mealQuickAddTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              local.mealQuickAddDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final canEdit = controller.canEdit;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: presets
                    .map((p) => _PresetChip(
                          preset: p,
                          canEdit: canEdit,
                          onTap: () {
                            controller.updatePortion('breakfast', p.value);
                            controller.updatePortion('lunch', p.value);
                            controller.updatePortion('dinner', p.value);
                          },
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuickAddPreset {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _QuickAddPreset({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _PresetChip extends StatelessWidget {
  final _QuickAddPreset preset;
  final bool canEdit;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.canEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canEdit ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: preset.color.withValues(alpha: canEdit ? 0.1 : 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: preset.color.withValues(alpha: canEdit ? 0.4 : 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                preset.icon,
                size: 18,
                color: canEdit ? preset.color : preset.color.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 8),
              Text(
                preset.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: canEdit
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
