import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../report_controller.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: () => controller.exportToPdf(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildMonthSelector(),
            ),
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
          ],
        );
      }),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              int newMonth = controller.selectedMonth.value - 1;
              int newYear = controller.selectedYear.value;
              if (newMonth < 1) {
                newMonth = 12;
                newYear--;
              }
              controller.changeMonth(newMonth, newYear);
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(DateTime(
              controller.selectedYear.value,
              controller.selectedMonth.value,
            )),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              int newMonth = controller.selectedMonth.value + 1;
              int newYear = controller.selectedYear.value;
              if (newMonth > 12) {
                newMonth = 1;
                newYear++;
              }
              controller.changeMonth(newMonth, newYear);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(dynamic summary) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _summaryItem('Total Meals', summary.totalMeals.toStringAsFixed(1)),
            _summaryItem('Total Expenses', 'Tk ${summary.totalExpenses.toStringAsFixed(2)}'),
            _summaryItem('Meal Rate', 'Tk ${summary.mealRate.toStringAsFixed(2)}'),
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
          final isNegative = m.finalBalance < 0;
          return DataRow(
            cells: [
              DataCell(Text(m.userName)),
              DataCell(Text(m.totalMeals.toStringAsFixed(1))),
              DataCell(Text(m.totalCost.toStringAsFixed(2))),
              DataCell(Text(m.totalDeposits.toStringAsFixed(2))),
              DataCell(Text(
                m.finalBalance.toStringAsFixed(2),
                style: TextStyle(
                  color: isNegative ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
