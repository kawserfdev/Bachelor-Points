import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A modern, responsive SaaS authentication shell for Web, Desktop, Tablet, and Mobile.
///
/// * **Desktop (>= 960px)**: Split-screen dual-panel layout with seamless non-scrolling form canvas.
/// * **Tablet (600px - 959px)**: Clean centered elevated card.
/// * **Mobile (< 600px)**: Full-width responsive scrollable layout.
class AuthScaffold extends StatelessWidget {
  /// The form / body content of the auth screen.
  final Widget child;

  /// Optional custom app bar.
  final PreferredSizeWidget? appBar;

  /// Padding applied on mobile screens.
  final EdgeInsets mobilePadding;

  /// Whether the child content should be centered vertically on mobile.
  final bool centered;

  /// Max width of the form container on tablet/desktop.
  final double maxWidth;

  /// Optional custom title for the branding side panel.
  final String? brandHeadline;

  /// Optional custom subtitle for the branding side panel.
  final String? brandSubtitle;

  const AuthScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.mobilePadding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    this.centered = false,
    this.maxWidth = 420,
    this.brandHeadline,
    this.brandSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isDesktop = screenWidth >= 960;
    final isTablet = screenWidth >= 600 && screenWidth < 960;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // ── 1. Desktop Split-Screen Layout (>= 960px) ──
    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFFAFAFC),
        body: Row(
          children: [
            // Left Branding Panel (44% width)
            Expanded(
              flex: 44,
              child: _BrandSidePanel(
                headline: brandHeadline,
                subtitle: brandSubtitle,
              ),
            ),

            // Right Form Panel (56% width) — Clean non-card SaaS layout
            Expanded(
              flex: 56,
              child: Container(
                color: isDark ? const Color(0xFF0E0E14) : const Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    // Top header bar (Home link & back button)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (appBar != null || context.canPop())
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, size: 20),
                              tooltip: 'Back',
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                }
                              },
                            )
                          else
                            const SizedBox.shrink(),
                          
                          // Quick back to website link
                          TextButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.home_outlined, size: 16),
                            label: const Text('bachelorpoints.com'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF8B3DFF),
                              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Centered Form Canvas (Fits cleanly without inner scroll if height permits)
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: screenHeight > 680
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: child,
                          ),
                        ),
                      ),
                    ),

                    // Subtle bottom footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '© ${DateTime.now().year} BachelorPoints • Made for Bangladesh 🇧🇩',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF71717A) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── 2. Tablet Layout (600px - 959px) ──
    if (isTablet) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FA),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Card(
                elevation: 4,
                shadowColor: cs.primary.withValues(alpha: 0.1),
                color: isDark ? const Color(0xFF14141C) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── 3. Mobile Layout (< 600px) ──
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: centered
            ? Center(
                child: SingleChildScrollView(
                  padding: mobilePadding,
                  child: child,
                ),
              )
            : SingleChildScrollView(
                padding: mobilePadding,
                child: child,
              ),
      ),
    );
  }
}

/// Left branding panel rendered on Desktop Web.
class _BrandSidePanel extends StatelessWidget {
  final String? headline;
  final String? subtitle;

  const _BrandSidePanel({
    this.headline,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8B3DFF);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF09090E),
            Color(0xFF130E24),
            Color(0xFF1A1230),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Brand Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B3DFF), Color(0xFFA855F7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.layers_rounded,
                    color: Color(0xFFC084FC),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BachelorPoints',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Mess Management SaaS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA855F7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center Value Proposition & Highlights
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇧🇩', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 6),
                    Text(
                      'Built for Bangladesh Mess Life',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Headline
              Text(
                headline ?? 'Stop Fighting Over Meal Costs.',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                subtitle ??
                    'Track meals, manage bazar, record expenses, monitor deposits, and calculate balances automatically.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // 4 Key Features List
              const _FeatureBullet(
                icon: Icons.restaurant_rounded,
                iconColor: Color(0xFF8B3DFF),
                title: 'Digital Meal Tracking',
                subtitle: 'Custom portions (0.5 to 2.0) with auto-lock',
              ),
              const SizedBox(height: 14),
              const _FeatureBullet(
                icon: Icons.calculate_rounded,
                iconColor: Color(0xFF10B981),
                title: 'Zero-Error Balance Math',
                subtitle: 'Automatic meal rates & instant deposit accounting',
              ),
              const SizedBox(height: 14),
              const _FeatureBullet(
                icon: Icons.shopping_bag_rounded,
                iconColor: Color(0xFFF59E0B),
                title: 'Smart Bazar Schedules',
                subtitle: 'Morning 8:00 AM push reminders & shared checklists',
              ),
              const SizedBox(height: 14),
              const _FeatureBullet(
                icon: Icons.description_rounded,
                iconColor: Color(0xFF06B6D4),
                title: 'Monthly PDF Statements',
                subtitle: 'Complete financial audits ready to share on WhatsApp',
              ),
            ],
          ),

          // Bottom Trust Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Online + Offline Ready • 100% Free Core',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureBullet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
