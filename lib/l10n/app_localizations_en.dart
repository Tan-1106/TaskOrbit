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

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get signUpNameLabel => 'Full Name';

  @override
  String get signUpNameRequired => 'Please enter your name';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpEmailRequired => 'Please enter your email';

  @override
  String get signUpEmailInvalid => 'Please enter a valid email';

  @override
  String get signUpPasswordLabel => 'Password';

  @override
  String get signUpPasswordRequired => 'Please enter your password';

  @override
  String get signUpPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get signUpAlreadyHaveAccount => 'Already have an account? Log In';

  @override
  String get forgotPasswordAppBarTitle => 'Reset Password';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle => 'Enter your email address to receive a password reset link.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordEmailRequired => 'Please enter your email';

  @override
  String get forgotPasswordEmailInvalid => 'Please enter a valid email';

  @override
  String get forgotPasswordButton => 'Send Reset Link';
}
