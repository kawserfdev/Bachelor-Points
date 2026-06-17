import 'package:bachelorpoints/modules/explore/detailspage_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/toletItem_model.dart';
import 'explore_controller.dart';

/// Explore tab — shows a grid of features and tolet listings.
class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ── Core Features (always visible) ──
    final coreFeatures = [
      _FeatureItem(Icons.receipt_long_rounded, 'Expenses', AppRoutes.expenses),
      _FeatureItem(
        Icons.account_balance_wallet_rounded,
        'Balances',
        AppRoutes.balanceSummary,
      ),
      _FeatureItem(Icons.bar_chart_rounded, 'Reports', AppRoutes.report),
      _FeatureItem(Icons.chat_bubble_rounded, 'Chat', AppRoutes.chat),
      _FeatureItem(Icons.checklist_rounded, 'Approvals', AppRoutes.approvals),
      _FeatureItem(
        Icons.notifications_outlined,
        'Notifications',
        AppRoutes.notifications,
      ),
    ];

    // ── Tolet Features (shown when expanded) ──
    final toletFeatures = [
      _FeatureItem(
        Icons.home_work_rounded,
        'Properties',
        AppRoutes.propertySearch,
      ),
      _FeatureItem(
        Icons.add_business_rounded,
        'Post Property',
        AppRoutes.propertyPost,
      ),
      _FeatureItem(Icons.list_alt_rounded, 'My Listings', AppRoutes.myListings),
      _FeatureItem(
        Icons.search_off_rounded,
        'Need Based',
        AppRoutes.needBasedPost,
      ),
      _FeatureItem(
        Icons.monetization_on_rounded,
        'Credits',
        AppRoutes.creditBalance,
      ),
      _FeatureItem(Icons.share_rounded, 'Referral', AppRoutes.referral),
    ];

    List<_FeatureItem> getDisplayFeatures() {
      if (controller.isExpandedFeatures.value) {
        return [...coreFeatures, ...toletFeatures];
      }
      return coreFeatures.take(4).toList();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  // _buildSectionHeader(
                  //   context,
                  //   title: 'Explore',
                  //   subtitle: 'Discover all features',
                  // ),
                  // const SizedBox(height: 24),

                  // // ── Feature Grid ──
                  // Obx(() => _buildFeatureGrid(context, getDisplayFeatures())),
                  // const SizedBox(height: 24),

                  // // ── Expand / Collapse Button ──
                  // _buildExpandButton(context),
                  // const SizedBox(height: 24),

                  // ── Tolet Feature Section (collapsible) ──
                  // Obx(() {
                  //   if (!controller.isExpandedFeatures.value) {
                  //     return const SizedBox.shrink();
                  //   }
                  //   return Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _buildSectionHeader(
                  //         context,
                  //         title: 'Tolet',
                  //         subtitle: 'Find your dream home',
                  //       ),
                  //       const SizedBox(height: 24),
                  //       _buildFeatureGrid(context, toletFeatures),
                  //       const SizedBox(height: 32),
                  //     ],
                  //   );
                  // }),

                  // ── Featured Listings Section ──
                  _buildSectionHeader(
                    context,
                    title: 'Tolet',
                    subtitle: 'Find your dream venue',
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  _buildSearchBar(context),
                  const SizedBox(height: 16),

                  // Filter pills
                  _buildFilterPills(context),
                  const SizedBox(height: 16),

                  // Listing cards
                  _buildListings(context),
                ],
              ),
            ),

            // ── Floating "Post Ad" Button ──
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.primary.withAlpha(100),
                ),
                onPressed: () => context.push(AppRoutes.propertyPost),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'Post Ad (বিজ্ঞাপন দিন)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  //  Section Header
  // ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withAlpha(140),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  //  Expand / Collapse Button
  // ────────────────────────────────────────────────────────
  Widget _buildExpandButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isExpanded = controller.isExpandedFeatures.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.toggleFeatures,
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
                  isExpanded ? 'Show Less' : 'Show More Features',
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

  // ────────────────────────────────────────────────────────
  //  Feature Grid
  // ────────────────────────────────────────────────────────
  Widget _buildFeatureGrid(BuildContext context, List<_FeatureItem> features) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(feature.route),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(70),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withAlpha(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      feature.icon,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    feature.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  //  Search Bar
  // ────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurface.withAlpha(140),
        ),
        hintText: 'Search locations (যেমন: ধানমন্ডি)...',
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withAlpha(100),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(120),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  //  Filter Pills
  // ────────────────────────────────────────────────────────
  Widget _buildFilterPills(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterPill(context, 'All', 'All (সব)'),
          const SizedBox(width: 8),
          _buildFilterPill(context, 'Seat', 'Seats (সিট)'),
          const SizedBox(width: 8),
          _buildFilterPill(context, 'Full Flat', 'Full Flat (পুরো ফ্ল্যাট)'),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context,
    String filterValue,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isSelected = controller.selectedToletFilter.value == filterValue;
      return GestureDetector(
        onTap: () => controller.selectedToletFilter.value = filterValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary
                : colorScheme.surfaceContainerHighest.withAlpha(180),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : colorScheme.outlineVariant.withAlpha(60),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface.withAlpha(200),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  // ────────────────────────────────────────────────────────
  //  Listings
  // ────────────────────────────────────────────────────────
  Widget _buildListings(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final currentFilter = controller.selectedToletFilter.value;
      final filteredList = mockTolets.where((item) {
        if (currentFilter == 'All') return true;
        return item.type == currentFilter;
      }).toList();

      if (filteredList.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: colorScheme.onSurface.withAlpha(60),
                ),
                const SizedBox(height: 12),
                Text(
                  'No listings found for this category.',
                  style: TextStyle(color: colorScheme.onSurface.withAlpha(140)),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredList.length,
        itemBuilder: (context, index) =>
            _buildListingCard(context, filteredList[index]),
      );
    });
  }

  Widget _buildListingCard(BuildContext context, ToletItem tolet) {
    final colorScheme = Theme.of(context).colorScheme;
    final seatsLeft = tolet.totalSeats - tolet.occupiedSeats;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(50)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image with badges ──
          Stack(
            children: [
              Image.network(
                tolet.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withAlpha(60),
                    ),
                  ),
                ),
              ),
              // Verified badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Seats left badge
              if (seatsLeft > 0)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$seatsLeft SEATS LEFT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Details ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tolet.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳ ${tolet.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'PER MONTH',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withAlpha(100),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: colorScheme.onSurface.withAlpha(140),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tolet.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primary),
                          foregroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsPage(item: tolet),
                            ),
                          );
                        },
                        child: const Text(
                          'Details (বিস্তারিত)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: Text(
                          tolet.type == 'Seat'
                              ? 'Request to Join'
                              : 'Book Flat (বুক করুন)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
//  Private data class
// ────────────────────────────────────────────────────────
class _FeatureItem {
  final IconData icon;
  final String label;
  final String route;

  const _FeatureItem(this.icon, this.label, this.route);
}
