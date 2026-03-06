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
  String get navAgenda => 'Agenda';

  @override
  String get navPomodoro => 'Pomodoro';

  @override
  String get navProfile => 'Profile';

  @override
  String get shellTitleDefault => 'Task Orbit';

  @override
  String get signInQuote => 'Organize your tasks - Orbit your productivity';

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
  String get signInOr => 'Or';

  @override
  String get signInContinue => 'Continue ';

  @override
  String get signInWithoutSignIn => 'without signing in';

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
  String get signUpAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get signUpSignIn => 'Sign In';

  @override
  String get signUpEmailAlreadyExists => 'Email already exists. Please sign in or verify your email if you haven\'t done so.';

  @override
  String get emailVerificationAppBarTitle => 'Email Verification';

  @override
  String get emailVerificationTitle => 'Verify your email';

  @override
  String emailVerificationMessage(String email) {
    return 'A verification email has been sent to $email. Please check your inbox and click the link to verify your account.';
  }

  @override
  String get emailVerificationResendButton => 'Resend';

  @override
  String emailVerificationResendCountdown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get emailVerificationConfirmButton => 'I\'ve verified my email';

  @override
  String get emailVerificationNotVerifiedError => 'Email not yet verified. Please check your inbox and click the verification link.';

  @override
  String get emailVerificationBackButton => 'Back to Sign In';

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

  @override
  String get agendaNoTasks => 'No tasks for this day';

  @override
  String get agendaManageCategories => 'Manage Categories';

  @override
  String get agendaFilter => 'Filter';

  @override
  String get agendaAddTask => 'Add task';

  @override
  String get taskDetailTitle => 'Task Details';

  @override
  String get taskDetailEditTooltip => 'Edit task';

  @override
  String get taskDetailDeleteTooltip => 'Delete task';

  @override
  String get taskDetailStatusCompleted => 'Completed';

  @override
  String get taskDetailStatusPending => 'Pending';

  @override
  String get taskDetailLabelDate => 'Date';

  @override
  String get taskDetailLabelTime => 'Time';

  @override
  String get taskDetailLabelAllDay => 'All day';

  @override
  String get taskDetailLabelDescription => 'Description';

  @override
  String get taskDetailConfirmEdit => 'Confirm Edit';

  @override
  String get taskDetailConfirmEditContent => 'Are you sure you want to save these changes?';

  @override
  String get taskDetailDeleteTitle => 'Delete Task';

  @override
  String taskDetailDeleteContent(String taskTitle) {
    return 'Are you sure you want to delete \"$taskTitle\"?';
  }

  @override
  String get taskDetailToggleConfirmTitle => 'Confirm';

  @override
  String get taskDetailToggleMarkCompleted => 'mark as completed';

  @override
  String get taskDetailToggleMarkPending => 'mark as pending';

  @override
  String taskDetailToggleContent(String action, String taskTitle) {
    return 'Do you want to $action \"$taskTitle\"?';
  }

  @override
  String get taskFormNewTask => 'New Task';

  @override
  String get taskFormEditTask => 'Edit Task';

  @override
  String get taskFormTitleLabel => 'Title';

  @override
  String get taskFormTitleRequired => 'Title is required';

  @override
  String get taskFormDescriptionLabel => 'Description (optional)';

  @override
  String get taskFormCategoryLabel => 'Category';

  @override
  String get taskFormNoCategoryOption => 'No Category';

  @override
  String get taskFormDateLabel => 'Date';

  @override
  String get taskFormAllDayLabel => 'All Day';

  @override
  String get taskFormStartTimeLabel => 'Start';

  @override
  String get taskFormEndTimeLabel => 'End';

  @override
  String get taskFormEndBeforeStartError => 'End time must be after start time';

  @override
  String get taskFormCreateButton => 'Create Task';

  @override
  String get taskFormSaveButton => 'Save Changes';

  @override
  String get filterTitle => 'Filter Tasks';

  @override
  String get filterKeywordLabel => 'Search keyword';

  @override
  String get filterStatusLabel => 'Status';

  @override
  String get filterStatusAll => 'All';

  @override
  String get filterStatusPending => 'Pending';

  @override
  String get filterStatusDone => 'Done';

  @override
  String get filterCategoryLabel => 'Category';

  @override
  String get filterAllCategories => 'All Categories';

  @override
  String get filterDateRangeLabel => 'Date Range';

  @override
  String get filterFromDate => 'From';

  @override
  String get filterToDate => 'To';

  @override
  String get filterCancelButton => 'Cancel';

  @override
  String get filterClearButton => 'Clear';

  @override
  String get filterApplyButton => 'Apply';

  @override
  String get categoryManageTitle => 'Manage Categories';

  @override
  String get categoryNoCategories => 'No categories yet';

  @override
  String get categoryNewTitle => 'New Category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryAddButton => 'Add Category';

  @override
  String get categoryNameRequired => 'Please enter a name';

  @override
  String get categoryDeleteTitle => 'Delete Category';

  @override
  String categoryDeleteContent(String categoryName) {
    return 'Are you sure you want to delete \"$categoryName\"?';
  }

  @override
  String get dialogCancelButton => 'Cancel';

  @override
  String get dialogConfirmButton => 'Confirm';

  @override
  String get dialogDeleteButton => 'Delete';

  @override
  String get profileNamePlaceholder => 'No name';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileOldPasswordLabel => 'Current Password';

  @override
  String get profileNewPasswordLabel => 'New Password';

  @override
  String get profileConfirmPasswordLabel => 'Confirm New Password';

  @override
  String get profilePasswordRequired => 'Password is required';

  @override
  String get profilePasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get profilePasswordMismatch => 'Passwords do not match';

  @override
  String get profileChangePasswordButton => 'Update Password';

  @override
  String get profileChangePasswordSuccess => 'Password updated successfully';

  @override
  String get profileChangePasswordError => 'Failed to update password';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageVietnamese => 'Tiếng Việt';

  @override
  String get profileStatsTitle => 'Task Statistics';

  @override
  String get profilePeriodMonth => 'Month';

  @override
  String get profilePeriodYear => 'Year';

  @override
  String get profileStatsCompleted => 'Completed';

  @override
  String get profileStatsIncomplete => 'Incomplete';

  @override
  String get profileStatsMissed => 'Missed';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutTitle => 'Sign Out';

  @override
  String get profileSignOutContent => 'Are you sure you want to sign out?';

  @override
  String get profileNoInternetTitle => 'No Internet Connection';

  @override
  String get profileNoInternetMessage => 'Please check your connection and try again.';

  @override
  String get profileGuestTitle => 'You are not signed in';

  @override
  String get profileGuestMessage => 'Sign in to sync your data and access it across devices.';

  @override
  String get profileSignInButton => 'Sign In';

  @override
  String get profileCreateAccountButton => 'Create Account';

  @override
  String get taskFormNotificationLabel => 'Remind me';

  @override
  String get taskFormNotificationNone => 'No reminder';

  @override
  String get taskFormNotification30m => '30 minutes before';

  @override
  String get taskFormNotification1h => '1 hour before';

  @override
  String get taskFormNotification2h => '2 hours before';

  @override
  String get taskFormNotification4h => '4 hours before';

  @override
  String get taskFormNotificationCustom => 'Custom';

  @override
  String get taskFormNotificationCustomLabel => 'Hours before';

  @override
  String get taskFormNotificationCustomSuffix => 'hours';

  @override
  String get taskFormNotificationCustomRequired => 'Please enter a value';

  @override
  String get taskFormNotificationCustomInvalid => 'Invalid value';

  @override
  String get taskFormNotificationPastError => 'Notification time cannot be in the past';

  @override
  String get pomodoroClassicPresetName => 'Classic Pomodoro';

  @override
  String get pomodoroClassicPresetDescription => 'The original 25/5/15 technique';

  @override
  String get pomodoroPhaseLabel_focus => 'Focus';

  @override
  String get pomodoroPhaseLabel_shortBreak => 'Short Break';

  @override
  String get pomodoroPhaseLabel_longBreak => 'Long Break';

  @override
  String get pomodoroStart => 'Start';

  @override
  String get pomodoroPause => 'Pause';

  @override
  String get pomodoroResetPhase => 'Reset phase';

  @override
  String get pomodoroResetAll => 'Reset all';

  @override
  String get pomodoroSelectPreset => 'Select preset';

  @override
  String get pomodoroAddPreset => 'Add preset';

  @override
  String get pomodoroEditPreset => 'Edit preset';

  @override
  String get pomodoroPresetFormNew => 'New Preset';

  @override
  String get pomodoroPresetFormEdit => 'Edit Preset';

  @override
  String get pomodoroPresetNameLabel => 'Name';

  @override
  String get pomodoroPresetNameRequired => 'Name is required';

  @override
  String get pomodoroPresetDescLabel => 'Description (optional)';

  @override
  String get pomodoroPresetFocusLabel => 'Focus (min)';

  @override
  String get pomodoroPresetShortBreakLabel => 'Short break (min)';

  @override
  String get pomodoroPresetLongBreakLabel => 'Long break (min)';

  @override
  String get pomodoroPresetCyclesLabel => 'Cycles before long break';

  @override
  String get pomodoroPresetOtherOption => 'Other';

  @override
  String get pomodoroPresetSaveButton => 'Save Preset';

  @override
  String get pomodoroPresetDeleteButton => 'Delete Preset';

  @override
  String get pomodoroDeletePresetTitle => 'Delete Preset';

  @override
  String pomodoroDeletePresetContent(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get pomodoroPresetCustomValueHint => 'Enter value';

  @override
  String get pomodoroPresetCustomValueRequired => 'Please enter a value';

  @override
  String get pomodoroPresetCustomValueInvalid => 'Must be a positive number';

  @override
  String get pomodoroRepeat => 'Repeat session';

  @override
  String get pomodoroViewPreset => 'View preset';

  @override
  String get pomodoroPresetDetail => 'Preset Details';

  @override
  String get pomodoroPresetDetailFocus => 'Focus';

  @override
  String get pomodoroPresetDetailShortBreak => 'Short Break';

  @override
  String get pomodoroPresetDetailLongBreak => 'Long Break';

  @override
  String get pomodoroPresetDetailCycles => 'Cycles';

  @override
  String pomodoroPresetDetailMinutes(int value) {
    return '$value min';
  }

  @override
  String pomodoroPresetDetailCycleValue(int value) {
    return '$value cycles';
  }

  @override
  String get pomodoroEditPresetConfirmTitle => 'Edit Preset';

  @override
  String pomodoroEditPresetConfirmContent(String name) {
    return 'Do you want to edit \"$name\"?';
  }

  @override
  String get pomodoroInfoAction => 'About Pomodoro';

  @override
  String get pomodoroInfoTitle => 'The Pomodoro Technique';

  @override
  String get pomodoroInfoOriginHeading => 'Origin';

  @override
  String get pomodoroInfoOriginText => 'Invented by Francesco Cirillo in the late 1980s while he was a university student. He used a tomato-shaped kitchen timer (\"pomodoro\" in Italian) to track his work — giving the technique its iconic name.';

  @override
  String get pomodoroInfoWhatHeading => 'What is it?';

  @override
  String get pomodoroInfoWhatText => 'A time-management method that breaks work into focused intervals separated by short breaks. The goal is to maintain deep focus while preventing mental fatigue.';

  @override
  String get pomodoroInfoHowHeading => 'How to use it';

  @override
  String get pomodoroInfoStep1 => 'Choose a task you want to work on.';

  @override
  String get pomodoroInfoStep2 => 'Start the timer for a Focus session (default: 25 min).';

  @override
  String get pomodoroInfoStep3 => 'Work with full focus until the timer rings — no distractions.';

  @override
  String get pomodoroInfoStep4 => 'Take a Short Break (default: 5 min). Stand up, stretch, rest your eyes.';

  @override
  String get pomodoroInfoStep5 => 'After every 4 cycles, take a Long Break (default: 15 min).';

  @override
  String get pomodoroInfoStep6 => 'Repeat and track your progress.';

  @override
  String get pomodoroInfoTipsHeading => 'Tips';

  @override
  String get pomodoroInfoTip1 => 'Silence notifications and remove distractions before starting.';

  @override
  String get pomodoroInfoTip2 => 'If interrupted, write down the distraction and continue focusing.';

  @override
  String get pomodoroInfoTip3 => 'Customize intervals in the preset settings to fit your rhythm.';

  @override
  String get pomodoroInfoGotIt => 'Got it';

  @override
  String get exitConfirmTitle => 'Exit App';

  @override
  String get exitConfirmMessage => 'Are you sure you want to exit the app?';

  @override
  String get exitConfirmCancel => 'Cancel';

  @override
  String get exitConfirmExit => 'Exit';

  @override
  String notifTaskReminderTitle(String taskTitle) {
    return 'Reminder: $taskTitle';
  }

  @override
  String get notifTaskReminderBody => 'You have an upcoming task.';

  @override
  String notifPomodoroOngoingTitle(String phaseName) {
    return '🍅 $phaseName in progress';
  }

  @override
  String notifPomodoroOngoingBody(String endTime) {
    return 'Ends at $endTime';
  }

  @override
  String notifPomodoroPhaseEndTitle(String phaseName) {
    return '🍅 $phaseName completed!';
  }

  @override
  String get notifPomodoroPhaseEndBody => 'Tap to continue your Pomodoro session.';
}
