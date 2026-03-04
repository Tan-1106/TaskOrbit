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

  @override
  Future<Either<Failure, List<Task>>> getTasksByDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline) {
        try {
          final remoteTasks = await remoteDataSource.getTasksByDate(
            userId,
            date,
          );
          if (remoteTasks.isNotEmpty) {
            await localDataSource.insertAll(
              remoteTasks.map((t) => t.copyWith(isSynced: true)).toList(),
            );
          }
        } catch (_) {
          // Remote failed — fall back to local silently
        }
      }

      final tasks = await localDataSource.getTasksByDate(userId, date);
      return right(tasks);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksForPeriod({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;
      if (isOnline) {
        try {
          final remoteTasks = await remoteDataSource.getTasksInRange(
            userId,
            from,
            to,
          );
          return right(remoteTasks);
        } catch (_) {
          // Fall through to local
        }
      }
      final tasks = await localDataSource.searchTasks(
        userId,
        fromDate: from,
        toDate: to,
      );
      return right(tasks);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({required Task task}) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline) {
        final syncedTask = task.copyWith(isSynced: true);
        await localDataSource.insertTask(syncedTask);
        await remoteDataSource.createTask(syncedTask);
        return right(syncedTask);
      } else {
        final unsyncedTask = task.copyWith(isSynced: false);
        await localDataSource.insertTask(unsyncedTask);
        return right(unsyncedTask);
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

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

  @override
  Future<Either<Failure, void>> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;

      await localDataSource.deleteTask(taskId);

      if (isOnline) {
        await remoteDataSource.deleteTask(userId, taskId);
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

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
          await remoteDataSource.deleteTask(userId, task.id);
        } else {
          await remoteDataSource.createTask(task);
        }
        await localDataSource.markAsSynced(task.id);
      }

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
