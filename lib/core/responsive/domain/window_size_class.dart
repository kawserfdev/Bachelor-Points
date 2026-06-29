import 'breakpoints.dart';
import 'device_type.dart';

/// Fine-grained Material Design 3 window-size class.
///
/// This is the full five-step classification used by the Material layout
/// system. Prefer [DeviceType] when you only need a coarse mobile / tablet /
/// desktop split; use [WindowSizeClass] when you need to differentiate, for
/// example, medium tablets from expanded desktops.
///
/// This enum has **no Flutter dependency**.
enum WindowSizeClass {
  /// Width < 600 dp. Phones in portrait.
  compact,

  /// 600 ≤ width < 840 dp. Phones in landscape, small tablets.
  medium,

  /// 840 ≤ width < 1200 dp. Large tablets, foldables, desktop.
  expanded,

  /// 1200 ≤ width < 1600 dp. Desktop.
  large,

  /// width ≥ 1600 dp. Large / ultra-wide desktop.
  extraLarge;

  /// Returns the [WindowSizeClass] for the given [width] in logical pixels.
  ///
  /// The value is clamped to a non-negative number so that unconstrained
  /// `LayoutBuilder` constraints resolve to [extraLarge] instead of throwing.
  static WindowSizeClass fromWidth(double width) {
    final w = width < 0 ? 0.0 : width;
    if (w < Breakpoints.medium) return WindowSizeClass.compact;
    if (w < Breakpoints.expanded) return WindowSizeClass.medium;
    if (w < Breakpoints.large) return WindowSizeClass.expanded;
    if (w < Breakpoints.extraLarge) return WindowSizeClass.large;
    return WindowSizeClass.extraLarge;
  }

  /// Whether this class is [compact].
  bool get isCompact => this == WindowSizeClass.compact;

  /// Whether this class is [medium].
  bool get isMedium => this == WindowSizeClass.medium;

  /// Whether this class is [expanded].
  bool get isExpanded => this == WindowSizeClass.expanded;

  /// Whether this class is [large].
  bool get isLarge => this == WindowSizeClass.large;

  /// Whether this class is [extraLarge].
  bool get isExtraLarge => this == WindowSizeClass.extraLarge;

  /// Whether this class is compact or medium (i.e. "small").
  bool get isSmall =>
      this == WindowSizeClass.compact || this == WindowSizeClass.medium;

  /// Whether this class is expanded or above (i.e. "wide").
  bool get isWide => !isSmall;

  /// The coarse [DeviceType] that corresponds to this window-size class.
  DeviceType get deviceType {
    switch (this) {
      case WindowSizeClass.compact:
        return DeviceType.mobile;
      case WindowSizeClass.medium:
      case WindowSizeClass.expanded:
        return DeviceType.tablet;
      case WindowSizeClass.large:
      case WindowSizeClass.extraLarge:
        return DeviceType.desktop;
    }
  }
}
