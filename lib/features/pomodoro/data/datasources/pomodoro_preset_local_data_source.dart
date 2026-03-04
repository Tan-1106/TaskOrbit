import 'package:drift/drift.dart';
import 'package:task_orbit/core/database/app_database.dart' as db_schema;
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart'
    as domain;

abstract interface class PomodoroPresetLocalDataSource {
  Future<List<domain.PomodoroPreset>> getPresets(String userId);

  Future<void> insertPreset(domain.PomodoroPreset preset);

  Future<void> deletePreset(String presetId);

  Future<void> markAsSynced(String presetId);

  Future<List<domain.PomodoroPreset>> getUnsyncedPresets(String userId);

  Future<void> migrateGuestData(String newUserId);

  Future<void> insertAll(List<domain.PomodoroPreset> presets);
}

class PomodoroPresetLocalDataSourceImpl
    implements PomodoroPresetLocalDataSource {
  final db_schema.AppDatabase db;

  const PomodoroPresetLocalDataSourceImpl(this.db);

  @override
  Future<List<domain.PomodoroPreset>> getPresets(String userId) async {
    final rows =
        await (db.select(db.pomodoroPresets)..where(
              (p) => p.userId.equals(userId) & p.isDeleted.equals(false),
            ))
            .get();
    return rows.map(_presetFromRow).toList();
  }

  @override
  Future<void> insertPreset(domain.PomodoroPreset preset) async {
    await db
        .into(db.pomodoroPresets)
        .insertOnConflictUpdate(_presetToCompanion(preset));
  }

  @override
  Future<void> deletePreset(String presetId) async {
    await (db.update(
      db.pomodoroPresets,
    )..where((p) => p.id.equals(presetId))).write(
      const db_schema.PomodoroPresetsCompanion(
        isDeleted: Value(true),
        isSynced: Value(false),
      ),
    );
  }

  @override
  Future<void> markAsSynced(String presetId) async {
    await (db.update(
      db.pomodoroPresets,
    )..where((p) => p.id.equals(presetId))).write(
      const db_schema.PomodoroPresetsCompanion(isSynced: Value(true)),
    );
  }

  @override
  Future<List<domain.PomodoroPreset>> getUnsyncedPresets(String userId) async {
    final rows =
        await (db.select(db.pomodoroPresets)..where(
              (p) => p.userId.equals(userId) & p.isSynced.equals(false),
            ))
            .get();
    return rows.map(_presetFromRow).toList();
  }

  @override
  Future<void> migrateGuestData(String newUserId) async {
    await (db.update(
      db.pomodoroPresets,
    )..where((p) => p.userId.equals(''))).write(
      db_schema.PomodoroPresetsCompanion(
        userId: Value(newUserId),
        isSynced: const Value(false),
      ),
    );
  }

  @override
  Future<void> insertAll(List<domain.PomodoroPreset> presets) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.pomodoroPresets,
        presets.map(_presetToCompanion).toList(),
      );
    });
  }

  domain.PomodoroPreset _presetFromRow(db_schema.PomodoroPreset row) {
    return domain.PomodoroPreset(
      id: row.id,
      userId: row.userId,
      name: row.name,
      description: row.description,
      focusMinutes: row.focusMinutes,
      shortBreakMinutes: row.shortBreakMinutes,
      longBreakMinutes: row.longBreakMinutes,
      cyclesBeforeLongBreak: row.cyclesBeforeLongBreak,
      isSynced: row.isSynced,
      isDeleted: row.isDeleted,
    );
  }

  db_schema.PomodoroPresetsCompanion _presetToCompanion(
    domain.PomodoroPreset preset,
  ) {
    return db_schema.PomodoroPresetsCompanion(
      id: Value(preset.id),
      userId: Value(preset.userId),
      name: Value(preset.name),
      description: Value(preset.description),
      focusMinutes: Value(preset.focusMinutes),
      shortBreakMinutes: Value(preset.shortBreakMinutes),
      longBreakMinutes: Value(preset.longBreakMinutes),
      cyclesBeforeLongBreak: Value(preset.cyclesBeforeLongBreak),
      isSynced: Value(preset.isSynced),
      isDeleted: Value(preset.isDeleted),
    );
  }
}
