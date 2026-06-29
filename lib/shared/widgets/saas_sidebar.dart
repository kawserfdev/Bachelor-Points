import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/notifications/providers/notification_providers.dart';

/// A professional, collapsible, responsive SaaS-style navigation sidebar.
///
/// Features:
/// * **Collapsible** — runtime toggle between expanded (264px) and collapsed
///   icon-rail (72px) modes with a smooth animated transition.
/// * **Hover Effect** — [MouseRegion]-driven hover highlight on every tile
///   (desktop only; touch devices get the standard InkWell ripple).
/// * **Selected State** — automatically detects the active route via
///   [GoRouterState] and highlights the matching item with a filled
///   background, primary-coloured icon/text, and a left accent bar.
/// * **Icons** — every menu item has a Material rounded icon (with an optional
///   filled variant for the selected state).
/// * **Responsive** — designed to be placed directly in a [Row] on
///   desktop/tablet, or inside a [Drawer] on mobile. Pass [showToggle] =
///   `false` for tablet/mobile to lock the collapsed/expanded state.
///
/// This widget reuses the existing GoRouter navigation ([context.push] /
/// [context.go]) and the existing [AppRoutes] constants. It does **not** modify
/// GoRouter, route names, or any business logic. Logout delegates to
/// [HomeController.logout] via [Get.find].
///
/// Menu items (mapped to existing routes):
/// Dashboard → [AppRoutes.home], Meals → [AppRoutes.mealEntry],
/// Expenses → [AppRoutes.expenses], Deposits → [AppRoutes.addDeposit],
/// Shopping → [AppRoutes.shoppingList], Reports → [AppRoutes.report],
/// Notifications → [AppRoutes.notifications], Profile → [AppRoutes.profile],
/// Settings → [AppRoutes.settings], Property → [AppRoutes.tolet],
/// Logout → [HomeController.logout].
class SaasSidebar extends ConsumerStatefulWidget {
  /// Mess name shown in the sidebar header (expanded mode only).
  final String messName;

  /// Invite code shown in the header chip (expanded mode only).
  final String inviteCode;

  /// Initial expanded state. `true` = full sidebar, `false` = icon rail.
  ///
  /// Defaults to `true`. When the parent rebuilds with a different value
  /// (e.g. device type changed) the sidebar adapts automatically.
  final bool extended;

  /// Whether to show the collapse/expand toggle button.
  ///
  /// Set to `true` on desktop (user can collapse), `false` on tablet/mobile
  /// (state is locked to [extended]).
  final bool showToggle;

  const SaasSidebar({
    super.key,
    required this.messName,
    required this.inviteCode,
    this.extended = true,
    this.showToggle = true,
  });

  @override
  ConsumerState<SaasSidebar> createState() => _SaasSidebarState();
}

class _SaasSidebarState extends ConsumerState<SaasSidebar> {
  late bool _collapsed;

  // ── Layout constants ─────────────────────────────────────────────────────
  static const double _expandedWidth = 264;
  static const double _collapsedWidth = 72;
  static const Duration _animDuration = Duration(milliseconds: 280);
  static const Curve _animCurve = Curves.easeInOutCubicEmphasized;

  @override
  void initState() {
    super.initState();
    _collapsed = !widget.extended;
  }

