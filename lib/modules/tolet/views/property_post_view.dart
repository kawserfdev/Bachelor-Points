import 'package:bachelorpoints/modules/tolet/property_post/property_post_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Create/edit property listing form.
class PropertyPostView extends GetView<PropertyPostController> {
  const PropertyPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.isEditing ? 'Edit Property' : 'Post Property')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: TextEditingController(text: controller.title.value), decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()), onChanged: (v) => controller.title.value = v),
        const SizedBox(height: 12),
        TextField(controller: TextEditingController(text: controller.description.value), decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3, onChanged: (v) => controller.description.value = v),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: controller.propertyType.value, decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()), items: ['family', 'bachelor', 'hostel', 'mess', 'office', 'shop', 'land'].map((t) => DropdownMenuItem(value: t, child: Text(t.capitalizeFirst ?? t))).toList(), onChanged: (v) => controller.propertyType.value = v ?? 'bachelor'),
        const SizedBox(height: 12),
        TextField(controller: TextEditingController(text: controller.price.value.toString()), decoration: const InputDecoration(labelText: 'Price (BDT/month)', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.price.value = double.tryParse(v) ?? 0),
        const SizedBox(height: 16),
        Text('Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(controller: TextEditingController(text: controller.division.value), decoration: const InputDecoration(labelText: 'Division', border: OutlineInputBorder()), onChanged: (v) => controller.division.value = v),
        const SizedBox(height: 8),
        TextField(controller: TextEditingController(text: controller.district.value), decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()), onChanged: (v) => controller.district.value = v),
        const SizedBox(height: 8),
        TextField(controller: TextEditingController(text: controller.upazila.value), decoration: const InputDecoration(labelText: 'Upazila', border: OutlineInputBorder()), onChanged: (v) => controller.upazila.value = v),
        const SizedBox(height: 8),
        TextField(controller: TextEditingController(text: controller.area.value), decoration: const InputDecoration(labelText: 'Area', border: OutlineInputBorder()), onChanged: (v) => controller.area.value = v),
        const SizedBox(height: 8),
        TextField(controller: TextEditingController(text: controller.road.value), decoration: const InputDecoration(labelText: 'Road', border: OutlineInputBorder()), onChanged: (v) => controller.road.value = v),
        const SizedBox(height: 16),
        Text('Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: TextEditingController(text: controller.bedrooms.value.toString()), decoration: const InputDecoration(labelText: 'Bedrooms', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.bedrooms.value = int.tryParse(v) ?? 1)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: TextEditingController(text: controller.bathrooms.value.toString()), decoration: const InputDecoration(labelText: 'Bathrooms', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.bathrooms.value = int.tryParse(v) ?? 1)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: TextEditingController(text: controller.floor.value.toString()), decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.floor.value = int.tryParse(v) ?? 1)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: TextEditingController(text: controller.areaSqft.value.toString()), decoration: const InputDecoration(labelText: 'Area (sqft)', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.areaSqft.value = double.tryParse(v) ?? 0)),
        ]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: Obx(() => FilledButton(onPressed: controller.isSubmitting.value ? null : () => _submit(context), child: Text(controller.isSubmitting.value ? 'Saving...' : (controller.isEditing ? 'Update Draft' : 'Save as Draft'))))),
        if (controller.isEditing) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _submitForReview(context), child: const Text('Submit for Review'))),
        ],
        const SizedBox(height: 20),
      ])),
    );
  }

  void _submit(BuildContext context) {
    // In real app, get userId/name from auth
    controller.saveDraft('userId', 'Owner Name', '01XXXXXXXXX').then((ok) {
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved as draft!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    });
  }

  void _submitForReview(BuildContext context) {
    controller.submitForReview().then((ok) {
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted for review!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    });
  }
}