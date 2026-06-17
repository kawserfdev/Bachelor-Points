import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../request_controller.dart';
import 'package:intl/intl.dart';

class ApprovalView extends GetView<RequestController> {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pending Approvals'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Deposits'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
           // _buildMealsTab(),
            _buildExpensesTab(),
            _buildDepositsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingMeals.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.pendingMeals.isEmpty) {
        return const Center(child: Text('No pending meals.'));
      }

      return ListView.builder(
        itemCount: controller.pendingMeals.length,
        itemBuilder: (context, index) {
          final meal = controller.pendingMeals[index];
          final dateStr = DateFormat('MMM dd, yyyy').format(meal.date);
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${meal.userName ?? 'User'} - Meals'),
              subtitle: Text(
                'Date: $dateStr\nBreakfast: ${meal.breakfast}, Lunch: ${meal.lunch}, Dinner: ${meal.dinner}'
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => controller.updateItemStatus('meal', meal.id, 'Approve'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => controller.updateItemStatus('meal', meal.id, 'Rejected'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildExpensesTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingExpenses.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.pendingExpenses.isEmpty) {
        return const Center(child: Text('No pending expenses.'));
      }

      return ListView.builder(
        itemCount: controller.pendingExpenses.length,
        itemBuilder: (context, index) {
          final expense = controller.pendingExpenses[index];
          final dateStr = DateFormat('MMM dd, yyyy').format(expense.date);
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${expense.addedByName ?? 'User'} - Expense (${expense.category})'),
              subtitle: Text(
                'Date: $dateStr\nAmount: ৳${expense.amount.toStringAsFixed(2)}\nNote: ${expense.description ?? 'None'}'
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => controller.updateItemStatus('expense', expense.id, 'Approve'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => controller.updateItemStatus('expense', expense.id, 'Rejected'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDepositsTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingDeposits.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.pendingDeposits.isEmpty) {
        return const Center(child: Text('No pending deposits.'));
      }

      return ListView.builder(
        itemCount: controller.pendingDeposits.length,
        itemBuilder: (context, index) {
          final deposit = controller.pendingDeposits[index];
          final dateStr = DateFormat('MMM dd, yyyy').format(deposit.date);
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${deposit.userName ?? 'User'} - Deposit'),
              subtitle: Text(
                'Date: $dateStr\nAmount: ৳${deposit.amount.toStringAsFixed(2)}'
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => controller.updateItemStatus('deposit', deposit.id, 'Approve'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => controller.updateItemStatus('deposit', deposit.id, 'Rejected'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
