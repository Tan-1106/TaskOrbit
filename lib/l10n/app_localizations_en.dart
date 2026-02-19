// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Task Orbit';

  @override
  String get signInQuote => 'Organize your tasks\nOrbit your productivity';

  @override
  String get signInEmailLabel => 'Your email';

  @override
  String get signInEmailRequired => 'Email is required';

  @override
  String get signInEmailInvalid => 'Please enter a valid email address';

  @override
  String get signInPasswordLabel => 'Your password';

  @override
  String get signInPasswordRequired => 'Password is required';

  @override
  String get signInPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get signInForgotPassword => 'Forgot password?';

  @override
  String get signInRememberMe => 'Remember me';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signInNoAccount => 'Don\'t have an account? ';

  @override
  String get signInSignUp => 'Sign Up';
}
