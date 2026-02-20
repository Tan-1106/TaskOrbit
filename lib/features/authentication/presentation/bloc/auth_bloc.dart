import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/usecases/forgot_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_login.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final ForgotPassword _forgotPassword;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required ForgotPassword forgotPassword,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _forgotPassword = forgotPassword,
        super(AuthInitial()) {
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
  }

  void _onAuthSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthForgotPasswordRequested(
      AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _forgotPassword(
      ForgotPasswordParams(email: event.email),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthForgotPasswordSuccess('Password reset email sent!')),
    );
  }
}
