import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:task_orbit/features/pomodoro/presentation/widgets/preset_form_sheet.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class PomodoroPresetDropdown extends StatelessWidget {
  final PomodoroState state;

  const PomodoroPresetDropdown({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final List<DropdownMenuItem<String>> items =
        state.presets.map((preset) {
          final isDefault = preset.id == 'default';
          return DropdownMenuItem<String>(
            value: preset.id,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    preset.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (!isDefault)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      // Close dropdown overlay first; opaque hit-test prevents double-pop.
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _openEditSheet(context, l10n, preset);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList()..add(
          DropdownMenuItem<String>(
            value: '__add__',
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.pomodoroAddPreset,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
    final List<Widget> selectedWidgets = [
      ...state.presets.map(
        (preset) => Align(
          alignment: Alignment.center,
          child: Text(
            preset.name,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: Text(l10n.pomodoroAddPreset, style: theme.textTheme.bodyMedium),
      ),
    ];
    final listKey = ValueKey(
      '${state.presets.length}_${state.selectedPreset.id}',
    );

    return Container(
      key: listKey,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedPreset.id,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items,
          selectedItemBuilder: (_) => selectedWidgets,
          onChanged: (value) {
            if (value == null) return;
            if (value == '__add__') {
              _openAddSheet(context, l10n);
              return;
            }
            final preset = state.presets.firstWhere((p) => p.id == value);
            context.read<PomodoroBloc>().add(PomodoroSelectPreset(preset));
          },
        ),
      ),
    );
  }

  void _openAddSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PomodoroBloc>(),
        child: const PresetFormSheet(),
      ),
    );
  }

  void _openEditSheet(
    BuildContext context,
    AppLocalizations l10n,
    PomodoroPreset preset,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PomodoroBloc>(),
        child: PresetFormSheet(existingPreset: preset),
      ),
    );
  }
}
