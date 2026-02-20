import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_sign_up.dart';

@GenerateMocks([IAuthRepository])
import 'user_sign_up_test.mocks.dart';

void main() {
  late UserSignUp useCase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    useCase = UserSignUp(mockAuthRepository);
    provideDummy<Either<Failure, User>>(Left(Failure()));
  });

  final tUser = User(
    id: 'test-uid-123',
    email: 'test@email.com',
    name: 'Test User',
  );

  const tName = 'Test User';
  const tEmail = 'test@email.com';
  const tPassword = 'password123';

  group('UserSignUp UseCase', () {
    test(
      'should return User when sign up is successful',
      () async {
        // Arrange
        when(mockAuthRepository.signUp(
          name: tName,
          email: tEmail,
          password: tPassword,
        )).thenAnswer((_) async => Right(tUser));

        // Act
        final result = await useCase(
          UserSignUpParams(name: tName, email: tEmail, password: tPassword),
        );

        // Assert
        expect(result, Right(tUser));
        verify(mockAuthRepository.signUp(
          name: tName,
          email: tEmail,
          password: tPassword,
        ));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return Failure when sign up fails (email already in use)',
      () async {
        // Arrange
        when(mockAuthRepository.signUp(
          name: tName,
          email: tEmail,
          password: tPassword,
        )).thenAnswer(
            (_) async => Left(Failure('Email already in use')));

        // Act
        final result = await useCase(
          UserSignUpParams(name: tName, email: tEmail, password: tPassword),
        );

        // Assert
        expect(result, Left(Failure('Email already in use')));
        verify(mockAuthRepository.signUp(
          name: tName,
          email: tEmail,
          password: tPassword,
        ));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}
