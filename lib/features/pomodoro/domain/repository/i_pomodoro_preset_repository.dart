import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';

abstract interface class IPomodoroPresetRepository {
  Future<Either<Failure, List<PomodoroPreset>>> getPresets(String userId);

  Future<Either<Failure, PomodoroPreset>> savePreset(PomodoroPreset preset);

  Future<Either<Failure, void>> deletePreset(String userId, String presetId);

  Future<Either<Failure, void>> syncPresets(String userId);
}
