import 'dart:math' show pi;

import 'package:flutter/material.dart';

/// Shared building blocks for the SaaS-style Home dashboard.
///
/// All widgets are theme-aware (Light & Dark) and depend only on Flutter/Material.
/// No external chart libraries are used — [DonutChart] and [MiniBarChart] are
/// rendered with [CustomPaint].
///
/// These widgets read no state themselves; callers wrap them in `Obx` and pass
/// already-resolved values, so they stay pure and reusable.

// ─────────────────────────────────────────────────────────────────────────────
// Semantic accent palette (consistent across mobile/tablet/desktop).
// Surfaces, text and borders always come from [ColorScheme] so Light/Dark work.
// ─────────────────────────────────────────────────────────────────────────────
class DashboardPalette {
  DashboardPalette._();

  static const Color members = Color(0xFF6366F1); // indigo (brand)
  static const Color bazar = Color(0xFFFF6B6B); // coral
  static const Color meals = Color(0xFFFFA726); // amber
  static const Color mealRate = Color(0xFF66BB6A); // green
  static const Color deposit = Color(0xFF42A5F5); // sky
  static const Color fixed = Color(0xFFAB47BC); // orchid
  static const Color balance = Color(0xFF26A69A); // teal
  static const Color report = Color(0xFFAB47BC);
  static const Color shopping = Color(0xFF00BFA5);
  static const Color settings = Color(0xFF5C6BC0);
  static const Color approvals = Color(0xFF78909C);
  static const Color notifications = Color(0xFFFFB74D);
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card (KPI tile)
// ─────────────────────────────────────────────────────────────────────────────
class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final String? subtitle;
  final TrendData? trend;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.subtitle,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // Dynamic padding based on available height
        final padding = height < 140 ? 10.0 : 16.0;

        // Dynamic icon container size and inner icon size
        final iconSize = height < 140 ? 36.0 : 44.0;
        final iconInnerSize = height < 140 ? 18.0 : 22.0;

        // Dynamic vertical spacing
        final spaceBeforeValue = height < 140 ? 8.0 : 16.0;
        final spaceBeforeLabel = height < 140 ? 2.0 : 4.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.28)
                    : accent.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accent, size: iconInnerSize),
                  ),
                  if (trend != null && height >= 120) _TrendBadge(trend: trend!),
                ],
              ),
              SizedBox(height: spaceBeforeValue),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: spaceBeforeLabel),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null && height >= 135) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle!,
                    maxLines: height < 150 ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class TrendData {
  final double percent;
  final bool positiveIsGood;

  const TrendData(this.percent, {this.positiveIsGood = true});
}

class _TrendBadge extends StatelessWidget {
  final TrendData trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isUp = trend.percent >= 0;
    final good = isUp == trend.positiveIsGood;
    final color = good ? DashboardPalette.mealRate : DashboardPalette.bazar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            '${isUp ? '+' : ''}${trend.percent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut chart — expense breakdown
// ─────────────────────────────────────────────────────────────────────────────
class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final String centerLabel;
  final String centerValue;

