import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';

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
  Future<Either<Failure, List<Task>>> getTasksByDate({
    required String userId,
    required DateTime date,
  });

  Future<Either<Failure, Task>> createTask({required Task task});

  Future<Either<Failure, Task>> updateTask({required Task task});

  Future<Either<Failure, void>> deleteTask({
    required String taskId,
    required String userId,
  });

  Future<Either<Failure, Task>> toggleTaskComplete({
    required String taskId,
    required String userId,
  });

  Future<Either<Failure, List<Task>>> searchTasks({
    required String userId,
    required TaskFilter filter,
  });

  Future<Either<Failure, List<Task>>> getTasksForPeriod({
    required String userId,
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, void>> syncPendingChanges({required String userId});
}
