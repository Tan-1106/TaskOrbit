import 'package:fpdart/fpdart.dart';
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/features/authentication/domain/entities/user.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, User>> checkEmailVerified({required String name});

  Future<Either<Failure, void>> deleteCurrentUser();
}
