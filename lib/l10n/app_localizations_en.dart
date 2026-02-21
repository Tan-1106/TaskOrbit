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
}
