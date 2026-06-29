import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../meal_controller.dart';

/// Desktop-only calendar widget for the Meal module.
///
/// Renders a compact month calendar. Tapping a date calls the existing
/// [MealController.changeDate], which triggers the controller's reactive
/// `ever(selectedDate, ...)` listener to reload that date's meal entry — no
/// business logic is duplicated.
class MealCalendar extends StatelessWidget {
  const MealCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<MealController>();

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
                Icon(Icons.calendar_month, color: cs.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  local.mealCalendarTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              local.mealCalendarHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final selected = controller.selectedDate.value;
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              return CalendarDatePicker(
                initialDate: selected,
                firstDate: today.subtract(const Duration(days: 30)),
                lastDate: today.add(const Duration(days: 30)),
                onDateChanged: (date) => controller.changeDate(date),
                selectableDayPredicate: (date) {
                  // Respect the controller's edit-window (±30 days).
                  final d = DateTime(date.year, date.month, date.day);
                  return !d.isBefore(today.subtract(const Duration(days: 30))) &&
                      !d.isAfter(today.add(const Duration(days: 30)));
                },
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final selected = controller.selectedDate.value;
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final isSelectedToday =
                  selected.year == today.year &&
                  selected.month == today.month &&
                  selected.day == today.day;

              if (!isSelectedToday) {
                return const SizedBox.shrink();
              }
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    local.mealCalendarToday,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
