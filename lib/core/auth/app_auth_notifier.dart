import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppAuthNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  User? _user;

  User? get currentUser => _user;

  bool get isGuest => _user == null || !_user!.emailVerified;

  bool get isAuthenticated => _user != null && _user!.emailVerified;

  AppAuthNotifier(this._firebaseAuth) {
    _user = _firebaseAuth.currentUser;

    _firebaseAuth.userChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }
}
