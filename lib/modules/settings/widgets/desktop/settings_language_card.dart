import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import 'settings_card_shell.dart';

/// Desktop-only Language settings card.
///
/// Renders the three supported locales (English, Bangla, Hindi) as selectable
/// tiles with native script previews. It reads and writes the active [Locale]
/// via the existing Riverpod [localeControllerProvider] — **no** new business
/// logic is introduced; this is a pure UI redesign of the mobile
/// `_buildLanguageCard` expansion tile.
class SettingsLanguageCard extends ConsumerWidget {
  const SettingsLanguageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeControllerProvider);
    final localeCtrl = ref.read(localeControllerProvider.notifier);

    final options = <_LocaleOption>[
      _LocaleOption(
        locale: const Locale('en'),
        label: local.english,
        nativeScript: 'English',
        flag: '🇬🇧',
      ),
      _LocaleOption(
        locale: const Locale('bn'),
        label: local.bangla,
        nativeScript: 'বাংলা',
        flag: '🇧🇩',
      ),
      _LocaleOption(
        locale: const Locale('hi'),
        label: local.hindi,
        nativeScript: 'हिन्दी',
        flag: '🇮🇳',
      ),
    ];

    return SettingsCardShell(
      icon: Icons.language_rounded,
      iconColor: Colors.indigo,
      title: local.settingsLanguageTitle,
      description: local.settingsLanguageDesc,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final opt = options[index];
              final selected = currentLocale == opt.locale;
              return _LocaleTile(
                option: opt,
                selected: selected,
                onTap: () => localeCtrl.setLocale(opt.locale),
              );
            },
          );
        },
      ),
    );
  }
}

/// Data carrier for a single locale option.
class _LocaleOption {
  final Locale locale;
  final String label;
  final String nativeScript;
  final String flag;

  const _LocaleOption({
    required this.locale,
    required this.label,
    required this.nativeScript,
    required this.flag,
  });
}

/// A single selectable language tile.
class _LocaleTile extends StatelessWidget {
  final _LocaleOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LocaleTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
              Text(
                option.flag,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.nativeScript,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
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
