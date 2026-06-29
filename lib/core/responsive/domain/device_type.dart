import 'breakpoints.dart';

/// Coarse device classification derived from the available layout width.
///
/// Maps the fine-grained Material window-size classes to three high-level
/// categories that are convenient for adaptive layouts:
///
/// * [mobile]  — phones in portrait (`width < 600`).
/// * [tablet]  — tablets and phones in landscape (`600 ≤ width < 1200`).
/// * [desktop] — desktops and large tablets (`width ≥ 1200`).
///
/// This enum has **no Flutter dependency**.
enum DeviceType {
  /// Phones in portrait. Width < [Breakpoints.medium] (600 dp).
  mobile,

  /// Tablets and large phones in landscape.
  /// [Breakpoints.medium] (600) ≤ width < [Breakpoints.large] (1200).
  tablet,

  /// Desktops and large tablets. Width ≥ [Breakpoints.large] (1200 dp).
  desktop;

  /// Returns the [DeviceType] for the given [width] in logical pixels.
  ///
  /// The value is clamped to a non-negative number so that unconstrained
  /// `LayoutBuilder` constraints (e.g. `maxWidth = double.infinity`) resolve
  /// to [desktop] instead of throwing.
  static DeviceType fromWidth(double width) {
    final w = width < 0 ? 0.0 : width;
    if (w < Breakpoints.medium) return DeviceType.mobile;
    if (w < Breakpoints.large) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Whether this device is a phone.
  bool get isMobile => this == DeviceType.mobile;

  /// Whether this device is a tablet.
  bool get isTablet => this == DeviceType.tablet;

  /// Whether this device is a desktop.
  bool get isDesktop => this == DeviceType.desktop;

  /// Whether this device is a tablet or desktop (i.e. "wide").
  bool get isWide => this != DeviceType.mobile;
}
