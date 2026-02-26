import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class GetTasksByDateParams {
  final String userId;
  final DateTime date;

  const GetTasksByDateParams({required this.userId, required this.date});
}

class GetTasksByDate implements UseCase<List<Task>, GetTasksByDateParams> {
  final ITaskRepository repository;

  const GetTasksByDate(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(GetTasksByDateParams params) async {
    return await repository.getTasksByDate(
      userId: params.userId,
      date: params.date,
    );
  }
}
