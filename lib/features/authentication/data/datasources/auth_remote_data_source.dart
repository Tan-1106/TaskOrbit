import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:task_orbit/core/error/exceptions.dart';
import 'package:task_orbit/features/authentication/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> sendEmailVerification();

  Future<UserModel> reloadAndCheckEmailVerified({
    required String name,
  });

  Future<void> deleteCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firestore, this.functions);

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (firebaseAuth.currentUser != null) {
        final userData = await firestore.collection('users').doc(firebaseAuth.currentUser!.uid).get();

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

      if (!response.user!.emailVerified) {
        final createdAt = response.user!.metadata.creationTime;
        final isExpired = createdAt != null && DateTime.now().difference(createdAt).inMinutes >= 15;
        if (isExpired) {
          try {
            await firestore.collection('pending_verifications').doc(response.user!.uid).delete();
            await response.user!.delete();
          } catch (_) {}
          throw const ServerException(
            'Verification link expired. Please register again.',
          );
        }

        await firebaseAuth.signOut();
        throw const ServerException(
          'Email not verified. Please check your inbox and verify your email before logging in.',
        );
      }

      final userDoc = await firestore.collection('users').doc(response.user!.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        final resolvedName = response.user!.displayName ?? '';
        final userModel = UserModel(
          id: response.user!.uid,
          email: response.user!.email ?? '',
          name: resolvedName,
        );
        await firestore.collection('users').doc(response.user!.uid).set(userModel.toMap());
        await firestore.collection('pending_verifications').doc(response.user!.uid).delete();
        return userModel;
      }
      await firestore.collection('pending_verifications').doc(response.user!.uid).delete();

      return UserModel.fromJson(userDoc.data()!);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Authentication failed');
    } catch (e) {
      if (e is ServerException) rethrow;
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
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        try {
          await currentUser.delete();
        } catch (_) {}
      }

      final response = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerException('User is null!');
      }
      await response.user!.updateDisplayName(name);
      await response.user!.getIdToken(true);

      try {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'sendVerificationEmail',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
        );
        await callable.call({'userName': name});
      } on FirebaseFunctionsException {
        await response.user!.sendEmailVerification();
      } catch (e) {
        await response.user!.sendEmailVerification();
      }
      await firestore.collection('pending_verifications').doc(response.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserModel(
        id: response.user!.uid,
        email: email,
        name: name,
      );
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const ServerException('email_already_in_use');
      }
      throw ServerException(e.message ?? 'Registration failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException('No user to send verification to');
      }
      try {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'sendVerificationEmail',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
        );
        await callable.call({'userName': user.displayName ?? ''});
      } on FirebaseFunctionsException {
        await user.sendEmailVerification();
      } catch (e) {
        await user.sendEmailVerification();
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to send verification email');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> reloadAndCheckEmailVerified({required String name}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const ServerException('No user found');

      await user.reload();
      final refreshed = firebaseAuth.currentUser;
      if (refreshed == null || !refreshed.emailVerified) {
        throw const ServerException('Email not yet verified');
      }

      final resolvedName = name.isNotEmpty ? name : (refreshed.displayName ?? '');
      final userModel = UserModel(
        id: refreshed.uid,
        email: refreshed.email ?? '',
        name: resolvedName,
      );

      await firestore.collection('users').doc(refreshed.uid).set(userModel.toMap());
      await firestore.collection('pending_verifications').doc(refreshed.uid).delete();
      await firebaseAuth.signOut();
      return userModel;
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Verification check failed');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete user');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      try {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'sendPasswordResetEmailCustom',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
        );
        await callable.call({'email': email});
      } on FirebaseFunctionsException {
        await firebaseAuth.sendPasswordResetEmail(email: email);
      } catch (e) {
        await firebaseAuth.sendPasswordResetEmail(email: email);
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const ServerException('No authenticated user');

      final credential = firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to change password');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
