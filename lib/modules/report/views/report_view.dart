import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../report_controller.dart';
import '../../../data/models/report_summary_model.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () => controller.exportToPdf(downloadOnly: true),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print PDF',
            onPressed: () => controller.exportToPdf(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final selectedMemberSummary = controller.memberSummaries.firstWhereOrNull(
          (m) => m.userId == controller.selectedMemberId.value,
        );

        return CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildMonthSelector()),
            SliverToBoxAdapter(child: _buildTabSelector()),
            // ── Overview tab ──
            if (controller.activeTab.value == 0) ...[
              if (controller.summary.value != null)
                SliverToBoxAdapter(
                  child: _buildSummaryCard(controller.summary.value!),
                ),
              if (controller.memberSummaries.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildDataTable(controller.memberSummaries),
                ),
              if (!controller.isLoading.value && controller.summary.value == null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No data found for selected month')),
                  ),
                ),
            ]
            // ── Member Report tab ──
            else ...[
              // Show member dropdown only for managers/owners
              if (controller.currentUserRole.value.canManageMembers)
                SliverToBoxAdapter(child: _buildMemberDropdown()),
              if (selectedMemberSummary != null) ...[
                SliverToBoxAdapter(
                  child: _buildMemberSummaryCard(selectedMemberSummary),
                ),
                SliverToBoxAdapter(
                  child: _buildDailyCards(controller.getSelectedMemberDailyRecords()),
                ),
              ] else
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No data found for selected member')),
                  ),
                ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Month Selector
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              int m = controller.selectedMonth.value - 1;
              int y = controller.selectedYear.value;
              if (m < 1) { m = 12; y--; }
              controller.changeMonth(m, y);
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(
              DateTime(controller.selectedYear.value, controller.selectedMonth.value),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              int m = controller.selectedMonth.value + 1;
              int y = controller.selectedYear.value;
              if (m > 12) { m = 1; y++; }
              controller.changeMonth(m, y);
            },
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Tab Selector
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SegmentedButton<int>(
        segments:  [
          ButtonSegment<int>(
            value: 0,
            label: Text('Overview'),
            icon: Icon(Icons.analytics_outlined),
          ),
          ButtonSegment<int>(
            value: 1,
            label: Text(controller.currentUserRole.value.canManageMembers ? 'Member Report' : 'My Report'),
            icon: Icon(Icons.person_outline),
          ),
        ],
        selected: {controller.activeTab.value},
        onSelectionChanged: (Set<int> s) => controller.activeTab.value = s.first,
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Overview tab widgets
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSummaryCard(dynamic summary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _summaryItem('Total Meals', summary.totalMeals.toStringAsFixed(1)),
            _summaryItem('Total Expenses', '৳${summary.totalExpenses.toStringAsFixed(0)}'),
            _summaryItem('Meal Rate', '৳${summary.mealRate.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDataTable(List<dynamic> members) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Member')),
          DataColumn(label: Text('Meals'), numeric: true),
          DataColumn(label: Text('Cost'), numeric: true),
          DataColumn(label: Text('Deposits'), numeric: true),
          DataColumn(label: Text('Balance'), numeric: true),
        ],
        rows: members.map((m) {
          final isNeg = m.finalBalance < 0;
          return DataRow(cells: [
            DataCell(Text(m.userName)),
            DataCell(Text(m.totalMeals.toStringAsFixed(1))),
            DataCell(Text('৳${m.totalCost.toStringAsFixed(0)}')),
            DataCell(Text('৳${m.totalDeposits.toStringAsFixed(0)}')),
            DataCell(Text(
              '৳${m.finalBalance.toStringAsFixed(0)}',
              style: TextStyle(
                color: isNeg ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Member Report tab widgets
  // ────────────────────────────────────────────────────────────────────────────

  /// Dropdown — only shown to managers/owners. Fixed overflow with isExpanded.
  Widget _buildMemberDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: controller.memberSummaries.any((m) => m.userId == controller.selectedMemberId.value)
            ? controller.selectedMemberId.value
            : null,
        decoration: InputDecoration(
          labelText: 'Select Member',
          prefixIcon: const Icon(Icons.person_search_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: controller.memberSummaries.map((m) {
          return DropdownMenuItem<String>(
            value: m.userId,
            child: Text(m.userName, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) controller.selectedMemberId.value = val;
        },
      ),
    );
  }

  Widget _buildMemberSummaryCard(MemberSummaryModel m) {
    final isNeg = m.finalBalance < 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${m.userName}\'s Monthly Summary',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _rowItem(Icons.restaurant_outlined, 'Total Meals', m.totalMeals.toStringAsFixed(1), null),
            const SizedBox(height: 10),
            _rowItem(Icons.payments_outlined, 'Meal Cost', '৳${m.totalCost.toStringAsFixed(2)}', Colors.red.shade700),
            const SizedBox(height: 10),
            _rowItem(Icons.account_balance_wallet_outlined, 'Total Deposits', '৳${m.totalDeposits.toStringAsFixed(2)}', Colors.blue.shade700),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Final Balance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNeg ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isNeg ? Colors.red.shade200 : Colors.green.shade200),
                  ),
                  child: Text(
                    '৳${m.finalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isNeg ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(IconData icon, String label, String value, Color? valueColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14))),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: valueColor),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Daily Activity Cards (replaces old DataTable)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildDailyCards(List<DailyRecord> records) {
    // Only keep days that have at least one activity
    final activeRecords = records
        .where((r) => r.meal != null || r.expenses.isNotEmpty || r.deposits.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Activity Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (activeRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No activity recorded this month.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeRecords.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) => _buildDayCard(activeRecords[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyRecord r) {
    final dateStr = DateFormat('dd MMM, yyyy').format(r.date);
    final dayStr  = DateFormat('EEE').format(r.date);

    final totalMeals   = r.meal?.totalMeals ?? 0.0;
    final totalExpense = r.expenses.fold(0.0, (s, e) => s + e.amount);
    final totalDeposit = r.deposits.fold(0.0, (s, d) => s + d.amount);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: date ──────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(dayStr, style: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            // ── Activity chips ────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Meals
                if (r.meal != null) ...[
                  if (r.meal!.breakfast > 0)
                    _chip(Icons.wb_sunny_outlined, 'B: ${r.meal!.breakfast.toStringAsFixed(1)}', Colors.amber),
                  if (r.meal!.lunch > 0)
                    _chip(Icons.lunch_dining_outlined, 'L: ${r.meal!.lunch.toStringAsFixed(1)}', Colors.orange),
                  if (r.meal!.dinner > 0)
                    _chip(Icons.dinner_dining_outlined, 'D: ${r.meal!.dinner.toStringAsFixed(1)}', Colors.deepOrange),
                  if (r.meal!.guestMeals > 0)
                    _chip(Icons.group_outlined, 'G: ${r.meal!.guestMeals.toStringAsFixed(1)}', Colors.purple),
                ],
                // Expenses
                for (final e in r.expenses)
                  _chip(
                    e.category == 'bazar' ? Icons.shopping_cart_outlined : Icons.receipt_outlined,
                    '${e.category[0].toUpperCase()}${e.category.substring(1)}: ৳${e.amount.toStringAsFixed(0)}',
                    Colors.orange,
                  ),
                // Deposits
                for (final d in r.deposits)
                  _chip(Icons.account_balance_wallet_outlined, 'Deposit: ৳${d.amount.toStringAsFixed(0)}', Colors.green),
              ],
            ),
            // ── Summary row ───────────────────────────────────────────────
            if (totalMeals > 0 || totalExpense > 0 || totalDeposit > 0) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (totalMeals > 0)
                    _miniStat('Meals', totalMeals.toStringAsFixed(1), Colors.deepPurple),
                  if (totalExpense > 0)
                    _miniStat('Expense', '৳${totalExpense.toStringAsFixed(0)}', Colors.orange.shade700),
                  if (totalDeposit > 0)
                    _miniStat('Deposit', '৳${totalDeposit.toStringAsFixed(0)}', Colors.green.shade700),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
