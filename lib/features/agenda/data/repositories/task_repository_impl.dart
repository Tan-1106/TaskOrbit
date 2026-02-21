import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/features/agenda/data/datasources/task_local_data_source.dart';
import 'package:task_orbit/features/agenda/data/datasources/task_remote_data_source.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  const TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityService,
  });

  // ─────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, List<Task>>> getTasksByDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline) {
        // Fetch from Firebase and merge into local DB
        try {
          final remoteTasks =
              await remoteDataSource.getTasksByDate(userId, date);
          if (remoteTasks.isNotEmpty) {
            await localDataSource.insertAll(
              remoteTasks.map((t) => t.copyWith(isSynced: true)).toList(),
            );
          }
        } catch (_) {
          // Remote fetch failed — fall back to local silently
        }
      }

      // Always return from local DB (single source of truth)
      final tasks = await localDataSource.getTasksByDate(userId, date);
      return right(tasks);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, Task>> createTask({required Task task}) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline) {
        // Save to local (synced) + push to Firebase
        final syncedTask = task.copyWith(isSynced: true);
        await localDataSource.insertTask(syncedTask);
        await remoteDataSource.createTask(syncedTask);
        return right(syncedTask);
      } else {
        // Save locally only (pending sync)
        final unsyncedTask = task.copyWith(isSynced: false);
        await localDataSource.insertTask(unsyncedTask);
        return right(unsyncedTask);
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, Task>> updateTask({required Task task}) async {
    try {
      final isOnline = await connectivityService.isConnected;
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now(),
        isSynced: isOnline,
      );

      await localDataSource.updateTask(updatedTask);

      if (isOnline) {
        await remoteDataSource.updateTask(updatedTask);
      }

      return right(updatedTask);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // DELETE (soft delete)
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, void>> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;

      // Soft delete locally
      await localDataSource.deleteTask(taskId);

      if (isOnline) {
        // Hard delete from Firebase
        await remoteDataSource.deleteTask(userId, taskId);
        // Now hard delete locally too (no need to sync later)
        // Already soft-deleted, will be cleaned up on sync
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // TOGGLE COMPLETE
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, Task>> toggleTaskComplete({
    required String taskId,
    required String userId,
  }) async {
    try {
      final existing = await localDataSource.getTaskById(taskId);
      if (existing == null) {
        return left(Failure('Task not found'));
      }

      final toggled = existing.copyWith(
        isCompleted: !existing.isCompleted,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      return await updateTask(task: toggled);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // SEARCH / FILTER
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, List<Task>>> searchTasks({
    required String userId,
    required TaskFilter filter,
  }) async {
    try {
      final tasks = await localDataSource.searchTasks(
        userId,
        keyword: filter.keyword,
        categoryId: filter.categoryId,
        isCompleted: filter.isCompleted,
        fromDate: filter.fromDate,
        toDate: filter.toDate,
      );
      return right(tasks);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // SYNC PENDING CHANGES
  // ─────────────────────────────────────────

  @override
  Future<Either<Failure, void>> syncPendingChanges({
    required String userId,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;
      if (!isOnline) return right(null);

      final unsyncedTasks = await localDataSource.getUnsyncedTasks(userId);

      for (final task in unsyncedTasks) {
        if (task.isDeleted) {
          // Push delete to Firebase
          await remoteDataSource.deleteTask(userId, task.id);
        } else {
          // Push create/update to Firebase
          await remoteDataSource.createTask(task);
        }
        await localDataSource.markAsSynced(task.id);
      }

      // Also pull any new tasks from Firebase that may not be local
      final remoteTasks = await remoteDataSource.getAllTasks(userId);
      if (remoteTasks.isNotEmpty) {
        await localDataSource.insertAll(
          remoteTasks.map((t) => t.copyWith(isSynced: true)).toList(),
        );
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
