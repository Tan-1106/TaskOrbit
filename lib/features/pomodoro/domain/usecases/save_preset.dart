import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/repository/i_pomodoro_preset_repository.dart';

class SavePreset {
  final IPomodoroPresetRepository repository;

  const SavePreset(this.repository);

  Future<Either<Failure, PomodoroPreset>> call(PomodoroPreset preset) {
    return repository.savePreset(preset);
  }
}
