part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

final class AuthForgotPasswordSuccess extends AuthState {
  final String message;

  AuthForgotPasswordSuccess(this.message);
}

final class AuthVerificationEmailSent extends AuthState {
  final String name;
  final String email;

  AuthVerificationEmailSent({ required this.name, required this.email});
}

final class AuthEmailVerified extends AuthState {}

final class AuthEmailNotVerified extends AuthState {
  final String message;

  AuthEmailNotVerified(this.message);
}

final class AuthEmailAlreadyExists extends AuthState {}