  @override
  void didUpdateWidget(covariant SaasSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adapt when the parent changes the desired initial state (e.g. device
    // type changed from desktop to tablet).
    if (oldWidget.extended != widget.extended) {
      _collapsed = !widget.extended;
    }
  }

  void _toggleCollapsed() {
    if (!widget.showToggle) {
      return;
    }
    setState(() => _collapsed = !_collapsed);
  }

  /// Returns the current full route path, e.g. `/home` or `/meal-entry`.
  String get _currentLocation {
    return GoRouterState.of(context).matchedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final local = AppLocalizations.of(context)!;
    final location = _currentLocation;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final items = _buildItems(local);
    final width = _collapsed ? _collapsedWidth : _expandedWidth;

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      width: width,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          right: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header (brand / mess identity + collapse toggle) ──
            _SidebarHeader(
              collapsed: _collapsed,
              messName: widget.messName,
              inviteCode: widget.inviteCode,
              showToggle: widget.showToggle,
              onToggle: _toggleCollapsed,
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // ── Navigation items ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in items)
                    _SaasSidebarTile(
                      item: item,
                      selected: _isSelected(item, location),
                      collapsed: _collapsed,
                      badge: item.route == AppRoutes.notifications &&
                              unreadCount > 0
                          ? unreadCount
                          : null,
                      onTap: () => _handleTap(context, item),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Footer (collapse toggle when collapsed + logout) ──
            if (_collapsed && widget.showToggle)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _CollapseButton(
                  collapsed: true,
                  onTap: _toggleCollapsed,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _SaasSidebarTile(
                item: _SaasSidebarItem(
                  icon: Icons.logout_rounded,
                  label: local.logoutBtn,
                  route: '',
                  isLogout: true,
                ),
                selected: false,
                collapsed: _collapsed,
                onTap: () => _showLogoutDialog(context, local),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the ordered list of navigation menu items using localized labels
  /// and existing [AppRoutes] constants.
  List<_SaasSidebarItem> _buildItems(AppLocalizations local) {
    return [
      _SaasSidebarItem(
        icon: Icons.dashboard_rounded,
        selectedIcon: Icons.dashboard_rounded,
        label: local.overview,
        route: AppRoutes.home,
      ),
      _SaasSidebarItem(
        icon: Icons.restaurant_menu_rounded,
        label: local.meals,
        route: AppRoutes.mealEntry,
      ),
      _SaasSidebarItem(
        icon: Icons.receipt_long_rounded,
        label: local.expensesTitle,
        route: AppRoutes.expenses,
        matchPrefixes: const [AppRoutes.expenses, AppRoutes.addExpense],
      ),
      _SaasSidebarItem(
        icon: Icons.savings_rounded,
        label: local.deposits,
        route: AppRoutes.addDeposit,
        matchPrefixes: const [
          AppRoutes.addDeposit,
          AppRoutes.balanceSummary,
        ],
      ),
      _SaasSidebarItem(
        icon: Icons.shopping_cart_checkout_rounded,
        label: local.shopping,
        route: AppRoutes.shoppingList,
        matchPrefixes: const [
          AppRoutes.shoppingList,
          AppRoutes.addShoppingItem,
        ],
      ),
      _SaasSidebarItem(
        icon: Icons.analytics_rounded,
        label: local.report,
        route: AppRoutes.report,
      ),
      _SaasSidebarItem(
        icon: Icons.notifications_outlined,
        selectedIcon: Icons.notifications_rounded,
        label: local.notifications,
        route: AppRoutes.notifications,
      ),
      _SaasSidebarItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Profile',
        route: AppRoutes.profile,
        matchPrefixes: const [AppRoutes.profile, AppRoutes.profileDetail],
      ),
      _SaasSidebarItem(
        icon: Icons.settings_suggest_rounded,
        label: local.settings,
        route: AppRoutes.settings,
      ),
      _SaasSidebarItem(
        icon: Icons.home_work_outlined,
        selectedIcon: Icons.home_work_rounded,
        label: 'Property',
        route: AppRoutes.tolet,
        matchPrefixes: const ['/tolet'],
      ),
    ];
  }

  /// Determines whether [item] represents the currently active route.
  bool _isSelected(_SaasSidebarItem item, String location) {
    if (item.matchPrefixes != null) {
      for (final prefix in item.matchPrefixes!) {
        if (location == prefix || location.startsWith('$prefix/')) {
          return true;
        }
      }
      return false;
    }
    return location == item.route || location.startsWith('${item.route}/');
  }

  /// Handles navigation when a tile is tapped.
  ///
  /// * Dashboard ([AppRoutes.home]) uses [context.go] to avoid stacking
  ///   multiple home screens.
  /// * All other items use [context.push] so the user can navigate back.
  /// * Logout is handled separately via [_showLogoutDialog].
  void _handleTap(BuildContext context, _SaasSidebarItem item) {
    if (item.route == AppRoutes.home) {
      context.go(item.route);
    } else {
      context.push(item.route);
    }
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations local) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(local.logoutTitle),
        content: Text(local.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.find<HomeController>().logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(local.logoutBtn),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable description of a single sidebar navigation entry.
class _SaasSidebarItem {
  /// Icon shown when the item is **not** selected.
  final IconData icon;

  /// Optional filled/rounded variant shown when the item **is** selected.
  /// Falls back to [icon] when `null`.
  final IconData? selectedIcon;

  /// Localized display label.
  final String label;

  /// Route path from [AppRoutes] to navigate to (e.g. `/meal-entry`).
  /// Empty string for non-navigating items (e.g. logout).
  final String route;

  /// Optional list of route prefixes used for selected-state matching.
  ///
  /// When provided, the item is considered selected if the current location
  /// equals or starts with any of these prefixes. This lets a single menu
  /// entry (e.g. "Expenses") stay highlighted across related sub-routes
  /// (e.g. `/expenses` and `/add-expense`).
  final List<String>? matchPrefixes;

  /// Whether this item triggers the logout flow instead of navigation.
  final bool isLogout;

  const _SaasSidebarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.route,
    this.matchPrefixes,
    this.isLogout = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final bool collapsed;
  final String messName;
  final String inviteCode;
  final bool showToggle;
  final VoidCallback onToggle;

  const _SidebarHeader({
    required this.collapsed,
    required this.messName,
    required this.inviteCode,
    required this.showToggle,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          // Brand row
          Row(
            children: [
              _BrandLogo(),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'BachelorPoints',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!collapsed && showToggle)
                _CollapseIconButton(collapsed: false, onTap: onToggle),
            ],
          ),
          // Invite chip (expanded only)
          if (!collapsed) ...[
            const SizedBox(height: 16),
            _InviteChip(inviteCode: inviteCode),
          ],
        ],
      ),
    );
  }
}

/// Gradient brand logo container.
class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
    );
  }
}

/// Compact icon button used in the header to collapse the sidebar.
class _CollapseIconButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const _CollapseIconButton({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: collapsed ? 'Expand' : 'Collapse',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width collapse button shown at the footer when the sidebar is
/// collapsed (so the user can expand it again).
class _CollapseButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const _CollapseButton({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _CollapseIconButton(collapsed: collapsed, onTap: onTap),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invite chip
// ─────────────────────────────────────────────────────────────────────────────

class _InviteChip extends StatelessWidget {
  final String inviteCode;

  const _InviteChip({required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: inviteCode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite code copied!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vpn_key_rounded, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                inviteCode,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: cs.onSurface,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.copy, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation tile
// ─────────────────────────────────────────────────────────────────────────────

/// A single sidebar navigation tile with hover, selected, and collapsed states.
class _SaasSidebarTile extends StatefulWidget {
  final _SaasSidebarItem item;
  final bool selected;
  final bool collapsed;
  final int? badge;
  final VoidCallback onTap;

  const _SaasSidebarTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
    this.badge,
  });

  @override
  State<_SaasSidebarTile> createState() => _SaasSidebarTileState();
}

class _SaasSidebarTileState extends State<_SaasSidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selected = widget.selected;
    final hovered = _isHovered;

    // Background colour depends on state priority: selected > hover > default.
    Color bgColor;
    if (selected) {
      bgColor = cs.primaryContainer.withValues(alpha: 0.55);
    } else if (hovered) {
      bgColor = cs.surfaceContainerHighest.withValues(alpha: 0.7);
    } else {
      bgColor = Colors.transparent;
    }

    final iconColor = selected ? cs.primary : cs.onSurfaceVariant;
    final labelColor = selected ? cs.primary : cs.onSurfaceVariant;
    final labelWeight = selected ? FontWeight.w700 : FontWeight.w500;

    final tile = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0 : 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.collapsed
              ? _buildCollapsed(cs, iconColor, selected)
              : _buildExpanded(
                  theme, cs, iconColor, labelColor, labelWeight, selected),
        ),
      ),
    );

    // Show a tooltip when collapsed (labels are hidden).
    if (widget.collapsed) {
      return Tooltip(
        message: widget.item.label,
        preferBelow: false,
        child: tile,
      );
    }
    return tile;
  }

  /// Icon-only layout for collapsed mode.
  Widget _buildCollapsed(ColorScheme cs, Color iconColor, bool selected) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Left accent bar for selected state.
        if (selected)
          Positioned(
            left: -12,
            top: 4,
            bottom: 4,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),
        Center(
          child: Icon(
            selected ? (widget.item.selectedIcon ?? widget.item.icon) : widget.item.icon,
            size: 22,
            color: iconColor,
          ),
        ),
        // Notification badge.
        if (widget.badge != null)
          Positioned(
            right: -2,
            top: -2,
            child: _Badge(count: widget.badge!),
          ),
      ],
    );
  }

  /// Full row layout for expanded mode.
  Widget _buildExpanded(
    ThemeData theme,
    ColorScheme cs,
    Color iconColor,
    Color labelColor,
    FontWeight labelWeight,
    bool selected,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Left accent bar for selected state.
        if (selected)
          Positioned(
            left: -14,
            top: 4,
            bottom: 4,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),
        Row(
          children: [
            Icon(
              selected
                  ? (widget.item.selectedIcon ?? widget.item.icon)
                  : widget.item.icon,
              size: 20,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: labelWeight,
                  color: labelColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.badge != null) ...[
              const SizedBox(width: 8),
              _Badge(count: widget.badge!),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification badge
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: cs.surface, width: 1.5),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(
            color: cs.onError,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
