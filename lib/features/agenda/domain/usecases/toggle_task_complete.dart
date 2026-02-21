import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class ToggleTaskCompleteParams {
  final String taskId;
  final String userId;
  const ToggleTaskCompleteParams({required this.taskId, required this.userId});
}

class ToggleTaskComplete implements UseCase<Task, ToggleTaskCompleteParams> {
  final ITaskRepository repository;
  const ToggleTaskComplete(this.repository);

  @override
  Future<Either<Failure, Task>> call(ToggleTaskCompleteParams params) async {
    return await repository.toggleTaskComplete(
      taskId: params.taskId,
      userId: params.userId,
    );
  }
}
