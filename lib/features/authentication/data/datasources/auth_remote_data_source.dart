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

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Resends a verification email to the currently signed-in (unverified) user.
  Future<void> sendEmailVerification();

  /// Reloads the current user and checks if their email is verified.
  /// If verified, saves the user data to Firestore and returns the [UserModel].
  /// Throws [ServerException] if not verified.
  Future<UserModel> reloadAndCheckEmailVerified({
    required String name,
  });

  /// Deletes the current Firebase Auth user without saving anything to Firestore.
  /// Called when the user backs out of the email verification page, freeing the email.
  Future<void> deleteCurrentUser();
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

      if (!response.user!.emailVerified) {
        await firebaseAuth.signOut();
        throw const ServerException(
          'Vui lòng xác thực email của bạn trước khi đăng nhập. (Please verify your email address).',
        );
      }

      final userDoc = await firestore
          .collection('users')
          .doc(response.user!.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        // First login after email verification: Firestore doc may not exist yet.
        // Create it now from the Firebase Auth user.
        final userModel = UserModel.fromFirebaseUser(
          uid: response.user!.uid,
          email: response.user!.email ?? '',
          name: response.user!.displayName ?? '',
        );
        await firestore
            .collection('users')
            .doc(response.user!.uid)
            .set(userModel.toMap());
        return userModel;
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
      // Clean up any leftover unverified session before creating a new account.
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

      // Store display name so it can be read back after email verification.
      await response.user!.updateDisplayName(name);

      // Send verification email. Firestore data is saved only after verification.
      await response.user!.sendEmailVerification();

      // Return a temporary model without saving to Firestore.
      return UserModel(
        id: response.user!.uid,
        email: email,
        name: name,
      );
    } on firebase.FirebaseAuthException catch (e) {
      // Surface the email-already-in-use code explicitly so the BLoC can
      // distinguish it from other registration errors.
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
      await user.sendEmailVerification();
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

      final resolvedName = name.isNotEmpty
          ? name
          : (refreshed.displayName ?? '');
      final userModel = UserModel(
        id: refreshed.uid,
        email: refreshed.email ?? '',
        name: resolvedName,
      );

      // Now it's safe to persist to Firestore.
      await firestore
          .collection('users')
          .doc(refreshed.uid)
          .set(userModel.toMap());

      // Sign out so user logs in fresh from sign-in page.
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
      await firebaseAuth.sendPasswordResetEmail(email: email);
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
