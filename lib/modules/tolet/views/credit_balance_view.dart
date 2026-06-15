import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../credit/credit_controller.dart';
import '../../../services/credit_service.dart';

/// Credit balance and transaction history view.
class CreditBalanceView extends GetView<CreditController> {
  const CreditBalanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Credits')),
      body: Column(children: [
        // Balance card
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withAlpha(180)]), borderRadius: BorderRadius.circular(20)), child: Column(children: [
          const Text('Your Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Obx(() => Text('${controller.balance.value} Credits', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800))),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Buy Credits', style: TextStyle(color: Colors.white)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70))),
        ])),
        // Pricing
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Credit Costs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
        const SizedBox(height: 8),
        _buildPricingRow(context, Icons.phone, 'Unlock Contact', '${CreditService.unlockContactCost} credits'),
        _buildPricingRow(context, Icons.location_on, 'Unlock Address', '${CreditService.unlockAddressCost} credits'),
        _buildPricingRow(context, Icons.post_add, 'Property Post', '${CreditService.propertyPostCost} credits'),
        _buildPricingRow(context, Icons.rocket_launch, 'Boost Listing', '${CreditService.boostListingCost} credits'),
      ]),
    );
  }

  Widget _buildPricingRow(BuildContext context, IconData icon, String label, String cost) {
    return ListTile(leading: Icon(icon), title: Text(label), trailing: Text(cost, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)));
  }
}