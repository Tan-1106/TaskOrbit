import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/features/pomodoro/data/datasources/pomodoro_preset_local_data_source.dart';
import 'package:task_orbit/features/pomodoro/data/datasources/pomodoro_preset_remote_data_source.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/repository/i_pomodoro_preset_repository.dart';

class PomodoroRepositoryImpl implements IPomodoroPresetRepository {
  final PomodoroPresetLocalDataSource localDataSource;
  final PomodoroPresetRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  const PomodoroRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<PomodoroPreset>>> getPresets(
    String userId,
  ) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline) {
        try {
          final remotePresets = await remoteDataSource.getAllPresets(userId);
          if (remotePresets.isNotEmpty) {
            await localDataSource.insertAll(
              remotePresets.map((p) => p.copyWith(isSynced: true)).toList(),
            );
          }
        } catch (_) {}
      }
      final presets = await localDataSource.getPresets(userId);
      return right(presets);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PomodoroPreset>> savePreset(
    PomodoroPreset preset,
  ) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline) {
        final syncedPreset = preset.copyWith(isSynced: true);
        await localDataSource.insertPreset(syncedPreset);
        await remoteDataSource.createPreset(syncedPreset);
        return right(syncedPreset);
      } else {
        final unsyncedPreset = preset.copyWith(isSynced: false);
        await localDataSource.insertPreset(unsyncedPreset);
        return right(unsyncedPreset);
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePreset(
    String userId,
    String presetId,
  ) async {
    try {
      final isOnline = await connectivityService.isConnected;
      await localDataSource.deletePreset(presetId);

      if (isOnline) {
        await remoteDataSource.deletePreset(userId, presetId);
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPresets(String userId) async {
    try {
      final isOnline = await connectivityService.isConnected;
      if (!isOnline) return right(null);

      final unsyncedPresets = await localDataSource.getUnsyncedPresets(userId);

      for (final preset in unsyncedPresets) {
        if (preset.isDeleted) {
          await remoteDataSource.deletePreset(userId, preset.id);
        } else {
          await remoteDataSource.createPreset(preset);
        }
        await localDataSource.markAsSynced(preset.id);
      }
      final remotePresets = await remoteDataSource.getAllPresets(userId);
      if (remotePresets.isNotEmpty) {
        await localDataSource.insertAll(
          remotePresets.map((p) => p.copyWith(isSynced: true)).toList(),
        );
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
