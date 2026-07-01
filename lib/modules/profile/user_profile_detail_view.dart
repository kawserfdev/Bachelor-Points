import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

import '../../core/responsive/responsive.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile_detail_model.dart';
import 'user_profile_detail_controller.dart';

/// Full-screen profile details page.
///
/// Shows the current user's personal info, profile completion ring,
/// mess membership, and account metadata — all driven reactively by
/// [UserProfileDetailController] which streams the Firestore document.
///
/// The layout is fully responsive:
/// * **Mobile** — single-column scrollable list (original layout).
/// * **Tablet / Desktop** — content centred with a constrained max width;
///   the info tiles are arranged in a 2-column grid to use horizontal space.
class UserProfileDetailView extends GetView<UserProfileDetailController> {
  const UserProfileDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context, l10n, profile, colorScheme, theme),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  context.responsivePadding,
                  0,
                  context.responsivePadding,
                  100,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          _buildCompletionCard(context, l10n, profile, theme, colorScheme),
                          const SizedBox(height: 20),
                          if (controller.messName.isNotEmpty) ...[
                            _buildMessCard(context, colorScheme, theme),
                            const SizedBox(height: 20),
                          ],
                          _buildSectionLabel(context, l10n.sectionPersonalInfo),
                          const SizedBox(height: 12),
                          _buildInfoTileGrid(
                            context,
                            children: [
                              _InfoTileData(
                                icon: Icons.person_outline_rounded,
                                label: l10n.fieldFullName,
                                value: profile.fullName.isNotEmpty ? profile.fullName : '—',
                                color: colorScheme.primary,
                              ),
                              _InfoTileData(
                                icon: Icons.email_outlined,
                                label: l10n.fieldEmail,
                                value: profile.email.isNotEmpty ? profile.email : '—',
                                color: const Color(0xFF42A5F5),
                              ),
                              _InfoTileData(
                                icon: Icons.phone_outlined,
                                label: l10n.fieldPhone,
                                value: profile.phoneNumber.isNotEmpty
                                    ? profile.phoneNumber
                                    : l10n.fieldNotSet,
                                color: const Color(0xFF66BB6A),
                              ),
                              _InfoTileData(
                                icon: Icons.location_on_outlined,
                                label: l10n.fieldAddress,
                                value: profile.address.isNotEmpty
                                    ? profile.address
                                    : l10n.fieldNotSet,
                                color: const Color(0xFFFFA726),
                              ),
                              if (profile.bio.isNotEmpty)
                                _InfoTileData(
                                  icon: Icons.info_outline_rounded,
                                  label: l10n.fieldBio,
                                  value: profile.bio,
                                  color: const Color(0xFFAB47BC),
                                ),
                            ],
                            theme: theme,
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel(context, l10n.sectionVerification),
                          const SizedBox(height: 12),
                          _buildInfoTileGrid(
                            context,
                            children: [
                              _InfoTileData(
                                icon: Icons.badge_outlined,
                                label: l10n.fieldNidNumber,
                                value: profile.nidNumber.isNotEmpty
                                    ? profile.nidNumber
                                    : l10n.fieldNotProvided,
                                color: const Color(0xFFEF5350),
                              ),
                            ],
                            theme: theme,
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel(context, l10n.sectionAccountInfo),
                          const SizedBox(height: 12),
                          _buildInfoTileGrid(
                            context,
                            children: [
                              _InfoTileData(
                                icon: Icons.fingerprint_rounded,
                                label: l10n.fieldUserId,
                                value: profile.uid,
                                color: colorScheme.tertiary,
                                copyable: true,
                              ),
                              if (profile.createdAt != null)
                                _InfoTileData(
                                  icon: Icons.calendar_today_outlined,
                                  label: l10n.fieldMemberSince,
                                  value: DateFormat('d MMM yyyy', langCode)
                                      .format(profile.createdAt!),
                                  color: const Color(0xFF26C6DA),
                                ),
                              if (profile.updatedAt != null)
                                _InfoTileData(
                                  icon: Icons.update_rounded,
                                  label: l10n.fieldLastUpdated,
                                  value: DateFormat('d MMM yyyy, h:mm a', langCode)
                                      .format(profile.updatedAt!),
                                  color: const Color(0xFF78909C),
                                ),
                            ],
                            theme: theme,
                          ),
                          const SizedBox(height: 28),
                          _buildEditButton(context, l10n, colorScheme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Sliver App Bar with avatar + name hero
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    UserProfileDetail profile,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          tooltip: l10n.editProfileTooltip,
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => context.push(AppRoutes.editProfile),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _HeroBackground(profile: profile, colorScheme: colorScheme),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Profile completion ring card
  // ─────────────────────────────────────────────────────────────
  Widget _buildCompletionCard(
    BuildContext context,
    AppLocalizations l10n,
    UserProfileDetail profile,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final pct = profile.completionPercent;
    final Color ringColor = pct >= 0.8
        ? const Color(0xFF4CAF50)
        : pct >= 0.4
        ? const Color(0xFFFFA726)
        : const Color(0xFFEF5350);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 6,
                  backgroundColor: colorScheme.outlineVariant.withAlpha(80),
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ringColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileCompletionLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _completionMessage(l10n, pct),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (pct < 1.0) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: Text(
                      l10n.completeProfileBtn,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Mess membership card
  // ─────────────────────────────────────────────────────────────
  Widget _buildMessCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withAlpha(230),
            colorScheme.tertiary.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.messName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (controller.userRole.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.userRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.people_alt_rounded, color: Colors.white54),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Responsive info-tile grid — single column on mobile, 2 columns on wide
  // ─────────────────────────────────────────────────────────────
  Widget _buildInfoTileGrid(
    BuildContext context, {
    required List<_InfoTileData> children,
    required ThemeData theme,
  }) {
    if (context.isWide && children.length > 1) {
      return Wrap(
        spacing: 12,
        runSpacing: 10,
        children: children
            .map((d) => _SizedInfoTile(
                  data: d,
                  theme: theme,
                  width: (MediaQuery.sizeOf(context).width.clamp(0, 760) - 12) / 2,
                ))
            .toList(),
      );
    }
    return Column(
      children: children
          .map((d) => _buildInfoTile(
                context: context,
                icon: d.icon,
                label: d.label,
                value: d.value,
                color: d.color,
                theme: theme,
                copyable: d.copyable,
              ))
          .toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
    bool copyable = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar(
                  l10n.copiedTitle,
                  l10n.userIdCopied,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Icon(
                Icons.copy_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.editProfile),
        icon: const Icon(Icons.edit, size: 20, color: Colors.white),
        label: Text(l10n.editProfileBtn),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _completionMessage(AppLocalizations l10n, double pct) {
    if (pct >= 1.0) return l10n.profileComplete2;
    if (pct >= 0.8) return l10n.profileAlmostDone2;
    if (pct >= 0.6) return l10n.profileGoodStart;
    if (pct >= 0.4) return l10n.profileAddPhoneAddress;
    return l10n.profileIncomplete;
  }
}

/// Plain data holder for an info tile, used by the responsive grid helper.
class _InfoTileData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool copyable;

  const _InfoTileData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.copyable = false,
  });
}

/// A fixed-width info tile used inside the 2-column [Wrap] on wide screens.
class _SizedInfoTile extends StatelessWidget {
  const _SizedInfoTile({required this.data, required this.theme, required this.width});

  final _InfoTileData data;
  final ThemeData theme;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(70),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(50),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: data.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (data.copyable)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: data.value));
                  Get.snackbar(
                    l10n.copiedTitle,
                    l10n.userIdCopied,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Flexible space hero background with avatar
// ─────────────────────────────────────────────────────────────
class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.profile, required this.colorScheme});

  final UserProfileDetail profile;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withAlpha(200),
            colorScheme.tertiary.withAlpha(160),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white.withAlpha(40),
                    backgroundImage: profile.avatarUrl.isNotEmpty
                        ? NetworkImage(profile.avatarUrl)
                        : null,
                    child: profile.avatarUrl.isEmpty
                        ? Text(
                            profile.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Add your logic to open camera/gallery here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.cameraNotImplemented),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withAlpha(200),
                              colorScheme.tertiary.withAlpha(160),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              profile.fullName.isNotEmpty ? profile.fullName : l10n.yourName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error state widget
// ─────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.somethingWentWrong,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryBtn),
            ),
          ],
        ),
      ),
    );
  }
}
