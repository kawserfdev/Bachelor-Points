import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/expense_model.dart';
import '../../expense_controller.dart';
import '../../../home/widgets/dashboard/dashboard_widgets.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only category-breakdown chart for the Expense module.
///
/// Aggregates the controller's already-loaded [ExpenseModel] list by category
/// and renders a [DonutChart] (reused from the home dashboard). It performs
/// **no** Firestore reads or writes — it only folds the in-memory list.
class ExpenseCharts extends StatelessWidget {
  const ExpenseCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.pie_chart_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                local.expenseChartsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final controller = Get.find<ExpenseController>();
              final expenses = controller.expenses;
              final segments = _aggregate(expenses, local);

              if (segments.isEmpty) {
                return Center(
                  child: Text(
                    local.expenseChartsNoData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final total =
                  expenses.fold<double>(0, (s, e) => s + e.amount);

              return DonutChart(
                segments: segments,
                centerLabel: local.expenseChartsTitle,
                centerValue: '৳${total.toStringAsFixed(0)}',
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Folds the expense list into donut segments grouped by category.
  List<DonutSegment> _aggregate(
      List<ExpenseModel> expenses, AppLocalizations local) {
    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    if (totals.isEmpty) return const [];

    // Stable ordering: bazar, rent, wifi, then others alphabetically.
    const order = ['bazar', 'rent', 'wifi'];
    final keys = totals.keys.toList()
      ..sort((a, b) {
        final ai = order.indexOf(a);
        final bi = order.indexOf(b);
        if (ai != -1 && bi != -1) return ai.compareTo(bi);
        if (ai != -1) return -1;
        if (bi != -1) return 1;
        return a.compareTo(b);
      });

    return keys.map((k) {
      return DonutSegment(
        label: _labelFor(k, local),
        value: totals[k]!,
        color: _colorFor(k),
      );
    }).toList();
  }

  static Color _colorFor(String category) {
    switch (category) {
      case 'bazar':
        return Colors.orange;
      case 'rent':
        return Colors.blue;
      case 'wifi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String _labelFor(String category, AppLocalizations local) {
    switch (category) {
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
}
