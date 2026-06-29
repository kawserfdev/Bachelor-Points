/// Material Design 3 responsive layout breakpoints.
///
/// Based on the Material Design window-size classes:
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
///
/// These are pure constants with **no Flutter dependency**, so they can be
/// used from any layer (domain, data, presentation) without pulling in the
/// Flutter framework.
///
/// | Class       | Width range        | Typical devices                         |
/// |-------------|--------------------|-----------------------------------------|
/// | compact     | 0 – 599            | Phone (portrait)                        |
/// | medium      | 600 – 839          | Phone (landscape), small tablet         |
/// | expanded    | 840 – 1199         | Large tablet, foldable, desktop         |
/// | large       | 1200 – 1599        | Desktop                                 |
/// | extraLarge  | 1600+              | Large desktop / ultra-wide              |
class Breakpoints {
  const Breakpoints._();

  /// Compact lower bound. Widths below [medium] are compact.
  static const double compact = 0;

  /// Medium lower bound (600 dp).
  static const double medium = 600;

  /// Expanded lower bound (840 dp).
  static const double expanded = 840;

  /// Large lower bound (1200 dp).
  static const double large = 1200;

  /// Extra-large lower bound (1600 dp).
  static const double extraLarge = 1600;

  /// Recommended maximum content width for single-column layouts such as
  /// authentication forms, chat threads, or detail panes.
  static const double contentMaxWidth = 600;

  /// Recommended maximum content width for two-pane (master-detail) layouts.
  static const double panedContentMaxWidth = 1200;

  /// Default horizontal page padding for compact devices.
  static const double paddingCompact = 16.0;

  /// Default horizontal page padding for medium / expanded devices.
  static const double paddingMedium = 24.0;

  /// Default horizontal page padding for large / extra-large devices.
  static const double paddingExpanded = 32.0;

  /// Default spacing between grid items.
  static const double gridSpacing = 16.0;

  /// Width at which the [ResponsiveScaffold] switches from a bottom
  /// [NavigationBar] to a side [NavigationRail] by default.
  static const double navigationRailBreakpoint = 600;

  /// Width at which the [NavigationRail] expands to show labels inline
  /// (the `extended` mode) by default.
  static const double navigationRailExtendedBreakpoint = 1200;
}
