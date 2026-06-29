/// BachelorPoints responsive core.
///
/// A self-contained, Clean Architecture module providing reusable responsive
/// utilities for Flutter Mobile, Tablet, Desktop, and Web. It depends only on
/// Flutter/Material 3 — **no** business logic, Firebase, Riverpod, or GoRouter.
///
/// ## Layers
///
/// * [domain] — pure-Dart constants & enums ([Breakpoints], [DeviceType],
///   [WindowSizeClass]).
/// * [utils] — [BuildContext] / [double] extensions for quick lookups.
/// * [widgets] — [ResponsiveBuilder], [ResponsiveLayout], [ResponsiveGrid],
///   [ResponsiveSpacing], [ResponsiveScaffold].
///
/// ## Quick start
///
/// ```dart
/// import 'package:bachelorpoints/core/responsive/responsive.dart';
///
/// // Branch on device type
/// ResponsiveBuilder(
///   builder: (context, deviceType, sizeClass, constraints) {
///     return switch (deviceType) {
///       DeviceType.mobile => MobileLayout(),
///       DeviceType.tablet => TabletLayout(),
///       DeviceType.desktop => DesktopLayout(),
///     };
///   },
/// )
///
/// // Center a single-column screen
/// ResponsiveLayout(child: AuthForm())
///
/// // Adaptive grid
/// ResponsiveGrid(maxCrossAxisExtent: 300, children: [...])
///
/// // Context extensions
/// final padding = context.responsivePadding;
/// final isWide = context.isWide;
/// ```
library;

// Domain ---------------------------------------------------------------------
export 'domain/breakpoints.dart';
export 'domain/device_type.dart';
export 'domain/window_size_class.dart';

// Utils ----------------------------------------------------------------------
export 'utils/responsive_extensions.dart';

// Widgets --------------------------------------------------------------------
export 'widgets/responsive_builder.dart';
export 'widgets/responsive_layout.dart';
export 'widgets/responsive_grid.dart';
export 'widgets/responsive_spacing.dart';
export 'widgets/responsive_scaffold.dart';
