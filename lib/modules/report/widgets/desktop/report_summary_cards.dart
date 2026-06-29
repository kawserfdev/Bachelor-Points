import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../report_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only KPI summary cards row for the Report module.
///
/// Renders a fluid grid of metric cards (Total Meals, Total Expenses, Meal
/// Rate, Members) that reactively read from the existing [ReportController].
/// It performs **no** business logic — every value is derived from the
/// controller's already-computed reactive state.
class ReportSummaryCards extends StatelessWidget {
  const ReportSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fluid column count: ~220px per card, clamped to 2–4 columns.
        final columns = (constraints.maxWidth / 220).floor().clamp(2, 4);

        return Obx(() {
          final controller = Get.find<ReportController>();
          final summary = controller.summary.value;
          final memberCount = controller.memberSummaries.length;

          final monthLabel = DateFormat(
            'MMM yyyy',
            locale,
          ).format(DateTime(
            controller.selectedYear.value,
            controller.selectedMonth.value,
          ));

          final totalMeals = summary?.totalMeals ?? 0.0;
          final totalExpenses = summary?.totalExpenses ?? 0.0;
          final mealRate = summary?.mealRate ?? 0.0;
          final avgMeals =
              memberCount > 0 ? totalMeals / memberCount : 0.0;

          final cards = <_SummaryCardData>[
            _SummaryCardData(
              label: local.reportTotalMeals,
              value: totalMeals.toStringAsFixed(1),
              icon: Icons.restaurant_rounded,
              accent: DashboardPalette.meals,
              caption: monthLabel,
            ),
            _SummaryCardData(
              label: local.reportTotalExpenses,
              value: '৳${totalExpenses.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_rounded,
              accent: DashboardPalette.bazar,
              caption: monthLabel,
            ),
            _SummaryCardData(
              label: local.reportMealRate,
              value: '৳${mealRate.toStringAsFixed(2)}',
              icon: Icons.trending_up_rounded,
              accent: DashboardPalette.mealRate,
              caption: local.reportSummaryAvgMeals,
            ),
            _SummaryCardData(
              label: local.reportSummaryMembers,
              value: '$memberCount',
              icon: Icons.group_rounded,
              accent: DashboardPalette.members,
              caption: avgMeals.toStringAsFixed(1),
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  local.reportSummaryTitle,
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

/// Semantic accent palette reused from the home dashboard so report cards
/// share the same visual language as the rest of the app.
class DashboardPalette {
  DashboardPalette._();

  static const Color members = Color(0xFF6366F1); // indigo (brand)
  static const Color bazar = Color(0xFFFF6B6B); // coral
  static const Color meals = Color(0xFFFFA726); // amber
  static const Color mealRate = Color(0xFF66BB6A); // green
  static const Color deposit = Color(0xFF42A5F5); // sky
  static const Color fixed = Color(0xFFAB47BC); // orchid
  static const Color balance = Color(0xFF26A69A); // teal
}
