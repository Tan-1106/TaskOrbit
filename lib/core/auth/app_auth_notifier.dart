import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Listens to FirebaseAuth.authStateChanges() and notifies GoRouter
/// to re-evaluate its redirect callback whenever the auth state changes.
class AppAuthNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  User? _user;

  User? get currentUser => _user;
  bool get isAuthenticated => _user != null;

  AppAuthNotifier(this._firebaseAuth) {
    // Initialize synchronously so GoRouter has the correct state
    // immediately — avoids flash redirect on app startup
    _user = _firebaseAuth.currentUser;

    // Then listen for ongoing changes (login, logout)
    _firebaseAuth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }
}
