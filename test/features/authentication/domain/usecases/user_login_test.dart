import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_login.dart';

// Dòng này bảo mockito tự sinh ra MockIAuthRepository
@GenerateMocks([IAuthRepository])
import 'user_login_test.mocks.dart';

void main() {
  late UserLogin useCase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    useCase = UserLogin(mockAuthRepository);
    provideDummy<Either<Failure, User>>(Left(Failure()));
  });

  final tUser = User(
    id: 'test-uid-123',
    email: 'test@email.com',
    name: 'Test User',
  );

  const tEmail = 'test@email.com';
  const tPassword = 'password123';

  group('UserLogin UseCase', () {
    test(
      'should return User when login is successful',
      () async {
        // Arrange
        when(mockAuthRepository.login(email: tEmail, password: tPassword))
            .thenAnswer((_) async => Right(tUser));

        // Act
        final result = await useCase(
          UserLoginParams(email: tEmail, password: tPassword),
        );

        // Assert
        expect(result, Right(tUser));
        verify(mockAuthRepository.login(email: tEmail, password: tPassword));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return Failure when login fails',
      () async {
        // Arrange
        when(mockAuthRepository.login(email: tEmail, password: tPassword))
            .thenAnswer((_) async => Left(Failure('Invalid credentials')));

        // Act
        final result = await useCase(
          UserLoginParams(email: tEmail, password: tPassword),
        );

        // Assert
        expect(result, Left(Failure('Invalid credentials')));
        verify(mockAuthRepository.login(email: tEmail, password: tPassword));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}
