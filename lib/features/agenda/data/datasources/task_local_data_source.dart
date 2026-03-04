import 'package:drift/drift.dart';
import 'package:task_orbit/core/database/app_database.dart' as db_schema;
import 'package:task_orbit/features/agenda/domain/entities/task.dart' as domain;

abstract interface class TaskLocalDataSource {
  Future<List<domain.Task>> getTasksByDate(String userId, DateTime date);

  Future<void> insertTask(domain.Task task);

  Future<void> updateTask(domain.Task task);

  Future<void> deleteTask(String taskId);

  Future<domain.Task?> getTaskById(String taskId);

  Future<List<domain.Task>> getUnsyncedTasks(String userId);

  Future<void> migrateGuestData(String newUserId);

  Future<void> markAsSynced(String taskId);

  Future<void> insertAll(List<domain.Task> tasks);

  Future<List<domain.Task>> searchTasks(
    String userId, {
    String? keyword,
    String? categoryId,
    bool? isCompleted,
    DateTime? fromDate,
    DateTime? toDate,
  });
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final db_schema.AppDatabase db;

  const TaskLocalDataSourceImpl(this.db);

  @override
  Future<List<domain.Task>> getTasksByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows =
        await (db.select(
              db.tasks,
            )..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.date.isBiggerOrEqualValue(startOfDay) &
                  t.date.isSmallerThanValue(endOfDay) &
                  t.isDeleted.equals(false),
            ))
            .get();

    return rows.map(_taskFromRow).toList();
  }

  @override
  Future<void> insertTask(domain.Task task) async {
    await db.into(db.tasks).insertOnConflictUpdate(_taskToCompanion(task));
  }

  @override
  Future<void> updateTask(domain.Task task) async {
    await (db.update(
      db.tasks,
    )..where((t) => t.id.equals(task.id))).write(_taskToCompanion(task));
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
      db_schema.TasksCompanion(
        isDeleted: const Value(true),
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<domain.Task?> getTaskById(String taskId) async {
    final row = await (db.select(
      db.tasks,
    )..where((t) => t.id.equals(taskId))).getSingleOrNull();
    return row != null ? _taskFromRow(row) : null;
  }

  @override
  Future<List<domain.Task>> getUnsyncedTasks(String userId) async {
    final rows = await (db.select(
      db.tasks,
    )..where((t) => t.userId.equals(userId) & t.isSynced.equals(false))).get();
    return rows.map(_taskFromRow).toList();
  }

  @override
  Future<void> migrateGuestData(String newUserId) async {
    await (db.update(db.tasks)..where((t) => t.userId.equals(''))).write(
      db_schema.TasksCompanion(
        userId: Value(newUserId),
        isSynced: const Value(false),
      ),
    );
  }

  @override
  Future<void> markAsSynced(String taskId) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
      const db_schema.TasksCompanion(isSynced: Value(true)),
    );
  }

  @override
  Future<void> insertAll(List<domain.Task> tasks) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.tasks,
        tasks.map(_taskToCompanion).toList(),
      );
    });
  }

  @override
  Future<List<domain.Task>> searchTasks(
    String userId, {
    String? keyword,
    String? categoryId,
    bool? isCompleted,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = db.select(db.tasks)
      ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false));

    if (keyword != null && keyword.isNotEmpty) {
      query.where(
        (t) => t.title.contains(keyword) | t.description.contains(keyword),
      );
    }
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (isCompleted != null) {
      query.where((t) => t.isCompleted.equals(isCompleted));
    }
    if (fromDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      query.where(
        (t) => t.date.isSmallerThanValue(toDate.add(const Duration(days: 1))),
      );
    }

    query.orderBy([(t) => OrderingTerm.asc(t.date)]);

    final rows = await query.get();
    return rows.map(_taskFromRow).toList();
  }

  domain.Task _taskFromRow(db_schema.Task row) {
    return domain.Task(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      date: row.date,
      startTime: row.startTime,
      endTime: row.endTime,
      isAllDay: row.isAllDay,
      categoryId: row.categoryId,
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
      isDeleted: row.isDeleted,
      notificationMinutesBefore: row.notificationMinutesBefore,
    );
  }

  db_schema.TasksCompanion _taskToCompanion(domain.Task task) {
    return db_schema.TasksCompanion(
      id: Value(task.id),
      userId: Value(task.userId),
      title: Value(task.title),
      description: Value(task.description),
      date: Value(task.date),
      startTime: Value(task.startTime),
      endTime: Value(task.endTime),
      isAllDay: Value(task.isAllDay),
      categoryId: Value(task.categoryId),
      isCompleted: Value(task.isCompleted),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
      isSynced: Value(task.isSynced),
      isDeleted: Value(task.isDeleted),
      notificationMinutesBefore: Value(task.notificationMinutesBefore),
    );
  }
}
