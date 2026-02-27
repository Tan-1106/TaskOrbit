import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class GetTasksForPeriod
    implements UseCase<List<Task>, GetTasksForPeriodParams> {
  final ITaskRepository taskRepository;

  GetTasksForPeriod(this.taskRepository);

  @override
  Future<Either<Failure, List<Task>>> call(
    GetTasksForPeriodParams params,
  ) async {
    return await taskRepository.getTasksForPeriod(
      userId: params.userId,
      from: params.from,
      to: params.to,
    );
  }
}

class GetTasksForPeriodParams {
  final String userId;
  final DateTime from;
  final DateTime to;

  GetTasksForPeriodParams({
    required this.userId,
    required this.from,
    required this.to,
  });
}
