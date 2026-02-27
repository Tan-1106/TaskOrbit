import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';

class GetCurrentUser implements UseCase<User, NoParams> {
  final IAuthRepository authRepository;

  GetCurrentUser(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.getCurrentUser();
  }
}
