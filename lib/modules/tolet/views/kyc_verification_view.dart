import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../referral/referral_controller.dart';

/// KYC verification screen for user NID upload.
class KycVerificationView extends GetView<ReferralController> {
  const KycVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.security, size: 64, color: Colors.blue),
        const SizedBox(height: 16),
        Text('Verify Your Identity', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Upload your NID card to get the Verified User badge. This is required for referral withdrawals.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        // Upload area
        Container(width: double.infinity, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          const Text('Tap to upload NID image', style: TextStyle(fontWeight: FontWeight.w500)),
        ])),
        const SizedBox(height: 16),
        TextField(decoration: const InputDecoration(labelText: 'NID Number', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('Submit for Verification'))),
      ])),
    );
  }
}