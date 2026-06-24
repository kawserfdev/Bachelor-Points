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

        return Column(
          children: [
            // List Header / Info Card (only in Shopping List tab)
            Obx(() {
              final activeList = controller.activeList.value;
              if (activeList != null && currentTab.value == 0) {
                return _buildListHeader(context, activeList);
              }
              return const SizedBox.shrink();
            }),

            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<int>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.blue;
                      }
                      return Colors.white;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.black87;
                    }),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.blue),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
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
                    ButtonSegment<int>(
                      value: 2,
                      label: Text('History'),
                      icon: Icon(Icons.history_rounded),
                    ),
                  ],
                  selected: {currentTab.value},
                  onSelectionChanged: (val) {
                    currentTab.value = val.first;
                  },
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: Obx(() {
                if (currentTab.value == 0) {
                  final activeList = controller.activeList.value;
                  if (activeList == null) {
                    return _buildNoActiveListState(context);
                  }
                  return _buildShoppingListTab(context);
                } else if (currentTab.value == 1) {
                  final activeList = controller.activeList.value;
                  if (activeList == null) {
                    return const Center(
                      child: Text('No active shopping list to view requests.'),
                    );
                  }
                  return _buildRequestsTab(context);
                } else {
                  return _buildHistoryTab(context);
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
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
                      if (list.startDate != null && list.endDate != null) ...[
                        Text(
                          'Period: ${DateFormat('d MMM yyyy').format(list.startDate!)} - ${DateFormat('d MMM yyyy').format(list.endDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                  decoration: item.isPurchased
                      ? TextDecoration.lineThrough
                      : null,
                  color: item.isPurchased
                      ? Colors.grey[500]
                      : colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.quantity.isEmpty
                        ? 'Quantity: unspecified'
                        : item.quantity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: item.isPurchased
                          ? Colors.grey[500]
                          : Colors.grey[700],
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFE69F04),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Priority: ${item.priority.toUpperCase()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: item.isUrgent
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(item.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
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
  // Create Shopping List Dialog (Manager only)
  // ────────────────────────────────────────────────────────────────────────────
  void _showCreateListDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTimeRange? selectedDateRange;
    String selectedStatus = 'active';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return AlertDialog(
              title: const Text('Create Shopping List'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter a title, select a date range, and determine status for this list.',
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
                    const SizedBox(height: 16),

                    // Date Range Selector
                    Text(
                      'Bazar Date Range *',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: now.add(const Duration(days: 365)),
                          initialDateRange:
                              selectedDateRange ??
                              DateTimeRange(
                                start: now,
                                end: now.add(const Duration(days: 6)),
                              ),
                        );
                        if (range != null) {
                          setState(() {
                            selectedDateRange = range;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedDateRange == null
                                    ? 'Select Date Range'
                                    : '${DateFormat('d MMM yyyy').format(selectedDateRange!.start)} - ${DateFormat('d MMM yyyy').format(selectedDateRange!.end)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selectedDateRange == null
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status selector
                    Text(
                      'Initial Status',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'active',
                            label: Text('Active'),
                            icon: Icon(Icons.play_circle_outline_rounded),
                          ),
                          ButtonSegment<String>(
                            value: 'inactive',
                            label: Text('Inactive'),
                            icon: Icon(Icons.pause_circle_outline_rounded),
                          ),
                        ],
                        selected: {selectedStatus},
                        onSelectionChanged: (val) {
                          setState(() {
                            selectedStatus = val.first;
                          });
                        },
                      ),
                    ),
                    if (selectedStatus == 'active') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Note: Activating this list will set the current active list to inactive.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      Get.snackbar(
                        'Validation',
                        'Title is required.',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (selectedDateRange == null) {
                      Get.snackbar(
                        'Validation',
                        'Date range is required.',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    controller.createList(
                      title: title,
                      startDate: selectedDateRange!.start,
                      endDate: selectedDateRange!.end,
                      status: selectedStatus,
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
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

  Widget _buildHistoryTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyLists = controller.historyLists;

    return Obx(() {
      if (historyLists.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 64,
                  color: colorScheme.secondary.withAlpha(120),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Shopping History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Shopping lists created in the last 2 months will appear here.',
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
        itemCount: historyLists.length,
        itemBuilder: (context, index) {
          final list = historyLists[index];
          final hasDateRange = list.startDate != null && list.endDate != null;

          return Card(
            key: ValueKey(list.id),
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: list.isActive
                    ? colorScheme.primary.withAlpha(120)
                    : colorScheme.outlineVariant,
                width: list.isActive ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              onTap: () => _showHistoryItemsBottomSheet(context, list),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      list.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(context, list),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  if (hasDateRange) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${DateFormat('d MMM yyyy').format(list.startDate!)} - ${DateFormat('d MMM yyyy').format(list.endDate!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Created: ${DateFormat('d MMM yyyy, h:mm a').format(list.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: controller.isManager
                  ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (val) {
                        if (val == 'toggle_status') {
                          _showToggleStatusConfirmation(context, list);
                        } else if (val == 'delete') {
                          _showDeleteConfirmation(context, list);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'toggle_status',
                          child: Row(
                            children: [
                              Icon(
                                list.isActive
                                    ? Icons.pause_circle_outline_rounded
                                    : Icons.play_circle_outline_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                list.isActive ? 'Mark Inactive' : 'Mark Active',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      );
    });
  }

  Widget _buildStatusBadge(BuildContext context, ShoppingListModel list) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = list.isActive;

    final bgColor = isActive
        ? colorScheme.primaryContainer
        : Colors.grey.shade100;
    final textColor = isActive
        ? colorScheme.onPrimaryContainer
        : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showToggleStatusConfirmation(
    BuildContext context,
    ShoppingListModel list,
  ) {
    final newStatus = list.isActive ? 'inactive' : 'active';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            list.isActive
                ? 'Deactivate Shopping List?'
                : 'Activate Shopping List?',
          ),
          content: Text(
            list.isActive
                ? 'Are you sure you want to mark this shopping list as inactive? Members will no longer be able to request items under it.'
                : 'Are you sure you want to activate this shopping list? Doing so will automatically deactivate any other active list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.updateListStatus(list.id, newStatus);
              },
              child: Text(list.isActive ? 'Deactivate' : 'Activate'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ShoppingListModel list) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Shopping List?'),
          content: const Text(
            'Are you sure you want to delete this shopping list? '
            'This will permanently delete the list and all its associated items. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                controller.deleteList(list.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryItemsBottomSheet(
    BuildContext context,
    ShoppingListModel list,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Bottom Sheet Handle Bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (list.startDate != null && list.endDate != null)
                        Text(
                          'Period: ${DateFormat('d MMM yyyy').format(list.startDate!)} - ${DateFormat('d MMM yyyy').format(list.endDate!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        'Created on: ${DateFormat('d MMM yyyy').format(list.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: FutureBuilder<List<ShoppingItemModel>>(
                    future: controller.fetchItemsForList(list.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading items: ${snapshot.error}'),
                        );
                      }
                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No items found in this list.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                item.itemName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: item.isPurchased
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.isPurchased ? Colors.grey : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.quantity.isEmpty
                                        ? 'Quantity: unspecified'
                                        : item.quantity,
                                  ),
                                  if (item.note != null &&
                                      item.note!.isNotEmpty)
                                    Text(
                                      'Note: ${item.note}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                  Text(
                                    'Requested by: ${item.requestedByName}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.isApproved
                                          ? Colors.green.shade50
                                          : item.isPending
                                          ? Colors.orange.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: item.isApproved
                                            ? Colors.green.shade200
                                            : item.isPending
                                            ? Colors.orange.shade200
                                            : Colors.red.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(
                                        color: item.isApproved
                                            ? Colors.green.shade700
                                            : item.isPending
                                            ? Colors.orange.shade700
                                            : Colors.red.shade700,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.isApproved)
                                    Text(
                                      item.isPurchased
                                          ? 'Purchased'
                                          : 'Not Purchased',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: item.isPurchased
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