  const DonutChart({
    super.key,
    required this.segments,
    required this.centerLabel,
    required this.centerValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final total = segments.fold<double>(0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            centerLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Donut (120) + gap (20) + legend min width (~120) ≈ 260.
              // Below that, stack the donut above the legend to avoid overflow.
              final sideBySide = constraints.maxWidth >= 280;

              final donut = SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: segments,
                    total: total,
                    trackColor: cs.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerValue,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              final legend = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: segments.map((s) {
                  final pct = total > 0 ? (s.value / total * 100) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );

              if (sideBySide) {
                // Expanded expands horizontally inside the Row.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    donut,
                    const SizedBox(width: 20),
                    Expanded(child: legend),
                  ],
                );
              }
              // Stacked: plain children (no Expanded) so the Column can
              // shrink-wrap inside the unbounded-height scroll parent.
              return Column(
                children: [
                  Center(child: donut),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double total;
  final Color trackColor;

  _DonutPainter({
    required this.segments,
    required this.total,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    const strokeWidth = 16.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    if (total <= 0) return;

    double startAngle = -pi / 2;
    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = (seg.value / total) * 2 * pi;
      segmentPaint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        segmentPaint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.total != total ||
      oldDelegate.trackColor != trackColor ||
      _segmentsDiffer(oldDelegate.segments);

  bool _segmentsDiffer(List<DonutSegment> other) {
    if (segments.length != other.length) {
      return true;
    }
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].value != other[i].value ||
          segments[i].color != other[i].color) {
        return true;
      }
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini bar chart — finances comparison
// ─────────────────────────────────────────────────────────────────────────────
class BarData {
  final String label;
  final double value;
  final Color color;

  const BarData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class MiniBarChart extends StatelessWidget {
  final String title;
  final List<BarData> bars;
  final String unit;

  const MiniBarChart({
    super.key,
    required this.title,
    required this.bars,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _BarPainter(
                bars: bars,
                gridColor: cs.outlineVariant.withValues(alpha: 0.4),
                labelColor: cs.onSurfaceVariant,
                valueColor: cs.onSurface,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<BarData> bars;
  final Color gridColor;
  final Color labelColor;
  final Color valueColor;

  _BarPainter({
    required this.bars,
    required this.gridColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final maxValue = bars.fold<double>(
        0, (m, b) => b.value > m ? b.value : m);
    if (maxValue <= 0) return;

    final labelHeight = 22.0;
    final chartHeight = size.height - labelHeight;
    final barAreaWidth = size.width / bars.length;
    final barWidth = barAreaWidth * 0.5;
    final gap = (barAreaWidth - barWidth) / 2;

    // Baseline
    final baselineY = chartHeight;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      gridPaint,
    );

    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final h = (bar.value / maxValue) * chartHeight;
      final x = i * barAreaWidth + gap;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, baselineY - h, barWidth, h),
        const Radius.circular(6),
      );
      final paint = Paint()
        ..color = bar.color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rect, paint);

      // Value label on top
      final tp = TextPainter(
        text: TextSpan(
          text: _formatShort(bar.value),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          i * barAreaWidth + (barAreaWidth - tp.width) / 2,
          baselineY - h - 14,
        ),
      );

      // Category label below baseline
      final lp = TextPainter(
        text: TextSpan(
          text: bar.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: barAreaWidth);
      lp.paint(
        canvas,
        Offset(
          i * barAreaWidth + (barAreaWidth - lp.width) / 2,
          baselineY + 6,
        ),
      );
    }
  }

  String _formatShort(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.valueColor != valueColor ||
      _barsDiffer(oldDelegate.bars);

  bool _barsDiffer(List<BarData> other) {
    if (bars.length != other.length) {
      return true;
    }
    for (var i = 0; i < bars.length; i++) {
      if (bars[i].value != other[i].value ||
          bars[i].color != other[i].color) {
        return true;
      }
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar navigation item (desktop)
// ─────────────────────────────────────────────────────────────────────────────
class SidebarNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const SidebarNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.accent,
    required this.onTap,
  });
}

class SidebarTile extends StatelessWidget {
  final SidebarNavItem item;
  final bool selected;

  const SidebarTile({super.key, required this.item, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? cs.primaryContainer.withValues(alpha: 0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                selected ? (item.selectedIcon ?? item.icon) : item.icon,
                size: 20,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick action card (grid style for tablet/desktop)
// ─────────────────────────────────────────────────────────────────────────────
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity tile (recent members feed)
// ─────────────────────────────────────────────────────────────────────────────
class ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? timeAgoText;
  final IconData icon;
  final Color accent;

  const ActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.timeAgoText,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (timeAgoText != null)
            Text(
              timeAgoText!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Formats a [DateTime] as a short relative-time string (e.g. "2d ago").
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
