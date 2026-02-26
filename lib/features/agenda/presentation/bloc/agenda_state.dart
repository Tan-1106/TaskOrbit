import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';

sealed class AgendaState {
  final DateTime selectedDate;
  final DateTime currentMonth;
  final List<Task> tasks;
  final List<Category> categories;

  const AgendaState({
    required this.selectedDate,
    required this.currentMonth,
    required this.tasks,
    required this.categories,
  });
}

class AgendaInitial extends AgendaState {
  AgendaInitial()
    : super(
        selectedDate: DateTime.now(),
        currentMonth: DateTime(DateTime.now().year, DateTime.now().month),
        tasks: const [],
        categories: const [],
      );
}

class AgendaLoading extends AgendaState {
  const AgendaLoading({
    required super.selectedDate,
    required super.currentMonth,
    required super.tasks,
    required super.categories,
  });
}

class AgendaLoaded extends AgendaState {
  const AgendaLoaded({
    required super.selectedDate,
    required super.currentMonth,
    required super.tasks,
    required super.categories,
  });
}

class AgendaFailure extends AgendaState {
  final String message;

  const AgendaFailure({
    required this.message,
    required super.selectedDate,
    required super.currentMonth,
    required super.tasks,
    required super.categories,
  });
}

class AgendaTaskActionSuccess extends AgendaState {
  final String message;

  const AgendaTaskActionSuccess({
    required this.message,
    required super.selectedDate,
    required super.currentMonth,
    required super.tasks,
    required super.categories,
  });
}
