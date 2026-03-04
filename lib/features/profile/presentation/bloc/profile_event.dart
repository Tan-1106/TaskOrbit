part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileLoadRequested extends ProfileEvent {}

final class ProfileReloadRequested extends ProfileEvent {}

final class ProfilePeriodChanged extends ProfileEvent {
  final PeriodType periodType;
  final int year;
  final int? month;

  ProfilePeriodChanged({
    required this.periodType,
    required this.year,
    this.month,
  });
}

final class ProfileChangePasswordRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  ProfileChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });
}

final class ProfileSignOutRequested extends ProfileEvent {}

final class ProfileUserSignedOut extends ProfileEvent {}
