import 'package:bachelorpoints/core/responsive/responsive.dart';
import 'package:bachelorpoints/modules/tolet/property_search/property_search_controller.dart';
import 'package:bachelorpoints/modules/tolet/widgets/desktop/property_map_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Map-based property search with radius/nearby filters.
class PropertyMapSearchView extends GetView<PropertySearchController> {
  const PropertyMapSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Search'), actions: [
        IconButton(icon: const Icon(Icons.list), tooltip: 'List View', onPressed: () => context.pop()),
      ]),
      body: ResponsiveBuilder(
        builder: (context, deviceType, sizeClass, constraints) {
          switch (deviceType) {
            case DeviceType.desktop:
              return const PropertyMapPanel();
            case DeviceType.tablet:
            case DeviceType.mobile:
              return _buildMobileBody(context);
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mobile / tablet body — preserves the original Stack layout
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileBody(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.grey[200], child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.map, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Map View', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          Text('Integrate google_maps_flutter for map display', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]))),
        Positioned(top: 12, left: 12, right: 12, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          const Text('Radius:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Obx(() => SegmentedButton<double>(
            segments: PropertySearchController.radiusOptions.map((r) => ButtonSegment<double>(value: r, label: Text('${r.toInt()} KM'))).toList(),
            selected: {controller.searchRadius.value},
            onSelectionChanged: (v) { controller.searchRadius.value = v.first; controller.searchNearby(); },
          ))),
        ])))),
        Positioned(top: 100, left: 12, right: 12, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nearby Places', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Obx(() => Row(children: PropertySearchController.nearbyPlaces.map((place) {
            final sel = controller.nearbyPlaceFilter.value == place;
            return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(place.capitalizeFirst ?? place), selected: sel, onSelected: (s) { controller.nearbyPlaceFilter.value = s ? place : ''; controller.searchNearby(); }));
          }).toList()))),
        ])))),
        Positioned(bottom: 24, left: 12, right: 12, child: Obx(() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${controller.properties.length} properties found', style: const TextStyle(fontWeight: FontWeight.w600)),
          FilledButton(onPressed: () => context.pop(), child: const Text('View List')),
        ]))))),
      ],
    );
  }
}