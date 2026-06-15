import 'package:bachelorpoints/modules/tolet/property_search/property_search_controller.dart';
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
      body: Column(
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
      ),
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