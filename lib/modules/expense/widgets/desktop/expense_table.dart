import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/expense_model.dart';
import '../../expense_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only expense ledger rendered as a [DataTable].
///
/// The table is **read-only** over the data layer — it receives a pre-filtered
/// list of [ExpenseModel] from the parent view (which applies search + category
/// filters locally). It performs no Firestore writes and calls no controller
/// mutation methods; it only reads [ExpenseController.isLoading] for the
/// loading state.
class ExpenseTable extends StatelessWidget {
  /// Expenses already filtered by the parent (search + category).
  final List<ExpenseModel> expenses;

  const ExpenseTable({super.key, required this.expenses});

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
                Icon(Icons.table_chart_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  local.expenseTableTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final controller = Get.find<ExpenseController>();
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
                    '${expenses.length}',
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
            child: expenses.isEmpty
                ? _buildEmpty(context, local)
                : SingleChildScrollView(
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
                              local.expenseTableDate,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              local.expenseTableCategory,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              local.expenseTableDescription,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              local.expenseTableAddedBy,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.expenseTableAmount,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                        ],
                        rows: expenses.map((e) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat('MMM dd, yyyy', locale)
                                      .format(e.date),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              DataCell(
                                _CategoryChip(category: e.category),
                              ),
                              DataCell(
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 260),
                                  child: Text(
                                    (e.description?.isNotEmpty ?? false)
                                        ? e.description!
                                        : '—',
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.addedByName ?? local.unknownMember,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '৳${e.amount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
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
              Icons.receipt_long_outlined,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              local.expenseTableEmpty,
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

/// Small colored category badge used inside table rows.
class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = _colorFor(category);
    final label = _labelFor(category, local);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(category), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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

  static IconData _iconFor(String category) {
    switch (category) {
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
