import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/report_summary_model.dart';
import '../../../home/widgets/dashboard/dashboard_widgets.dart';
import '../../report_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only analytics panel for the Report module.
///
/// Renders two side-by-side charts derived purely from the controller's
/// already-loaded reactive state:
/// * **Donut chart** — expense breakdown (bazar vs fixed costs).
/// * **Bar chart** — per-member meal counts.
///
/// It performs **no** Firestore reads or writes and calls no controller
/// mutation methods — it only folds the in-memory lists.
class ReportCharts extends StatelessWidget {
  const ReportCharts({super.key});

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
              Icon(Icons.insights_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                local.reportChartsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final controller = Get.find<ReportController>();
              final expenses = controller.monthExpenses;
              final members = controller.memberSummaries;

              final donutSegments = _aggregateExpenses(expenses, local);
              final barData = _aggregateMemberMeals(members);

              final hasDonut = donutSegments.isNotEmpty;
              final hasBars = barData.isNotEmpty;

              if (!hasDonut && !hasBars) {
                return Center(
                  child: Text(
                    local.reportChartNoData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasDonut)
                    Expanded(
                      flex: 2,
                      child: DonutChart(
                        segments: donutSegments,
                        centerLabel: local.reportChartExpenseBreakdown,
                        centerValue:
                            '৳${expenses.fold<double>(0, (s, e) => s + e.amount).toStringAsFixed(0)}',
                      ),
                    ),
                  if (hasDonut && hasBars) const SizedBox(width: 16),
                  if (hasBars)
                    Expanded(
                      flex: 3,
                      child: MiniBarChart(
                        title: local.reportChartMemberMeals,
                        bars: barData,
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Folds the expense list into donut segments: bazar vs fixed costs.
  List<DonutSegment> _aggregateExpenses(
    List<dynamic> expenses,
    AppLocalizations local,
  ) {
    double bazarTotal = 0;
    double fixedTotal = 0;
    for (final e in expenses) {
      if (e.category == 'bazar') {
        bazarTotal += e.amount as double;
      } else {
        fixedTotal += e.amount as double;
      }
    }
    if (bazarTotal == 0 && fixedTotal == 0) return const [];

    return [
      DonutSegment(
        label: local.reportChartBazar,
        value: bazarTotal,
        color: DashboardPalette.bazar,
      ),
      DonutSegment(
        label: local.reportChartFixed,
        value: fixedTotal,
        color: DashboardPalette.fixed,
      ),
    ];
  }

  /// Folds the member summaries into bar data sorted by meal count desc.
  List<BarData> _aggregateMemberMeals(List<MemberSummaryModel> members) {
    if (members.isEmpty) return const [];
    final sorted = List<MemberSummaryModel>.from(members)
      ..sort((a, b) => b.totalMeals.compareTo(a.totalMeals));

    // Limit to top 8 members so the bar chart stays readable.
    final top = sorted.length > 8 ? sorted.sublist(0, 8) : sorted;

    return top.map((m) {
      final initials = _initials(m.userName);
      return BarData(
        label: initials,
        value: m.totalMeals,
        color: DashboardPalette.meals,
      );
    }).toList();
  }

  /// Returns up to 2 uppercase initials for a name (e.g. "Rahim Uddin" → "RU").
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }
}
