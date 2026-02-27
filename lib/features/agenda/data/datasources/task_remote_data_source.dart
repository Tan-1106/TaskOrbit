import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart' as domain;

abstract interface class TaskRemoteDataSource {
  Future<List<domain.Task>> getTasksByDate(String userId, DateTime date);

  Future<void> createTask(domain.Task task);

  Future<void> updateTask(domain.Task task);

  Future<void> deleteTask(String userId, String taskId);

  Future<List<domain.Task>> getAllTasks(String userId);

  Future<List<domain.Task>> getTasksInRange(
    String userId,
    DateTime from,
    DateTime to,
  );
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  const TaskRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<List<domain.Task>> getTasksByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot =
        await _tasksRef(
              userId,
            )
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('date', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

    return snapshot.docs.map((doc) => _taskFromDoc(doc)).toList();
  }

  @override
  Future<void> createTask(domain.Task task) async {
    await _tasksRef(task.userId).doc(task.id).set(_taskToMap(task));
  }

  @override
  Future<void> updateTask(domain.Task task) async {
    await _tasksRef(task.userId).doc(task.id).update(_taskToMap(task));
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
  }

  @override
  Future<List<domain.Task>> getAllTasks(String userId) async {
    final snapshot = await _tasksRef(userId).get();
    return snapshot.docs.map((doc) => _taskFromDoc(doc)).toList();
  }

  @override
  Future<List<domain.Task>> getTasksInRange(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final startOfFrom = DateTime(from.year, from.month, from.day);
    final endOfTo = DateTime(to.year, to.month, to.day).add(
      const Duration(days: 1),
    );

    final snapshot = await _tasksRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfFrom))
        .where('date', isLessThan: Timestamp.fromDate(endOfTo))
        .get();

    return snapshot.docs.map((doc) => _taskFromDoc(doc)).toList();
  }

  // ─────────────────────────────────────
  // Mappers
  // ─────────────────────────────────────

  domain.Task _taskFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return domain.Task(
      id: doc.id,
      userId: d['userId'] as String,
      title: d['title'] as String,
      description: d['description'] as String?,
      date: (d['date'] as Timestamp).toDate(),
      startTime: d['startTime'] != null
          ? (d['startTime'] as Timestamp).toDate()
          : null,
      endTime: d['endTime'] != null
          ? (d['endTime'] as Timestamp).toDate()
          : null,
      isAllDay: d['isAllDay'] as bool? ?? false,
      categoryId: d['categoryId'] as String?,
      isCompleted: d['isCompleted'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
      // From Firebase = always synced
      isDeleted: false,
      notificationMinutesBefore: d['notificationMinutesBefore'] as int?,
    );
  }

  Map<String, dynamic> _taskToMap(domain.Task task) {
    return {
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'date': Timestamp.fromDate(task.date),
      'startTime': task.startTime != null
          ? Timestamp.fromDate(task.startTime!)
          : null,
      'endTime': task.endTime != null
          ? Timestamp.fromDate(task.endTime!)
          : null,
      'isAllDay': task.isAllDay,
      'categoryId': task.categoryId,
      'isCompleted': task.isCompleted,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'updatedAt': Timestamp.fromDate(task.updatedAt),
      if (task.notificationMinutesBefore != null)
        'notificationMinutesBefore': task.notificationMinutesBefore,
    };
  }
}
