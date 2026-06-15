import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../need_based_post/need_based_post_controller.dart';

/// Need-based post: Tenant posts what they need, landlords contact them.
class NeedBasedPostView extends GetView<NeedBasedPostController> {
  const NeedBasedPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Need Based Posts')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showCreateDialog(context), icon: const Icon(Icons.add), label: const Text('Post Need')),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.posts.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.post_add, size: 64, color: Colors.grey[400]), const SizedBox(height: 12), Text('No need-based posts yet', style: TextStyle(color: Colors.grey[600]))]));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.posts.length,
          itemBuilder: (context, i) {
            final p = controller.posts[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(radius: 18, child: Text(p.userName.isNotEmpty ? p.userName[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.w700))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(p.userName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Text(p.propertyType.capitalizeFirst ?? p.propertyType, style: TextStyle(fontSize: 11, color: Colors.blue[700]))),
                  ]),
                  const SizedBox(height: 10),
                  Text('Need ${p.bedrooms} Bed ${p.propertyType.capitalizeFirst}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 4), Text('${p.area}, ${p.district}', style: TextStyle(color: Colors.grey[600], fontSize: 13))]),
                  const SizedBox(height: 4),
                  Text('Budget: ₹${p.minBudget.toInt()} - ₹${p.maxBudget.toInt()}', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                  if (p.description.isNotEmpty) ...[const SizedBox(height: 6), Text(p.description, style: TextStyle(fontSize: 13, color: Colors.grey[700]))],
                ]),
              ),
            );
          },
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('What do you need?'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: controller.propertyType.value, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()), items: ['family', 'bachelor', 'hostel', 'mess'].map((t) => DropdownMenuItem(value: t, child: Text(t.capitalizeFirst ?? t))).toList(), onChanged: (v) => controller.propertyType.value = v ?? 'bachelor'),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Bedrooms', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.bedrooms.value = int.tryParse(v) ?? 1)), const SizedBox(width: 8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Bathrooms', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.bathrooms.value = int.tryParse(v) ?? 1))]),
        const SizedBox(height: 10),
        TextField(decoration: const InputDecoration(labelText: 'Area', border: OutlineInputBorder()), onChanged: (v) => controller.area.value = v),
        const SizedBox(height: 10),
        TextField(decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()), onChanged: (v) => controller.district.value = v),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Min Budget', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.minBudget.value = double.tryParse(v) ?? 0)), const SizedBox(width: 8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Max Budget', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => controller.maxBudget.value = double.tryParse(v) ?? 0))]),
        const SizedBox(height: 10),
        TextField(decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2, onChanged: (v) => controller.description.value = v),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          Navigator.pop(ctx);
          await controller.createPost('userId', 'User', '01XXXXXXXXX');
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted!'), backgroundColor: Colors.green));
        }, child: const Text('Post')),
      ],
    ));
  }
}