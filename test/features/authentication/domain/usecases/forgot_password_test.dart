import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';
import 'package:task_orbit/features/authentication/domain/usecases/forgot_password.dart';

@GenerateMocks([IAuthRepository])
import 'forgot_password_test.mocks.dart';

void main() {
  late ForgotPassword useCase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    useCase = ForgotPassword(mockAuthRepository);
    provideDummy<Either<Failure, void>>(Left(Failure()));
  });

  const tEmail = 'test@email.com';

  group('ForgotPassword UseCase', () {
    test(
      'should return void (Right) when reset email is sent successfully',
      () async {
        // Arrange
        when(mockAuthRepository.forgotPassword(email: tEmail))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(ForgotPasswordParams(email: tEmail));

        // Assert
        expect(result, const Right(null));
        verify(mockAuthRepository.forgotPassword(email: tEmail));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return Failure when reset email fails (user not found)',
      () async {
        // Arrange
        when(mockAuthRepository.forgotPassword(email: tEmail))
            .thenAnswer(
                (_) async => Left(Failure('No user found with this email')));

        // Act
        final result = await useCase(ForgotPasswordParams(email: tEmail));

        // Assert
        expect(result, Left(Failure('No user found with this email')));
        verify(mockAuthRepository.forgotPassword(email: tEmail));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}
