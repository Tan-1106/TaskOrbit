part of 'profile_bloc.dart';

enum ChangePasswordStatus { idle, loading, success, failure }

class ProfileState {
  final String userName;
  final String userEmail;
  final PeriodType periodType;
  final int selectedYear;
  final int? selectedMonth;
  final bool statsLoading;
  final int completedCount;
  // Map of date → task count for incomplete tasks in the future (date ≥ today)
  final Map<DateTime, int> pendingDates;
  // Map of date → task count for incomplete tasks in the past (date < today)
  final Map<DateTime, int> missedDates;
  final ChangePasswordStatus changePasswordStatus;
  final String? changePasswordError;

  const ProfileState({
    this.userName = '',
    this.userEmail = '',
    this.periodType = PeriodType.month,
    this.selectedYear = 0,
    this.selectedMonth,
    this.statsLoading = false,
    this.completedCount = 0,
    this.pendingDates = const {},
    this.missedDates = const {},
    this.changePasswordStatus = ChangePasswordStatus.idle,
    this.changePasswordError,
  });

  int get pendingCount => pendingDates.values.fold(0, (sum, c) => sum + c);
  int get missedCount => missedDates.values.fold(0, (sum, c) => sum + c);

  ProfileState copyWith({
    String? userName,
    String? userEmail,
    PeriodType? periodType,
    int? selectedYear,
    int? selectedMonth,
    bool? statsLoading,
    int? completedCount,
    Map<DateTime, int>? pendingDates,
    Map<DateTime, int>? missedDates,
    ChangePasswordStatus? changePasswordStatus,
    String? changePasswordError,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      periodType: periodType ?? this.periodType,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      statsLoading: statsLoading ?? this.statsLoading,
      completedCount: completedCount ?? this.completedCount,
      pendingDates: pendingDates ?? this.pendingDates,
      missedDates: missedDates ?? this.missedDates,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      changePasswordError: changePasswordError ?? this.changePasswordError,
    );
  }
}
