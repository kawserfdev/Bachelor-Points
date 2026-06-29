import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tolet/credit/credit_controller.dart';
import '../../property_detail/property_detail_controller.dart';

/// Desktop two-column layout for the property detail page.
///
/// Left column: image gallery + description + info tiles.
/// Right column: price card, owner info with unlock rows, action buttons.
///
/// All data access goes through the existing [PropertyDetailController] and
/// [CreditController] — no new business logic is introduced.
class PropertyDetailPanel extends StatelessWidget {
  const PropertyDetailPanel({
    super.key,
    required this.controller,
    required this.propertyId,
  });

  final PropertyDetailController controller;
  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentUserId = AppAuthService().currentUser?.uid ?? '';

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final p = controller.property.value;
      if (p == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 12),
              Text(
                'Property not found',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left column: gallery + description ─────────────────
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image gallery
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 420,
                          child: p.images.isNotEmpty
                              ? PageView.builder(
                                  itemCount: p.images.length,
                                  itemBuilder: (c, i) => Image.network(
                                    p.images[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(cs),
                                  ),
                                )
                              : _imagePlaceholder(cs),
                        ),
                      ),
                      if (p.images.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              'Swipe to view ${p.images.length} photos',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Title + type chip
                      Text(
                        p.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _typeChip(context, p.propertyType),
                          if (p.isBoosted) _boostedChip(context),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Info tiles
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.bed_outlined,
                              label: 'Bedrooms',
                              value: '${p.bedrooms}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.bathtub_outlined,
                              label: 'Bathrooms',
                              value: '${p.bathrooms}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.layers_outlined,
                              label: 'Floor',
                              value: '${p.floor}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.crop_square_outlined,
                              label: 'Area',
                              value: '${p.areaSqft.toInt()} sqft',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (p.description.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // ── Right column: price + owner + actions ───────────────
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Rent',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${p.price.toStringAsFixed(0)}',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '/month',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location card
                      _infoCard(
                        context,
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        value: controller.getAddressDisplay(currentUserId),
                      ),
                      const SizedBox(height: 16),

                      // Owner info section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline,
                                    color: cs.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Owner Info',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildUnlockRow(
                              context,
                              Icons.phone_outlined,
                              'Phone',
                              controller.getPhoneNumber(currentUserId),
                              controller.hasUnlockedContact(currentUserId),
                              '5 Credits',
                              () => _unlock(context, propertyId, currentUserId,
                                  isContact: true),
                            ),
                            const SizedBox(height: 12),
                            _buildUnlockRow(
                              context,
                              Icons.location_on_outlined,
                              'Address',
                              controller.getAddressDisplay(currentUserId),
                              controller.hasUnlockedAddress(currentUserId),
                              '10 Credits',
                              () => _unlock(context, propertyId, currentUserId,
                                  isContact: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.push('/tolet/chat?propertyId=${p.id}'),
                          icon: const Icon(Icons.chat_outlined),
                          label: const Text('Chat with Owner'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(
                                  const SnackBar(content: Text('Report submitted'))),
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text('Report Listing'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _imagePlaceholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.home_work_outlined, size: 80, color: cs.outline),
      ),
    );
  }

  Widget _typeChip(BuildContext context, String type) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.capitalizeFirst ?? type,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _boostedChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            'Boosted',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String value}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool unlocked,
    String cost,
    VoidCallback onUnlock,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? Colors.green.shade50
            : cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked ? Colors.green.shade100 : cs.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: unlocked ? Colors.green.shade700 : cs.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!unlocked)
            FilledButton.tonal(
              onPressed: onUnlock,
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(cost, style: const TextStyle(fontSize: 12)),
            )
          else
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  void _unlock(BuildContext context, String propertyId, String userId,
      {required bool isContact}) {
    final creditCtrl = Get.find<CreditController>();
    final label = isContact ? 'Phone' : 'Address';
    final cost = isContact ? 5 : 10;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unlock $label'),
        content: Text('Unlock for $cost credits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = isContact
                  ? await creditCtrl.unlockContact(propertyId, userId)
                  : await creditCtrl.unlockAddress(propertyId, userId);
              if (ok) {
                await controller.loadProperty(propertyId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label unlocked!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(creditCtrl.error.value.isNotEmpty
                          ? creditCtrl.error.value
                          : 'Failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Unlock ($cost Credits)'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: cs.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
