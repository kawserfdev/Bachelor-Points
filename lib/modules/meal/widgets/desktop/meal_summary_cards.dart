import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../meal_controller.dart';

/// Desktop-only summary cards for the Meal module.
///
/// Renders a responsive row of metric cards (Breakfast, Lunch, Dinner, Guest,
/// Total) plus an edit-status badge. All values are read reactively from the
/// existing [MealController] — no business logic is duplicated or modified.
class MealSummaryCards extends StatelessWidget {
  const MealSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Obx(() {
      final controller = Get.find<MealController>();
      final b = controller.breakfast.value;
      final l = controller.lunch.value;
      final d = controller.dinner.value;
      final g = controller.guestMeals.value;
      final total = controller.totalDailyMeals;
      final canEdit = controller.canEdit;

      final cards = <_SummaryCardData>[
        _SummaryCardData(
          label: local.mealSummaryBreakfast,
          value: b,
          icon: Icons.breakfast_dining,
          color: cs.primary,
        ),
        _SummaryCardData(
          label: local.mealSummaryLunch,
          value: l,
          icon: Icons.lunch_dining,
          color: cs.tertiary,
        ),
        _SummaryCardData(
          label: local.mealSummaryDinner,
          value: d,
          icon: Icons.dinner_dining,
          color: cs.secondary,
        ),
        _SummaryCardData(
          label: local.mealSummaryGuest,
          value: g,
          icon: Icons.people_alt_outlined,
          color: cs.error,
        ),
        _SummaryCardData(
          label: local.mealSummaryTotal,
          value: total,
          icon: Icons.local_dining,
          color: cs.primary,
          emphasize: true,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                local.mealSummaryTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _StatusBadge(canEdit: canEdit),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Fluid column count based on available width.
              final count = (constraints.maxWidth / 220).floor().clamp(2, 5);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) =>
                    _SummaryCard(data: cards[index]),
              );
            },
          ),
        ],
      );
    });
  }
}

class _SummaryCardData {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final bool emphasize;

  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.emphasize = false,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: data.emphasize ? 4 : 1,
      shadowColor: data.color.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: data.emphasize
              ? LinearGradient(
                  colors: [
                    data.color,
                    data.color.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  data.icon,
                  size: 22,
                  color: data.emphasize
                      ? cs.onPrimary.withValues(alpha: 0.9)
                      : data.color,
                ),
                if (data.emphasize)
                  Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: cs.onPrimary.withValues(alpha: 0.7),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              data.value.toStringAsFixed(1),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: data.emphasize ? cs.onPrimary : cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: data.emphasize
                    ? cs.onPrimary.withValues(alpha: 0.85)
                    : cs.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool canEdit;

  const _StatusBadge({required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final color = canEdit ? Colors.green : Colors.orangeAccent;
    final icon = canEdit ? Icons.check_circle : Icons.lock_clock;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            canEdit ? local.mealSummaryStatusEditable : local.mealSummaryStatusLocked,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
