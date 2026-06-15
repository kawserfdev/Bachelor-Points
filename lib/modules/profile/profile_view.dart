import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../core/routes/app_routes.dart';
import 'profile_controller.dart';

/// Profile tab — displays user info, completion progress, KYC status,
/// credit balance, referral info, and app settings.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;
    final displayName = controller.fullName.isNotEmpty
        ? controller.fullName.value
        : (user?.displayName ?? user?.email ?? 'User');
    final email = controller.email.isNotEmpty
        ? controller.email.value
        : (user?.email ?? '');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            children: [
              // ── Profile Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withAlpha(204),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildAvatar(displayName),
                    const SizedBox(height: 14),
                    // Verification badges row
                    if (controller.badges.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 6,
                          children: controller.badges.map((b) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: Colors.amber.shade300,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _badgeLabel(b.badgeType),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile Completion ──
              _buildCompletionCard(theme),
              const SizedBox(height: 16),

              // ── Credit & KYC Summary ──
              _buildCreditKycRow(theme, colorScheme),
              const SizedBox(height: 16),

              // ── Account Section ──
              _buildSectionHeader('Account', Icons.person_outline_rounded),
              _ProfileMenuItem(
                icon: Icons.edit_rounded,
                iconBgColor: const Color(0xFF42A5F5).withAlpha(26),
                iconColor: const Color(0xFF42A5F5),
                label: 'Edit Profile',
                onTap: () => context.push(AppRoutes.createProfile),
              ),
              _ProfileMenuItem(
                icon: Icons.verified_user_rounded,
                iconBgColor: controller.isKycVerified.value
                    ? const Color(0xFF66BB6A).withAlpha(26)
                    : const Color(0xFFFFA726).withAlpha(26),
                iconColor: controller.isKycVerified.value
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFFFFA726),
                label: _kycLabel(),
                trailing: _kycChip(),
                onTap: () => context.push(AppRoutes.kycVerification),
              ),
              _ProfileMenuItem(
                icon: Icons.monetization_on_rounded,
                iconBgColor: const Color(0xFFFFC107).withAlpha(26),
                iconColor: const Color(0xFFFF8F00),
                label: 'Credits',
                trailing: Text(
                  '${controller.creditBalance.value}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                onTap: () => context.push(AppRoutes.creditBalance),
              ),
              _ProfileMenuItem(
                icon: Icons.share_rounded,
                iconBgColor: const Color(0xFF2196F3).withAlpha(26),
                iconColor: const Color(0xFF2196F3),
                label: 'Referral',
                trailing: controller.pendingCommission > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${controller.pendingCommission}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () => context.push(AppRoutes.referral),
              ),
              const SizedBox(height: 12),

              // ── App Section ──
              _buildSectionHeader('App', Icons.settings_rounded),
              _ProfileMenuItem(
                icon: Icons.settings_rounded,
                iconBgColor: const Color(0xFF5C6BC0).withAlpha(26),
                iconColor: const Color(0xFF5C6BC0),
                label: 'Settings',
                onTap: () => context.push('/settings'),
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline_rounded,
                iconBgColor: const Color(0xFF66BB6A).withAlpha(26),
                iconColor: const Color(0xFF66BB6A),
                label: 'About',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                iconBgColor: const Color(0xFFFFA726).withAlpha(26),
                iconColor: const Color(0xFFFFA726),
                label: 'Help & Support',
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // ── Logout Button ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: BorderSide(color: Colors.red.withAlpha(77)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar Widget ──
  Widget _buildAvatar(String displayName) {
    if (controller.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white.withAlpha(51),
        backgroundImage: NetworkImage(controller.avatarUrl.value),
      );
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white.withAlpha(51),
      child: Text(
        displayName.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ── Profile Completion Card ──
  Widget _buildCompletionCard(ThemeData theme) {
    final pct = controller.completionPercent.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(13)),
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.withAlpha(51),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct >= 0.8
                        ? const Color(0xFF4CAF50)
                        : pct >= 0.4
                            ? const Color(0xFFFFA726)
                            : const Color(0xFFFF6B6B),
                  ),
                ),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Completion',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _completionMessage(pct),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  // ── Credit & KYC Row ──
  Widget _buildCreditKycRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Credit card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Credits',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${controller.creditBalance.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // KYC card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kycCardColor(),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      controller.isKycVerified.value
                          ? Icons.verified_rounded
                          : Icons.gpp_bad_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'KYC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _kycStatusLabel(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  String _kycLabel() {
    switch (controller.kycStatus.value) {
      case 'verified':
        return 'KYC Verified';
      case 'pending':
        return 'KYC Pending';
      case 'rejected':
        return 'KYC Rejected';
      default:
        return 'KYC Verification';
    }
  }

  Widget? _kycChip() {
    final status = controller.kycStatus.value;
    if (status == 'unverified') return null;
    Color color;
    String label;
    switch (status) {
      case 'verified':
        color = const Color(0xFF4CAF50);
        label = 'Verified';
        break;
      case 'pending':
        color = const Color(0xFFFFA726);
        label = 'Pending';
        break;
      case 'rejected':
        color = const Color(0xFFFF6B6B);
        label = 'Rejected';
        break;
      default:
        return null;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  String _kycStatusLabel() {
    switch (controller.kycStatus.value) {
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not Verified';
    }
  }

  Color _kycCardColor() {
    switch (controller.kycStatus.value) {
      case 'verified':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFA726);
      case 'rejected':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF78909C);
    }
  }

  String _completionMessage(double pct) {
    if (pct >= 1.0) return 'Your profile is fully complete!';
    if (pct >= 0.8) return 'Almost there — add your NID to finish!';
    if (pct >= 0.6) return 'Add your address and NID for full completion.';
    if (pct >= 0.4) return 'Add your phone number and address.';
    return 'Complete your profile to unlock all features.';
  }

  String _badgeLabel(String badgeType) {
    switch (badgeType) {
      case 'verified_user':
        return 'Verified User';
      case 'verified_property':
        return 'Verified Property';
      case 'verified_agency':
        return 'Verified Agency';
      default:
        return badgeType;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final authService = Get.find<AuthService>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? All local data will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await authService.signOut();
            },
            child:
                const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Profile Menu Item ──
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}