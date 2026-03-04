part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({
    required this.email,
    required this.password,
  });
}

final class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  AuthForgotPasswordRequested({required this.email});
}

final class AuthSendVerificationEmailRequested extends AuthEvent {}

final class AuthCheckEmailVerifiedRequested extends AuthEvent {
  final String name;

  AuthCheckEmailVerifiedRequested({required this.name});
}

final class AuthDeleteUnverifiedUserRequested extends AuthEvent {}
