import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/usecases/forgot_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_login.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_sign_up.dart';
import 'package:task_orbit/features/authentication/presentation/bloc/auth_bloc.dart';

@GenerateNiceMocks([
  MockSpec<UserLogin>(),
  MockSpec<UserSignUp>(),
  MockSpec<ForgotPassword>(),
])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockUserLogin mockUserLogin;
  late MockUserSignUp mockUserSignUp;
  late MockForgotPassword mockForgotPassword;

  setUp(() {
    mockUserLogin = MockUserLogin();
    mockUserSignUp = MockUserSignUp();
    mockForgotPassword = MockForgotPassword();
    provideDummy<Either<Failure, User>>(Left(Failure()));
    provideDummy<Either<Failure, void>>(Left(Failure()));

    authBloc = AuthBloc(
      userLogin: mockUserLogin,
      userSignUp: mockUserSignUp,
      forgotPassword: mockForgotPassword,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final tUser = User(
    id: 'test-uid-123',
    email: 'test@email.com',
    name: 'Test User',
  );

  const tEmail = 'test@email.com';
  const tPassword = 'password123';
  const tName = 'Test User';

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  // ─────────────────────────────────────────
  // AuthLoginRequested
  // ─────────────────────────────────────────
  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(mockUserLogin(any))
            .thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthLoginRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(mockUserLogin(any))
            .thenAnswer((_) async => Left(Failure('Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthLoginRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });

  // ─────────────────────────────────────────
  // AuthSignUpRequested
  // ─────────────────────────────────────────
  group('AuthSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when sign up succeeds',
      build: () {
        when(mockUserSignUp(any))
            .thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthSignUpRequested(name: tName, email: tEmail, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when sign up fails',
      build: () {
        when(mockUserSignUp(any))
            .thenAnswer((_) async => Left(Failure('Email already in use')));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthSignUpRequested(name: tName, email: tEmail, password: tPassword),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });

  // ─────────────────────────────────────────
  // AuthForgotPasswordRequested
  // ─────────────────────────────────────────
  group('AuthForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthForgotPasswordSuccess] when reset email is sent',
      build: () {
        when(mockForgotPassword(any))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthForgotPasswordRequested(email: tEmail),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthForgotPasswordSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when reset email fails',
      build: () {
        when(mockForgotPassword(any))
            .thenAnswer((_) async => Left(Failure('User not found')));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthForgotPasswordRequested(email: tEmail),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });
}
