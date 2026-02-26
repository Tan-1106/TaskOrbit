import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/repository/category_repository.dart';

class DeleteCategoryParams {
  final String categoryId;
  final String userId;

  const DeleteCategoryParams({required this.categoryId, required this.userId});
}

class DeleteCategory implements UseCase<void, DeleteCategoryParams> {
  final ICategoryRepository repository;

  const DeleteCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    return await repository.deleteCategory(
      categoryId: params.categoryId,
      userId: params.userId,
    );
  }
}
