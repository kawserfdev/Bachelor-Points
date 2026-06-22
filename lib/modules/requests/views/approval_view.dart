import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../request_controller.dart';
import 'package:intl/intl.dart';
import '../../../data/models/request_model.dart';

class ApprovalView extends GetView<RequestController> {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildFilterChips(context),
          _buildStatusBar(context),
          const Divider(height: 1),
          Expanded(child: _buildRequestList(context)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = [
      'All', 'Pending', 'Approved', 'Rejected',
      'Expense', 'Deposit', 'Join', 'Remove', 'RoleChange',
    ];
    final icons = {
      'All': Icons.list_alt_rounded,
      'Pending': Icons.hourglass_empty_rounded,
      'Approved': Icons.check_circle_outline_rounded,
      'Rejected': Icons.cancel_outlined,
      'Expense': Icons.receipt_long_rounded,
      'Deposit': Icons.account_balance_wallet_rounded,
      'Join': Icons.person_add_rounded,
      'Remove': Icons.person_remove_rounded,
      'RoleChange': Icons.manage_accounts_rounded,
    };

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: filters.map((filter) {
              final isSelected = controller.activeFilter.value == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(
                    icons[filter],
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(filter == 'RoleChange' ? 'Role' : filter),
                  selected: isSelected,
                  onSelected: (_) => controller.activeFilter.value = filter,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildStatusBar(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusBadge(
                  label: 'Pending',
                  count: controller.pendingCount,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _StatusBadge(
                  label: 'Approved',
                  count: controller.approvedCount,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatusBadge(
                  label: 'Rejected',
                  count: controller.rejectedCount,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildRequestList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.allRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final requests = controller.filteredRequests;

      if (requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No ${controller.activeFilter.value.toLowerCase()} requests',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchRequests(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            if (req.isFinancial) {
              return _buildFinancialCard(context, req);
            }
            return _buildMemberCard(context, req);
          },
        ),
      );
    });
  }

  // ──────────────────────────────────────────────
  // Financial request card (expense / deposit)
  // ──────────────────────────────────────────────

  Widget _buildFinancialCard(BuildContext context, RequestModel request) {
    final theme = Theme.of(context);
    final isExpense = request.requestType == 'expense';
    final dateStr = DateFormat('MMM dd, yyyy').format(request.requestDate);
    final canModify = request.status == 'Pending' && controller.canApprove;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(request.status).withAlpha(60),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: type badge + status
            Row(
              children: [
                _TypeBadge(
                  icon: isExpense
                      ? Icons.receipt_long_rounded
                      : Icons.account_balance_wallet_rounded,
                  label: isExpense ? 'Expense' : 'Deposit',
                  color: isExpense ? Colors.red : Colors.blue,
                ),
                const Spacer(),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 12),
            if (request.title != null && request.title!.isNotEmpty)
              Text(
                request.title!,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            if (request.category != null && request.category!.isNotEmpty)
              Text(
                'Category: ${request.category!.capitalizeFirst}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            if (request.paymentMethod != null &&
                request.paymentMethod!.isNotEmpty)
              Text(
                'Payment: ${request.paymentMethod!.capitalizeFirst}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            if (request.note != null && request.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Note: ${request.note}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '৳${request.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(dateStr,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Requested by ${request.createdByName ?? 'Unknown'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            _buildAuditTrail(request),
            if (canModify) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildFinancialActions(context, request),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialActions(BuildContext context, RequestModel request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showEditDialog(context, request),
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('Edit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _confirmReject(context, request),
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _confirmApprove(context, request),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Member request card (JOIN_MESS, REMOVE_MEMBER, ROLE_CHANGE)
  // ──────────────────────────────────────────────

  Widget _buildMemberCard(BuildContext context, RequestModel request) {
    final theme = Theme.of(context);
    final canModify = request.status == 'Pending' && controller.canApprove;

    final (icon, label, color) = _memberRequestMeta(request.requestType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(request.status).withAlpha(60),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: type badge + status
            Row(
              children: [
                _TypeBadge(icon: icon, label: label, color: color),
                const Spacer(),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 12),
            // Member name
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withAlpha(30),
                  child: Text(
                    (request.memberName ?? request.userName ?? '?')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.memberName ?? request.userName ?? 'Unknown',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (request.userEmail != null)
                        Text(
                          request.userEmail!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Role info for ROLE_CHANGE
            if (request.requestType == 'ROLE_CHANGE' &&
                request.oldRole != null &&
                request.newRole != null) ...[
              Row(
                children: [
                  _RoleChip(role: request.oldRole!),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 16, color: Colors.grey),
                  ),
                  _RoleChip(role: request.newRole!, isNew: true),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Current role for REMOVE_MEMBER
            if (request.requestType == 'REMOVE_MEMBER' &&
                request.currentRole != null) ...[
              Text(
                'Current Role: ${request.currentRole!.capitalizeFirst}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
            ],
            // Reason
            if (request.reason != null && request.reason!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Reason: ${request.reason}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            // Date + requested by
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(request.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.person_outline_rounded,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'by ${request.createdByName ?? 'Unknown'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            _buildAuditTrail(request),
            if (canModify) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildMemberActions(context, request),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberActions(BuildContext context, RequestModel request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => _confirmReject(context, request),
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _confirmApprove(context, request),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Shared widgets
  // ──────────────────────────────────────────────

  Widget _buildAuditTrail(RequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (request.status == 'Approved' && request.approvedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Approved on ${DateFormat('MMM dd, yyyy – hh:mm a').format(request.approvedAt!)}',
              style: TextStyle(fontSize: 11, color: Colors.green[600]),
            ),
          ),
        if (request.status == 'Rejected' && request.rejectedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Rejected on ${DateFormat('MMM dd, yyyy – hh:mm a').format(request.rejectedAt!)}',
              style: TextStyle(fontSize: 11, color: Colors.red[600]),
            ),
          ),
        if (request.updatedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Updated on ${DateFormat('MMM dd, yyyy – hh:mm a').format(request.updatedAt!)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Dialogs
  // ──────────────────────────────────────────────

  void _confirmApprove(BuildContext context, RequestModel request) {
    String body;
    if (request.isFinancial) {
      body =
          'Are you sure you want to approve this ${request.requestType} request for ৳${request.amount.toStringAsFixed(2)}?\n\n'
          'This will ${request.requestType == 'expense' ? 'deduct from' : 'add to'} the balance.';
    } else if (request.requestType == 'JOIN_MESS') {
      body =
          'Approve join request for ${request.userName ?? request.userEmail ?? 'Unknown'}?\n\n'
          'They will be added as a Member.';
    } else if (request.requestType == 'REMOVE_MEMBER') {
      body =
          'Approve removal of ${request.memberName ?? 'Unknown'}?\n\n'
          'They will be removed from the mess.';
    } else {
      body =
          'Approve role change for ${request.memberName ?? 'Unknown'} from ${request.oldRole ?? '?'} to ${request.newRole ?? '?'}?';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Approval'),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.approveRequest(request);
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, RequestModel request) {
    final label = request.isFinancial ? request.requestType : 'this';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Rejection'),
        content: Text(
          'Are you sure you want to reject $label request?\n\nThis will not affect any data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.rejectRequest(request);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, RequestModel request) {
    if (request.requestType == 'expense') {
      _showEditExpenseDialog(context, request);
    } else {
      _showEditDepositDialog(context, request);
    }
  }

  void _showEditExpenseDialog(BuildContext context, RequestModel request) {
    final titleCtrl = TextEditingController(text: request.title);
    final amountCtrl =
        TextEditingController(text: request.amount.toString());
    final noteCtrl = TextEditingController(text: request.note);
    String category = request.category ?? 'other';
    DateTime date = request.requestDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Expense Request'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'bazar', child: Text('Bazar')),
                      DropdownMenuItem(value: 'rent', child: Text('Rent')),
                      DropdownMenuItem(value: 'wifi', child: Text('WiFi')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) {
                      if (v != null) category = v;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Amount (৳)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount required';
                      final d = double.tryParse(v);
                      if (d == null || d <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setDialogState(() => date = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(date)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  controller.updateExpenseRequest(
                    requestId: request.id,
                    title: titleCtrl.text.trim(),
                    category: category,
                    amount: double.parse(amountCtrl.text),
                    date: date,
                    note: noteCtrl.text.trim().isEmpty
                        ? null
                        : noteCtrl.text.trim(),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDepositDialog(BuildContext context, RequestModel request) {
    final amountCtrl =
        TextEditingController(text: request.amount.toString());
    final noteCtrl = TextEditingController(text: request.note);
    String paymentMethod = request.paymentMethod ?? 'cash';
    DateTime date = request.requestDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Deposit Request'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Amount (৳)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount required';
                      final d = double.tryParse(v);
                      if (d == null || d <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'bkash', child: Text('bKash')),
                      DropdownMenuItem(value: 'nagad', child: Text('Nagad')),
                      DropdownMenuItem(
                          value: 'bank', child: Text('Bank Transfer')),
                    ],
                    onChanged: (v) {
                      if (v != null) paymentMethod = v;
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setDialogState(() => date = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(date)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  controller.updateDepositRequest(
                    requestId: request.id,
                    amount: double.parse(amountCtrl.text),
                    paymentMethod: paymentMethod,
                    date: date,
                    note: noteCtrl.text.trim().isEmpty
                        ? null
                        : noteCtrl.text.trim(),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  (IconData, String, Color) _memberRequestMeta(String type) {
    switch (type) {
      case 'JOIN_MESS':
        return (Icons.person_add_rounded, 'Join Mess', Colors.indigo);
      case 'REMOVE_MEMBER':
        return (Icons.person_remove_rounded, 'Remove Member', Colors.red);
      case 'ROLE_CHANGE':
        return (Icons.manage_accounts_rounded, 'Role Change', Colors.teal);
      default:
        return (Icons.help_outline_rounded, type, Colors.grey);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ──────────────────────────────────────────────
// Reusable widgets
// ──────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TypeBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color _color() {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: c,
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  final bool isNew;

  const _RoleChip({required this.role, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    final color = isNew ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: isNew ? Border.all(color: color, width: 1) : null,
      ),
      child: Text(
        role.capitalizeFirst ?? role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
