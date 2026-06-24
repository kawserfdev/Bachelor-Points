import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../shopping_controller.dart';
import '../../../data/models/shopping_item_model.dart';
import '../../../data/models/shopping_list_model.dart';

class ShoppingListView extends GetView<ShoppingController> {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentTab = 0.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          Obx(() {
            if (!controller.isManager) return const SizedBox.shrink();
            final hasActiveList = controller.activeList.value != null;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasActiveList)
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded),
                    tooltip: 'Complete List',
                    onPressed: () => _showCompleteListConfirmation(context),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'New List',
                  onPressed: () => _showCreateListDialog(context),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeList = controller.activeList.value;
        if (activeList == null) {
          return _buildNoActiveListState(context);
        }

        return Column(
          children: [
            // List Header / Info Card
            _buildListHeader(context, activeList),

            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('Shopping List'),
                      icon: Icon(Icons.shopping_cart_rounded),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('Requests'),
                      icon: Icon(Icons.receipt_long_rounded),
                    ),
                  ],
                  selected: {currentTab.value},
                  onSelectionChanged: (val) => currentTab.value = val.first,
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: Obx(() {
                if (currentTab.value == 0) {
                  return _buildShoppingListTab(context);
                } else {
                  return _buildRequestsTab(context);
                }
              }),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        final hasActiveList = controller.activeList.value != null;
        if (!hasActiveList) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.addShoppingItem),
          label: const Text('Request Item'),
          icon: const Icon(Icons.add_shopping_cart_rounded),
        );
      }),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Empty State: No Active List
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildNoActiveListState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Active Shopping List',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                controller.isManager
                    ? 'Start a new shopping list to begin organizing bazar schedules and requesting items for the mess.'
                    : 'There is currently no active shopping list in this mess. Please request your manager or admin to start a new shopping list.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.isManager) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showCreateListDialog(context),
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: const Text('Create Shopping List'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // List Header / Progress Section
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildListHeader(BuildContext context, ShoppingListModel list) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = controller.totalApprovedCount;
    final purchased = controller.purchasedCount;
    final double progress = total > 0 ? purchased / total : 0.0;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${DateFormat('d MMM yyyy').format(list.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bazar Progress',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$purchased / $total Items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.surfaceVariant,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Shopping List Tab (Approved Items)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildShoppingListTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = controller.approvedItems;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.playlist_add_rounded,
                size: 64,
                color: colorScheme.secondary.withAlpha(120),
              ),
              const SizedBox(height: 16),
              Text(
                'No approved items yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Members can request items, and managers will approve them to show up here.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          key: ValueKey(item.id),
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          color: item.isPurchased
              ? colorScheme.surfaceVariant.withAlpha(80)
              : colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: item.isPurchased
                  ? colorScheme.outlineVariant.withAlpha(80)
                  : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: ListTile(
              leading: Checkbox(
                value: item.isPurchased,
                onChanged: (val) {
                  if (val != null) {
                    controller.togglePurchased(item.id, item.isPurchased);
                  }
                },
              ),
              title: Text(
                item.itemName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                  color: item.isPurchased ? Colors.grey[500] : colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.quantity.isEmpty ? 'Quantity: unspecified' : item.quantity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: item.isPurchased ? Colors.grey[500] : Colors.grey[700],
                    ),
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${item.note}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Req by: ${item.requestedByName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isUrgent
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isUrgent
                        ? Colors.red.shade200
                        : Colors.blue.shade200,
                  ),
                ),
                child: Text(
                  item.priority.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: item.isUrgent
                        ? Colors.red.shade700
                        : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Requests Tab (Pending & Rejected Items)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildRequestsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = controller.visibleRequestItems;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_rounded,
                size: 64,
                color: colorScheme.secondary.withAlpha(120),
              ),
              const SizedBox(height: 16),
              Text(
                'No requests found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isManager
                    ? 'Pending member requests will appear here for your approval.'
                    : 'Requests you submit for bazar items will show up here.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          key: ValueKey(item.id),
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.itemName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(context, item),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty: ${item.quantity.isEmpty ? "unspecified" : item.quantity}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFE69F04)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Priority: ${item.priority.toUpperCase()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: item.isUrgent ? Colors.red.shade700 : Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(item.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Note: ${item.note}',
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Requested by: \n${item.requestedByName}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    if (item.isPending && controller.isManager)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.close, color: Colors.red),
                            tooltip: 'Reject',
                            onPressed: () => controller.rejectItem(item.id),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.check, color: Colors.green),
                            tooltip: 'Approve',
                            onPressed: () => controller.approveItem(item.id),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.green.shade50,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build status chips for requests
  Widget _buildStatusChip(BuildContext context, ShoppingItemModel item) {
    final theme = Theme.of(context);
    Color bgColor;
    Color textColor;
    String label;

    if (item.isApproved) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      label = 'Approved';
    } else if (item.isRejected) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      label = 'Rejected';
    } else {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade700;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Create List Dialog (Manager only)
  // ────────────────────────────────────────────────────────────────────────────
  void _showCreateListDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Shopping List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a title for this shopping list (e.g. "June Weekly Bazar"). '
                'Note: Creating a new list will automatically complete any existing active list.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'List Title *',
                  hintText: 'e.g. Bazar List - June Week 4',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Validation',
                    'Title is required.',
                    backgroundColor: Colors.orangeAccent,
                    colorText: Colors.white,
                  );
                  return;
                }
                Navigator.pop(context);
                controller.createList(titleController.text);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Complete List Dialog (Manager only)
  // ────────────────────────────────────────────────────────────────────────────
  void _showCompleteListConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Shopping List?'),
          content: const Text(
            'Are you sure you want to mark this shopping list as completed? '
            'This action cannot be undone, and you will need to start a new list to request further items.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.pop(context);
                controller.completeList();
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }


}
