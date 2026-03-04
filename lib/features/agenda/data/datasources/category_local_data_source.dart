import 'dart:ui';
import 'package:drift/drift.dart';
import 'package:task_orbit/core/database/app_database.dart' as db_schema;
import 'package:task_orbit/features/agenda/domain/entities/category.dart'
    as domain;

abstract interface class CategoryLocalDataSource {
  Future<List<domain.Category>> getCategories(String userId);

  Future<void> insertCategory(domain.Category category);

  Future<void> deleteCategory(String categoryId);

  Future<void> markAsSynced(String categoryId);

  Future<List<domain.Category>> getUnsyncedCategories(String userId);

  Future<void> migrateGuestData(String newUserId);

  Future<void> insertAll(List<domain.Category> categories);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final db_schema.AppDatabase db;

  const CategoryLocalDataSourceImpl(this.db);

  @override
  Future<List<domain.Category>> getCategories(String userId) async {
    final rows = await (db.select(
      db.categories,
    )..where((c) => c.userId.equals(userId) & c.isDeleted.equals(false))).get();
    return rows.map(_categoryFromRow).toList();
  }

  @override
  Future<void> insertCategory(domain.Category category) async {
    await db
        .into(db.categories)
        .insertOnConflictUpdate(_categoryToCompanion(category));
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await (db.update(
      db.categories,
    )..where((c) => c.id.equals(categoryId))).write(
      const db_schema.CategoriesCompanion(
        isDeleted: Value(true),
        isSynced: Value(false),
      ),
    );
  }

  @override
  Future<void> markAsSynced(String categoryId) async {
    await (db.update(db.categories)..where((c) => c.id.equals(categoryId)))
        .write(const db_schema.CategoriesCompanion(isSynced: Value(true)));
  }

  @override
  Future<List<domain.Category>> getUnsyncedCategories(String userId) async {
    final rows = await (db.select(
      db.categories,
    )..where((c) => c.userId.equals(userId) & c.isSynced.equals(false))).get();
    return rows.map(_categoryFromRow).toList();
  }

  @override
  Future<void> migrateGuestData(String newUserId) async {
    await (db.update(db.categories)..where((c) => c.userId.equals(''))).write(
      db_schema.CategoriesCompanion(
        userId: Value(newUserId),
        isSynced: const Value(false),
      ),
    );
  }

  @override
  Future<void> insertAll(List<domain.Category> categories) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.categories,
        categories.map(_categoryToCompanion).toList(),
      );
    });
  }

  domain.Category _categoryFromRow(db_schema.Category row) {
    return domain.Category(
      id: row.id,
      userId: row.userId,
      name: row.name,
      color: Color(row.colorValue),
      isSynced: row.isSynced,
      isDeleted: row.isDeleted,
    );
  }

  db_schema.CategoriesCompanion _categoryToCompanion(domain.Category cat) {
    return db_schema.CategoriesCompanion(
      id: Value(cat.id),
      userId: Value(cat.userId),
      name: Value(cat.name),
      colorValue: Value(cat.color.toARGB32()),
      isSynced: Value(cat.isSynced),
      isDeleted: Value(cat.isDeleted),
    );
  }
}
