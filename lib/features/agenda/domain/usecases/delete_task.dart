import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';
import 'package:task_orbit/core/services/notification_service.dart';

class DeleteTaskParams {
  final String taskId;
  final String userId;

  const DeleteTaskParams({required this.taskId, required this.userId});
}

class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final ITaskRepository repository;
  final NotificationService notificationService;

  const DeleteTask(this.repository, this.notificationService);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    final result = await repository.deleteTask(
      taskId: params.taskId,
      userId: params.userId,
    );
    return result.map((_) {
      notificationService.cancelNotification(params.taskId.hashCode);
    });
  }
}
