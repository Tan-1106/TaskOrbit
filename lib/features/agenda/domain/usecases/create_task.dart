import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class CreateTask implements UseCase<Task, Task> {
  final ITaskRepository repository;

  const CreateTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(Task task) async {
    return await repository.createTask(task: task);
  }
}
