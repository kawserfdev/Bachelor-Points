import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/property_model.dart';

/// Desktop data-table view of property listings.
///
/// Renders the same [PropertyModel] list as the card grid, but in a compact
/// tabular layout suited to wide screens. Row taps navigate to the property
/// detail page — the same route the mobile cards use. Pure presentation; no
/// data mutations.
class PropertyListingTable extends StatelessWidget {
  const PropertyListingTable({
    super.key,
    required this.properties,
  });

  /// The (already filtered) properties to display.
  final List<PropertyModel> properties;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (properties.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, size: 48, color: cs.outline),
            const SizedBox(height: 12),
            Text(
              'No properties found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            cs.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          dataRowMinHeight: 64,
          dataRowMaxHeight: 72,
          columnSpacing: 24,
          horizontalMargin: 20,
          columns: const [
            DataColumn(
              label: Text('Property', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            DataColumn(
              label: Text('Type', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            DataColumn(
              label: Text('Location', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            DataColumn(
              label: Text('Price', style: TextStyle(fontWeight: FontWeight.w700)),
              numeric: true,
            ),
            DataColumn(
              label: Text('Details', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            DataColumn(
              label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
          rows: properties.map((p) => _buildRow(context, p)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, PropertyModel p) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DataRow(
      onSelectChanged: (_) =>
          context.push('${AppRoutes.propertyDetail}?id=${p.id}'),
      cells: [
        // Property (thumbnail + title)
        DataCell(
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: p.images.isNotEmpty
                      ? Image.network(
                          p.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbPlaceholder(cs),
                        )
                      : _thumbPlaceholder(cs),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: Text(
                  p.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Type
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              p.propertyType.capitalizeFirst ?? p.propertyType,
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // Location
        DataCell(
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${p.area}, ${p.district}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Price
        DataCell(
          Text(
            '৳${p.price.toStringAsFixed(0)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // Details (bed/bath/floor/area)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailChip(icon: Icons.bed_outlined, label: '${p.bedrooms}'),
              const SizedBox(width: 10),
              _DetailChip(icon: Icons.bathtub_outlined, label: '${p.bathrooms}'),
              const SizedBox(width: 10),
              _DetailChip(icon: Icons.layers_outlined, label: 'F${p.floor}'),
              const SizedBox(width: 10),
              _DetailChip(
                  icon: Icons.crop_square_outlined,
                  label: '${p.areaSqft.toInt()}'),
            ],
          ),
        ),
        // Status (boosted / verified)
        DataCell(
          p.isBoosted
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch,
                          size: 14, color: Colors.deepOrange.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Boosted',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.deepOrange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          size: 14, color: Colors.green.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _thumbPlaceholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.home_work_outlined, size: 24, color: cs.outline),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
