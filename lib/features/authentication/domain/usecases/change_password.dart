import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final IAuthRepository authRepository;

  ChangePassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await authRepository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });
}
