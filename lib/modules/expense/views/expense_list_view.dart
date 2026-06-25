import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../expense_controller.dart';
import '../widgets/expense_summary_card.dart';
import '../../../core/routes/app_routes.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

class ExpenseListView extends GetView<ExpenseController> {
  const ExpenseListView({super.key});

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
        child: Column(
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
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(expense.category).withValues(alpha: 0.2),
                          child: Icon(_getCategoryIcon(expense.category), color: _getCategoryColor(expense.category)),
                        ),
                        title: Text(
                          _getCategoryLabel(context, expense.category).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (expense.description != null && expense.description!.isNotEmpty)
                              Text(expense.description!, style: const TextStyle(fontSize: 12)),
                            Text(
                              "${DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(expense.date)} • ${local.addedByLabel(expense.addedByName ?? local.unknownMember)}",
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addExpense),
        icon: const Icon(Icons.add),
        label: Text(local.addExpenseTitle),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => controller.changeMonth(-1),
        ),
        Obx(() => Text(
              DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(controller.selectedMonth.value),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      case 'bazar': return local.categoryBazar;
      case 'rent': return local.categoryRent;
      case 'wifi': return local.categoryWifi;
      default: return local.categoryOther;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'bazar': return Icons.shopping_cart;
      case 'rent': return Icons.home;
      case 'wifi': return Icons.wifi;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bazar': return Colors.orange;
      case 'rent': return Colors.blue;
      case 'wifi': return Colors.green;
      default: return Colors.grey;
    }
  }
}
