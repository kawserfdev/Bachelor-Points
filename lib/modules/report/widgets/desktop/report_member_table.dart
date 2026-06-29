import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/report_summary_model.dart';
import '../../report_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only member summary table for the Report module Overview tab.
///
/// Renders a [DataTable] of [MemberSummaryModel] entries. It is **read-only**
/// over the data layer — it receives the controller's already-computed
/// `memberSummaries` list and performs no Firestore writes or controller
/// mutations. It only reads [ReportController.isLoading] for the loading state.
class ReportMemberTable extends StatelessWidget {
  const ReportMemberTable({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                Icon(Icons.table_chart_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  local.reportTableTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final controller = Get.find<ReportController>();
                  if (controller.isLoading.value) {
                    return SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    );
                  }
                  return Text(
                    '${controller.memberSummaries.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              final controller = Get.find<ReportController>();
              final members = controller.memberSummaries;

              if (members.isEmpty) {
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
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 64,
                      columns: [
                        DataColumn(
                          label: Text(
                            local.reportColMember,
                            style: _headerStyle(theme, cs),
                          ),
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColMeals,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColCost,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColDeposits,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              local.reportColBalance,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          numeric: true,
                        ),
                      ],
                      rows: members.map((m) {
                        final isNeg = m.finalBalance < 0;
                        return DataRow(cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      cs.primaryContainer.withValues(alpha: 0.5),
                                  child: Text(
                                    _initials(m.userName),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  m.userName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                m.totalMeals.toStringAsFixed(1),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '৳${m.totalCost.toStringAsFixed(0)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '৳${m.totalDeposits.toStringAsFixed(0)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isNeg
                                      ? Colors.red.withValues(alpha: 0.12)
                                      : Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '৳${m.finalBalance.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isNeg
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
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
              Icons.people_outline_rounded,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              local.reportTableEmpty,
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

  /// Returns up to 2 uppercase initials for a name.
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }
}
