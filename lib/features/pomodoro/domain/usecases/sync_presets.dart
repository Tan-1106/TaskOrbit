import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/pomodoro/domain/repository/i_pomodoro_preset_repository.dart';

class SyncPresets {
  final IPomodoroPresetRepository repository;

  const SyncPresets(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.syncPresets(userId);
  }
}
