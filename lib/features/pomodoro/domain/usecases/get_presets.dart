import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/repository/i_pomodoro_preset_repository.dart';

class GetPresets {
  final IPomodoroPresetRepository repository;

  const GetPresets(this.repository);

  Future<Either<Failure, List<PomodoroPreset>>> call(String userId) {
    return repository.getPresets(userId);
  }
}
