import 'package:flutter/material.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';
import 'package:task_orbit/init_dependencies.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class LanguageSwitcherCard extends StatelessWidget {
    const LanguageSwitcherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = serviceLocator<LocaleNotifier>().value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(l10n.profileLanguageLabel),
        trailing: DropdownButton<String>(
          value: currentLocale.languageCode,
          underline: const SizedBox.shrink(),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(l10n.profileLanguageEnglish),
            ),
            DropdownMenuItem(
              value: 'vi',
              child: Text(l10n.profileLanguageVietnamese),
            ),
          ],
          onChanged: (code) {
            if (code != null) {
              serviceLocator<LocaleNotifier>().setLocale(Locale(code));
            }
          },
        ),
      ),
    );
  }
}