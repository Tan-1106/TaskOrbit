import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';

abstract interface class ICategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories({
    required String userId,
  });

  Future<Either<Failure, Category>> createCategory({
    required Category category,
  });

  Future<Either<Failure, void>> deleteCategory({
    required String categoryId,
    required String userId,
  });

  Future<Either<Failure, void>> syncPendingCategories({
    required String userId,
  });
}
