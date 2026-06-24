import 'package:bachelorpoints/core/routes/app_routes.dart';
import 'package:bachelorpoints/core/theme/app_theme.dart';
import 'package:bachelorpoints/data/models/property_model.dart';
import 'package:bachelorpoints/modules/tolet/property_search/tolet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class ToletView extends StatefulWidget {
  const ToletView({super.key});

  @override
  State<ToletView> createState() => _ToletViewState();
}

class _ToletViewState extends State<ToletView>
    with SingleTickerProviderStateMixin {
  late final ToletController controller;
  late final TextEditingController _searchController;
  late final AnimationController _shimmerController;

  static const List<String> _filters = [
    'All',
    'Seat',
    'Full Flat',
    'Office',
    'Shop',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<ToletController>();
    _searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader(theme)),

                // ── Search bar ──────────────────────────────────────────
                SliverToBoxAdapter(child: _buildSearchBar(theme)),

                // ── Filter pills ─────────────────────────────────────────
                SliverToBoxAdapter(child: _buildFilterPills(theme)),

                // ── Boosted section ──────────────────────────────────────
                SliverToBoxAdapter(child: _buildBoostedSection(theme)),

                // ── Listings ─────────────────────────────────────────────
                _buildListings(theme, colorScheme),

                // ── Bottom padding for FAB ───────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),

            // ── Floating Post Ad button ──────────────────────────────────
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildPostAdButton(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tolet',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Find your dream home 🏡',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.propertySearch),
                  tooltip: 'Advanced Search',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Search bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => controller.searchQuery.value = v,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search by area, title…',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primary,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _searchController.clear();
                controller.searchQuery.value = '';
              },
            );
          }),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Filter pills
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFilterPills(ThemeData theme) {
    return SizedBox(
      height: 52,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final filter = _filters[i];
            final selected =
                controller.selectedToletFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.selectedToletFilter.value = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary
                      : theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected
                        ? AppTheme.primary
                        : theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  filter,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Boosted section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBoostedSection(ThemeData theme) {
    return Obx(() {
      final boosted = controller.boostedListings;
      if (boosted.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  'Featured Properties',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: boosted.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _BoostedCard(property: boosted[i]),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Main listings sliver
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildListings(ThemeData theme, ColorScheme colorScheme) {
    return Obx(() {
      if (controller.isLoadingListings.value) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _ShimmerCard(animation: _shimmerController),
            childCount: 3,
          ),
        );
      }

      final listings = controller.filteredListings;

      if (listings.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(theme),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _PropertyCard(property: listings[i]),
          ),
          childCount: listings.length,
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty state
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 48,
              color: AppTheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No listings found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different filter or search term.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              controller.searchQuery.value = '';
              controller.selectedToletFilter.value = 'All';
              _searchController.clear();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Floating Post Ad button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPostAdButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.propertyPost),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.primary.withBlue(220),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Post Ad',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Boosted card (horizontal scroll)
// ═══════════════════════════════════════════════════════════════════════════
class _BoostedCard extends StatelessWidget {
  const _BoostedCard({required this.property});
  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/tolet/property?id=${property.id}'),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  _PropertyImage(
                    images: property.images,
                    height: 120,
                    width: double.infinity,
                  ),
                  // Boosted badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _Badge(
                      label: '🔥 Boosted',
                      color: Colors.deepOrange.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${property.price.toStringAsFixed(0)}/mo',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${property.area}, ${property.district}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Main property card (vertical list)
// ═══════════════════════════════════════════════════════════════════════════
class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property});
  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image with badges ──────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                _PropertyImage(
                  images: property.images,
                  height: 180,
                  width: double.infinity,
                ),
                // Verified badge top-left
                Positioned(
                  top: 10,
                  left: 10,
                  child: _Badge(label: '✓ VERIFIED', color: Colors.green.shade600),
                ),
                // Boosted badge top-right
                if (property.isBoosted)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _Badge(
                      label: '🔥 BOOSTED',
                      color: Colors.deepOrange.shade600,
                    ),
                  ),
                // Price overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৳${property.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '/month',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  property.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14,
                        color: AppTheme.primary.withOpacity(0.8)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${property.area}, ${property.district}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Info row
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoChip(
                        icon: Icons.bed_rounded,
                        label: '${property.bedrooms ?? 0} Bed',
                      ),
                      _VertDivider(),
                      _InfoChip(
                        icon: Icons.bathtub_rounded,
                        label: '${property.bathrooms ?? 0} Bath',
                      ),
                      _VertDivider(),
                      _InfoChip(
                        icon: Icons.layers_rounded,
                        label: 'Floor ${property.floor ?? 'N/A'}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context
                            .push('/tolet/property?id=${property.id}'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // Chat / Request action
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Chat / Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
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

// ═══════════════════════════════════════════════════════════════════════════
// Shimmer placeholder card
// ═══════════════════════════════════════════════════════════════════════════
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.animation});
  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Opacity(
          opacity: 0.4 + 0.6 * animation.value,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.12),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(
                            width: double.infinity, height: 18, color: base),
                        const SizedBox(height: 8),
                        _ShimmerBox(width: 160, height: 14, color: base),
                        const SizedBox(height: 12),
                        _ShimmerBox(
                            width: double.infinity, height: 44, color: base),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ShimmerBox(
                                  width: double.infinity,
                                  height: 44,
                                  color: base),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ShimmerBox(
                                  width: double.infinity,
                                  height: 44,
                                  color: base),
                            ),
                          ],
                        ),
                      ],
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
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
  });
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Network image with a fallback placeholder.
class _PropertyImage extends StatelessWidget {
  const _PropertyImage({
    required this.images,
    required this.height,
    required this.width,
  });
  final List<String> images;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return _placeholder();
    return Image.network(
      images.first,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE8E8F0),
      child: const Center(
        child: Icon(Icons.home_rounded, size: 40, color: Color(0xFFBBBBCC)),
      ),
    );
  }
}

/// Small colored badge chip.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Icon + label info chip.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon,
            size: 15,
            color: AppTheme.primary.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}

/// Vertical divider for info row.
class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }
}
