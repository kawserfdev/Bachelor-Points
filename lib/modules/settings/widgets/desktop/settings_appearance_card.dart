import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../../core/theme/theme_controller.dart';
import 'settings_card_shell.dart';

/// Desktop-only Appearance settings card.
///
/// Renders a visual theme-mode picker (Light / Dark / System) as three
/// selectable tiles. It reads and writes the active [ThemeMode] via the
/// existing Riverpod [themeControllerProvider] — **no** new business logic is
/// introduced; this is a pure UI redesign of the mobile
/// `_buildAppearanceCard` expansion tile.
class SettingsAppearanceCard extends ConsumerWidget {
  const SettingsAppearanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeControllerProvider);
    final themeCtrl = ref.read(themeControllerProvider.notifier);

    final options = <_ThemeOption>[
      _ThemeOption(
        mode: ThemeMode.light,
        label: local.light,
        description: local.lightDesc,
        icon: Icons.light_mode_rounded,
        previewLight: Colors.white,
        previewDark: const Color(0xFFE3E3E3),
      ),
      _ThemeOption(
        mode: ThemeMode.dark,
        label: local.dark,
        description: local.darkDesc,
        icon: Icons.dark_mode_rounded,
        previewLight: const Color(0xFF1C1C1E),
        previewDark: const Color(0xFF2C2C2E),
      ),
      _ThemeOption(
        mode: ThemeMode.system,
        label: local.system,
        description: local.systemDesc,
        icon: Icons.settings_suggest_rounded,
        previewLight: const Color(0xFF6E6E73),
        previewDark: const Color(0xFF8E8E93),
      ),
    ];

    return SettingsCardShell(
      icon: Icons.palette_outlined,
      iconColor: Theme.of(context).colorScheme.primary,
      title: local.settingsAppearanceTitle,
      description: local.settingsAppearanceDesc,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Fluid columns: 1 on narrow, 3 on wide.
          final columns =
              (constraints.maxWidth / 200).floor().clamp(1, 3);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemBuilder: (context, index) {
              final opt = options[index];
              final selected = themeMode == opt.mode;
              return _ThemeTile(
                option: opt,
                selected: selected,
                onTap: () => themeCtrl.setThemeMode(opt.mode),
              );
            },
          );
        },
      ),
    );
  }
}

/// Data carrier for a single theme-mode option.
class _ThemeOption {
  final ThemeMode mode;
  final String label;
  final String description;
  final IconData icon;
  final Color previewLight;
  final Color previewDark;

  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.description,
    required this.icon,
    required this.previewLight,
    required this.previewDark,
  });
}

/// A single selectable theme tile with a color preview swatch.
class _ThemeTile extends StatelessWidget {
  final _ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final previewColor = isDark ? option.previewDark : option.previewLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? cs.primaryContainer.withValues(alpha: 0.35)
                : cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.6)
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Color preview swatch
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  option.icon,
                  color: isDark ? Colors.white : Colors.black54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
