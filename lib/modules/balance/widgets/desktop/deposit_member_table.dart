import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/member_balance_model.dart';
import '../../balance_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only member-balance ledger rendered as a [DataTable].
///
/// Combines the "Deposit Table" and "Member Summary" requirements into a
/// single read-only ledger. It receives the controller's already-computed
/// [MemberBalanceModel] list from the parent view and performs **no** business
/// logic — it only reads [BalanceController.isLoading] for the loading state.
class DepositMemberTable extends StatelessWidget {
  /// Member balances already computed by the controller.
  final List<MemberBalanceModel> members;

  const DepositMemberTable({super.key, required this.members});

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
                  local.depositTableTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final controller = Get.find<BalanceController>();
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
                    '${members.length}',
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
            child: members.isEmpty
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
                              local.depositTableMember,
                              style: _headerStyle(theme, cs),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.depositTableMeals,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.depositTableDeposits,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.depositTableMealCost,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.depositTableFixedCost,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.depositTableTotalCost,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                local.depositTableBalance,
                                style: _headerStyle(theme, cs),
                              ),
                            ),
                          ),
                        ],
                        rows: members.map((m) {
                          final getsMoney = m.balance >= 0;
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: cs.primary
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        m.userName.isNotEmpty
                                            ? m.userName
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: cs.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 160),
                                      child: Text(
                                        m.userName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                    '৳${m.totalDeposits.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '৳${m.mealCost.toStringAsFixed(0)}',
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
                                    '৳${m.fixedCost.toStringAsFixed(0)}',
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
                                    '৳${m.totalCost.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _BalanceChip(
                                    balance: m.balance,
                                    getsMoney: getsMoney,
                                    local: local,
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
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              local.depositTableEmpty,
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

/// Colored balance badge used inside table rows.
class _BalanceChip extends StatelessWidget {
  final double balance;
  final bool getsMoney;
  final AppLocalizations local;

  const _BalanceChip({
    required this.balance,
    required this.getsMoney,
    required this.local,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getsMoney ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        getsMoney
            ? local.getsLabel(balance.toStringAsFixed(0))
            : local.owesLabel(balance.abs().toStringAsFixed(0)),
        style: theme.textTheme.labelSmall?.copyWith(
          color: getsMoney ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
