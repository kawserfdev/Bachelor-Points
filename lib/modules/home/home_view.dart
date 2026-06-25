import 'package:bachelorpoints/core/theme/app_theme.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'package:bachelorpoints/shared/helpers/constraction_massage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';
import '../mess/mess_controller.dart';
import '../notifications/providers/notification_providers.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/member_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final messController = Get.find<MessController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (messController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final mess = messController.activeMess.value;

        if (mess == null) {
          return _buildNoMessState(context);
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => messController.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    messController,
                    mess.name,
                    mess.inviteCode,
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryCards(context),
                  const SizedBox(height: 28),
                  _buildQuickActions(context),
                  const SizedBox(height: 28),
                  _buildMembersPreview(context, messController),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    final messController = Get.find<MessController>();
    final colorScheme = Theme.of(context).colorScheme;
    final local = AppLocalizations.of(context)!;
    return Obx(() {
      final isExpanded = messController.isExpandedFeatures.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: messController.toggleFeatures,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isExpanded
                  ? AppTheme.primary.withAlpha(20)
                  : colorScheme.surfaceContainerHighest.withAlpha(120),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? AppTheme.primary.withAlpha(50)
                    : colorScheme.outlineVariant.withAlpha(60),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isExpanded ? local.showLess : local.showMoreFeatures,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ──────────────────────────────────────────
  // No Mess State
  // ──────────────────────────────────────────
  Widget _buildNoMessState(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
              ),
              child: Icon(
                Icons.group_off_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary.withAlpha(153),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              local.notInMess,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              local.notInMessDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
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
    );
  }

  // ──────────────────────────────────────────
  // Header: Greeting + Mess Info + Actions
  // ──────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    MessController messController,
    String messName,
    String inviteCode,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final local = AppLocalizations.of(context)!;

    // Get current user's role from members list
    final currentUserId = controller.authService.currentUser.value?.uid;
    final currentMember = messController.members
        .cast<MemberModel?>()
        .firstWhere((m) => m?.userId == currentUserId, orElse: () => null);
    final userRole = currentMember?.role ?? 'member';
    final roleLabel = userRole[0].toUpperCase() + userRole.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Greeting + role badge + notification icon
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.heyGreeting(_userGreeting(context)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    local.manageMessEfficiently,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell
            Consumer(
              builder: (context, ref, child) {
                final unreadCount = ref.watch(unreadNotificationsCountProvider);
                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  alignment: const Alignment(0.65, -0.65),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => context.push(AppRoutes.notifications),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Mess info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primary.withAlpha(204)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(77),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          messName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(77),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                            ),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.vpn_key_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: inviteCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invite code copied!'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  inviteCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _userGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final local = AppLocalizations.of(context)!;
    if (hour < 12) return local.goodMorning;
    if (hour < 17) return local.goodAfternoon;
    return local.goodEvening;
  }

  // ──────────────────────────────────────────
  // Summary Cards
  // ──────────────────────────────────────────
  Widget _buildSummaryCards(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final local = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            local.overview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.people_rounded,
                label: local.members,
                value: '${controller.memberCount.value}',
                color: colorScheme.primary,
                bgColor: colorScheme.primary.withAlpha(26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.shopping_cart_rounded,
                label: local.bazar,
                value:
                    '৳${controller.totalBazarExpense.value.toStringAsFixed(0)}',
                color: const Color(0xFFFF6B6B),
                bgColor: const Color(0xFFFF6B6B).withAlpha(26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.restaurant_rounded,
                label: local.totalMeals,
                value: controller.myTotalMeals.value.toStringAsFixed(1),
                color: const Color(0xFFFFA726),
                bgColor: const Color(0xFFFFA726).withAlpha(26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.calculate_rounded,
                label: local.mealRate,
                value: '৳${controller.mealRate.value.toStringAsFixed(1)}',
                color: const Color(0xFF66BB6A),
                bgColor: const Color(0xFF66BB6A).withAlpha(26),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Quick Actions Grid
  // ──────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final local = AppLocalizations.of(context)!;
    final actions = [
      _QuickAction(
        icon: Icons.restaurant_menu_rounded,
        label: local.addMeal,
        color: const Color(0xFFFFA726), // Warm Orange
        onTap: () => context.push(AppRoutes.mealEntry),
      ),
      _QuickAction(
        icon: Icons.receipt_long_rounded,
        label: local.addExpense,
        color: const Color(0xFFFF6B6B), // Coral Red
        onTap: () => context.push(AppRoutes.addExpense),
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        label: local.addDeposit,
        color: const Color(0xFF42A5F5), // Sky Blue
        onTap: () => context.push(AppRoutes.addDeposit),
      ),
      _QuickAction(
        icon: Icons.bar_chart_rounded,
        label: local.balances,
        color: const Color(0xFF66BB6A), // Fresh Green
        onTap: () => context.push(AppRoutes.balanceSummary),
      ),
      _QuickAction(
        icon: Icons.analytics_rounded,
        label: local.report,
        color: const Color(0xFFAB47BC), // Orchid Purple
        onTap: () => context.push(AppRoutes.report),
      ),
      _QuickAction(
        icon: Icons.chat_bubble_rounded,
        label: local.chat,
        color: const Color(0xFF26A69A), // Deep Teal
        onTap: () {
          showMessage(context, 'Chat functionality coming soon!');
        }, // => context.push(AppRoutes.chat),
      ),
      _QuickAction(
        icon: Icons.checklist_rounded,
        label: local.approvals,
        color: const Color(0xFF78909C), // Slate Blue Grey
        onTap: () => context.push(AppRoutes.approvals),
      ),
      _QuickAction(
        icon: Icons.notifications_active_rounded,
        label: local.notifications,
        color: const Color(0xFFFFB74D), // Amber
        onTap: () => context.push(
          AppRoutes.notifications,
        ), // Note: update route if app_routes contains specific notifications path
      ),
      // _QuickAction(
      //   icon: Icons.home_work_rounded,
      //   label: 'Properties',
      //   color: const Color(0xFFE91E63), // Rose/Pink
      //   onTap: () => context.push(AppRoutes.tolet),
      // ),
      _QuickAction(
        icon: Icons.shopping_cart_checkout_rounded,
        label: local.shopping,
        color: const Color(0xFF00BFA5), // Teal
        onTap: () => context.push(AppRoutes.shoppingList),
      ),
      _QuickAction(
        icon: Icons.add_business_rounded,
        label: local.postProperty,
        color: const Color(0xFF4CAF50), // Olive Green
        onTap: () => showMessage(context, 'Post Property functionality coming soon!')// context.push(AppRoutes.propertyPost),
      ),
      _QuickAction(
        icon: Icons.list_alt_rounded,
        label: local.myListings,
        color: const Color(0xFFFF9800), // Dark Amber
        onTap: () => showMessage(context, 'My Listings functionality coming soon!')//context.push(AppRoutes.myListings),
      ),
      _QuickAction(
        icon: Icons.search_off_rounded,
        label: local.needBased,
        color: const Color(0xFF795548), // Warm Brown
        onTap: () => showMessage(context, 'Need Based functionality coming soon!')// context.push(AppRoutes.needBasedPost),
      ),
      _QuickAction(
        icon: Icons.monetization_on_rounded,
        label: local.credits,
        color: const Color(0xFFFFC107), // Golden Yellow
        onTap: () => showMessage(context, 'Credits functionality coming soon!')// context.push(AppRoutes.creditBalance),
      ),
      _QuickAction(
        icon: Icons.share_rounded,
        label: local.referral,
        color: const Color(0xFF2196F3), // Indigo Blue
        onTap: () => showMessage(context, 'Referral functionality coming soon!')// context.push(AppRoutes.referral),
      ),
      _QuickAction(
        icon: Icons.settings_suggest_rounded,
        label: local.settings,
        color: const Color(0xFF5C6BC0), // Soft Blue Indigo
        onTap: () => context.push(AppRoutes.settings),
      ),
    ];
    // List<_QuickAction> getDisplayFeatures() {
    //   return actions.take(4).toList();
    // }
    final messController = Get.find<MessController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            local.quickActions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.80,
          ),
          itemCount: messController.isExpandedFeatures.value
              ? actions.length
              : 4,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: action.onTap,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: action.color.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(action.icon, color: action.color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildExpandButton(context),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Members Preview (show top 3-4 members)
  // ──────────────────────────────────────────
  Widget _buildMembersPreview(
    BuildContext context,
    MessController messController,
  ) {
    final theme = Theme.of(context);
    final members = messController.members;
    final displayMembers = members.take(4).toList();

    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Members',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (members.length > 4)
              TextButton(
                onPressed: () => context.push(AppRoutes.members),
                child: Text(
                  'See All (${members.length})',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...displayMembers.map(
          (member) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    (member.fullName ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    member.fullName ?? member.email ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Logout Dialog
  // ──────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

// ──────────────────────────────────────────
// Summary Card Widget
// ──────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Quick Action Data
// ──────────────────────────────────────────
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
