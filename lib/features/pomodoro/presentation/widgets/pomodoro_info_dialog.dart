import 'package:flutter/material.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

/// Shows the Pomodoro technique info dialog.
void showPomodoroInfoDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => const _PomodoroInfoDialog(),
  );
}

class _PomodoroInfoDialog extends StatelessWidget {
  const _PomodoroInfoDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Row(
                children: [
                  const Text('🍅', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.pomodoroInfoTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      icon: Icons.history_edu_rounded,
                      heading: l10n.pomodoroInfoOriginHeading,
                      color: colorScheme.tertiary,
                      child: Text(
                        l10n.pomodoroInfoOriginText,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      icon: Icons.lightbulb_outline_rounded,
                      heading: l10n.pomodoroInfoWhatHeading,
                      color: colorScheme.secondary,
                      child: Text(
                        l10n.pomodoroInfoWhatText,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      icon: Icons.list_alt_rounded,
                      heading: l10n.pomodoroInfoHowHeading,
                      color: colorScheme.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Step(number: 1, text: l10n.pomodoroInfoStep1),
                          _Step(number: 2, text: l10n.pomodoroInfoStep2),
                          _Step(number: 3, text: l10n.pomodoroInfoStep3),
                          _Step(number: 4, text: l10n.pomodoroInfoStep4),
                          _Step(number: 5, text: l10n.pomodoroInfoStep5),
                          _Step(number: 6, text: l10n.pomodoroInfoStep6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      icon: Icons.tips_and_updates_rounded,
                      heading: l10n.pomodoroInfoTipsHeading,
                      color: Colors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Tip(text: l10n.pomodoroInfoTip1),
                          _Tip(text: l10n.pomodoroInfoTip2),
                          _Tip(text: l10n.pomodoroInfoTip3),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.pomodoroInfoGotIt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String heading;
  final Color color;
  final Widget child;

  const _Section({
    required this.icon,
    required this.heading,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              heading,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: child,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;

  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

