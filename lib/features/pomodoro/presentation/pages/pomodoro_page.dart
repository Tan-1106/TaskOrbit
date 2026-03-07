import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:task_orbit/features/pomodoro/presentation/widgets/pomodoro_preset_dropdown.dart';
import 'package:task_orbit/features/pomodoro/presentation/widgets/pomodoro_timer_widget.dart';
import 'package:task_orbit/features/pomodoro/presentation/widgets/pomodoro_info_dialog.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      context.read<PomodoroBloc>().add(PomodoroLoad(userId));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;

        ShellActionsScope.of(context)
          ..clear()
          ..setActions([
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: l10n.pomodoroInfoAction,
              onPressed: () => showPomodoroInfoDialog(context),
            ),
          ]);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        final color = phaseColor(state.phase, context);

        return SizedBox.expand(
          child: Column(
            children: [
              const SizedBox(height: 16),
              PomodoroPresetDropdown(state: state),
              _RepeatCheckbox(state: state, l10n: l10n),
              const Spacer(),
              PomodoroTimerWidget(state: state),
              const Spacer(),
              _ControlRow(state: state, color: color, l10n: l10n),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }
}

class _ControlRow extends StatelessWidget {
  final PomodoroState state;
  final Color color;
  final AppLocalizations l10n;

  const _ControlRow({
    required this.state,
    required this.color,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.replay,
          label: l10n.pomodoroResetAll,
          color: color,
          size: 48,
          onTap: () => context.read<PomodoroBloc>().add(const PomodoroResetAll()),
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: color,
                shape: const CircleBorder(),
                elevation: 6,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.read<PomodoroBloc>().add(const PomodoroStartPause()),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        state.isRunning ? Icons.pause : Icons.play_arrow,
                        key: ValueKey(state.isRunning),
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: Icons.refresh,
          label: l10n.pomodoroResetPhase,
          color: color,
          size: 48,
          onTap: () => context.read<PomodoroBloc>().add(const PomodoroResetCycle()),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: color.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, color: color, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatCheckbox extends StatelessWidget {
  final PomodoroState state;
  final AppLocalizations l10n;

  const _RepeatCheckbox({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.read<PomodoroBloc>().add(const PomodoroToggleRepeat()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.pomodoroRepeat,
                style: theme.textTheme.bodyMedium,
              ),
              Checkbox(
                value: state.isRepeat,
                onChanged: (_) =>
                    context.read<PomodoroBloc>().add(
                      const PomodoroToggleRepeat(),
                    ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
