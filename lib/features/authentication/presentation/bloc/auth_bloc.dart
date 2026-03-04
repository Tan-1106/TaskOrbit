import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/usecases/check_email_verified.dart';
import 'package:task_orbit/features/authentication/domain/usecases/delete_current_user.dart';
import 'package:task_orbit/features/authentication/domain/usecases/forgot_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/send_email_verification.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_login.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_sign_up.dart';
import 'package:task_orbit/core/usecases/usecase.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final ForgotPassword _forgotPassword;
  final SendEmailVerification _sendEmailVerification;
  final CheckEmailVerified _checkEmailVerified;
  final DeleteCurrentUser _deleteCurrentUser;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required ForgotPassword forgotPassword,
    required SendEmailVerification sendEmailVerification,
    required CheckEmailVerified checkEmailVerified,
    required DeleteCurrentUser deleteCurrentUser,
  }) : _userSignUp = userSignUp,
       _userLogin = userLogin,
       _forgotPassword = forgotPassword,
       _sendEmailVerification = sendEmailVerification,
       _checkEmailVerified = checkEmailVerified,
       _deleteCurrentUser = deleteCurrentUser,
       super(AuthInitial()) {
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthSendVerificationEmailRequested>(_onSendVerificationEmailRequested);
    on<AuthCheckEmailVerifiedRequested>(_onCheckEmailVerifiedRequested);
    on<AuthDeleteUnverifiedUserRequested>(_onDeleteUnverifiedUserRequested);
  }

  void _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    res.fold(
      (failure) {
        if (failure.message == 'email_already_in_use') {
          emit(AuthEmailAlreadyExists());
        } else {
          emit(AuthFailure(failure.message));
        }
      },
      // Sign-up succeeded: emit verification-sent state instead of AuthSuccess.
      (_) =>
          emit(AuthVerificationEmailSent(email: event.email, name: event.name)),
    );
  }

  void _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (failure) {
        if (failure.message.contains('unverified_email')) {
          emit(AuthVerificationEmailSent(email: event.email, name: ''));
        } else {
          emit(AuthFailure(failure.message));
        }
      },
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _forgotPassword(
      ForgotPasswordParams(email: event.email),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthForgotPasswordSuccess('Password reset email sent!')),
    );
  }

  void _onSendVerificationEmailRequested(
    AuthSendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _sendEmailVerification(NoParams());
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) {},
    );
  }

  void _onCheckEmailVerifiedRequested(
    AuthCheckEmailVerifiedRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final res = await _checkEmailVerified(
      CheckEmailVerifiedParams(name: event.name),
    );

    res.fold(
      (failure) => emit(AuthEmailNotVerified(failure.message)),
      (_) => emit(AuthEmailVerified()),
    );
  }

  void _onDeleteUnverifiedUserRequested(
    AuthDeleteUnverifiedUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _deleteCurrentUser(NoParams());
    // No state emission needed; the caller handles navigation.
  }
}
