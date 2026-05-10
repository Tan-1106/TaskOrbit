import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  final FirebaseFunctions functions;

  const TaskRemoteDataSourceImpl(this.firestore, this.functions);

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<List<domain.Task>> getTasksByDate(String userId, DateTime date) async {
    try {
      final callable = functions.httpsCallable('getSecureTasks');
      final response = await callable.call({
        'date': date.toIso8601String(),
      });

      final List tasksData = response.data['tasks'];
      return tasksData.map((d) => _taskFromMap(d)).toList();
    } catch (e) {
      // Fallback to local filtering if needed, but Cloud Function should handle it
      rethrow;
    }
  }

  @override
  Future<void> createTask(domain.Task task) async {
    final callable = functions.httpsCallable('saveSecureTask');
    await callable.call({
      'id': task.id,
      ..._taskToMap(task),
    });
  }

  @override
  Future<void> updateTask(domain.Task task) async {
    final callable = functions.httpsCallable('saveSecureTask');
    await callable.call({
      'id': task.id,
      ..._taskToMap(task),
    });
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
  }

  @override
  Future<List<domain.Task>> getAllTasks(String userId) async {
    final callable = functions.httpsCallable('getSecureTasks');
    final response = await callable.call();

    final List tasksData = response.data['tasks'];
    return tasksData.map((d) => _taskFromMap(d)).toList();
  }

  @override
  Future<List<domain.Task>> getTasksInRange(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final callable = functions.httpsCallable('getSecureTasks');
    final response = await callable.call({
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });

    final List tasksData = response.data['tasks'];
    return tasksData.map((d) => _taskFromMap(d)).toList();
  }

  domain.Task _taskFromMap(Map<String, dynamic> d) {
    return domain.Task(
      id: d['id'] as String,
      userId: d['userId'] as String,
      title: d['title'] as String,
      description: d['description'] as String?,
      date: DateTime.parse(d['date'] as String),
      startTime: d['startTime'] != null ? DateTime.parse(d['startTime'] as String) : null,
      endTime: d['endTime'] != null ? DateTime.parse(d['endTime'] as String) : null,
      isAllDay: d['isAllDay'] as bool? ?? false,
      categoryId: d['categoryId'] as String?,
      isCompleted: d['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(d['createdAt'] as String),
      updatedAt: DateTime.parse(d['updatedAt'] as String),
      isSynced: true,
      isDeleted: false,
      notificationMinutesBefore: d['notificationMinutesBefore'] as int?,
    );
  }

  Map<String, dynamic> _taskToMap(domain.Task task) {
    return {
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'date': task.date.toIso8601String(),
      'startTime': task.startTime?.toIso8601String(),
      'endTime': task.endTime?.toIso8601String(),
      'isAllDay': task.isAllDay,
      'categoryId': task.categoryId,
      'isCompleted': task.isCompleted,
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      if (task.notificationMinutesBefore != null) 'notificationMinutesBefore': task.notificationMinutesBefore,
    };
  }
}
