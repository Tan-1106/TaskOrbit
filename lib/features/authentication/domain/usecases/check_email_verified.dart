import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';

class CheckEmailVerified implements UseCase<User, CheckEmailVerifiedParams> {
  final IAuthRepository authRepository;

  CheckEmailVerified(this.authRepository);

  @override
  Future<Either<Failure, User>> call(CheckEmailVerifiedParams params) async {
    return await authRepository.checkEmailVerified(name: params.name);
  }
}

class CheckEmailVerifiedParams {
  final String name;

  CheckEmailVerifiedParams({required this.name});
}
