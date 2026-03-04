import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';

abstract class PomodoroEvent {
  const PomodoroEvent();
}

class PomodoroLoad extends PomodoroEvent {
  final String userId;

  const PomodoroLoad(this.userId);
}

class PomodoroSelectPreset extends PomodoroEvent {
  final PomodoroPreset preset;

  const PomodoroSelectPreset(this.preset);
}

class PomodoroStartPause extends PomodoroEvent {
  const PomodoroStartPause();
}

class PomodoroResetCycle extends PomodoroEvent {
  const PomodoroResetCycle();
}

class PomodoroResetAll extends PomodoroEvent {
  const PomodoroResetAll();
}

class PomodoroSavePreset extends PomodoroEvent {
  final PomodoroPreset preset;

  const PomodoroSavePreset(this.preset);
}

class PomodoroDeletePreset extends PomodoroEvent {
  final String presetId;

  const PomodoroDeletePreset(this.presetId);
}

class PomodoroToggleRepeat extends PomodoroEvent {
  const PomodoroToggleRepeat();
}
