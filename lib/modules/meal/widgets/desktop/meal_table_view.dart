import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../meal_controller.dart';

/// Desktop-only table view for the Meal module.
///
/// Renders a [DataTable] listing each meal type (Breakfast, Lunch, Dinner,
/// Guest) with its current portion and inline +/- quick-adjust controls. All
/// reads/writes go through the existing [MealController] reactive state and
/// [MealController.updatePortion] — no business logic is duplicated.
class MealTableView extends StatelessWidget {
  const MealTableView({super.key});

  static const _portionOptions = [0.0, 0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<MealController>();

    final rows = <_MealRowData>[
      _MealRowData(
        label: local.breakfast,
        icon: Icons.breakfast_dining,
        rx: controller.breakfast,
        type: 'breakfast',
      ),
      _MealRowData(
        label: local.lunch,
        icon: Icons.lunch_dining,
        rx: controller.lunch,
        type: 'lunch',
      ),
      _MealRowData(
        label: local.dinner,
        icon: Icons.dinner_dining,
        rx: controller.dinner,
        type: 'dinner',
      ),
      _MealRowData(
        label: local.guestMeals,
        icon: Icons.people_alt_outlined,
        rx: controller.guestMeals,
        type: 'guest',
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
                Icon(Icons.table_restaurant, color: cs.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  local.mealTableTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final canEdit = controller.canEdit;
              return DataTable(
                columnSpacing: 24,
                horizontalMargin: 0,
                headingRowHeight: 44,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 64,
                columns: [
                  DataColumn(
                    label: Text(
                      local.mealTableMeal,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      local.mealTablePortion,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      local.mealTableAction,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: rows
                    .map((r) => _buildRow(context, r, canEdit))
                    .toList(growable: false),
              );
            }),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, _MealRowData row, bool canEdit) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<MealController>();

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(row.icon, size: 20, color: cs.primary),
              const SizedBox(width: 12),
              Text(
                row.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Obx(() => Text(
                row.rx.value.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              )),
        ),
        DataCell(
          Obx(() {
            final current = row.rx.value;
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _portionOptions.map((option) {
                final selected = current == option;
                return ChoiceChip(
                  label: Text(option.toString()),
                  selected: selected,
                  onSelected: canEdit
                      ? (sel) {
                          if (sel) {
                            controller.updatePortion(row.type, option);
                          }
                        }
                      : null,
                  selectedColor: cs.primary,
                  labelStyle: TextStyle(
                    color: selected ? cs.onPrimary : cs.onSurface,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }
}

class _MealRowData {
  final String label;
  final IconData icon;
  final RxDouble rx;
  final String type;

  const _MealRowData({
    required this.label,
    required this.icon,
    required this.rx,
    required this.type,
  });
}
