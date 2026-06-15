import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';

/// Explore tab — shows a grid of features accessible from the app.
class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = [
      _FeatureItem(
        icon: Icons.receipt_long_rounded,
        label: 'Expenses',
        color: const Color(0xFFFF6B6B),
        route: AppRoutes.expenses,
      ),
      _FeatureItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Balances',
        color: const Color(0xFF42A5F5),
        route: AppRoutes.balanceSummary,
      ),
      _FeatureItem(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        color: const Color(0xFFAB47BC),
        route: AppRoutes.report,
      ),
      _FeatureItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Chat',
        color: const Color(0xFF26A69A),
        route: AppRoutes.chat,
      ),
      _FeatureItem(
        icon: Icons.checklist_rounded,
        label: 'Approvals',
        color: const Color(0xFF78909C),
        route: AppRoutes.approvals,
      ),
      _FeatureItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        color: const Color(0xFFFFA726),
        route: AppRoutes.notifications,
      ),
      // ── Tolet Features ──
      _FeatureItem(
        icon: Icons.home_work_rounded,
        label: 'Properties',
        color: const Color(0xFFE91E63),
        route: AppRoutes.propertySearch,
      ),
      _FeatureItem(
        icon: Icons.add_business_rounded,
        label: 'Post Property',
        color: const Color(0xFF4CAF50),
        route: AppRoutes.propertyPost,
      ),
      _FeatureItem(
        icon: Icons.list_alt_rounded,
        label: 'My Listings',
        color: const Color(0xFFFF9800),
        route: AppRoutes.myListings,
      ),
      _FeatureItem(
        icon: Icons.search_off_rounded,
        label: 'Need Based',
        color: const Color(0xFF795548),
        route: AppRoutes.needBasedPost,
      ),
      _FeatureItem(
        icon: Icons.monetization_on_rounded,
        label: 'Credits',
        color: const Color(0xFFFFC107),
        route: AppRoutes.creditBalance,
      ),
      _FeatureItem(
        icon: Icons.share_rounded,
        label: 'Referral',
        color: const Color(0xFF2196F3),
        route: AppRoutes.referral,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Discover all features',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return GestureDetector(
                  onTap: () => context.push(feature.route),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withAlpha(13)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: feature.color.withAlpha(26),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            feature.icon,
                            color: feature.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          feature.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
