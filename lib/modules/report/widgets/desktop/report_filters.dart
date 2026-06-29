import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../report_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only filter & export toolbar for the Report module.
///
/// Renders four control groups, all delegating to the existing
/// [ReportController] methods — **no** new business logic:
/// * **Month navigation** — calls [ReportController.changeMonth].
/// * **Tab selector** — Overview / Member Report, sets [activeTab].
/// * **Member dropdown** — only for managers/owners, sets [selectedMemberId].
/// * **Export buttons** — Download PDF + Print via [exportToPdf].
class ReportFilters extends StatelessWidget {
  const ReportFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                local.reportFiltersTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              _ExportButtons(),
            ],
          ),
          const SizedBox(height: 12),
          // Month navigation + tab selector in a responsive row.
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MonthNav(locale: locale),
              _TabSelector(local: local),
            ],
          ),
          // Member dropdown — only for managers/owners.
          Obx(() {
            final controller = Get.find<ReportController>();
            if (!controller.currentUserRole.value.canManageMembers) {
              return const SizedBox.shrink();
            }
            if (controller.activeTab.value != 1) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _MemberDropdown(local: local),
            );
          }),
        ],
      ),
    );
  }
}

/// Compact month stepper that delegates to [ReportController.changeMonth].
class _MonthNav extends StatelessWidget {
  final String locale;

  const _MonthNav({required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<ReportController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
            onPressed: () {
              int m = controller.selectedMonth.value - 1;
              int y = controller.selectedYear.value;
              if (m < 1) {
                m = 12;
                y--;
              }
              controller.changeMonth(m, y);
            },
          ),
          Obx(() => Text(
                DateFormat('MMMM yyyy', locale).format(DateTime(
                  controller.selectedYear.value,
                  controller.selectedMonth.value,
                )),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              )),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
            onPressed: () {
              int m = controller.selectedMonth.value + 1;
              int y = controller.selectedYear.value;
              if (m > 12) {
                m = 1;
                y++;
              }
              controller.changeMonth(m, y);
            },
          ),
        ],
      ),
    );
  }
}

/// Segmented button for Overview / Member Report tabs.
class _TabSelector extends StatelessWidget {
  final AppLocalizations local;

  const _TabSelector({required this.local});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() => SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(
              value: 0,
              label: Text(local.reportTabOverview),
              icon: const Icon(Icons.analytics_outlined),
            ),
            ButtonSegment<int>(
              value: 1,
              label: Text(
                controller.currentUserRole.value.canManageMembers
                    ? local.reportTabMemberReport
                    : local.reportTabMyReport,
              ),
              icon: const Icon(Icons.person_outline),
            ),
          ],
          selected: {controller.activeTab.value},
          onSelectionChanged: (Set<int> s) =>
              controller.activeTab.value = s.first,
        ));
  }
}

/// Member dropdown for managers/owners — sets [selectedMemberId].
class _MemberDropdown extends StatelessWidget {
  final AppLocalizations local;

  const _MemberDropdown({required this.local});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<ReportController>();

    return Obx(() {
      final members = controller.memberSummaries;
      final currentId = controller.selectedMemberId.value;
      final hasMember = members.any((m) => m.userId == currentId);

      return SizedBox(
        width: 280,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: hasMember ? currentId : null,
          decoration: InputDecoration(
            labelText: local.reportSelectMember,
            prefixIcon: const Icon(Icons.person_search_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          items: members
              .map((m) => DropdownMenuItem<String>(
                    value: m.userId,
                    child: Text(m.userName, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) controller.selectedMemberId.value = val;
          },
        ),
      );
    });
  }
}

/// Export buttons — Download PDF + Print, delegating to [exportToPdf].
class _ExportButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<ReportController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.tonalIcon(
          onPressed: () => controller.exportToPdf(downloadOnly: true),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: Text(local.reportExportPdf),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => controller.exportToPdf(),
          icon: const Icon(Icons.print_rounded, size: 18),
          label: Text(local.reportPrintReport),
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
