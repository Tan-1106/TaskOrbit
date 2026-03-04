import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/pomodoro/domain/repository/i_pomodoro_preset_repository.dart';

class DeletePreset {
  final IPomodoroPresetRepository repository;

  const DeletePreset(this.repository);

  Future<Either<Failure, void>> call(String userId, String presetId) {
    return repository.deletePreset(userId, presetId);
  }
}
