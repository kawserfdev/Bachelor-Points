import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../balance_controller.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/member_balance_model.dart';
import '../widgets/desktop/deposit_charts.dart';
import '../widgets/desktop/deposit_member_table.dart';
import '../widgets/desktop/deposit_summary_cards.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../core/localization/number_converter.dart';

/// Responsive Balance/Deposit summary screen.
///
/// Layout strategy (layout-only redesign — no business logic changes):
/// * **Mobile**  — preserves the original single-column design (month
///   selector, global metrics card, scrollable member-balance list, FAB).
/// * **Tablet**  — adaptive 2-column grid of member-balance cards with the
///   global metrics card spanning the top.
/// * **Desktop** — SaaS-style dashboard: payment-summary cards row, a month
///   toolbar, then a row pairing the member-balance ledger table with a
///   deposit-distribution donut chart.
///
/// The controller ([BalanceController]) is reused as-is. Search filtering is
/// performed locally over the controller's already-computed `memberBalances`
/// list — no new data-layer code.
class BalanceSummaryView extends StatefulWidget {
  const BalanceSummaryView({super.key});

  @override
  State<BalanceSummaryView> createState() => _BalanceSummaryViewState();
}

class _BalanceSummaryViewState extends State<BalanceSummaryView> {
  late final BalanceController controller;

  /// Local-only desktop search query.
  String _searchQuery = '';

  /// Whether the current locale is Bangla.
  bool get _isBangla =>
      Localizations.localeOf(context).languageCode == 'bn';

  /// Converts ASCII digits in [text] to Bangla digits when the current
  /// locale is Bangla; otherwise returns [text] unchanged.
  String _convert(String text) =>
      _isBangla ? NumberConverter.englishToBangla(text) : text;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BalanceController>();
  }

  /// Filters the controller's member-balance list by the local search query.
  /// Pure derivation — does not mutate the controller.
  List<MemberBalanceModel> _filteredMembers() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return controller.memberBalances.toList();
    return controller.memberBalances
        .where((m) => m.userName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(local.messBalancesTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, sizeClass, constraints) {
            return switch (deviceType) {
              DeviceType.mobile => _buildMobileBody(context, local),
              DeviceType.tablet => _buildTabletBody(context, local),
              DeviceType.desktop => _buildDesktopBody(context, local),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addDeposit),
        icon: const Icon(Icons.account_balance_wallet),
        label: Text(local.addDepositTitle),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Mobile — preserves the original design exactly.
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildMobileBody(BuildContext context, AppLocalizations local) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildMonthSelector(context),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: _GlobalMetricsCard(),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.memberBalances.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.memberBalances.isEmpty) {
              return Center(
                child: Text(local.noMembersOrError),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.memberBalances.length,
              itemBuilder: (context, index) {
                final member = controller.memberBalances[index];
                return _MemberBalanceCard(member: member);
              },
            );
          }),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Tablet — adaptive grid layout.
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildTabletBody(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthSelector(context),
            const SizedBox(height: 16),
            const _GlobalMetricsCard(),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.memberBalances.isEmpty) {
                return const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.memberBalances.isEmpty) {
                return SizedBox(
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(local.noMembersOrError,
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.memberBalances.length,
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 440,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final member = controller.memberBalances[index];
                  return _MemberBalanceCard(member: member);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Desktop — SaaS dashboard: summary cards + toolbar + table/charts.
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildDesktopBody(BuildContext context, AppLocalizations local) {
    final locale = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DepositSummaryCards(),
            const SizedBox(height: 24),
            // Toolbar: month navigation + search.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _DesktopMonthNav(locale: locale),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _DesktopSearch(
                    query: _searchQuery,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Main row: member ledger table (wide) + donut chart (narrow).
            SizedBox(
              height: 460,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.memberBalances.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      return DepositMemberTable(
                        members: _filteredMembers(),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 2,
                    child: DepositCharts(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared helpers (preserved from the original view).
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildMonthSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => controller.changeMonth(-1),
        ),
        Obx(() => Text(
              _convert(DateFormat('MMMM yyyy',
                      Localizations.localeOf(context).languageCode)
                  .format(controller.selectedMonth.value)),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            )),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => controller.changeMonth(1),
        ),
      ],
    );
  }
}

/// Compact month stepper for the desktop toolbar that delegates to
/// [BalanceController.changeMonth].
class _DesktopMonthNav extends StatelessWidget {
  final String locale;

  const _DesktopMonthNav({required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<BalanceController>();
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    String convert(String text) =>
        isBangla ? NumberConverter.englishToBangla(text) : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => Text(
                  convert(DateFormat('MMMM yyyy', locale)
                      .format(controller.selectedMonth.value)),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
            onPressed: () => controller.changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
            onPressed: () => controller.changeMonth(1),
          ),
        ],
      ),
    );
  }
}

/// Desktop-only search field for filtering members by name.
class _DesktopSearch extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const _DesktopSearch({required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: TextEditingController(text: query)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: query.length),
          ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.depositTableMember,
          prefixIcon: const Icon(Icons.search_rounded),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _GlobalMetricsCard extends StatelessWidget {
  const _GlobalMetricsCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BalanceController>();
    final local = AppLocalizations.of(context)!;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    String convert(String text) =>
        isBangla ? NumberConverter.englishToBangla(text) : text;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade700,
            Colors.teal.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.mealRate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          convert('৳${controller.mealRate.value.toStringAsFixed(2)}'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.totalMessMeals,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          convert(controller.globalTotalMeals.value.toStringAsFixed(1)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.totalBazar,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            convert('৳${controller.globalTotalBazar.value.toStringAsFixed(0)}'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.totalFixedCosts,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            convert('৳${controller.globalTotalFixed.value.toStringAsFixed(0)}'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MemberBalanceCard extends StatelessWidget {
  final dynamic member;

  const _MemberBalanceCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final bool getsMoney = member.balance >= 0;
    final local = AppLocalizations.of(context)!;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    String convert(String text) =>
        isBangla ? NumberConverter.englishToBangla(text) : text;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  child: Text(
                    member.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    member.userName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getsMoney
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    convert(getsMoney
                        ? local.getsLabel(member.balance.toStringAsFixed(0))
                        : local.owesLabel(member.balance.abs().toStringAsFixed(0))),
                    style: TextStyle(
                      color: getsMoney ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(local.meals, convert(member.totalMeals.toStringAsFixed(1))),
                _buildStatItem(local.deposits, convert('৳${member.totalDeposits.toStringAsFixed(0)}')),
                _buildStatItem(local.mealCost, convert('৳${member.mealCost.toStringAsFixed(0)}')),
                _buildStatItem(local.fixedCost, convert('৳${member.fixedCost.toStringAsFixed(0)}')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
