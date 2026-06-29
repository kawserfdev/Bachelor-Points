import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../expense_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only summary cards row for the Expense module.
///
/// Renders a fluid grid of metric cards (Total, Per Person, Entries, Average)
/// that reactively read from the existing [ExpenseController]. It performs
/// **no** business logic — every value is derived from the controller's
/// already-computed reactive state.
class ExpenseSummaryCards extends StatelessWidget {
  const ExpenseSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fluid column count: ~220px per card, clamped to 2–4 columns.
        final columns =
            (constraints.maxWidth / 220).floor().clamp(2, 4);

        return Obx(() {
          final controller = Get.find<ExpenseController>();
          final total = controller.totalMonthlyExpense.value;
          final share = controller.costPerPerson.value;
          final count = controller.expenses.length;
          final avg = count > 0 ? total / count : 0.0;
          final monthLabel = DateFormat(
            'MMM yyyy',
            Localizations.localeOf(context).languageCode,
          ).format(controller.selectedMonth.value);

          final cards = <_SummaryCardData>[
            _SummaryCardData(
              label: local.expenseSummaryTotal,
              value: '৳${total.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet_rounded,
              accent: cs.primary,
              caption: monthLabel,
            ),
            _SummaryCardData(
              label: local.expenseSummaryShare,
              value: '৳${share.toStringAsFixed(2)}',
              icon: Icons.group_rounded,
              accent: cs.tertiary,
              caption: local.yourEstimatedShare,
            ),
            _SummaryCardData(
              label: local.expenseSummaryCount,
              value: '$count',
              icon: Icons.receipt_long_rounded,
              accent: cs.secondary,
              caption: monthLabel,
            ),
            _SummaryCardData(
              label: local.expenseSummaryAvg,
              value: '৳${avg.toStringAsFixed(2)}',
              icon: Icons.trending_up_rounded,
              accent: Colors.deepOrange,
              caption: local.expenseSummaryCount,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  local.expenseSummaryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) =>
                    _SummaryCard(data: cards[index]),
              ),
            ],
          );
        });
      },
    );
  }
}

/// Immutable data carrier for a single summary card.
class _SummaryCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String caption;

  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.caption,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data.caption,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
