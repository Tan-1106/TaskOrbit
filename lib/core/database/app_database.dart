import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────
// Table Definitions
// ─────────────────────────────────────────

class Tasks extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  TextColumn get description => text().nullable()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get startTime => dateTime().nullable()();

  DateTimeColumn get endTime => dateTime().nullable()();

  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();

  TextColumn get categoryId => text().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  IntColumn get notificationMinutesBefore => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  IntColumn get colorValue => integer()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────
// Database
// ─────────────────────────────────────────

@DriftDatabase(tables: [Tasks, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(tasks, tasks.notificationMinutesBefore);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'task_orbit_db');
  }
}
