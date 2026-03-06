import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/features/agenda/data/datasources/category_local_data_source.dart';
import 'package:task_orbit/features/agenda/data/datasources/category_remote_data_source.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';
import 'package:task_orbit/features/agenda/domain/repository/category_repository.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  const CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    required String userId,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;

      if (isOnline && userId.isNotEmpty) {
        try {
          final remote = await remoteDataSource.getCategories(userId);
          if (remote.isNotEmpty) {
            await localDataSource.insertAll(
              remote.map((c) => c.copyWith(isSynced: true)).toList(),
            );
          }
        } catch (_) {}
      }

      final categories = await localDataSource.getCategories(userId);
      return right(categories);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required Category category,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;
      final canSync = isOnline && category.userId.isNotEmpty;

      if (canSync) {
        final synced = category.copyWith(isSynced: true);
        await localDataSource.insertCategory(synced);
        await remoteDataSource.createCategory(synced);
        return right(synced);
      } else {
        final unsynced = category.copyWith(isSynced: false);
        await localDataSource.insertCategory(unsynced);
        return right(unsynced);
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory({
    required String categoryId,
    required String userId,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;
      await localDataSource.deleteCategory(categoryId);

      if (isOnline && userId.isNotEmpty) {
        await remoteDataSource.deleteCategory(userId, categoryId);
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingCategories({
    required String userId,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected;
      if (!isOnline || userId.isEmpty) return right(null);

      await localDataSource.migrateGuestData(userId);

      final unsynced = await localDataSource.getUnsyncedCategories(userId);

      for (final cat in unsynced) {
        if (cat.isDeleted) {
          await remoteDataSource.deleteCategory(userId, cat.id);
        } else {
          await remoteDataSource.createCategory(cat);
        }
        await localDataSource.markAsSynced(cat.id);
      }

      // Pull down remote categories to merge any data from other devices
      final remoteCategories = await remoteDataSource.getCategories(userId);
      if (remoteCategories.isNotEmpty) {
        await localDataSource.insertAll(
          remoteCategories
              .map((c) => c.copyWith(isSynced: true))
              .toList(),
        );
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
