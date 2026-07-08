import 'package:bachelorpoints/core/responsive/responsive.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../mess/mess_controller.dart';
import '../../../notifications/providers/notification_providers.dart';
import '../../home_controller.dart';
import 'dashboard_widgets.dart';

/// Modern SaaS-style dashboard for **tablet & desktop** widths.
///
/// Layout:
/// * Left sidebar (navigation + mess identity)
/// * Top app bar (greeting, search hint, notifications, theme toggle, avatar)
/// * KPI stat cards (adaptive grid)
/// * Charts row (donut + bar)
/// * Quick actions grid
/// * Recent activity feed
///
/// Reuses [HomeController] and [MessController] observables — no business logic
/// is duplicated or modified. Mobile widths are handled by [HomeView] which
/// keeps the existing mobile design untouched.
class SaaSDashboard extends StatelessWidget {
  const SaaSDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final messController = Get.find<MessController>();
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (messController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final mess = messController.activeMess.value;
      if (mess == null) {
        return _NoMessState();
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _DashboardTopBar(
              controller: controller,
              messName: mess.name,
              inviteCode: mess.inviteCode,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => messController.refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1400,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatCards(context, controller),
                        const SizedBox(height: 24),
                        _buildChartsRow(context, controller),
                        const SizedBox(height: 28),
                        _buildQuickActions(context),
                        const SizedBox(height: 28),
                        _buildRecentActivity(context, messController),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stat cards (adaptive grid)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatCards(BuildContext context, HomeController controller) {
    final local = AppLocalizations.of(context)!;
    final isDesktop = context.deviceType == DeviceType.desktop;
    final crossAxisCount = isDesktop ? 4 : 2;

    final cards = <DashboardStatCard>[
      DashboardStatCard(
        icon: Icons.people_rounded,
        label: local.members,
        value: '${controller.memberCount.value}',
        accent: DashboardPalette.members,
        subtitle: local.manageMessEfficiently,
      ),
      DashboardStatCard(
        icon: Icons.account_balance_wallet_rounded,
        label: local.balances,
        value: '৳${controller.myBalance.value.toStringAsFixed(0)}',
        accent: DashboardPalette.balance,
        trend: TrendData(
          controller.myBalance.value >= 0 ? 8 : -8,
          positiveIsGood: true,
        ),
      ),
      DashboardStatCard(
        icon: Icons.shopping_cart_rounded,
        label: local.bazar,
        value: '৳${controller.totalBazarExpense.value.toStringAsFixed(0)}',
        accent: DashboardPalette.bazar,
        subtitle: 'This month',
      ),
      DashboardStatCard(
        icon: Icons.calculate_rounded,
        label: local.mealRate,
        value: '৳${controller.mealRate.value.toStringAsFixed(1)}',
        accent: DashboardPalette.mealRate,
        subtitle: local.totalMeals,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.35 : 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) => cards[i],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Charts row (donut + bar)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChartsRow(BuildContext context, HomeController controller) {
    final local = AppLocalizations.of(context)!;
    final isDesktop = context.deviceType == DeviceType.desktop;

    final donut = DonutChart(
      centerLabel: local.overview,
      centerValue: '৳${(controller.totalBazarExpense.value +
              controller.totalFixedExpense.value)
          .toStringAsFixed(0)}',
      segments: [
        DonutSegment(
          label: local.bazar,
          value: controller.totalBazarExpense.value,
          color: DashboardPalette.bazar,
        ),
        DonutSegment(
          label: 'Fixed',
          value: controller.totalFixedExpense.value,
          color: DashboardPalette.fixed,
        ),
      ],
    );

    final bar = MiniBarChart(
      title: local.overview,
      bars: [
        BarData(
          label: local.bazar,
          value: controller.totalBazarExpense.value,
          color: DashboardPalette.bazar,
        ),
        BarData(
          label: 'Fixed',
          value: controller.totalFixedExpense.value,
          color: DashboardPalette.fixed,
        ),
        BarData(
          label: local.totalMeals,
          value: controller.myTotalMeals.value,
          color: DashboardPalette.meals,
        ),
        BarData(
          label: local.balances,
          value: controller.myDeposits.value,
          color: DashboardPalette.deposit,
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: donut),
          const SizedBox(width: 20),
          Expanded(flex: 1, child: bar),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        donut,
        const SizedBox(height: 16),
        bar,
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Quick actions grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isDesktop = context.deviceType == DeviceType.desktop;

    final actions = <QuickActionCard>[
      QuickActionCard(
        icon: Icons.restaurant_menu_rounded,
        label: local.addMeal,
        accent: DashboardPalette.meals,
        onTap: () => context.push(AppRoutes.mealEntry),
      ),
      QuickActionCard(
        icon: Icons.receipt_long_rounded,
        label: local.addExpense,
        accent: DashboardPalette.bazar,
        onTap: () => context.push(AppRoutes.addExpense),
      ),
      QuickActionCard(
        icon: Icons.account_balance_wallet_rounded,
        label: local.addDeposit,
        accent: DashboardPalette.deposit,
        onTap: () => context.push(AppRoutes.addDeposit),
      ),
      QuickActionCard(
        icon: Icons.bar_chart_rounded,
        label: local.balances,
        accent: DashboardPalette.balance,
        onTap: () => context.push(AppRoutes.balanceSummary),
      ),
      QuickActionCard(
        icon: Icons.analytics_rounded,
        label: local.report,
        accent: DashboardPalette.report,
        onTap: () => context.push(AppRoutes.report),
      ),
      QuickActionCard(
        icon: Icons.checklist_rounded,
        label: local.approvals,
        accent: DashboardPalette.approvals,
        onTap: () => context.push(AppRoutes.approvals),
      ),
      QuickActionCard(
        icon: Icons.shopping_cart_checkout_rounded,
        label: local.shopping,
        accent: DashboardPalette.shopping,
        onTap: () => context.push(AppRoutes.shoppingList),
      ),
      QuickActionCard(
        icon: Icons.notifications_active_rounded,
        label: local.notifications,
        accent: DashboardPalette.notifications,
        onTap: () => context.push(AppRoutes.notifications),
      ),
      QuickActionCard(
        icon: Icons.settings_suggest_rounded,
        label: local.settings,
        accent: DashboardPalette.settings,
        onTap: () => context.push(AppRoutes.settings),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: local.quickActions),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isDesktop ? 160 : 120,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, i) => actions[i],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Recent activity feed
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRecentActivity(BuildContext context, MessController messController) {
    final local = AppLocalizations.of(context)!;
    final members = messController.members;
    final recent = [...members]
      ..sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
    final display = recent.take(6).toList();

    if (display.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activity',
          actionLabel: local.members,
          onAction: () => context.push(AppRoutes.members),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: display.map((m) {
              final name = m.fullName ?? m.email ?? 'Unknown';
              return ActivityTile(
                title: name,
                subtitle: '${m.role[0].toUpperCase()}${m.role.substring(1)} • ${local.members}',
                timeAgoText: timeAgo(m.joinedAt),
                icon: Icons.person_add_alt_1_rounded,
                accent: DashboardPalette.members,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top app bar
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTopBar extends StatelessWidget {
  final HomeController controller;
  final String messName;
  final String inviteCode;

  const _DashboardTopBar({
    required this.controller,
    required this.messName,
    required this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final local = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? local.goodMorning
        : hour < 17
            ? local.goodAfternoon
            : local.goodEvening;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  local.heyGreeting(greeting),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  local.manageMessEfficiently,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Search hint (desktop only)
          // if (context.deviceType == DeviceType.desktop)
          //   Container(
          //     width: 240,
          //     height: 40,
          //     padding: const EdgeInsets.symmetric(horizontal: 12),
          //     decoration: BoxDecoration(
          //       color: cs.surfaceContainerHighest,
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: Row(
          //       children: [
          //         Icon(Icons.search_rounded,
          //             size: 18, color: cs.onSurfaceVariant),
          //         const SizedBox(width: 8),
          //         Text(
          //           'Search...',
          //           style: theme.textTheme.bodySmall?.copyWith(
          //             color: cs.onSurfaceVariant,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
            
          //   if (context.deviceType == DeviceType.desktop) const SizedBox(width: 12),
          // // Notifications
          Consumer(
            builder: (context, ref, child) {
              final unreadCount = ref.watch(unreadNotificationsCountProvider);
              return Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                alignment: const Alignment(0.65, -0.65),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: cs.onSurface),
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No-mess state (desktop variant)
// ─────────────────────────────────────────────────────────────────────────────
class _NoMessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.group_off_rounded,
                    size: 56, color: cs.primary.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 28),
              Text(
                local.notInMess,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                local.notInMessDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.createMess),
                  icon: const Icon(Icons.add),
                  label: Text(local.createMess),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.joinMess),
                  icon: const Icon(Icons.login),
                  label: Text(local.joinMess),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Obx(() {
                final isLoading = Get.find<MessController>().isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => Get.find<MessController>().refresh(),
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(isLoading ? local.refreshing : local.refresh),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
