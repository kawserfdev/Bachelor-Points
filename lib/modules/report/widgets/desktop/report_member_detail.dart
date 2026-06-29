import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../report_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only daily activity table for the Report module Member Report tab.
///
/// Renders a [DataTable] of [DailyRecord] entries for the selected member.
/// It is **read-only** over the data layer — it calls the existing
/// [ReportController.getSelectedMemberDailyRecords] method (which only folds
/// the in-memory lists) and performs no Firestore writes or controller
/// mutations.
class ReportMemberDetail extends StatelessWidget {
  const ReportMemberDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.calendar_view_week_rounded,
                    color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  local.reportMemberDetailTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              final controller = Get.find<ReportController>();
              // Re-read selectedMemberId so the table rebuilds on change.
              controller.selectedMemberId.value;

              final records = controller.getSelectedMemberDailyRecords();
              final activeRecords = records
                  .where((r) =>
                      r.meal != null ||
                      r.expenses.isNotEmpty ||
                      r.deposits.isNotEmpty)
                  .toList();

              if (activeRecords.isEmpty) {
                return _buildEmpty(context, local);
              }

              return Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 60,
                      columns: [
                        DataColumn(
                          label: Text(
                            local.reportColDate,
                            style: _headerStyle(theme, cs),
                          ),
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColBreakfast,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColLunch,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColDinner,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColGuest,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColDayExpense,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColDayDeposit,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColDayTotal,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                      ],
                      rows: activeRecords.map((r) {
                        final dateStr =
                            DateFormat('dd MMM', locale).format(r.date);
                        final dayStr = DateFormat('EEE', locale).format(r.date);

                        final breakfast = r.meal?.breakfast ?? 0.0;
                        final lunch = r.meal?.lunch ?? 0.0;
                        final dinner = r.meal?.dinner ?? 0.0;
                        final guest = r.meal?.guestMeals ?? 0.0;
                        final totalExpense =
                            r.expenses.fold(0.0, (s, e) => s + e.amount);
                        final totalDeposit =
                            r.deposits.fold(0.0, (s, d) => s + d.amount);
                        final dayTotal = totalDeposit - totalExpense;

                        return DataRow(cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    dayStr,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateStr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(_mealCell(breakfast, theme)),
                          DataCell(_mealCell(lunch, theme)),
                          DataCell(_mealCell(dinner, theme)),
                          DataCell(_mealCell(guest, theme)),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                totalExpense > 0
                                    ? '৳${totalExpense.toStringAsFixed(0)}'
                                    : '—',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                totalDeposit > 0
                                    ? '৳${totalDeposit.toStringAsFixed(0)}'
                                    : '—',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                dayTotal != 0
                                    ? '৳${dayTotal.toStringAsFixed(0)}'
                                    : '—',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: dayTotal >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Renders a meal count cell — shows "—" when zero.
  Widget _mealCell(double value, ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        value > 0 ? value.toStringAsFixed(1) : '—',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              local.reportNoActivityThisMonth,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle(ThemeData theme, ColorScheme cs) =>
      theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
      ) ??
      const TextStyle(fontWeight: FontWeight.w700);
}
