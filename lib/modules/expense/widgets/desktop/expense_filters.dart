import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../expense_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only filter bar for the Expense module.
///
/// Renders two control groups:
/// * **Month navigation** — calls the existing [ExpenseController.changeMonth]
///   method (no new business logic).
/// * **Category filter** — purely local UI state; the selected category is
///   reported back to the parent via [onCategoryChanged] so the parent can
///   filter its in-memory list.
class ExpenseFilters extends StatelessWidget {
  /// Currently selected category filter (`'all'` means no filter).
  final String selectedCategory;

  /// Called when the user picks a different category.
  final ValueChanged<String> onCategoryChanged;

  const ExpenseFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  /// The category options shown in the filter row.
  static const List<String> categories = ['all', 'bazar', 'rent', 'wifi', 'other'];

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                local.expenseFiltersTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Month navigation — reuses the existing controller method.
          _MonthNav(locale: locale),
          const SizedBox(height: 12),
          Text(
            local.expenseFiltersCategory,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((c) {
              final selected = c == selectedCategory;
              return ChoiceChip(
                label: Text(_labelFor(c, local)),
                selected: selected,
                onSelected: (_) => onCategoryChanged(c),
                avatar: Icon(_iconFor(c), size: 16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _labelFor(String category, AppLocalizations local) {
    switch (category) {
      case 'all':
        return local.expenseFiltersAll;
      case 'bazar':
        return local.categoryBazar;
      case 'rent':
        return local.categoryRent;
      case 'wifi':
        return local.categoryWifi;
      default:
        return local.categoryOther;
    }
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'all':
        return Icons.list_rounded;
      case 'bazar':
        return Icons.shopping_cart_rounded;
      case 'rent':
        return Icons.home_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

/// Compact month stepper that delegates to [ExpenseController.changeMonth].
class _MonthNav extends StatelessWidget {
  final String locale;

  const _MonthNav({required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<ExpenseController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
            onPressed: () => controller.changeMonth(-1),
          ),
          Obx(() => Text(
                DateFormat('MMMM yyyy', locale)
                    .format(controller.selectedMonth.value),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              )),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
            onPressed: () => controller.changeMonth(1),
          ),
        ],
      ),
    );
  }
}
