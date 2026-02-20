import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/exceptions.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:task_orbit/features/authentication/data/models/user_model.dart';
import 'package:task_orbit/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';

@GenerateMocks([AuthRemoteDataSource])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
    provideDummy<Either<Failure, User>>(Left(Failure()));
    provideDummy<Either<Failure, void>>(Left(Failure()));
  });

  final tUserModel = UserModel(
    id: 'test-uid-123',
    email: 'test@email.com',
    name: 'Test User',
  );

  const tEmail = 'test@email.com';
  const tPassword = 'password123';
  const tName = 'Test User';

  // ─────────────────────────────────────────
  // login()
  // ─────────────────────────────────────────
  group('login', () {
    test(
      'should return User on success',
      () async {
        when(mockDataSource.loginWithEmailPassword(
                email: tEmail, password: tPassword))
            .thenAnswer((_) async => tUserModel);

        final result =
            await repository.login(email: tEmail, password: tPassword);

        expect(result, Right(tUserModel));
        verify(mockDataSource.loginWithEmailPassword(
            email: tEmail, password: tPassword));
      },
    );

    test(
      'should return Failure when ServerException is thrown',
      () async {
        when(mockDataSource.loginWithEmailPassword(
                email: tEmail, password: tPassword))
            .thenThrow(const ServerException('Invalid credentials'));

        final result =
            await repository.login(email: tEmail, password: tPassword);

        expect(result, Left(Failure('Invalid credentials')));
      },
    );
  });

  // ─────────────────────────────────────────
  // signUp()
  // ─────────────────────────────────────────
  group('signUp', () {
    test(
      'should return User on successful sign up',
      () async {
        when(mockDataSource.signUpWithEmailPassword(
                name: tName, email: tEmail, password: tPassword))
            .thenAnswer((_) async => tUserModel);

        final result = await repository.signUp(
            name: tName, email: tEmail, password: tPassword);

        expect(result, Right(tUserModel));
        verify(mockDataSource.signUpWithEmailPassword(
            name: tName, email: tEmail, password: tPassword));
      },
    );

    test(
      'should return Failure when ServerException is thrown',
      () async {
        when(mockDataSource.signUpWithEmailPassword(
                name: tName, email: tEmail, password: tPassword))
            .thenThrow(const ServerException('Email already in use'));

        final result = await repository.signUp(
            name: tName, email: tEmail, password: tPassword);

        expect(result, Left(Failure('Email already in use')));
      },
    );
  });

  // ─────────────────────────────────────────
  // forgotPassword()
  // ─────────────────────────────────────────
  group('forgotPassword', () {
    test(
      'should return void on success',
      () async {
        when(mockDataSource.sendPasswordResetEmail(email: tEmail))
            .thenAnswer((_) async {});

        final result = await repository.forgotPassword(email: tEmail);

        expect(result, const Right(null));
        verify(mockDataSource.sendPasswordResetEmail(email: tEmail));
      },
    );

    test(
      'should return Failure when ServerException is thrown',
      () async {
        when(mockDataSource.sendPasswordResetEmail(email: tEmail))
            .thenThrow(const ServerException('User not found'));

        final result = await repository.forgotPassword(email: tEmail);

        expect(result, Left(Failure('User not found')));
      },
    );
  });
}
