import 'package:flutter/material.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

sealed class AgendaEvent {}

class AgendaLoadTasks extends AgendaEvent {
  final DateTime date;
  AgendaLoadTasks({required this.date});
}

class AgendaDateChanged extends AgendaEvent {
  final DateTime date;
  AgendaDateChanged({required this.date});
}

class AgendaMonthChanged extends AgendaEvent {
  final DateTime month;
  AgendaMonthChanged({required this.month});
}

class AgendaCreateTask extends AgendaEvent {
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String? categoryId;

  AgendaCreateTask({
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.categoryId,
  });
}

class AgendaUpdateTask extends AgendaEvent {
  final String taskId;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String? categoryId;
  final bool isCompleted;

  AgendaUpdateTask({
    required this.taskId,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.categoryId,
    required this.isCompleted,
  });
}

class AgendaDeleteTask extends AgendaEvent {
  final String taskId;
  AgendaDeleteTask({required this.taskId});
}

class AgendaToggleTaskComplete extends AgendaEvent {
  final String taskId;
  AgendaToggleTaskComplete({required this.taskId});
}

class AgendaSearchTasks extends AgendaEvent {
  final TaskFilter filter;
  AgendaSearchTasks({required this.filter});
}

class AgendaSyncTasks extends AgendaEvent {}

// ── Category Events ─────────────────────────────

class AgendaLoadCategories extends AgendaEvent {}

class AgendaCreateCategory extends AgendaEvent {
  final String name;
  final Color color;
  AgendaCreateCategory({required this.name, required this.color});
}

class AgendaDeleteCategory extends AgendaEvent {
  final String categoryId;
  AgendaDeleteCategory({required this.categoryId});
}
