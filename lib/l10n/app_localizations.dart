import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Orbit'**
  String get appTitle;

  /// No description provided for @navAgenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get navAgenda;

  /// No description provided for @navPomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get navPomodoro;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @shellTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Task Orbit'**
  String get shellTitleDefault;

  /// No description provided for @signInQuote.
  ///
  /// In en, this message translates to:
  /// **'Organize your tasks - Orbit your productivity'**
  String get signInQuote;

  /// No description provided for @signInEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get signInEmailLabel;

  /// No description provided for @signInEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get signInEmailRequired;

  /// No description provided for @signInEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get signInEmailInvalid;

  /// No description provided for @signInPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get signInPasswordLabel;

  /// No description provided for @signInPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get signInPasswordRequired;

  /// No description provided for @signInPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get signInPasswordMinLength;

  /// No description provided for @signInForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get signInForgotPassword;

  /// No description provided for @signInRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get signInRememberMe;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @signInNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get signInNoAccount;

  /// No description provided for @signInSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signInSignUp;

  /// No description provided for @signInOr.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get signInOr;

  /// No description provided for @signInContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue '**
  String get signInContinue;

  /// No description provided for @signInWithoutSignIn.
  ///
  /// In en, this message translates to:
  /// **'without signing in'**
  String get signInWithoutSignIn;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// No description provided for @signUpNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signUpNameLabel;

  /// No description provided for @signUpNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get signUpNameRequired;

  /// No description provided for @signUpEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signUpEmailLabel;

  /// No description provided for @signUpEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get signUpEmailRequired;

  /// No description provided for @signUpEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get signUpEmailInvalid;

  /// No description provided for @signUpPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signUpPasswordLabel;

  /// No description provided for @signUpPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get signUpPasswordRequired;

  /// No description provided for @signUpPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get signUpPasswordMinLength;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signUpAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get signUpAlreadyHaveAccount;

  /// No description provided for @signUpSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signUpSignIn;

  /// No description provided for @signUpEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please sign in instead.'**
  String get signUpEmailAlreadyExists;

  /// No description provided for @emailVerificationAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerificationAppBarTitle;

  /// No description provided for @emailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to {email}. Please check your inbox and click the link to verify your account.'**
  String emailVerificationMessage(String email);

  /// No description provided for @emailVerificationResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get emailVerificationResendButton;

  /// No description provided for @emailVerificationResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String emailVerificationResendCountdown(int seconds);

  /// No description provided for @emailVerificationConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get emailVerificationConfirmButton;

  /// No description provided for @emailVerificationNotVerifiedError.
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Please check your inbox and click the verification link.'**
  String get emailVerificationNotVerifiedError;

  /// No description provided for @emailVerificationBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get emailVerificationBackButton;

  /// No description provided for @forgotPasswordAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordAppBarTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a password reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get forgotPasswordEmailInvalid;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordButton;

  /// No description provided for @agendaNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get agendaNoTasks;

  /// No description provided for @agendaManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get agendaManageCategories;

  /// No description provided for @agendaFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get agendaFilter;

  /// No description provided for @agendaAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get agendaAddTask;

  /// No description provided for @taskDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetailTitle;

  /// No description provided for @taskDetailEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get taskDetailEditTooltip;

  /// No description provided for @taskDetailDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get taskDetailDeleteTooltip;

  /// No description provided for @taskDetailStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskDetailStatusCompleted;

  /// No description provided for @taskDetailStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskDetailStatusPending;

  /// No description provided for @taskDetailLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get taskDetailLabelDate;

  /// No description provided for @taskDetailLabelTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get taskDetailLabelTime;

  /// No description provided for @taskDetailLabelAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get taskDetailLabelAllDay;

  /// No description provided for @taskDetailLabelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDetailLabelDescription;

  /// No description provided for @taskDetailConfirmEdit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Edit'**
  String get taskDetailConfirmEdit;

  /// No description provided for @taskDetailConfirmEditContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save these changes?'**
  String get taskDetailConfirmEditContent;

  /// No description provided for @taskDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get taskDetailDeleteTitle;

  /// No description provided for @taskDetailDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{taskTitle}\"?'**
  String taskDetailDeleteContent(String taskTitle);

  /// No description provided for @taskDetailToggleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get taskDetailToggleConfirmTitle;

  /// No description provided for @taskDetailToggleMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'mark as completed'**
  String get taskDetailToggleMarkCompleted;

  /// No description provided for @taskDetailToggleMarkPending.
  ///
  /// In en, this message translates to:
  /// **'mark as pending'**
  String get taskDetailToggleMarkPending;

  /// No description provided for @taskDetailToggleContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to {action} \"{taskTitle}\"?'**
  String taskDetailToggleContent(String action, String taskTitle);

  /// No description provided for @taskFormNewTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get taskFormNewTask;

  /// No description provided for @taskFormEditTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get taskFormEditTask;

  /// No description provided for @taskFormTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskFormTitleLabel;

  /// No description provided for @taskFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get taskFormTitleRequired;

  /// No description provided for @taskFormDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get taskFormDescriptionLabel;

  /// No description provided for @taskFormCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get taskFormCategoryLabel;

  /// No description provided for @taskFormNoCategoryOption.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get taskFormNoCategoryOption;

  /// No description provided for @taskFormDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get taskFormDateLabel;

  /// No description provided for @taskFormAllDayLabel.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get taskFormAllDayLabel;

  /// No description provided for @taskFormStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get taskFormStartTimeLabel;

  /// No description provided for @taskFormEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get taskFormEndTimeLabel;

  /// No description provided for @taskFormEndBeforeStartError.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get taskFormEndBeforeStartError;

  /// No description provided for @taskFormCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get taskFormCreateButton;

  /// No description provided for @taskFormSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get taskFormSaveButton;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Tasks'**
  String get filterTitle;

  /// No description provided for @filterKeywordLabel.
  ///
  /// In en, this message translates to:
  /// **'Search keyword'**
  String get filterKeywordLabel;

  /// No description provided for @filterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatusLabel;

  /// No description provided for @filterStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterStatusAll;

  /// No description provided for @filterStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterStatusPending;

  /// No description provided for @filterStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filterStatusDone;

  /// No description provided for @filterCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategoryLabel;

  /// No description provided for @filterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get filterAllCategories;

  /// No description provided for @filterDateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filterDateRangeLabel;

  /// No description provided for @filterFromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterFromDate;

  /// No description provided for @filterToDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterToDate;

  /// No description provided for @filterCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get filterCancelButton;

  /// No description provided for @filterClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClearButton;

  /// No description provided for @filterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApplyButton;

  /// No description provided for @categoryManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get categoryManageTitle;

  /// No description provided for @categoryNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoryNoCategories;

  /// No description provided for @categoryNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get categoryNewTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameLabel;

  /// No description provided for @categoryAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryAddButton;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get categoryNameRequired;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{categoryName}\"?'**
  String categoryDeleteContent(String categoryName);

  /// No description provided for @dialogCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancelButton;

  /// No description provided for @dialogConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirmButton;

  /// No description provided for @dialogDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDeleteButton;

  /// No description provided for @profileNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get profileNamePlaceholder;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileOldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get profileOldPasswordLabel;

  /// No description provided for @profileNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get profileNewPasswordLabel;

  /// No description provided for @profileConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get profileConfirmPasswordLabel;

  /// No description provided for @profilePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get profilePasswordRequired;

  /// No description provided for @profilePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get profilePasswordMinLength;

  /// No description provided for @profilePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get profilePasswordMismatch;

  /// No description provided for @profileChangePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get profileChangePasswordButton;

  /// No description provided for @profileChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get profileChangePasswordSuccess;

  /// No description provided for @profileChangePasswordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password'**
  String get profileChangePasswordError;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageLabel;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get profileLanguageVietnamese;

  /// No description provided for @profileStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Statistics'**
  String get profileStatsTitle;

  /// No description provided for @profilePeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get profilePeriodMonth;

  /// No description provided for @profilePeriodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get profilePeriodYear;

  /// No description provided for @profileStatsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get profileStatsCompleted;

  /// No description provided for @profileStatsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get profileStatsIncomplete;

  /// No description provided for @profileStatsMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get profileStatsMissed;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutContent;

  /// No description provided for @profileNoInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get profileNoInternetTitle;

  /// No description provided for @profileNoInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get profileNoInternetMessage;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your data and access it across devices.'**
  String get profileGuestMessage;

  /// No description provided for @profileSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get profileSignInButton;

  /// No description provided for @profileCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get profileCreateAccountButton;

  /// No description provided for @taskFormNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get taskFormNotificationLabel;

  /// No description provided for @taskFormNotificationNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get taskFormNotificationNone;

  /// No description provided for @taskFormNotification30m.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get taskFormNotification30m;

  /// No description provided for @taskFormNotification1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get taskFormNotification1h;

  /// No description provided for @taskFormNotification2h.
  ///
  /// In en, this message translates to:
  /// **'2 hours before'**
  String get taskFormNotification2h;

  /// No description provided for @taskFormNotification4h.
  ///
  /// In en, this message translates to:
  /// **'4 hours before'**
  String get taskFormNotification4h;

  /// No description provided for @taskFormNotificationCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get taskFormNotificationCustom;

  /// No description provided for @taskFormNotificationCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours before'**
  String get taskFormNotificationCustomLabel;

  /// No description provided for @taskFormNotificationCustomSuffix.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get taskFormNotificationCustomSuffix;

  /// No description provided for @taskFormNotificationCustomRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get taskFormNotificationCustomRequired;

  /// No description provided for @taskFormNotificationCustomInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get taskFormNotificationCustomInvalid;

  /// No description provided for @taskFormNotificationPastError.
  ///
  /// In en, this message translates to:
  /// **'Notification time cannot be in the past'**
  String get taskFormNotificationPastError;

  /// No description provided for @pomodoroClassicPresetName.
  ///
  /// In en, this message translates to:
  /// **'Classic Pomodoro'**
  String get pomodoroClassicPresetName;

  /// No description provided for @pomodoroClassicPresetDescription.
  ///
  /// In en, this message translates to:
  /// **'The original 25/5/15 technique'**
  String get pomodoroClassicPresetDescription;

  /// No description provided for @pomodoroPhaseLabel_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get pomodoroPhaseLabel_focus;

  /// No description provided for @pomodoroPhaseLabel_shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get pomodoroPhaseLabel_shortBreak;

  /// No description provided for @pomodoroPhaseLabel_longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get pomodoroPhaseLabel_longBreak;

  /// No description provided for @pomodoroStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get pomodoroStart;

  /// No description provided for @pomodoroPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pomodoroPause;

  /// No description provided for @pomodoroResetPhase.
  ///
  /// In en, this message translates to:
  /// **'Reset phase'**
  String get pomodoroResetPhase;

  /// No description provided for @pomodoroResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get pomodoroResetAll;

  /// No description provided for @pomodoroSelectPreset.
  ///
  /// In en, this message translates to:
  /// **'Select preset'**
  String get pomodoroSelectPreset;

  /// No description provided for @pomodoroAddPreset.
  ///
  /// In en, this message translates to:
  /// **'Add preset'**
  String get pomodoroAddPreset;

  /// No description provided for @pomodoroEditPreset.
  ///
  /// In en, this message translates to:
  /// **'Edit preset'**
  String get pomodoroEditPreset;

  /// No description provided for @pomodoroPresetFormNew.
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get pomodoroPresetFormNew;

  /// No description provided for @pomodoroPresetFormEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Preset'**
  String get pomodoroPresetFormEdit;

  /// No description provided for @pomodoroPresetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pomodoroPresetNameLabel;

  /// No description provided for @pomodoroPresetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get pomodoroPresetNameRequired;

  /// No description provided for @pomodoroPresetDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get pomodoroPresetDescLabel;

  /// No description provided for @pomodoroPresetFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus (min)'**
  String get pomodoroPresetFocusLabel;

  /// No description provided for @pomodoroPresetShortBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Short break (min)'**
  String get pomodoroPresetShortBreakLabel;

  /// No description provided for @pomodoroPresetLongBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Long break (min)'**
  String get pomodoroPresetLongBreakLabel;

  /// No description provided for @pomodoroPresetCyclesLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycles before long break'**
  String get pomodoroPresetCyclesLabel;

  /// No description provided for @pomodoroPresetOtherOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pomodoroPresetOtherOption;

  /// No description provided for @pomodoroPresetSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get pomodoroPresetSaveButton;

  /// No description provided for @pomodoroPresetDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get pomodoroPresetDeleteButton;

  /// No description provided for @pomodoroDeletePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get pomodoroDeletePresetTitle;

  /// No description provided for @pomodoroDeletePresetContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String pomodoroDeletePresetContent(String name);

  /// No description provided for @pomodoroPresetCustomValueHint.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get pomodoroPresetCustomValueHint;

  /// No description provided for @pomodoroPresetCustomValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pomodoroPresetCustomValueRequired;

  /// No description provided for @pomodoroPresetCustomValueInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must be a positive number'**
  String get pomodoroPresetCustomValueInvalid;

  /// No description provided for @pomodoroRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat session'**
  String get pomodoroRepeat;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
