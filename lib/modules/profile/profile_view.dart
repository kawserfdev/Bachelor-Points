import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../core/responsive/responsive.dart';
import '../../services/auth_service.dart';
import '../../core/routes/app_routes.dart';
import 'profile_controller.dart';

/// Profile tab — displays user info, completion progress, KYC status,
/// credit balance, referral info, and app settings.
///
/// The layout is fully responsive:
/// * **Mobile** — single-column scrollable list (original layout).
/// * **Tablet / Desktop** — content centred with a constrained max width;
///   the menu items are arranged in a 2-column grid to use horizontal space.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        padding: EdgeInsets.all(context.responsivePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
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
                                        _badgeLabel(l10n, b.badgeType),
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
                  _buildCompletionCard(context, l10n, theme),
                  const SizedBox(height: 16),

                  // ── Credit Summary ──
                  _buildCreditCard(l10n, theme, colorScheme),
                  const SizedBox(height: 16),

                  // ── Account Section ──
                  _buildSectionHeader(l10n.profileSectionAccount, Icons.person_outline_rounded),
                  _buildMenuGroup(
                    context,
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.account_circle_outlined,
                        iconBgColor: const Color(0xFF6366F1).withAlpha(26),
                        iconColor: const Color(0xFF6366F1),
                        label: l10n.myProfileDetails,
                        onTap: () => context.push(AppRoutes.profileDetail),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.monetization_on_rounded,
                        iconBgColor: const Color(0xFFFFC107).withAlpha(26),
                        iconColor: const Color(0xFFFF8F00),
                        label: l10n.credits,
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
                        label: l10n.referral,
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
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── App Section ──
                  _buildSectionHeader(l10n.profileSectionApp, Icons.settings_rounded),
                  _buildMenuGroup(
                    context,
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.settings_rounded,
                        iconBgColor: const Color(0xFF5C6BC0).withAlpha(26),
                        iconColor: const Color(0xFF5C6BC0),
                        label: l10n.settings,
                        onTap: () => context.push(AppRoutes.settings),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.info_outline_rounded,
                        iconBgColor: const Color(0xFF66BB6A).withAlpha(26),
                        iconColor: const Color(0xFF66BB6A),
                        label: l10n.about,
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        iconBgColor: const Color(0xFFFFA726).withAlpha(26),
                        iconColor: const Color(0xFFFFA726),
                        label: l10n.helpSupport,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Logout Button ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, l10n),
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: Text(
                        l10n.logoutBtn,
                        style: const TextStyle(color: Colors.red),
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
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Responsive menu group — single column on mobile, 2-column grid on wide
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMenuGroup(BuildContext context, {required List<Widget> children}) {
    // On wide screens, lay the menu items out in a 2-column grid so the
    // horizontal space is used. On mobile they stack vertically as before.
    if (context.isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 4.2,
        ),
        itemBuilder: (context, i) => children[i],
      );
    }
    return Column(children: children);
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
  Widget _buildCompletionCard(BuildContext context, AppLocalizations l10n, ThemeData theme) {
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
                  l10n.profileCompletionLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _completionMessage(l10n, pct),
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

  // ── Credit Card ──
  Widget _buildCreditCard(AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Text(
                l10n.credits,
                style: const TextStyle(
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

  String _completionMessage(AppLocalizations l10n, double pct) {
    if (pct >= 1.0) return l10n.profileComplete;
    if (pct >= 0.8) return l10n.profileAlmostDone;
    if (pct >= 0.6) return l10n.profileAddAddressNid;
    if (pct >= 0.4) return l10n.profileAddPhone;
    return l10n.profileIncomplete;
  }

  String _badgeLabel(AppLocalizations l10n, String badgeType) {
    switch (badgeType) {
      case 'verified_user':
        return l10n.badgeVerifiedUser;
      case 'verified_property':
        return l10n.badgeVerifiedProperty;
      case 'verified_agency':
        return l10n.badgeVerifiedAgency;
      default:
        return badgeType;
    }
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    final authService = Get.find<AuthService>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await authService.signOut();
            },
            child: Text(l10n.logoutBtn, style: const TextStyle(color: Colors.red)),
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
