import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:task_orbit/features/pomodoro/presentation/widgets/preset_form_sheet.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

/// A bottom sheet that displays the details of a Pomodoro preset
/// with Edit and Delete actions.
class PresetDetailSheet extends StatelessWidget {
  final PomodoroPreset preset;

  const PresetDetailSheet({super.key, required this.preset});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Text(
            l10n.pomodoroPresetDetail,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // ── Preset name ──
          Text(
            preset.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (preset.description != null && preset.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              preset.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ── Stats grid ──
          _DetailGrid(preset: preset, l10n: l10n),
          const SizedBox(height: 28),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmEdit(context, l10n),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.pomodoroEditPreset),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _confirmDelete(context, l10n),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.pomodoroPresetDeleteButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmEdit(BuildContext context, AppLocalizations l10n) {
    final bloc = context.read<PomodoroBloc>();
    Navigator.of(context).pop(); // close detail sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: PresetFormSheet(existingPreset: preset),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    final bloc = context.read<PomodoroBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pomodoroDeletePresetTitle),
        content: Text(l10n.pomodoroDeletePresetContent(preset.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              bloc.add(PomodoroDeletePreset(preset.id));
              Navigator.of(context).pop(); // close detail sheet
            },
            child: Text(l10n.dialogDeleteButton),
          ),
        ],
      ),
    );
  }
}

/// A 2x2 grid showing the preset's timing configuration.
class _DetailGrid extends StatelessWidget {
  final PomodoroPreset preset;
  final AppLocalizations l10n;

  const _DetailGrid({required this.preset, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DetailTile(
                  icon: Icons.center_focus_strong,
                  label: l10n.pomodoroPresetDetailFocus,
                  value: l10n.pomodoroPresetDetailMinutes(preset.focusMinutes),
                  color: const Color(0xFF5C6BC0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailTile(
                  icon: Icons.coffee,
                  label: l10n.pomodoroPresetDetailShortBreak,
                  value: l10n.pomodoroPresetDetailMinutes(preset.shortBreakMinutes),
                  color: const Color(0xFF66BB6A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailTile(
                  icon: Icons.weekend,
                  label: l10n.pomodoroPresetDetailLongBreak,
                  value: l10n.pomodoroPresetDetailMinutes(preset.longBreakMinutes),
                  color: const Color(0xFFFFA726),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailTile(
                  icon: Icons.loop,
                  label: l10n.pomodoroPresetDetailCycles,
                  value: l10n.pomodoroPresetDetailCycleValue(preset.cyclesBeforeLongBreak),
                  color: const Color(0xFFAB47BC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
