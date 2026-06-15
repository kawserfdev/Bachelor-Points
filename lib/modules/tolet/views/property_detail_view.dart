import 'package:bachelorpoints/modules/tolet/property_detail/property_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../credit/credit_controller.dart';
import '../../../core/auth/auth_service.dart';

/// Full property detail view with gallery, info, and unlock system.
class PropertyDetailView extends GetView<PropertyDetailController> {
  const PropertyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final propertyId = GoRouterState.of(context).uri.queryParameters['id'] ?? '';
    final currentUserId = AppAuthService().currentUser?.uid ?? '';

    // Load property on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.property.value == null) controller.loadProperty(propertyId);
    });

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        final p = controller.property.value;
        if (p == null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 12),
          Text('Property not found', style: TextStyle(color: Colors.grey[600])),
        ]));

        return CustomScrollView(slivers: [
          SliverAppBar(expandedHeight: 280, pinned: true, flexibleSpace: FlexibleSpaceBar(
            background: p.images.isNotEmpty
                ? PageView.builder(itemCount: p.images.length, itemBuilder: (c, i) => Image.network(p.images[i], fit: BoxFit.cover))
                : Container(color: colorScheme.surfaceContainerHighest, child: const Icon(Icons.home, size: 80)),
          )),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(p.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${p.price.toInt()}', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800)),
                const Text('/month', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ]),
            const SizedBox(height: 6),
            Row(children: [Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]), const SizedBox(width: 4), Expanded(child: Text(controller.getAddressDisplay(currentUserId), style: TextStyle(color: Colors.grey[600], fontSize: 14)))]),
            if (p.isBoosted) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade200)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.rocket_launch, size: 16, color: Colors.orange), SizedBox(width: 4), Text('Boosted', style: TextStyle(color: Colors.orange, fontSize: 12))]))],
            const SizedBox(height: 20),
            Row(children: [
              _buildInfoTile(context, Icons.bed, 'Bedrooms', '${p.bedrooms}'),
              const SizedBox(width: 8),
              _buildInfoTile(context, Icons.bathtub, 'Bathrooms', '${p.bathrooms}'),
              const SizedBox(width: 8),
              _buildInfoTile(context, Icons.layers, 'Floor', '${p.floor}'),
              const SizedBox(width: 8),
              _buildInfoTile(context, Icons.square_foot, 'Area', '${p.areaSqft.toInt()} sqft'),
            ]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)), child: Text(p.propertyType.capitalizeFirst ?? p.propertyType, style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 13))),
            const SizedBox(height: 20), const Divider(),
            if (p.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(p.description, style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 16), const Divider(),
            ],
            const SizedBox(height: 16),
            Text('Owner Info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildUnlockRow(context, Icons.phone, 'Phone', controller.getPhoneNumber(currentUserId), controller.hasUnlockedContact(currentUserId), '5 Credits', () => _unlock(context, propertyId, currentUserId, isContact: true)),
            const SizedBox(height: 12),
            _buildUnlockRow(context, Icons.location_on, 'Address', controller.getAddressDisplay(currentUserId), controller.hasUnlockedAddress(currentUserId), '10 Credits', () => _unlock(context, propertyId, currentUserId, isContact: false)),
            const SizedBox(height: 26),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => context.push('/tolet/chat?propertyId=${p.id}'), icon: const Icon(Icons.chat), label: const Text('Chat with Owner'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted'))), icon: const Icon(Icons.flag_outlined), label: const Text('Report Listing'))),
            const SizedBox(height: 40),
          ]))),
        ]);
      }),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withAlpha(60), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black.withAlpha(13))), child: Column(children: [Icon(icon, size: 22, color: cs.primary), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]))])));
  }

  Widget _buildUnlockRow(BuildContext context, IconData icon, String label, String value, bool unlocked, String cost, VoidCallback onUnlock) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: unlocked ? Colors.green.shade50 : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: unlocked ? Colors.green : Colors.grey[600], size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))])),
      if (!unlocked) FilledButton.tonal(onPressed: onUnlock, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)), child: Text(cost, style: const TextStyle(fontSize: 12))) else const Icon(Icons.check_circle, color: Colors.green),
    ]);
  }

  void _unlock(BuildContext context, String propertyId, String userId, {required bool isContact}) {
    final creditCtrl = Get.find<CreditController>();
    final label = isContact ? 'Phone' : 'Address';
    final cost = isContact ? 5 : 10;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Unlock $label'),
      content: Text('Unlock for $cost credits?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          Navigator.pop(ctx);
          final ok = isContact ? await creditCtrl.unlockContact(propertyId, userId) : await creditCtrl.unlockAddress(propertyId, userId);
          if (ok) {
            await controller.loadProperty(propertyId);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label unlocked!'), backgroundColor: Colors.green));
          } else {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(creditCtrl.error.value.isNotEmpty ? creditCtrl.error.value : 'Failed'), backgroundColor: Colors.red));
          }
        }, child: Text('Unlock ($cost Credits)')),
      ],
    ));
  }
}