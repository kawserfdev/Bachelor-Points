import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../expense_controller.dart';
import '../widgets/expense_summary_card.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/expense_model.dart';
import '../widgets/desktop/expense_charts.dart';
import '../widgets/desktop/expense_filters.dart';
import '../widgets/desktop/expense_search.dart';
import '../widgets/desktop/expense_summary_cards.dart';
import '../widgets/desktop/expense_table.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Responsive Expense list screen.
///
/// Layout strategy (layout-only redesign — no business logic changes):
/// * **Mobile**  — preserves the original single-column design (month
///   selector, summary card, scrollable expense list, FAB).
/// * **Tablet**  — adaptive 2-column grid of expense cards with the summary
///   card spanning the top.
/// * **Desktop** — SaaS-style dashboard: summary cards row, a toolbar with
///   search + filters, then a row pairing the expense ledger table with a
///   category-breakdown donut chart.
///
/// The controller ([ExpenseController]) is reused as-is. Search and category
/// filtering are performed locally over the controller's already-loaded
/// `expenses` list — no new data-layer code.
class ExpenseListView extends StatefulWidget {
  const ExpenseListView({super.key});

  @override
  State<ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<ExpenseListView> {
  late final ExpenseController controller;

  /// Local-only desktop search query.
  String _searchQuery = '';

  /// Local-only desktop category filter (`'all'` = no filter).
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    controller = Get.find<ExpenseController>();
  }

  /// Filters the controller's expense list by the local search + category
  /// state. Pure derivation — does not mutate the controller.
  List<ExpenseModel> _filteredExpenses() {
    final q = _searchQuery.trim().toLowerCase();
    return controller.expenses.where((e) {
      if (_selectedCategory != 'all' && e.category != _selectedCategory) {
        return false;
      }
      if (q.isEmpty) return true;
      final desc = (e.description ?? '').toLowerCase();
      final name = (e.addedByName ?? '').toLowerCase();
      final cat = e.category.toLowerCase();
      return desc.contains(q) || name.contains(q) || cat.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(local.expensesTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, sizeClass, constraints) {
            return switch (deviceType) {
              DeviceType.mobile => _buildMobileBody(context, local),
              DeviceType.tablet => _buildTabletBody(context, local),
              DeviceType.desktop => _buildDesktopBody(context, local),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addExpense),
        icon: const Icon(Icons.add),
        label: Text(local.addExpenseTitle),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Mobile — preserves the original design exactly.
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildMobileBody(BuildContext context, AppLocalizations local) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildMonthSelector(context),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ExpenseSummaryCard(),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.expenses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(local.noExpensesFound,
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.expenses.length,
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];
                return Card(
                  elevation: 0,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(expense.category)
                          .withValues(alpha: 0.2),
                      child: Icon(_getCategoryIcon(expense.category),
                          color: _getCategoryColor(expense.category)),
                    ),
                    title: Text(
                      _getCategoryLabel(context, expense.category)
                          .toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (expense.description != null &&
                            expense.description!.isNotEmpty)
                          Text(expense.description!,
                              style: const TextStyle(fontSize: 12)),
                        Text(
                          "${DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(expense.date)} • ${local.addedByLabel(expense.addedByName ?? local.unknownMember)}",
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '৳${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Tablet — adaptive grid layout.
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildTabletBody(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthSelector(context),
            const SizedBox(height: 16),
            const ExpenseSummaryCard(),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.expenses.isEmpty) {
                return const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.expenses.isEmpty) {
                return SizedBox(
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(local.noExpensesFound,
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.expenses.length,
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) {
                  final expense = controller.expenses[index];
                  return _TabletExpenseCard(expense: expense);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Desktop — SaaS dashboard: summary cards + toolbar + table/charts.
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildDesktopBody(BuildContext context, AppLocalizations local) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ExpenseSummaryCards(),
            const SizedBox(height: 24),
            // Toolbar: search + filters side by side.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ExpenseSearch(
                    query: _searchQuery,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ExpenseFilters(
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (c) =>
                        setState(() => _selectedCategory = c),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Main row: ledger table (wide) + donut chart (narrow).
            SizedBox(
              height: 460,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.expenses.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      return ExpenseTable(
                        expenses: _filteredExpenses(),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 2,
                    child: ExpenseCharts(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared helpers (preserved from the original view).
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildMonthSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => controller.changeMonth(-1),
        ),
        Obx(() => Text(
              DateFormat('MMMM yyyy',
                      Localizations.localeOf(context).languageCode)
                  .format(controller.selectedMonth.value),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            )),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => controller.changeMonth(1),
        ),
      ],
    );
  }

  String _getCategoryLabel(BuildContext context, String category) {
    final local = AppLocalizations.of(context)!;
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'bazar':
        return Icons.shopping_cart;
      case 'rent':
        return Icons.home;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
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
}

/// Compact expense card used in the tablet grid.
class _TabletExpenseCard extends StatelessWidget {
  final ExpenseModel expense;

  const _TabletExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    Color categoryColor(String category) {
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

    IconData categoryIcon(String category) {
      switch (category) {
        case 'bazar':
          return Icons.shopping_cart;
        case 'rent':
          return Icons.home;
        case 'wifi':
          return Icons.wifi;
        default:
          return Icons.category;
      }
    }

    String categoryLabel(String category) {
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

    final color = categoryColor(expense.category);

    return Container(
      padding: const EdgeInsets.all(14),
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
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon(expense.category), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  categoryLabel(expense.category).toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (expense.description != null &&
                    expense.description!.isNotEmpty)
                  Text(
                    expense.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${DateFormat('MMM dd, yyyy', locale).format(expense.date)} • ${expense.addedByName ?? local.unknownMember}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '৳${expense.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
