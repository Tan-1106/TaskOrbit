import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';

class DeleteCurrentUser implements UseCase<void, NoParams> {
  final IAuthRepository authRepository;

  DeleteCurrentUser(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.deleteCurrentUser();
  }
}
