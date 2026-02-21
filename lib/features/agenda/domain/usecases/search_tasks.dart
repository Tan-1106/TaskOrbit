import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class SearchTasks implements UseCase<List<Task>, SearchTasksParams> {
  final ITaskRepository repository;
  const SearchTasks(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(SearchTasksParams params) async {
    return await repository.searchTasks(
      userId: params.userId,
      filter: params.filter,
    );
  }
}

class SearchTasksParams {
  final String userId;
  final TaskFilter filter;
  const SearchTasksParams({required this.userId, required this.filter});
}
