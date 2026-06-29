import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../property_search/property_search_controller.dart';

/// Desktop layout for the map-based property search.
///
/// Renders a large map placeholder on the left with a results sidebar on the
/// right. The radius [SegmentedButton] and nearby-places [FilterChip]s sit in
/// a floating card over the map — mirroring the mobile layout but scaled for
/// wide screens.
///
/// All filter mutations delegate to the existing [PropertySearchController]
/// reactive state and call its [PropertySearchController.searchNearby] method.
/// No new business logic is introduced.
class PropertyMapPanel extends StatelessWidget {
  const PropertyMapPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<PropertySearchController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Map area (left, flexible) ────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Map placeholder
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined,
                            size: 96, color: cs.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Map View',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Integrate google_maps_flutter for map display',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Radius control (top-left floating card)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.my_location_rounded,
                                color: cs.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Search Radius',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Obx(() => SegmentedButton<double>(
                                  segments: PropertySearchController.radiusOptions
                                      .map((r) => ButtonSegment<double>(
                                            value: r,
                                            label: Text('${r.toInt()} KM'),
                                          ))
                                      .toList(),
                                  selected: {controller.searchRadius.value},
                                  onSelectionChanged: (v) {
                                    controller.searchRadius.value = v.first;
                                    controller.searchNearby();
                                  },
                                )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nearby Places',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PropertySearchController.nearbyPlaces
                              .map((place) {
                            return Obx(() {
                              final sel =
                                  controller.nearbyPlaceFilter.value == place;
                              return FilterChip(
                                label: Text(place.capitalizeFirst ?? place),
                                selected: sel,
                                onSelected: (s) {
                                  controller.nearbyPlaceFilter.value =
                                      s ? place : '';
                                  controller.searchNearby();
                                },
                              );
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── Results sidebar (right, fixed width) ───────────────────────
          SizedBox(
            width: 320,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt_rounded,
                            color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Results',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${controller.properties.length}',
                                style: TextStyle(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  // Property list
                  Expanded(
                    child: Obx(() {
                      if (controller.properties.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_work_outlined,
                                  size: 48, color: cs.outline),
                              const SizedBox(height: 12),
                              Text(
                                'No properties found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.properties.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = controller.properties[index];
                          return _ResultTile(property: p);
                        },
                      );
                    }),
                  ),
                  // Footer button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.view_list_rounded),
                        label: const Text('View Full List'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.property});
  final dynamic property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () => context.push('/tolet/property?id=${property.id}'),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: property.images.isNotEmpty
              ? Image.network(property.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(cs))
              : _placeholder(cs),
        ),
      ),
      title: Text(
        property.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${property.area}, ${property.district}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '৳${property.price.toStringAsFixed(0)}',
        style: theme.textTheme.labelLarge?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.home_work_outlined, size: 20, color: cs.outline),
    );
  }
}
