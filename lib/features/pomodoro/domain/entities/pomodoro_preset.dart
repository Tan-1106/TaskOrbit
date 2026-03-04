class PomodoroPreset {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int cyclesBeforeLongBreak;
  final bool isSynced;
  final bool isDeleted;

  const PomodoroPreset({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.cyclesBeforeLongBreak,
    this.isSynced = false,
    this.isDeleted = false,
  });

  PomodoroPreset copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? cyclesBeforeLongBreak,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return PomodoroPreset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      cyclesBeforeLongBreak: cyclesBeforeLongBreak ?? this.cyclesBeforeLongBreak,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroPreset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PomodoroPreset(id: $id, name: $name)';
}
