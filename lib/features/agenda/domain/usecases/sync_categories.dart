import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/repository/category_repository.dart';

class SyncCategoriesParams {
  final String userId;

  const SyncCategoriesParams({required this.userId});
}

class SyncCategories implements UseCase<void, SyncCategoriesParams> {
  final ICategoryRepository repository;

  const SyncCategories(this.repository);

  @override
  Future<Either<Failure, void>> call(SyncCategoriesParams params) async {
    return await repository.syncPendingCategories(userId: params.userId);
  }
}

