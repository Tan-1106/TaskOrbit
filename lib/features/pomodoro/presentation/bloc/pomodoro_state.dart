import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_phase.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';

/// The built-in classic Pomodoro preset (not persisted to DB).
const classicPreset = PomodoroPreset(
  id: 'default',
  userId: '',
  name: 'Classic Pomodoro',
  description: 'The original 25/5/15 technique',
  focusMinutes: 25,
  shortBreakMinutes: 5,
  longBreakMinutes: 15,
  cyclesBeforeLongBreak: 4,
  isSynced: true,
  isDeleted: false,
);

class PomodoroState {
  final List<PomodoroPreset> presets;
  final PomodoroPreset selectedPreset;
  final PomodoroPhase phase;

  /// 0-based index of the current focus cycle within a round.
  final int cycleIndex;

  final int secondsRemaining;
  final bool isRunning;

  /// True when the entire session has ended (last longBreak finished).
  final bool isFinished;

  /// Whether to loop back to Focus after the long break ends.
  final bool isRepeat;

  const PomodoroState({
    required this.presets,
    required this.selectedPreset,
    this.phase = PomodoroPhase.focus,
    this.cycleIndex = 0,
    required this.secondsRemaining,
    this.isRunning = false,
    this.isFinished = false,
    this.isRepeat = false,
  });

  factory PomodoroState.initial() {
    return PomodoroState(
      presets: const [classicPreset],
      selectedPreset: classicPreset,
      secondsRemaining: classicPreset.focusMinutes * 60,
    );
  }

  PomodoroState copyWith({
    List<PomodoroPreset>? presets,
    PomodoroPreset? selectedPreset,
    PomodoroPhase? phase,
    int? cycleIndex,
    int? secondsRemaining,
    bool? isRunning,
    bool? isFinished,
    bool? isRepeat,
  }) {
    return PomodoroState(
      presets: presets ?? this.presets,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      phase: phase ?? this.phase,
      cycleIndex: cycleIndex ?? this.cycleIndex,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
      isRepeat: isRepeat ?? this.isRepeat,
    );
  }
}
