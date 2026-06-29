import 'package:bachelorpoints/core/responsive/responsive.dart';
import 'package:bachelorpoints/core/theme/app_theme.dart';
import 'package:bachelorpoints/modules/tolet/property_search/property_search_controller.dart';
import 'package:bachelorpoints/modules/tolet/widgets/desktop/property_filters.dart';
import 'package:bachelorpoints/modules/tolet/widgets/desktop/property_grid.dart';
import 'package:bachelorpoints/modules/tolet/widgets/desktop/property_listing_table.dart';
import 'package:bachelorpoints/modules/tolet/widgets/desktop/property_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/property_model.dart';

/// Property search screen with filter chips and list view.
class PropertySearchView extends GetView<PropertySearchController> {
  const PropertySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Map Search',
            onPressed: () => context.push(AppRoutes.propertyMapSearch),
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType, sizeClass, constraints) {
          switch (deviceType) {
            case DeviceType.desktop:
              return _DesktopSearchBody(controller: controller);
            case DeviceType.tablet:
            case DeviceType.mobile:
              return _buildMobileBody(context, theme, colorScheme);
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mobile / tablet body — preserves the original layout
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by area, road, title...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => controller.searchQuery.value = v,
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildFilterChip(context, controller.division.value.isEmpty ? 'Division' : controller.division.value, () => _pickOption(context, 'Division', PropertySearchController.divisions, (v) { controller.division.value = v; controller.search(); })),
              const SizedBox(width: 8),
              _buildFilterChip(context, controller.propertyType.value.isEmpty ? 'Type' : controller.propertyType.value.capitalize!, () => _pickOption(context, 'Type', PropertySearchController.propertyTypes, (v) { controller.propertyType.value = v; controller.search(); })),
              const SizedBox(width: 8),
              _buildFilterChip(context, '₹${controller.minPrice.value.toInt()}-₹${controller.maxPrice.value.toInt()}', () => _showPriceDialog(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.error.isNotEmpty) return Center(child: Text(controller.error.value));
            if (controller.properties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No properties found', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: controller.search, icon: const Icon(Icons.search), label: const Text('Search')),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.properties.length,
              itemBuilder: (context, index) {
                final p = controller.properties[index];
                return _buildPropertyCard(context, p);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: const TextStyle(fontSize: 13)), const SizedBox(width: 4), const Icon(Icons.arrow_drop_down, size: 18)]),
      ),
    );
  }

  void _pickOption(BuildContext context, String title, List<String> options, ValueChanged<String> onPick) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        children: options.map((o) => ListTile(title: Text(o.capitalizeFirst ?? o), onTap: () { onPick(o); Navigator.pop(ctx); })).toList(),
      ),
    );
  }

  void _showPriceDialog(BuildContext context) {
    RangeValues values = RangeValues(controller.minPrice.value, controller.maxPrice.value);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Price Range'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            RangeSlider(values: values, min: 0, max: 100000, divisions: 100, labels: RangeLabels('₹${values.start.toInt()}', '₹${values.end.toInt()}'), onChanged: (v) => setState(() => values = v)),
            Text('₹${values.start.toInt()} - ₹${values.end.toInt()}'),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () { controller.minPrice.value = values.start; controller.maxPrice.value = values.end; Navigator.pop(ctx); controller.search(); }, child: const Text('Apply')),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel p) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => context.push('${AppRoutes.propertyDetail}?id=${p.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 120, height: 120,
              child: p.images.isNotEmpty
                  ? Image.network(p.images.first, fit: BoxFit.cover)
                  : Container(color: colorScheme.surfaceContainerHighest, child: const Icon(Icons.home, size: 48)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${p.area}, ${p.district}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const Spacer(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('₹${p.price.toInt()}/mo', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                    if (p.isBoosted) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)), child: const Text('Boosted', style: TextStyle(fontSize: 10, color: Colors.orange))),
                  ]),
                  Row(children: [
                    _buildInfoChip(Icons.bed, '${p.bedrooms}'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.bathtub, '${p.bathrooms}'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.square_foot, '${p.areaSqft.toInt()}sqft'),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey[500]),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Desktop search body — filters sidebar + grid/table toggle
// ═══════════════════════════════════════════════════════════════════════════
class _DesktopSearchBody extends StatefulWidget {
  const _DesktopSearchBody({required this.controller});
  final PropertySearchController controller;

  @override
  State<_DesktopSearchBody> createState() => _DesktopSearchBodyState();
}

class _DesktopSearchBodyState extends State<_DesktopSearchBody> {
  late final TextEditingController _searchController;
  bool _tableMode = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top bar: search + view toggle + map action ──────────────
          Row(
            children: [
              Expanded(
                child: PropertySearchBar(
                  controller: _searchController,
                  onChanged: (v) => controller.searchQuery.value = v,
                  onSubmitted: (v) => controller.searchQuery.value = v,
                  hintText: 'Search by area, road, title...',
                ),
              ),
              const SizedBox(width: 16),
              _buildViewToggle(theme),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: () => context.push(AppRoutes.propertyMapSearch),
                icon: const Icon(Icons.map_outlined),
                tooltip: 'Map Search',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Main content: filters sidebar + results ────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filters sidebar
                SizedBox(width: 280, child: PropertyFilters()),
                const SizedBox(width: 24),

                // Results
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.error.isNotEmpty) {
                      return Center(child: Text(controller.error.value));
                    }
                    if (controller.properties.isEmpty) {
                      return _buildEmptyState(theme);
                    }
                    final properties = controller.properties;
                    if (_tableMode) {
                      return SingleChildScrollView(
                        child: PropertyListingTable(properties: properties),
                      );
                    }
                    return SingleChildScrollView(
                      child: PropertyGrid(properties: properties),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // View toggle (grid / table)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildViewToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(
            theme,
            icon: Icons.grid_view_rounded,
            label: 'Grid',
            selected: !_tableMode,
            onTap: () => setState(() => _tableMode = false),
          ),
          _toggleButton(
            theme,
            icon: Icons.table_rows_rounded,
            label: 'Table',
            selected: _tableMode,
            onTap: () => setState(() => _tableMode = true),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 48,
              color: AppTheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No properties found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search term.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.controller.search,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}