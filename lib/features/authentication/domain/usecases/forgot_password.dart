import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';

class ForgotPassword implements UseCase<void, ForgotPasswordParams> {
  final IAuthRepository authRepository;

  ForgotPassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    return await authRepository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams {
  final String email;

  ForgotPasswordParams({required this.email});
}
