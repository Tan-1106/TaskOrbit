import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:task_orbit/core/error/exceptions.dart';
import 'package:task_orbit/features/authentication/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firestore);

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (firebaseAuth.currentUser != null) {
        final userData = await firestore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .get();

        if (userData.data() != null) {
          return UserModel.fromJson(userData.data()!);
        }
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      // Fetch user data from firestore
      final userDoc = await firestore
          .collection('users')
          .doc(response.user!.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        return UserModel.fromFirebaseUser(
          uid: response.user!.uid,
          email: response.user!.email ?? '',
          name: response.user!.displayName ?? '',
        );
      }

      return UserModel.fromJson(userDoc.data()!);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      // Save additional user data to Firestore
      final userModel = UserModel(
        id: response.user!.uid,
        email: email,
        name: name,
      );

      await firestore
          .collection('users')
          .doc(response.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Registration failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
