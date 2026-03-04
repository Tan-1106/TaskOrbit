import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart' as domain;

abstract interface class PomodoroPresetRemoteDataSource {
  Future<List<domain.PomodoroPreset>> getAllPresets(String userId);

  Future<void> createPreset(domain.PomodoroPreset preset);

  Future<void> updatePreset(domain.PomodoroPreset preset);

  Future<void> deletePreset(String userId, String presetId);
}

class PomodoroPresetRemoteDataSourceImpl implements PomodoroPresetRemoteDataSource {
  final FirebaseFirestore firestore;

  const PomodoroPresetRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _presetsRef(String userId) {
    return firestore.collection('users').doc(userId).collection('pomodoro_presets');
  }

  @override
  Future<List<domain.PomodoroPreset>> getAllPresets(String userId) async {
    final snapshot = await _presetsRef(userId).get();
    return snapshot.docs.map((doc) => _presetFromDoc(doc, userId)).toList();
  }

  @override
  Future<void> createPreset(domain.PomodoroPreset preset) async {
    await _presetsRef(preset.userId).doc(preset.id).set(_presetToMap(preset));
  }

  @override
  Future<void> updatePreset(domain.PomodoroPreset preset) async {
    await _presetsRef(
      preset.userId,
    ).doc(preset.id).update(_presetToMap(preset));
  }

  @override
  Future<void> deletePreset(String userId, String presetId) async {
    await _presetsRef(userId).doc(presetId).delete();
  }

  domain.PomodoroPreset _presetFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String userId,
  ) {
    final d = doc.data()!;
    return domain.PomodoroPreset(
      id: doc.id,
      userId: userId,
      name: d['name'] as String,
      description: d['description'] as String?,
      focusMinutes: d['focusMinutes'] as int,
      shortBreakMinutes: d['shortBreakMinutes'] as int,
      longBreakMinutes: d['longBreakMinutes'] as int,
      cyclesBeforeLongBreak: d['cyclesBeforeLongBreak'] as int,
      isSynced: true,
      isDeleted: false,
    );
  }

  Map<String, dynamic> _presetToMap(domain.PomodoroPreset preset) {
    return {
      'name': preset.name,
      'description': preset.description,
      'focusMinutes': preset.focusMinutes,
      'shortBreakMinutes': preset.shortBreakMinutes,
      'longBreakMinutes': preset.longBreakMinutes,
      'cyclesBeforeLongBreak': preset.cyclesBeforeLongBreak,
    };
  }
}
