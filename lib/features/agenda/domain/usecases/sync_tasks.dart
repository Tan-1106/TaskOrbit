import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class SyncTasksParams {
  final String userId;

  const SyncTasksParams({required this.userId});
}

class SyncTasks implements UseCase<void, SyncTasksParams> {
  final ITaskRepository repository;

  const SyncTasks(this.repository);

  @override
  Future<Either<Failure, void>> call(SyncTasksParams params) async {
    return await repository.syncPendingChanges(userId: params.userId);
  }
}
