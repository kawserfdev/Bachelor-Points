import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../balance_controller.dart';
import '../../../home/widgets/dashboard/dashboard_widgets.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only deposit-distribution chart for the Balance/Deposit module.
///
/// Aggregates the controller's already-computed [MemberBalanceModel] list by
/// member and renders a [DonutChart] (reused from the home dashboard). It
/// performs **no** Firestore reads or writes — it only folds the in-memory
/// list of per-member deposit totals.
class DepositCharts extends StatelessWidget {
  const DepositCharts({super.key});

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
                local.depositChartsTitle,
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
              final controller = Get.find<BalanceController>();
              final members = controller.memberBalances;
              final segments = _aggregate(members);

              if (segments.isEmpty) {
                return Center(
                  child: Text(
                    local.depositChartsNoData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final total =
                  members.fold<double>(0, (s, m) => s + m.totalDeposits);

              return DonutChart(
                segments: segments,
                centerLabel: local.depositChartsTotal,
                centerValue: '৳${total.toStringAsFixed(0)}',
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Folds the member-balance list into donut segments grouped by member.
  /// Only members with a positive deposit total are shown.
  List<DonutSegment> _aggregate(List members) {
    final palette = _palette;
    final result = <DonutSegment>[];
    int i = 0;
    for (final m in members) {
      if (m.totalDeposits <= 0) continue;
      result.add(
        DonutSegment(
          label: m.userName,
          value: m.totalDeposits,
          color: palette[i % palette.length],
        ),
      );
      i++;
    }
    return result;
  }

  /// Stable, accessible color palette for member segments.
  static const List<Color> _palette = [
    Color(0xFF1ABC9C), // teal
    Color(0xFF3498DB), // blue
    Color(0xFF9B59B6), // purple
    Color(0xFFE67E22), // orange
    Color(0xFFE74C3C), // red
    Color(0xFFF1C40F), // yellow
    Color(0xFF2ECC71), // green
    Color(0xFF1F8FE6), // sky
  ];
}
