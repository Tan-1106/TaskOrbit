import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';
import 'package:task_orbit/features/agenda/domain/repository/category_repository.dart';

class CreateCategory implements UseCase<Category, Category> {
  final ICategoryRepository repository;

  const CreateCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(Category category) async {
    return await repository.createCategory(category: category);
  }
}
