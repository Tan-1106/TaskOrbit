import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart' as domain;
import 'package:task_orbit/features/agenda/domain/entities/category.dart'
    as domain_cat;
import 'package:task_orbit/features/agenda/domain/usecases/get_tasks_by_date.dart';
import 'package:task_orbit/features/agenda/domain/usecases/create_task.dart';
import 'package:task_orbit/features/agenda/domain/usecases/update_task.dart';
import 'package:task_orbit/features/agenda/domain/usecases/delete_task.dart';
import 'package:task_orbit/features/agenda/domain/usecases/toggle_task_complete.dart';
import 'package:task_orbit/features/agenda/domain/usecases/search_tasks.dart';
import 'package:task_orbit/features/agenda/domain/usecases/sync_tasks.dart';
import 'package:task_orbit/features/agenda/domain/usecases/sync_categories.dart';
import 'package:task_orbit/features/agenda/domain/usecases/get_categories.dart';
import 'package:task_orbit/features/agenda/domain/usecases/create_category.dart';
import 'package:task_orbit/features/agenda/domain/usecases/delete_category.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final GetTasksByDate _getTasksByDate;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final ToggleTaskComplete _toggleTaskComplete;
  final SearchTasks _searchTasks;
  final SyncTasks _syncTasks;
  final SyncCategories _syncCategories;
  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final DeleteCategory _deleteCategory;
  final FirebaseAuth _firebaseAuth;
  final ConnectivityService _connectivityService;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _authSubscription;

  static const _uuid = Uuid();

  AgendaBloc({
    required GetTasksByDate getTasksByDate,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required ToggleTaskComplete toggleTaskComplete,
    required SearchTasks searchTasks,
    required SyncTasks syncTasks,
    required SyncCategories syncCategories,
    required GetCategories getCategories,
    required CreateCategory createCategory,
    required DeleteCategory deleteCategory,
    required FirebaseAuth firebaseAuth,
    required ConnectivityService connectivityService,
  }) : _getTasksByDate = getTasksByDate,
       _createTask = createTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _toggleTaskComplete = toggleTaskComplete,
       _searchTasks = searchTasks,
       _syncTasks = syncTasks,
       _syncCategories = syncCategories,
       _getCategories = getCategories,
       _createCategory = createCategory,
       _deleteCategory = deleteCategory,
       _firebaseAuth = firebaseAuth,
       _connectivityService = connectivityService,
       super(AgendaInitial()) {
    on<AgendaLoadTasks>(_onLoadTasks);
    on<AgendaDateChanged>(_onDateChanged);
    on<AgendaMonthChanged>(_onMonthChanged);
    on<AgendaCreateTask>(_onCreateTask);
    on<AgendaUpdateTask>(_onUpdateTask);
    on<AgendaDeleteTask>(_onDeleteTask);
    on<AgendaToggleTaskComplete>(_onToggleTaskComplete);
    on<AgendaSearchTasks>(_onSearchTasks);
    on<AgendaSyncTasks>(_onSyncTasks);
    on<AgendaSyncCategories>(_onSyncCategories);
    on<AgendaLoadCategories>(_onLoadCategories);
    on<AgendaCreateCategory>(_onCreateCategory);
    on<AgendaDeleteCategory>(_onDeleteCategory);

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((isConnected) {
          if (isConnected) {
            add(AgendaSyncTasks());
            add(AgendaSyncCategories());
          }
        });

    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null && user.emailVerified) {
        add(AgendaSyncTasks());
        add(AgendaSyncCategories());
      }
    });
  }

  String get _userId => _firebaseAuth.currentUser?.uid ?? '';

  Future<void> _onLoadTasks(
    AgendaLoadTasks event,
    Emitter<AgendaState> emit,
  ) async {
    emit(
      AgendaLoading(
        selectedDate: event.date,
        currentMonth: state.currentMonth,
        tasks: state.tasks,
        categories: state.categories,
      ),
    );

    final result = await _getTasksByDate(
      GetTasksByDateParams(userId: _userId, date: event.date),
    );

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: event.date,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (tasks) => emit(
        AgendaLoaded(
          selectedDate: event.date,
          currentMonth: state.currentMonth,
          tasks: tasks,
          categories: state.categories,
        ),
      ),
    );
  }

  Future<void> _onDateChanged(
    AgendaDateChanged event,
    Emitter<AgendaState> emit,
  ) async {
    add(AgendaLoadTasks(date: event.date));
  }

  void _onMonthChanged(AgendaMonthChanged event, Emitter<AgendaState> emit) {
    emit(
      AgendaLoaded(
        selectedDate: event.month,
        currentMonth: event.month,
        tasks: const [],
        categories: state.categories,
      ),
    );
    add(AgendaLoadTasks(date: event.month));
  }

  Future<void> _onCreateTask(
    AgendaCreateTask event,
    Emitter<AgendaState> emit,
  ) async {
    final now = DateTime.now();
    final task = domain.Task(
      id: _uuid.v4(),
      userId: _userId,
      title: event.title,
      description: event.description,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      categoryId: event.categoryId,
      createdAt: now,
      updatedAt: now,
      notificationMinutesBefore: event.notificationMinutesBefore,
    );

    final result = await _createTask(task);

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (_) {
        emit(
          AgendaTaskActionSuccess(
            message: 'Task created successfully',
            selectedDate: state.selectedDate,
            currentMonth: state.currentMonth,
            tasks: state.tasks,
            categories: state.categories,
          ),
        );
        add(AgendaLoadTasks(date: state.selectedDate));
      },
    );
  }

  Future<void> _onUpdateTask(
    AgendaUpdateTask event,
    Emitter<AgendaState> emit,
  ) async {
    final now = DateTime.now();
    final existing = state.tasks.firstWhere((t) => t.id == event.taskId);
    final updatedTask = existing.copyWith(
      title: event.title,
      description: event.description,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      categoryId: event.categoryId,
      isCompleted: event.isCompleted,
      updatedAt: now,
      notificationMinutesBefore: event.notificationMinutesBefore,
    );

    final result = await _updateTask(updatedTask);

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (_) {
        emit(
          AgendaTaskActionSuccess(
            message: 'Task updated successfully',
            selectedDate: state.selectedDate,
            currentMonth: state.currentMonth,
            tasks: state.tasks,
            categories: state.categories,
          ),
        );
        add(AgendaLoadTasks(date: state.selectedDate));
      },
    );
  }

  Future<void> _onDeleteTask(
    AgendaDeleteTask event,
    Emitter<AgendaState> emit,
  ) async {
    final result = await _deleteTask(
      DeleteTaskParams(taskId: event.taskId, userId: _userId),
    );

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (_) {
        emit(
          AgendaTaskActionSuccess(
            message: 'Task deleted successfully',
            selectedDate: state.selectedDate,
            currentMonth: state.currentMonth,
            tasks: state.tasks,
            categories: state.categories,
          ),
        );
        add(AgendaLoadTasks(date: state.selectedDate));
      },
    );
  }

  Future<void> _onToggleTaskComplete(
    AgendaToggleTaskComplete event,
    Emitter<AgendaState> emit,
  ) async {
    final result = await _toggleTaskComplete(
      ToggleTaskCompleteParams(taskId: event.taskId, userId: _userId),
    );

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (_) => add(AgendaLoadTasks(date: state.selectedDate)),
    );
  }

  Future<void> _onSearchTasks(
    AgendaSearchTasks event,
    Emitter<AgendaState> emit,
  ) async {
    emit(
      AgendaLoading(
        selectedDate: state.selectedDate,
        currentMonth: state.currentMonth,
        tasks: state.tasks,
        categories: state.categories,
      ),
    );

    final result = await _searchTasks(
      SearchTasksParams(userId: _userId, filter: event.filter),
    );

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (tasks) => emit(
        AgendaLoaded(
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: tasks,
          categories: state.categories,
        ),
      ),
    );
  }

  Future<void> _onSyncTasks(
    AgendaSyncTasks event,
    Emitter<AgendaState> emit,
  ) async {
    final result = await _syncTasks(SyncTasksParams(userId: _userId));

    result.fold(
      (failure) => {/* Silently fail sync */},
      (_) => add(AgendaLoadTasks(date: state.selectedDate)),
    );
  }

  Future<void> _onSyncCategories(
    AgendaSyncCategories event,
    Emitter<AgendaState> emit,
  ) async {
    final result = await _syncCategories(
      SyncCategoriesParams(userId: _userId),
    );

    result.fold(
      (failure) => {/* Silently fail sync */},
      (_) => add(AgendaLoadCategories()),
    );
  }

  Future<void> _onLoadCategories(
    AgendaLoadCategories event,
    Emitter<AgendaState> emit,
  ) async {
    final result = await _getCategories(
      GetCategoriesParams(userId: _userId),
    );

    result.fold(
      (failure) => {/* Silently fail — categories are non-critical */},
      (categories) => emit(
        AgendaLoaded(
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: categories,
        ),
      ),
    );
  }

  Future<void> _onCreateCategory(
    AgendaCreateCategory event,
    Emitter<AgendaState> emit,
  ) async {
    final category = domain_cat.Category(
      id: _uuid.v4(),
      userId: _userId,
      name: event.name,
      color: event.color,
    );

    final result = await _createCategory(category);

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (_) {
        emit(
          AgendaTaskActionSuccess(
            message: 'Category created',
            selectedDate: state.selectedDate,
            currentMonth: state.currentMonth,
            tasks: state.tasks,
            categories: state.categories,
          ),
        );
        add(AgendaLoadCategories());
      },
    );
  }

  Future<void> _onDeleteCategory(
    AgendaDeleteCategory event,
    Emitter<AgendaState> emit,
  ) async {
    final result = await _deleteCategory(
      DeleteCategoryParams(categoryId: event.categoryId, userId: _userId),
    );

    result.fold(
      (failure) => emit(
        AgendaFailure(
          message: failure.message,
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          tasks: state.tasks,
          categories: state.categories,
        ),
      ),
      (_) {
        emit(
          AgendaTaskActionSuccess(
            message: 'Category deleted',
            selectedDate: state.selectedDate,
            currentMonth: state.currentMonth,
            tasks: state.tasks,
            categories: state.categories,
          ),
        );
        add(AgendaLoadCategories());
      },
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
