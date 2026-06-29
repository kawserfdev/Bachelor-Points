import 'package:flutter/material.dart';

import '../domain/breakpoints.dart';
import '../domain/device_type.dart';
import '../domain/window_size_class.dart';

/// Convenience extensions on [BuildContext] and [double] for responsive
/// layout decisions.
///
/// These extensions are the primary way most call-sites will interact with the
/// responsive core. They read the nearest [MediaQuery] / [BoxConstraints] and
/// return a [DeviceType] or [WindowSizeClass], so widgets can branch their
/// build without manually wiring up a [LayoutBuilder].
///
/// Example:
/// ```dart
/// final padding = context.responsivePadding;
/// final isWide = context.isWide;
/// final columns = context.responsiveGridColumns;
/// ```
extension ResponsiveContextExtensions on BuildContext {
  // ---------------------------------------------------------------------------
  // Core lookups
  // ---------------------------------------------------------------------------

  /// The available width in logical pixels, taken from [MediaQuery].
  ///
  /// Falls back to [double.infinity] when no [MediaQuery] is available, which
  /// the [DeviceType] / [WindowSizeClass] helpers treat as the widest class.
  double get availableWidth {
    final mq = MediaQuery.maybeOf(this);
    return mq?.size.width ?? double.infinity;
  }

  /// The available height in logical pixels, taken from [MediaQuery].
  double get availableHeight {
    final mq = MediaQuery.maybeOf(this);
    return mq?.size.height ?? double.infinity;
  }

  // ---------------------------------------------------------------------------
  // Coarse device classification
  // ---------------------------------------------------------------------------

  /// The coarse [DeviceType] (mobile / tablet / desktop) for the current
  /// width.
  DeviceType get deviceType => DeviceType.fromWidth(availableWidth);

  /// `true` when the current width maps to [DeviceType.mobile].
  bool get isMobile => deviceType.isMobile;

  /// `true` when the current width maps to [DeviceType.tablet].
  bool get isTablet => deviceType.isTablet;

  /// `true` when the current width maps to [DeviceType.desktop].
  bool get isDesktop => deviceType.isDesktop;

  /// `true` when the current width maps to a tablet or desktop (i.e. "wide").
  bool get isWide => deviceType.isWide;

  // ---------------------------------------------------------------------------
  // Fine-grained window-size class
  // ---------------------------------------------------------------------------

  /// The fine-grained Material 3 [WindowSizeClass] for the current width.
  WindowSizeClass get windowSizeClass =>
      WindowSizeClass.fromWidth(availableWidth);

  /// `true` when the current width is in the compact range (< 600 dp).
  bool get isCompact => windowSizeClass.isCompact;

  /// `true` when the current width is in the medium range (600–839 dp).
  bool get isMedium => windowSizeClass.isMedium;

  /// `true` when the current width is in the expanded range (840–1199 dp).
  bool get isExpanded => windowSizeClass.isExpanded;

  /// `true` when the current width is in the large range (1200–1599 dp).
  bool get isLarge => windowSizeClass.isLarge;

  /// `true` when the current width is in the extra-large range (≥ 1600 dp).
  bool get isExtraLarge => windowSizeClass.isExtraLarge;

  // ---------------------------------------------------------------------------
  // Spacing & padding helpers
  // ---------------------------------------------------------------------------

  /// Adaptive horizontal page padding based on the current width.
  ///
  /// * compact  → [Breakpoints.paddingCompact] (16)
  /// * medium   → [Breakpoints.paddingMedium] (24)
  /// * expanded → [Breakpoints.paddingExpanded] (32)
  double get responsivePadding {
    if (isCompact) return Breakpoints.paddingCompact;
    if (isMedium || isExpanded) return Breakpoints.paddingMedium;
    return Breakpoints.paddingExpanded;
  }

  /// Adaptive horizontal page padding as an [EdgeInsets] symmetric value.
  EdgeInsets get responsivePaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: responsivePadding);

  /// Adaptive page padding as an [EdgeInsets] with both horizontal and
  /// vertical components.
  EdgeInsets responsivePaddingAll({double verticalFactor = 0.5}) =>
      EdgeInsets.fromLTRB(
        responsivePadding,
        responsivePadding * verticalFactor,
        responsivePadding,
        responsivePadding * verticalFactor,
      );

  /// Default spacing between grid items.
  double get responsiveGridSpacing => Breakpoints.gridSpacing;

  // ---------------------------------------------------------------------------
  // Grid helpers
  // ---------------------------------------------------------------------------

  /// A sensible default column count for a responsive grid at the current
  /// width.
  ///
  /// * compact  → 1
  /// * medium   → 2
  /// * expanded → 3
  /// * large    → 4
  /// * extraLarge → 5
  int get responsiveGridColumns {
    switch (windowSizeClass) {
      case WindowSizeClass.compact:
        return 1;
      case WindowSizeClass.medium:
        return 2;
      case WindowSizeClass.expanded:
        return 3;
      case WindowSizeClass.large:
        return 4;
      case WindowSizeClass.extraLarge:
        return 5;
    }
  }

  /// The recommended maximum content width for single-column layouts.
  double get contentMaxWidth => Breakpoints.contentMaxWidth;

  /// The recommended maximum content width for two-pane (master-detail)
  /// layouts.
  double get panedContentMaxWidth => Breakpoints.panedContentMaxWidth;

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  /// `true` when the width is wide enough to show a [NavigationRail] instead
  /// of a bottom [NavigationBar].
  bool get shouldUseNavigationRail =>
      availableWidth >= Breakpoints.navigationRailBreakpoint;

  /// `true` when the width is wide enough to show an *extended*
  /// [NavigationRail] (labels always visible).
  bool get shouldUseExtendedNavigationRail =>
      availableWidth >= Breakpoints.navigationRailExtendedBreakpoint;
}

/// Extensions on [double] for clamping and scaling values by breakpoint.
///
/// Useful for deriving sizes (icon sizes, card heights, etc.) that should
/// scale gently with the available width.
extension ResponsiveDoubleExtensions on double {
  /// Clamps this value to the inclusive range [`min`, `max`].
  double clampTo(double min, double max) =>
      this < min ? min : (this > max ? max : this);

  /// Linearly interpolates this value between [compact] and [expanded] based
  /// on the supplied [width].
  ///
  /// Below [Breakpoints.medium] the result is [compact]; above
  /// [Breakpoints.expanded] the result is [expanded]; in between it is
  /// linearly interpolated.
  double lerpByWidth(double width, {required double compact, required double expanded}) {
    if (width <= Breakpoints.medium) return compact;
    if (width >= Breakpoints.expanded) return expanded;
    final t = (width - Breakpoints.medium) /
        (Breakpoints.expanded - Breakpoints.medium);
    return compact + (expanded - compact) * t;
  }
}
