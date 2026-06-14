import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';
import '../mess/mess_controller.dart';
import '../mess/widgets/member_list_view.dart';
import '../../../core/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final messController = Get.find<MessController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
      ),
      body: Obx(() {
        if (messController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final mess = messController.activeMess.value;

        if (mess == null) {
          // No Mess State
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'You are not in a Mess',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new mess or join an existing one using an invite code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.createMess),
                    icon: const Icon(Icons.add),
                    label: const Text('CREATE MESS'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.joinMess),
                    icon: const Icon(Icons.login),
                    label: const Text('JOIN MESS'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Active Mess State
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mess.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Invite Code: ${mess.inviteCode}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: mess.inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invite code copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: MemberListView(),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (messController.activeMess.value != null && !messController.isLoading.value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'balance_btn',
                onPressed: () => context.push(AppRoutes.balanceSummary),
                icon: const Icon(Icons.account_balance),
                label: const Text('Balances'),
                backgroundColor: Colors.teal.shade200,
                foregroundColor: Colors.teal.shade900,
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: 'expense_btn',
                onPressed: () => context.push(AppRoutes.expenses),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Expenses'),
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: 'meal_btn',
                onPressed: () => context.push(AppRoutes.mealEntry),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Add Meal'),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? All local data will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
