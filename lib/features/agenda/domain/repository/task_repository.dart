import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';

/// Filter criteria for searching tasks
class TaskFilter {
  final String? keyword;
  final String? categoryId;
  final bool? isCompleted;
  final DateTime? fromDate;
  final DateTime? toDate;

  const TaskFilter({
    this.keyword,
    this.categoryId,
    this.isCompleted,
    this.fromDate,
    this.toDate,
  });
}

abstract interface class ITaskRepository {
  /// Get all tasks for a specific date
  Future<Either<Failure, List<Task>>> getTasksByDate({
    required String userId,
    required DateTime date,
  });

  /// Create a new task
  Future<Either<Failure, Task>> createTask({required Task task});

  /// Update an existing task
  Future<Either<Failure, Task>> updateTask({required Task task});

  /// Delete a task (soft delete for sync)
  Future<Either<Failure, void>> deleteTask({
    required String taskId,
    required String userId,
  });

  /// Toggle task completion status
  Future<Either<Failure, Task>> toggleTaskComplete({
    required String taskId,
    required String userId,
  });

  /// Search/filter tasks
  Future<Either<Failure, List<Task>>> searchTasks({
    required String userId,
    required TaskFilter filter,
  });

  /// Get all tasks in a date range (for profile statistics)
  Future<Either<Failure, List<Task>>> getTasksForPeriod({
    required String userId,
    required DateTime from,
    required DateTime to,
  });

  /// Sync all pending local changes to Firebase
  Future<Either<Failure, void>> syncPendingChanges({required String userId});
}
