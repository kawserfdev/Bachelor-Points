import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../referral/referral_controller.dart';

/// Referral system view.
class ReferralView extends GetView<ReferralController> {
  const ReferralView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Referral')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Referral info
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.deepPurple.shade400]), borderRadius: BorderRadius.circular(16)), child: Column(children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text('Invite Friends & Earn', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Earn commission when friends buy credits', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Obx(() => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(10)), child: Row(children: [Expanded(child: Text(controller.getReferralLink('userId'), style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {})]))),
        ])),
        const SizedBox(height: 20),
        // KYC section
        Text('KYC Verification', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Icon(Icons.verified_user, size: 40, color: controller.isKycVerified.value ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(controller.isKycVerified.value ? 'Verified' : 'Not Verified', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(controller.isKycVerified.value ? 'Your NID is verified' : 'Verify your NID to earn badges', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ])),
          if (!controller.isKycVerified.value) FilledButton(onPressed: () {}, child: const Text('Verify')),
        ]))),
        const SizedBox(height: 12),
        Text('Badges', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Obx(() => Wrap(spacing: 8, runSpacing: 8, children: controller.badges.map((b) => Chip(avatar: const Icon(Icons.verified, size: 16, color: Colors.green), label: Text(b.badgeType.replaceAll('_', ' ').capitalizeFirst ?? ''))).toList())),
        if (controller.badges.isEmpty) Text('No badges yet. Complete verifications to earn badges.', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
      ])),
    );
  }
}