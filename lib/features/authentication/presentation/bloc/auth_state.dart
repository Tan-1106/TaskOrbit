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

/// Emitted after sign-up: verification email has been sent.
/// The UI should navigate to the EmailVerificationPage.
final class AuthVerificationEmailSent extends AuthState {
  final String email;
  final String name;

  AuthVerificationEmailSent({required this.email, required this.name});
}

/// Emitted when the user's email has been confirmed verified.
/// The UI should navigate back to sign-in.
final class AuthEmailVerified extends AuthState {}

/// Emitted when the user checks verification but their email is still unverified.
final class AuthEmailNotVerified extends AuthState {
  final String message;

  AuthEmailNotVerified(this.message);
}

/// Emitted when the sign-up email is already registered to an existing account.
/// The UI should show a snackbar and stay on the sign-up page.
final class AuthEmailAlreadyExists extends AuthState {}
