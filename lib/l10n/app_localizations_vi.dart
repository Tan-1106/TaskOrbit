// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Task Orbit';

  @override
  String get navAgenda => 'Lịch';

  @override
  String get navPomodoro => 'Pomodoro';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get shellTitleDefault => 'Task Orbit';

  @override
  String get signInQuote => 'Tổ chức công việc của bạn\nTăng năng suất cùng Task Orbit';

  @override
  String get signInEmailLabel => 'Email của bạn';

  @override
  String get signInEmailRequired => 'Vui lòng nhập email';

  @override
  String get signInEmailInvalid => 'Vui lòng nhập địa chỉ email hợp lệ';

  @override
  String get signInPasswordLabel => 'Mật khẩu của bạn';

  @override
  String get signInPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get signInPasswordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get signInForgotPassword => 'Quên mật khẩu?';

  @override
  String get signInRememberMe => 'Nhớ đăng nhập';

  @override
  String get signInButton => 'Đăng nhập';

  @override
  String get signInNoAccount => 'Chưa có tài khoản? ';

  @override
  String get signInSignUp => 'Đăng ký';

  @override
  String get signUpTitle => 'Tạo tài khoản';

  @override
  String get signUpNameLabel => 'Họ và tên';

  @override
  String get signUpNameRequired => 'Vui lòng nhập tên của bạn';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpEmailRequired => 'Vui lòng nhập email của bạn';

  @override
  String get signUpEmailInvalid => 'Vui lòng nhập email hợp lệ';

  @override
  String get signUpPasswordLabel => 'Mật khẩu';

  @override
  String get signUpPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get signUpPasswordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get signUpButton => 'Đăng ký';

  @override
  String get signUpAlreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get forgotPasswordAppBarTitle => 'Đặt lại mật khẩu';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu?';

  @override
  String get forgotPasswordSubtitle => 'Nhập địa chỉ email để nhận liên kết đặt lại mật khẩu.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordEmailRequired => 'Vui lòng nhập email của bạn';

  @override
  String get forgotPasswordEmailInvalid => 'Vui lòng nhập email hợp lệ';

  @override
  String get forgotPasswordButton => 'Gửi liên kết đặt lại';

  @override
  String get agendaNoTasks => 'Không có công việc nào trong ngày này';

  @override
  String get agendaManageCategories => 'Quản lý danh mục';

  @override
  String get agendaFilter => 'Lọc';

  @override
  String get agendaAddTask => 'Thêm công việc';

  @override
  String get taskDetailTitle => 'Chi tiết công việc';

  @override
  String get taskDetailEditTooltip => 'Chỉnh sửa công việc';

  @override
  String get taskDetailDeleteTooltip => 'Xóa công việc';

  @override
  String get taskDetailStatusCompleted => 'Đã hoàn thành';

  @override
  String get taskDetailStatusPending => 'Chưa hoàn thành';

  @override
  String get taskDetailLabelDate => 'Ngày';

  @override
  String get taskDetailLabelTime => 'Thời gian';

  @override
  String get taskDetailLabelAllDay => 'Cả ngày';

  @override
  String get taskDetailLabelDescription => 'Mô tả';

  @override
  String get taskDetailConfirmEdit => 'Xác nhận chỉnh sửa';

  @override
  String get taskDetailConfirmEditContent => 'Bạn có chắc muốn lưu các thay đổi này không?';

  @override
  String get taskDetailDeleteTitle => 'Xóa công việc';

  @override
  String taskDetailDeleteContent(String taskTitle) {
    return 'Bạn có chắc muốn xóa \"$taskTitle\" không?';
  }

  @override
  String get taskDetailToggleConfirmTitle => 'Xác nhận';

  @override
  String get taskDetailToggleMarkCompleted => 'đánh dấu là đã hoàn thành';

  @override
  String get taskDetailToggleMarkPending => 'đánh dấu là chưa hoàn thành';

  @override
  String taskDetailToggleContent(String action, String taskTitle) {
    return 'Bạn có muốn $action \"$taskTitle\" không?';
  }

  @override
  String get taskFormNewTask => 'Công việc mới';

  @override
  String get taskFormEditTask => 'Chỉnh sửa công việc';

  @override
  String get taskFormTitleLabel => 'Tiêu đề';

  @override
  String get taskFormTitleRequired => 'Tiêu đề là bắt buộc';

  @override
  String get taskFormDescriptionLabel => 'Mô tả (tùy chọn)';

  @override
  String get taskFormCategoryLabel => 'Danh mục';

  @override
  String get taskFormNoCategoryOption => 'Không có danh mục';

  @override
  String get taskFormDateLabel => 'Ngày';

  @override
  String get taskFormAllDayLabel => 'Cả ngày';

  @override
  String get taskFormStartTimeLabel => 'Bắt đầu';

  @override
  String get taskFormEndTimeLabel => 'Kết thúc';

  @override
  String get taskFormEndBeforeStartError => 'Thời gian kết thúc phải sau thời gian bắt đầu';

  @override
  String get taskFormCreateButton => 'Tạo công việc';

  @override
  String get taskFormSaveButton => 'Lưu thay đổi';

  @override
  String get filterTitle => 'Lọc công việc';

  @override
  String get filterKeywordLabel => 'Từ khóa tìm kiếm';

  @override
  String get filterStatusLabel => 'Trạng thái';

  @override
  String get filterStatusAll => 'Tất cả';

  @override
  String get filterStatusPending => 'Chưa hoàn thành';

  @override
  String get filterStatusDone => 'Đã xong';

  @override
  String get filterCategoryLabel => 'Danh mục';

  @override
  String get filterAllCategories => 'Tất cả danh mục';

  @override
  String get filterDateRangeLabel => 'Khoảng thời gian';

  @override
  String get filterFromDate => 'Từ ngày';

  @override
  String get filterToDate => 'Đến ngày';

  @override
  String get filterCancelButton => 'Hủy';

  @override
  String get filterClearButton => 'Xóa lọc';

  @override
  String get filterApplyButton => 'Áp dụng';

  @override
  String get categoryManageTitle => 'Quản lý danh mục';

  @override
  String get categoryNoCategories => 'Chưa có danh mục nào';

  @override
  String get categoryNewTitle => 'Danh mục mới';

  @override
  String get categoryNameLabel => 'Tên danh mục';

  @override
  String get categoryAddButton => 'Thêm danh mục';

  @override
  String get categoryNameRequired => 'Vui lòng nhập tên';

  @override
  String get categoryDeleteTitle => 'Xóa danh mục';

  @override
  String categoryDeleteContent(String categoryName) {
    return 'Bạn có chắc muốn xóa \"$categoryName\" không?';
  }

  @override
  String get dialogCancelButton => 'Hủy';

  @override
  String get dialogConfirmButton => 'Xác nhận';

  @override
  String get dialogDeleteButton => 'Xóa';

  @override
  String get profileNamePlaceholder => 'Chưa có tên';

  @override
  String get profileSettingsTitle => 'Cài đặt';

  @override
  String get profileChangePassword => 'Đổi mật khẩu';

  @override
  String get profileOldPasswordLabel => 'Mật khẩu hiện tại';

  @override
  String get profileNewPasswordLabel => 'Mật khẩu mới';

  @override
  String get profileConfirmPasswordLabel => 'Xác nhận mật khẩu mới';

  @override
  String get profilePasswordRequired => 'Mật khẩu là bắt buộc';

  @override
  String get profilePasswordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get profilePasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get profileChangePasswordButton => 'Cập nhật mật khẩu';

  @override
  String get profileChangePasswordSuccess => 'Đổi mật khẩu thành công';

  @override
  String get profileChangePasswordError => 'Đổi mật khẩu thất bại';

  @override
  String get profileLanguageLabel => 'Ngôn ngữ';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageVietnamese => 'Tiếng Việt';

  @override
  String get profileStatsTitle => 'Thống kê công việc';

  @override
  String get profilePeriodMonth => 'Tháng';

  @override
  String get profilePeriodYear => 'Năm';

  @override
  String get profileStatsCompleted => 'Đã hoàn thành';

  @override
  String get profileStatsIncomplete => 'Chưa hoàn thành';

  @override
  String get profileStatsMissed => 'Đã bỏ lỡ';

  @override
  String get profileSignOut => 'Đăng xuất';

  @override
  String get profileSignOutTitle => 'Đăng xuất';

  @override
  String get profileSignOutContent => 'Bạn có chắc muốn đăng xuất không?';
}
