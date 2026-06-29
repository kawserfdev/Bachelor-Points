import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/property_model.dart';

/// Desktop-styled property listing card.
///
/// A pure presentation widget that renders a single [PropertyModel] as a
/// polished card with image, badges, price overlay, title, location and info
/// chips. Tapping the card navigates to the property detail page — the same
/// route the mobile card uses, so no new navigation logic is introduced.
///
/// This widget is stateless and performs no data mutations.
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    this.compact = false,
  });

  /// The property to render.
  final PropertyModel property;

  /// When `true`, renders a slimmer card suitable for dense grids.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final imageHeight = compact ? 150.0 : 190.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('${AppRoutes.propertyDetail}?id=${property.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with badges + price overlay ──────────────────────
              Stack(
                children: [
                  _PropertyImage(
                    images: property.images,
                    height: imageHeight,
                    width: double.infinity,
                  ),
                  // Verified badge (top-left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Badge(
                      label: '✓ VERIFIED',
                      color: Colors.green.shade600,
                    ),
                  ),
                  // Boosted badge (top-right)
                  if (property.isBoosted)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _Badge(
                        label: '🔥 BOOSTED',
                        color: Colors.deepOrange.shade600,
                      ),
                    ),
                  // Price overlay (bottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
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
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
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

              // ── Card body ──────────────────────────────────────────────
              Expanded(
                child: Padding(
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
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppTheme.primary.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${property.area}, ${property.district}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Info chips row
                      const Divider(height: 20),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.bed_outlined,
                            label: '${property.bedrooms}',
                          ),
                          const _VertDivider(),
                          _InfoChip(
                            icon: Icons.bathtub_outlined,
                            label: '${property.bathrooms}',
                          ),
                          const _VertDivider(),
                          _InfoChip(
                            icon: Icons.layers_outlined,
                            label: 'F${property.floor}',
                          ),
                          const _VertDivider(),
                          _InfoChip(
                            icon: Icons.crop_square_outlined,
                            label: '${property.areaSqft.toInt()}',
                          ),
                        ],
                      ),
                    ],
                  ),
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
// Shared helpers (desktop-styled, non-deprecated)
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
    if (images.isEmpty) return _placeholder(context);
    return Image.network(
      images.first,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(context),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _placeholder(context);
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 40,
          color: cs.outline,
        ),
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
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.primary.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

/// Vertical divider for info row.
class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}
