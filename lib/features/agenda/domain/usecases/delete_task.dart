import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class DeleteTaskParams {
  final String taskId;
  final String userId;

  const DeleteTaskParams({required this.taskId, required this.userId});
}

class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final ITaskRepository repository;

  const DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(
      taskId: params.taskId,
      userId: params.userId,
    );
  }
}
