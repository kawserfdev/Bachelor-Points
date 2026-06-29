import 'package:flutter/material.dart';

import '../domain/breakpoints.dart';
import 'responsive_builder.dart';

/// A destination in a [ResponsiveScaffold].
///
/// Mirrors the shape of [NavigationDestination] / [NavigationRailDestination]
/// so the same data can drive both the bottom [NavigationBar] and the side
/// [NavigationRail].
class ResponsiveDestination {
  /// Creates a responsive navigation destination.
  const ResponsiveDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
  });

  /// The icon shown when the destination is unselected.
  final Widget icon;

  /// The icon shown when the destination is selected.
  final Widget? selectedIcon;

  /// The text label for the destination.
  final String label;

  /// An optional badge count shown on the icon.
  final int? badge;

  /// An optional tooltip shown on long press / hover.
  final String? tooltip;
}

/// A Material 3 adaptive scaffold that switches between a bottom
/// [NavigationBar] (mobile) and a side [NavigationRail] (tablet/desktop)
/// based on the available width.
///
/// It is **navigation-framework agnostic**: it does not import or depend on
/// GoRouter, Riverpod, or any business logic. The caller supplies the
/// destinations, the current [selectedIndex], and an [onDestinationSelected]
/// callback — making it a drop-in shell for a GoRouter `ShellRoute` builder
/// or a hand-rolled navigation controller.
///
/// Behaviour by device class:
///
/// * **Mobile** (`width < 600`): bottom [NavigationBar] with the [body]
///   filling the remaining space.
/// * **Tablet** (`600 ≤ width < 1200`): collapsed [NavigationRail] (icons
///   only, labels on tap) on the start side.
/// * **Desktop** (`width ≥ 1200`): extended [NavigationRail] (icons + labels
///   always visible) on the start side.
///
/// Example (inside a GoRouter `ShellRoute` builder):
/// ```dart
/// ShellRoute(
///   builder: (context, state, child) => ResponsiveScaffold(
///     destinations: [
///       ResponsiveDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
///       ResponsiveDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Report'),
///     ],
///     selectedIndex: _computeIndex(state),
///     onDestinationSelected: (i) => context.go(_routeForIndex(i)),
///     body: child,
///   ),
/// )
/// ```
class ResponsiveScaffold extends StatelessWidget {
  /// Creates an adaptive scaffold.
  const ResponsiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomSheet,
    this.railBackgroundColor,
    this.railElevation,
    this.railWidth,
    this.useExtendedRailAt,
    this.useRailAt,
    this.safeArea = true,
  });

  /// The navigation destinations. Must contain at least one entry.
  final List<ResponsiveDestination> destinations;

  /// The index of the currently selected destination.
  final int selectedIndex;

  /// Called when the user selects a destination.
  final ValueChanged<int> onDestinationSelected;

  /// The main content of the scaffold.
  final Widget body;

  /// An optional [AppBar] shown at the top of the [body].
  final PreferredSizeWidget? appBar;

  /// The background color of the scaffold body. When `null`, the theme's
  /// [ColorScheme.surface] is used.
  final Color? backgroundColor;

  /// An optional floating action button.
  final Widget? floatingActionButton;

  /// An optional persistent bottom sheet.
  final Widget? bottomSheet;

  /// The background color of the [NavigationRail]. When `null`, the theme
  /// default is used.
  final Color? railBackgroundColor;

  /// The elevation of the [NavigationRail]. When `null`, the theme default
  /// is used.
  final double? railElevation;

  /// The width of the [NavigationRail] when collapsed. Defaults to 72.
  final double? railWidth;

  /// The width at which the rail switches to extended mode. Defaults to
  /// [Breakpoints.navigationRailExtendedBreakpoint] (1200 dp).
  final double? useExtendedRailAt;

  /// The width at which the bottom navigation bar is replaced by the rail.
  /// Defaults to [Breakpoints.navigationRailBreakpoint] (600 dp).
  final double? useRailAt;

  /// Whether to wrap the body in a [SafeArea]. Defaults to `true`.
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    assert(destinations.isNotEmpty, 'destinations must not be empty');
    assert(
      selectedIndex >= 0 && selectedIndex < destinations.length,
      'selectedIndex is out of range',
    );

    final railBreakpoint = useRailAt ?? Breakpoints.navigationRailBreakpoint;
    final extendedBreakpoint =
        useExtendedRailAt ?? Breakpoints.navigationRailExtendedBreakpoint;

    return ResponsiveBuilder(
      builder: (context, deviceType, sizeClass, constraints) {
        final useRail = constraints.maxWidth >= railBreakpoint;
        final useExtended = constraints.maxWidth >= extendedBreakpoint;

        if (!useRail) {
          return _buildMobile(context);
        }
        return _buildWide(context, useExtended);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: bottom NavigationBar
  // ---------------------------------------------------------------------------

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: safeArea
          ? SafeArea(
              top: appBar == null,
              child: body,
            )
          : body,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: _badge(d.icon, d.badge),
              selectedIcon: _badge(d.selectedIcon ?? d.icon, d.badge),
              label: d.label,
              tooltip: d.tooltip,
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tablet / Desktop: side NavigationRail
  // ---------------------------------------------------------------------------

  Widget _buildWide(BuildContext context, bool extended) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: extended,
            backgroundColor: railBackgroundColor,
            elevation: railElevation,
            minWidth: railWidth,
            leading: floatingActionButton,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: _badge(d.icon, d.badge),
                  selectedIcon: _badge(d.selectedIcon ?? d.icon, d.badge),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: safeArea
                ? SafeArea(
                    top: appBar == null,
                    child: body,
                  )
                : body,
          ),
        ],
      ),
      bottomSheet: bottomSheet,
    );
  }

  // ---------------------------------------------------------------------------
  // Badge helper
  // ---------------------------------------------------------------------------

  Widget _badge(Widget icon, int? count) {
    if (count == null || count <= 0) return icon;
    return Badge(
      label: Text('$count'),
      child: icon,
    );
  }
}
