import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../balance_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only payment-summary cards row for the Balance/Deposit module.
///
/// Renders a fluid grid of metric cards (Total Deposits, Total Cost, Net
/// Balance, Members) that reactively read from the existing
/// [BalanceController]. It performs **no** business logic — every value is
/// derived from the controller's already-computed reactive state
/// (`memberBalances`, `globalTotalBazar`, `globalTotalFixed`).
class DepositSummaryCards extends StatelessWidget {
  const DepositSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fluid column count: ~220px per card, clamped to 2–4 columns.
        final columns = (constraints.maxWidth / 220).floor().clamp(2, 4);

        return Obx(() {
          final controller = Get.find<BalanceController>();
          final members = controller.memberBalances;

          final totalDeposits =
              members.fold<double>(0, (s, m) => s + m.totalDeposits);
          final totalCost =
              members.fold<double>(0, (s, m) => s + m.totalCost);
          final netBalance = totalDeposits - totalCost;
          final memberCount = members.length;
          final monthLabel = DateFormat(
            'MMM yyyy',
            Localizations.localeOf(context).languageCode,
          ).format(controller.selectedMonth.value);

          final cards = <_SummaryCardData>[
            _SummaryCardData(
              label: local.depositSummaryTotalDeposits,
              value: '৳${totalDeposits.toStringAsFixed(2)}',
              icon: Icons.savings_rounded,
              accent: cs.primary,
              caption: monthLabel,
            ),
            _SummaryCardData(
              label: local.depositSummaryTotalCost,
              value: '৳${totalCost.toStringAsFixed(2)}',
              icon: Icons.shopping_cart_checkout_rounded,
              accent: Colors.deepOrange,
              caption: monthLabel,
            ),
            _SummaryCardData(
              label: local.depositSummaryNetBalance,
              value: '৳${netBalance.toStringAsFixed(2)}',
              icon: netBalance >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              accent: netBalance >= 0 ? Colors.green : Colors.red,
              caption: netBalance >= 0
                  ? local.getsLabel(netBalance.toStringAsFixed(0))
                  : local.owesLabel(netBalance.abs().toStringAsFixed(0)),
            ),
            _SummaryCardData(
              label: local.depositSummaryMembers,
              value: '$memberCount',
              icon: Icons.group_rounded,
              accent: cs.tertiary,
              caption: local.meals,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  local.depositSummaryTitle,
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
