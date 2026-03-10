import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// TABLES DEFINITIONS
// Tasks
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

// Categories
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

// Pomodoro Presets
class PomodoroPresets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get focusMinutes => integer()();
  IntColumn get shortBreakMinutes => integer()();
  IntColumn get longBreakMinutes => integer()();
  IntColumn get cyclesBeforeLongBreak => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// DATABASE DEFINITION
/// To generate the database code, run: `dart run build_runner build --delete-conflicting-outputs`
@DriftDatabase(tables: [Tasks, Categories, PomodoroPresets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

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
        if (from < 3) {
          await m.createTable(pomodoroPresets);
        }
      },
    );
  }

  // Opens a connection to the local SQLite database using Drift's Flutter integration.
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'task_orbit_db');
  }
}
