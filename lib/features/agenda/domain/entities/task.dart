class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String? categoryId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;
  final int? notificationMinutesBefore;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.categoryId,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
    this.notificationMinutesBefore,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? categoryId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    int? notificationMinutesBefore,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      notificationMinutesBefore:
          notificationMinutesBefore ?? this.notificationMinutesBefore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, date: $date)';
}
