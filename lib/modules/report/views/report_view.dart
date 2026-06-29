import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/responsive/responsive.dart';
import '../report_controller.dart';
import '../../../data/models/report_summary_model.dart';
import '../widgets/desktop/report_summary_cards.dart';
import '../widgets/desktop/report_charts.dart';
import '../widgets/desktop/report_filters.dart';
import '../widgets/desktop/report_member_table.dart';
import '../widgets/desktop/report_member_detail.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  late final ReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ReportController>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveBuilder(
      builder: (context, deviceType, sizeClass, constraints) {
        final isDesktop = deviceType != DeviceType.mobile;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.reportTitle),
            // On desktop the export buttons live in the filters toolbar.
            actions: isDesktop
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.download),
                      tooltip: l10n.downloadPdfTooltip,
                      onPressed: () =>
                          controller.exportToPdf(downloadOnly: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: l10n.printPdfTooltip,
                      onPressed: () => controller.exportToPdf(),
                    ),
                  ],
          ),
          body: switch (deviceType) {
            DeviceType.mobile => _buildMobileBody(l10n),
            _ => _buildDesktopBody(),
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Mobile body — preserves the original 3-section scroll layout
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildMobileBody(AppLocalizations l10n) {
    return Obx(() {
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
          SliverToBoxAdapter(child: _buildTabSelector(l10n)),
          // ── Overview tab ──
          if (controller.activeTab.value == 0) ...[
            if (controller.summary.value != null)
              SliverToBoxAdapter(
                child: _buildSummaryCard(controller.summary.value!, l10n),
              ),
            if (controller.memberSummaries.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildDataTable(controller.memberSummaries, l10n),
              ),
            if (!controller.isLoading.value &&
                controller.summary.value == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text(l10n.noDataForMonth)),
                ),
              ),
          ]
          // ── Member Report tab ──
          else ...[
            // Show member dropdown only for managers/owners
            if (controller.currentUserRole.value.canManageMembers)
              SliverToBoxAdapter(child: _buildMemberDropdown(l10n)),
            if (selectedMemberSummary != null) ...[
              SliverToBoxAdapter(
                child: _buildMemberSummaryCard(selectedMemberSummary, l10n),
              ),
              SliverToBoxAdapter(
                child: _buildDailyCards(
                    controller.getSelectedMemberDailyRecords(), l10n),
              ),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text(l10n.noDataForMember)),
                ),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      );
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Desktop body — SaaS dashboard with filters, KPI cards, charts & tables
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildDesktopBody() {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      if (controller.isLoading.value && controller.summary.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final selectedMemberSummary = controller.memberSummaries.firstWhereOrNull(
        (m) => m.userId == controller.selectedMemberId.value,
      );

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter & export toolbar
                ReportFilters(),
                const SizedBox(height: 20),
                // KPI summary cards
                ReportSummaryCards(),
                const SizedBox(height: 20),
                // Tab-specific content
                if (controller.activeTab.value == 0) ...[
                  // Overview: charts + member table side by side
                  SizedBox(
                    height: 460,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 2, child: ReportCharts()),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: ReportMemberTable()),
                      ],
                    ),
                  ),
                ] else ...[
                  // Member Report: daily activity table
                  if (selectedMemberSummary != null)
                    SizedBox(
                      height: 520,
                      child: ReportMemberDetail(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(child: Text(l10n.noDataForMember)),
                    ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
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
  Widget _buildTabSelector(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SegmentedButton<int>(
        segments:  [
          ButtonSegment<int>(
            value: 0,
            label: Text(l10n.reportTabOverview),
            icon: const Icon(Icons.analytics_outlined),
          ),
          ButtonSegment<int>(
            value: 1,
            label: Text(controller.currentUserRole.value.canManageMembers
                ? l10n.reportTabMemberReport
                : l10n.reportTabMyReport),
            icon: const Icon(Icons.person_outline),
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
  Widget _buildSummaryCard(dynamic summary, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _summaryItem(l10n.reportTotalMeals, summary.totalMeals.toStringAsFixed(1)),
            _summaryItem(l10n.reportTotalExpenses, '৳${summary.totalExpenses.toStringAsFixed(0)}'),
            _summaryItem(l10n.reportMealRate, '৳${summary.mealRate.toStringAsFixed(2)}'),
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

  Widget _buildDataTable(List<dynamic> members, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(l10n.reportColMember)),
          DataColumn(label: Text(l10n.reportColMeals), numeric: true),
          DataColumn(label: Text(l10n.reportColCost), numeric: true),
          DataColumn(label: Text(l10n.reportColDeposits), numeric: true),
          DataColumn(label: Text(l10n.reportColBalance), numeric: true),
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
  Widget _buildMemberDropdown(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: controller.memberSummaries.any((m) => m.userId == controller.selectedMemberId.value)
            ? controller.selectedMemberId.value
            : null,
        decoration: InputDecoration(
          labelText: l10n.reportSelectMember,
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

  Widget _buildMemberSummaryCard(MemberSummaryModel m, AppLocalizations l10n) {
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
                    l10n.reportMonthlySummary(m.userName),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _rowItem(Icons.restaurant_outlined, l10n.reportTotalMeals, m.totalMeals.toStringAsFixed(1), null),
            const SizedBox(height: 10),
            _rowItem(Icons.payments_outlined, l10n.reportMealCost, '৳${m.totalCost.toStringAsFixed(2)}', Colors.red.shade700),
            const SizedBox(height: 10),
            _rowItem(Icons.account_balance_wallet_outlined, l10n.reportTotalDeposits, '৳${m.totalDeposits.toStringAsFixed(2)}', Colors.blue.shade700),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.reportFinalBalance, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
  Widget _buildDailyCards(List<DailyRecord> records, AppLocalizations l10n) {
    // Only keep days that have at least one activity
    final activeRecords = records
        .where((r) => r.meal != null || r.expenses.isNotEmpty || r.deposits.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportDailyActivityLog,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (activeRecords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text(l10n.reportNoActivityThisMonth)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeRecords.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) => _buildDayCard(activeRecords[index], l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyRecord r, AppLocalizations l10n) {
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
                    _chip(Icons.wb_sunny_outlined, l10n.reportChipBreakfast(r.meal!.breakfast.toStringAsFixed(1)), Colors.amber),
                  if (r.meal!.lunch > 0)
                    _chip(Icons.lunch_dining_outlined, l10n.reportChipLunch(r.meal!.lunch.toStringAsFixed(1)), Colors.orange),
                  if (r.meal!.dinner > 0)
                    _chip(Icons.dinner_dining_outlined, l10n.reportChipDinner(r.meal!.dinner.toStringAsFixed(1)), Colors.deepOrange),
                  if (r.meal!.guestMeals > 0)
                    _chip(Icons.group_outlined, l10n.reportChipGuest(r.meal!.guestMeals.toStringAsFixed(1)), Colors.purple),
                ],
                // Expenses
                for (final e in r.expenses)
                  _chip(
                    e.category == 'bazar' ? Icons.shopping_cart_outlined : Icons.receipt_outlined,
                    l10n.reportChipExpense(
                      '${e.category[0].toUpperCase()}${e.category.substring(1)}',
                      e.amount.toStringAsFixed(0),
                    ),
                    Colors.orange,
                  ),
                // Deposits
                for (final d in r.deposits)
                  _chip(Icons.account_balance_wallet_outlined, l10n.reportChipDeposit(d.amount.toStringAsFixed(0)), Colors.green),
              ],
            ),
            // ── Summary row ───────────────────────────────────────────────
            if (totalMeals > 0 || totalExpense > 0 || totalDeposit > 0) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (totalMeals > 0)
                    _miniStat(l10n.reportMiniMeals, totalMeals.toStringAsFixed(1), Colors.deepPurple),
                  if (totalExpense > 0)
                    _miniStat(l10n.reportMiniExpense, '৳${totalExpense.toStringAsFixed(0)}', Colors.orange.shade700),
                  if (totalDeposit > 0)
                    _miniStat(l10n.reportMiniDeposit, '৳${totalDeposit.toStringAsFixed(0)}', Colors.green.shade700),
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
