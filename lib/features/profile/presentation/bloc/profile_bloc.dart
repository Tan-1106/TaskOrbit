import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_orbit/features/agenda/domain/usecases/get_tasks_for_period.dart';
import 'package:task_orbit/features/authentication/domain/usecases/change_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/get_current_user.dart';
import 'package:task_orbit/core/usecases/usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

enum PeriodType { month, year }

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetTasksForPeriod _getTasksForPeriod;
  final ChangePassword _changePassword;
  final GetCurrentUser _getCurrentUser;
  final FirebaseAuth _firebaseAuth;

  ProfileBloc({
    required GetTasksForPeriod getTasksForPeriod,
    required ChangePassword changePassword,
    required GetCurrentUser getCurrentUser,
    required FirebaseAuth firebaseAuth,
  }) : _getTasksForPeriod = getTasksForPeriod,
       _changePassword = changePassword,
       _getCurrentUser = getCurrentUser,
       _firebaseAuth = firebaseAuth,
       super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileReloadRequested>(_onReload);
    on<ProfilePeriodChanged>(_onPeriodChanged);
    on<ProfileChangePasswordRequested>(_onChangePassword);
    on<ProfileSignOutRequested>(_onSignOut);
  }

  String get _userId => _firebaseAuth.currentUser?.uid ?? '';

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final firebaseUser = _firebaseAuth.currentUser;
    final now = DateTime.now();

    final userResult = await _getCurrentUser(NoParams());
    final userName = userResult.fold(
      (_) => firebaseUser?.displayName ?? '',
      (user) => user.name,
    );

    final initialState = state.copyWith(
      userName: userName,
      userEmail: firebaseUser?.email ?? '',
      periodType: PeriodType.month,
      selectedYear: now.year,
      selectedMonth: now.month,
      statsLoading: true,
    );
    emit(initialState);
    await _loadStats(emit);
  }

  Future<void> _onReload(
    ProfileReloadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(statsLoading: true));
    await _loadStats(emit);
  }

  Future<void> _onPeriodChanged(
    ProfilePeriodChanged event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        periodType: event.periodType,
        selectedYear: event.year,
        selectedMonth: event.month,
        statsLoading: true,
      ),
    );
    await _loadStats(emit);
  }

  Future<void> _onChangePassword(
    ProfileChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(changePasswordStatus: ChangePasswordStatus.loading));

    final result = await _changePassword(
      ChangePasswordParams(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          changePasswordStatus: ChangePasswordStatus.failure,
          changePasswordError: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(changePasswordStatus: ChangePasswordStatus.success),
      ),
    );

    // Reset status after a short delay so UI can react once
    await Future.delayed(const Duration(milliseconds: 100));
    emit(state.copyWith(changePasswordStatus: ChangePasswordStatus.idle));
  }

  Future<void> _onSignOut(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _firebaseAuth.signOut();
    // AppAuthNotifier listens to authStateChanges and triggers GoRouter redirect
  }

  Future<void> _loadStats(Emitter<ProfileState> emit) async {
    final DateRange range = _buildRange(
      state.periodType,
      state.selectedYear ?? DateTime.now().year,
      state.selectedMonth,
    );

    final result = await _getTasksForPeriod(
      GetTasksForPeriodParams(
        userId: _userId,
        from: range.from,
        to: range.to,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(statsLoading: false)),
      (tasks) {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

        int completed = 0;
        final Map<DateTime, int> pendingDates = {};
        final Map<DateTime, int> missedDates = {};

        for (final task in tasks) {
          if (task.isCompleted) {
            completed++;
          } else {
            final taskDay = DateTime(
              task.date.year,
              task.date.month,
              task.date.day,
            );
            if (taskDay.isBefore(today)) {
              missedDates[taskDay] = (missedDates[taskDay] ?? 0) + 1;
            } else {
              pendingDates[taskDay] = (pendingDates[taskDay] ?? 0) + 1;
            }
          }
        }

        emit(
          state.copyWith(
            statsLoading: false,
            completedCount: completed,
            pendingDates: pendingDates,
            missedDates: missedDates,
          ),
        );
      },
    );
  }

  DateRange _buildRange(PeriodType type, int year, int? month) {
    if (type == PeriodType.year) {
      return DateRange(
        from: DateTime(year, 1, 1),
        to: DateTime(year, 12, 31),
      );
    }
    final m = month ?? DateTime.now().month;
    final lastDay = DateTime(year, m + 1, 0).day;
    return DateRange(
      from: DateTime(year, m, 1),
      to: DateTime(year, m, lastDay),
    );
  }
}

class DateRange {
  final DateTime from;
  final DateTime to;
  const DateRange({required this.from, required this.to});
}
