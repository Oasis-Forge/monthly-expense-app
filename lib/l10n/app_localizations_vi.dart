// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Cài đặt';

  @override
  String get transferTooltip => 'Chuyển khoản';

  @override
  String get searchTooltip => 'Tìm kiếm';

  @override
  String get addButton => 'Thêm';

  @override
  String get emptyPeriod => 'Chưa có giao dịch nào trong kỳ này.';

  @override
  String get balanceLabel => 'Số dư';

  @override
  String get expandSummaryTooltip => 'Hiện thu và chi';

  @override
  String get collapseSummaryTooltip => 'Chỉ hiện số dư';

  @override
  String get periodNetLabel => 'Kỳ này';

  @override
  String carriedForwardLine(String amount) {
    return 'Chuyển từ kỳ trước $amount';
  }

  @override
  String get incomeLabel => 'Thu nhập';

  @override
  String get expenseLabel => 'Chi tiêu';

  @override
  String upcomingCategory(String category) {
    return '$category · Sắp tới';
  }

  @override
  String get upcomingLabel => 'Sắp tới';

  @override
  String detailAdded(String date) {
    return 'Đã thêm $date';
  }

  @override
  String detailChanged(String date) {
    return 'Sửa lần cuối $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Có $count giao dịch định kỳ đến hạn',
      one: 'Có 1 giao dịch định kỳ đến hạn',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: 'Đã dùng $percent · $over vượt hạn mức',
      one: 'Đã dùng $percent · 1 vượt hạn mức',
      zero: 'Đã dùng $percent',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã đặt $count ngân sách',
      one: 'Đã đặt 1 ngân sách',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'Không thể xóa giao dịch. Vui lòng thử lại.';

  @override
  String get transactionDeleted => 'Đã xóa giao dịch';

  @override
  String get transferDeleted => 'Đã xóa khoản chuyển';

  @override
  String get undoButton => 'Hoàn tác';

  @override
  String get undoFailed => 'Không thể hoàn tác. Vui lòng thử lại.';

  @override
  String get restoreFailed =>
      'Không thể khôi phục giao dịch. Vui lòng thử lại.';

  @override
  String get restoreTransferFailed =>
      'Không khôi phục được giao dịch chuyển. Thử lại.';

  @override
  String get addTransactionTitle => 'Thêm giao dịch';

  @override
  String get editTransactionTitle => 'Sửa giao dịch';

  @override
  String get transactionDetailTitle => 'Chi tiết';

  @override
  String get editTooltip => 'Sửa';

  @override
  String get deleteTooltip => 'Xóa';

  @override
  String get duplicateTooltip => 'Nhân bản';

  @override
  String get rowMenuTooltip => 'Thao tác khác';

  @override
  String get deleteTransactionTitle => 'Xóa giao dịch này?';

  @override
  String get deleteTransactionMessage =>
      'Mục này chuyển vào thùng rác và khôi phục được trong 30 ngày.';

  @override
  String get discardChangesTitle => 'Bỏ thay đổi?';

  @override
  String get discardChangesMessage => 'Nội dung bạn nhập ở đây chưa được lưu.';

  @override
  String get discardButton => 'Bỏ';

  @override
  String get keepEditingButton => 'Tiếp tục sửa';

  @override
  String get titleOptionalLabel => 'Tiêu đề (không bắt buộc)';

  @override
  String get amountLabel => 'Số tiền';

  @override
  String get amountRequired => 'Nhập số tiền';

  @override
  String get amountInvalid => 'Nhập số tiền hợp lệ';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Xóa lùi';

  @override
  String get hideKeypadTooltip => 'Ẩn bàn phím';

  @override
  String get categoryLabel => 'Danh mục';

  @override
  String get categoryRequired => 'Chọn danh mục';

  @override
  String get accountLabel => 'Tài khoản';

  @override
  String get accountRequired => 'Chọn tài khoản';

  @override
  String get dateLabel => 'Ngày';

  @override
  String get noteLabel => 'Ghi chú';

  @override
  String get previousDayTooltip => 'Ngày trước';

  @override
  String get nextDayTooltip => 'Ngày sau';

  @override
  String get noteOptionalLabel => 'Ghi chú (không bắt buộc)';

  @override
  String get saveChangesButton => 'Lưu thay đổi';

  @override
  String get addTransactionButton => 'Thêm giao dịch';

  @override
  String get saveAndAddAnotherButton => 'Lưu & thêm mới';

  @override
  String get transactionAdded => 'Đã thêm giao dịch';

  @override
  String get saveFailed => 'Không thể lưu giao dịch. Vui lòng thử lại.';

  @override
  String get noExpensesInPeriod => 'Chưa có khoản chi nào trong kỳ này.';

  @override
  String totalSpent(String amount) {
    return 'Tổng chi: $amount';
  }

  @override
  String periodRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String categoryAndDate(String category, String date) {
    return '$category · $date';
  }

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get drawerAddHeader => 'Thêm mới';

  @override
  String get drawerAddExpense => 'Thêm khoản chi';

  @override
  String get drawerAddIncome => 'Thêm khoản thu';

  @override
  String get drawerPlanHeader => 'Kế hoạch';

  @override
  String get drawerReviewHeader => 'Nhìn lại';

  @override
  String get drawerSpending => 'Chi tiêu theo danh mục';

  @override
  String get drawerManageHeader => 'Quản lý';

  @override
  String get drawerDataHeader => 'Dữ liệu';

  @override
  String get currencyLabel => 'Đơn vị tiền tệ';

  @override
  String get currencySearchHint => 'Tìm đơn vị tiền tệ';

  @override
  String changeCurrencyTitle(String code) {
    return 'Đổi đơn vị tiền tệ sang $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Số tiền giữ nguyên; chỉ nhãn đơn vị tiền tệ thay đổi.';

  @override
  String get changeButton => 'Đổi';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get saveButton => 'Lưu';

  @override
  String get removeButton => 'Gỡ bỏ';

  @override
  String get themeLabel => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Mặc định hệ thống';

  @override
  String get monthStartLabel => 'Ngày bắt đầu tháng';

  @override
  String get monthStartLastDay => 'Ngày cuối tháng';

  @override
  String get showCarriedForwardLabel => 'Chuyển số dư sang kỳ sau';

  @override
  String get showCarriedForwardSubtitle => 'Mỗi kỳ bắt đầu từ số dư kỳ trước';

  @override
  String get trashTitle => 'Thùng rác';

  @override
  String get trashEmpty => 'Thùng rác trống.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'xóa vĩnh viễn sau $days ngày',
      one: 'xóa vĩnh viễn sau 1 ngày',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Khôi phục';

  @override
  String get categoriesTitle => 'Danh mục';

  @override
  String get addCategoryTooltip => 'Thêm danh mục';

  @override
  String get addCategoryTitle => 'Thêm danh mục';

  @override
  String get editCategoryTitle => 'Sửa danh mục';

  @override
  String get categoryNameLabel => 'Tên';

  @override
  String get categoryNameRequired => 'Nhập tên';

  @override
  String get categoryNameTaken => 'Tên này đã được dùng';

  @override
  String get archiveAction => 'Lưu trữ';

  @override
  String get unarchiveAction => 'Bỏ lưu trữ';

  @override
  String get deleteAction => 'Xóa';

  @override
  String get archivedHeader => 'Đã lưu trữ';

  @override
  String get accountsTotalLabel => 'Tổng';

  @override
  String get categorySaveFailed => 'Không thể lưu danh mục. Vui lòng thử lại.';

  @override
  String get accountsTitle => 'Tài khoản';

  @override
  String get accountCash => 'Tiền mặt';

  @override
  String get accountTypeLabel => 'Loại';

  @override
  String get accountTypeCash => 'Tiền mặt';

  @override
  String get accountTypeBank => 'Ngân hàng';

  @override
  String get accountTypeCard => 'Thẻ';

  @override
  String get accountTypeOther => 'Khác';

  @override
  String get addAccountTooltip => 'Thêm tài khoản';

  @override
  String get addAccountTitle => 'Thêm tài khoản';

  @override
  String get editAccountTitle => 'Sửa tài khoản';

  @override
  String get openingBalanceLabel => 'Số dư ban đầu';

  @override
  String get openingDateLabel => 'Ngày mở';

  @override
  String get accountSaveFailed => 'Không thể lưu tài khoản. Vui lòng thử lại.';

  @override
  String get transferTitle => 'Chuyển khoản';

  @override
  String get editTransferTitle => 'Sửa khoản chuyển';

  @override
  String get transferLabel => 'Chuyển khoản';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Từ';

  @override
  String get toAccountLabel => 'Đến';

  @override
  String get sameAccountError => 'Chọn hai tài khoản khác nhau';

  @override
  String get needTwoAccounts =>
      'Thêm tài khoản thứ hai để chuyển tiền giữa các tài khoản.';

  @override
  String get addTransferButton => 'Thêm khoản chuyển';

  @override
  String get transferSaveFailed =>
      'Không thể lưu khoản chuyển. Vui lòng thử lại.';

  @override
  String get searchHint => 'Tìm giao dịch';

  @override
  String get allTypesFilter => 'Tất cả';

  @override
  String get allCategoriesFilter => 'Tất cả danh mục';

  @override
  String get allAccountsFilter => 'Tất cả tài khoản';

  @override
  String get allTimeFilter => 'Mọi lúc';

  @override
  String get clearDatesTooltip => 'Xóa ngày';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kết quả',
      one: '1 kết quả',
    );
    return '$_temp0 · Thu $income · Chi $expense';
  }

  @override
  String get noSearchResults => 'Không có giao dịch phù hợp.';

  @override
  String get budgetsTitle => 'Ngân sách';

  @override
  String get budgetsTooltip => 'Ngân sách';

  @override
  String get overallBudget => 'Tổng thể';

  @override
  String get noBudget => 'Chưa có ngân sách';

  @override
  String budgetsHint(String period) {
    return 'Hạn mức áp dụng từ $period trở đi; các kỳ trước giữ nguyên hạn mức cũ.';
  }

  @override
  String get budgetLimitLabel => 'Hạn mức mỗi kỳ';

  @override
  String get budgetSaveFailed => 'Không thể lưu ngân sách. Vui lòng thử lại.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent trên $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'Còn $remaining · $perDay mỗi ngày';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'Đã chi $amount · $perDay mỗi ngày cho đến nay';
  }

  @override
  String get homeSetBudget => 'Đặt ngân sách hàng tháng';

  @override
  String budgetLeft(String remaining) {
    return 'Còn $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Vượt $amount';
  }

  @override
  String get budgetLimitReached => 'Đã đạt hạn mức';

  @override
  String budgetLimitOnly(String limit) {
    return 'Hạn mức $limit';
  }

  @override
  String get recurringTitle => 'Định kỳ';

  @override
  String get addRecurringTooltip => 'Thêm giao dịch định kỳ';

  @override
  String get addRecurringTitle => 'Thêm giao dịch định kỳ';

  @override
  String get editRecurringTitle => 'Sửa giao dịch định kỳ';

  @override
  String get dueHeader => 'Đến hạn';

  @override
  String get upcomingHeader => '30 ngày tới';

  @override
  String get rulesHeader => 'Quy tắc';

  @override
  String billsPerMonth(String amount) {
    return '$amount mỗi tháng tiền hóa đơn';
  }

  @override
  String nextBillToday(String title) {
    return 'Tiếp theo: $title, hôm nay';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'Tiếp theo: $title, ngày mai';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tiếp theo: $title, sau $days ngày',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Không có gì trong 30 ngày tới.';

  @override
  String get noRules => 'Chưa có giao dịch định kỳ nào.';

  @override
  String get postButton => 'Ghi nhận';

  @override
  String get skipButton => 'Bỏ qua';

  @override
  String get postFailed => 'Không thể ghi nhận giao dịch. Vui lòng thử lại.';

  @override
  String get recurringSaveFailed =>
      'Không thể lưu giao dịch định kỳ. Vui lòng thử lại.';

  @override
  String get everyLabel => 'Mỗi';

  @override
  String get frequencyDays => 'Ngày';

  @override
  String get frequencyWeeks => 'Tuần';

  @override
  String get frequencyMonths => 'Tháng';

  @override
  String get frequencyYears => 'Năm';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count ngày',
      one: 'Mỗi ngày',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count tuần',
      one: 'Mỗi tuần',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count tháng',
      one: 'Mỗi tháng',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count năm',
      one: 'Mỗi năm',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Tạm dừng';
  }

  @override
  String get startsLabel => 'Bắt đầu';

  @override
  String get endsLabel => 'Kết thúc';

  @override
  String get endNever => 'Không bao giờ';

  @override
  String get endAfter => 'Sau';

  @override
  String get endOnDate => 'Vào ngày';

  @override
  String get timesLabel => 'Số lần';

  @override
  String get endsOnLabel => 'Kết thúc vào';

  @override
  String get wholeNumberInvalid => 'Nhập số nguyên từ 1 trở lên';

  @override
  String get endDateInvalid => 'Ngày kết thúc phải sau ngày bắt đầu';

  @override
  String get autoPostLabel => 'Tự động ghi nhận';

  @override
  String get autoPostSubtitle =>
      'Nếu không, giao dịch sẽ chờ trong mục Đến hạn để bạn nhấn';

  @override
  String get pauseTooltip => 'Tạm dừng';

  @override
  String get resumeTooltip => 'Tiếp tục';

  @override
  String get categoryFood => 'Ăn uống';

  @override
  String get categoryGroceries => 'Tạp hóa';

  @override
  String get categoryTransport => 'Đi lại';

  @override
  String get categoryShopping => 'Mua sắm';

  @override
  String get categoryBills => 'Hóa đơn';

  @override
  String get categoryRent => 'Thuê nhà';

  @override
  String get categoryHealth => 'Sức khỏe';

  @override
  String get categoryEducation => 'Giáo dục';

  @override
  String get categoryEntertainment => 'Giải trí';

  @override
  String get categorySalary => 'Lương';

  @override
  String get categoryBusiness => 'Kinh doanh';

  @override
  String get categoryInvestment => 'Đầu tư';

  @override
  String get categoryGift => 'Quà tặng';

  @override
  String get categoryOther => 'Khác';

  @override
  String get previousPeriodTooltip => 'Kỳ trước';

  @override
  String get wholePeriodTooltip => 'Hiện toàn bộ kỳ';

  @override
  String get nextPeriodTooltip => 'Kỳ sau';

  @override
  String get insightsTooltip => 'Phân tích';

  @override
  String get insightsTitle => 'Phân tích';

  @override
  String get calendarTab => 'Lịch';

  @override
  String get trendTab => 'Xu hướng';

  @override
  String get noIncomeInPeriod => 'Chưa có khoản thu nào trong kỳ này.';

  @override
  String totalIncome(String amount) {
    return 'Tổng thu: $amount';
  }

  @override
  String comparedMore(String amount) {
    return 'nhiều hơn tháng trước $amount';
  }

  @override
  String comparedLess(String amount) {
    return 'ít hơn tháng trước $amount';
  }

  @override
  String get comparedSame => 'Giống tháng trước';

  @override
  String get categoryNewLabel => 'mới';

  @override
  String get calendarHint => 'Chạm vào một ngày để xem giao dịch của ngày đó.';

  @override
  String get dayEmpty => 'Không có gì trong ngày này.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tháng',
      one: '1 tháng',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Thu $income · Chi $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Trung bình mỗi kỳ · Thu $income · Chi $expense';
  }

  @override
  String get weekStartLabel => 'Ngày bắt đầu tuần';

  @override
  String weekStartDefault(String day) {
    return 'Mặc định ($day)';
  }

  @override
  String get firstRunTitle => 'Chào mừng đến với Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Theo dõi khoản chi và thu của bạn. Dữ liệu chỉ lưu trên thiết bị này.';

  @override
  String get addFirstTransactionButton => 'Thêm giao dịch đầu tiên';

  @override
  String get setupIntro =>
      'Chọn ngôn ngữ và đơn vị tiền tệ. Bạn có thể đổi lại sau trong Cài đặt.';

  @override
  String get setupContinueButton => 'Tiếp tục';

  @override
  String get setupRestoreTitle => 'Khôi phục bản sao lưu';

  @override
  String get setupRestoreSubtitle =>
      'Lấy lại dữ liệu và cài đặt từ tệp sao lưu';

  @override
  String get walkthroughEntryTitle => 'Thêm nhanh trong vài giây';

  @override
  String get walkthroughEntryBody =>
      'Bàn phím tự tính tổng, chụp ảnh hóa đơn, và ghi âm khi gõ chữ chậm.';

  @override
  String get walkthroughPlanTitle => 'Lên kế hoạch cho tháng';

  @override
  String get walkthroughPlanBody =>
      'Ngân sách theo danh mục, hóa đơn tự lặp lại, và ghi chú nhắc bạn.';

  @override
  String get walkthroughInsightsTitle => 'Xem tiền đi đâu';

  @override
  String get walkthroughInsightsBody =>
      'Biểu đồ, lịch, và báo cáo PDF hoặc CSV cho bất kỳ kỳ nào.';

  @override
  String get walkthroughPrivacyTitle => 'Chỉ riêng bạn';

  @override
  String get walkthroughPrivacyBody =>
      'Không cần tài khoản. Những gì bạn ghi lại chỉ lưu trên điện thoại này; quảng cáo giúp duy trì ứng dụng không bao giờ thấy được.';

  @override
  String get walkthroughBringTitle => 'Mang theo dữ liệu bạn đã có';

  @override
  String get walkthroughBringBody =>
      'Chuyển từ ứng dụng hoặc điện thoại khác? Hãy bắt đầu từ bản sao lưu hoặc tệp CSV thay vì một ứng dụng trống.';

  @override
  String get firstRunRestoreTitle => 'Khôi phục bản sao lưu này?';

  @override
  String get firstRunRestoreMessage =>
      'Thao tác này thay thế toàn bộ dữ liệu trong ứng dụng, và khôi phục lại ngôn ngữ cùng đơn vị tiền tệ đã lưu.';

  @override
  String get walkthroughNextButton => 'Tiếp theo';

  @override
  String get walkthroughStartButton => 'Bắt đầu';

  @override
  String get walkthroughDoneButton => 'Xong';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Trang $current trên $total';
  }

  @override
  String get walkthroughReplayTitle => 'Xem lại phần giới thiệu';

  @override
  String get walkthroughReplaySubtitle =>
      'Bốn trang hiển thị khi ứng dụng mới cài';

  @override
  String get removeAdsTitle => 'Xóa quảng cáo';

  @override
  String get exportCsvMenu => 'Xuất CSV';

  @override
  String get exportCsvTooltip => 'Xuất CSV';

  @override
  String get csvExported => 'Đã lưu tệp CSV';

  @override
  String get csvExportFailed => 'Không thể xuất CSV. Vui lòng thử lại.';

  @override
  String get backupTitle => 'Sao lưu & khôi phục';

  @override
  String get backupIntro =>
      'Bản sao lưu là tệp bạn tự chọn nơi lưu. Không có gì được tải lên hay gửi đi tự động.';

  @override
  String get backUpNowTitle => 'Sao lưu ngay';

  @override
  String lastBackupLine(String date) {
    return 'Sao lưu lần cuối $date';
  }

  @override
  String get neverBackedUp => 'Chưa sao lưu lần nào';

  @override
  String get backupSaved => 'Đã lưu bản sao lưu';

  @override
  String get backupSaveFailed => 'Không thể lưu bản sao lưu. Vui lòng thử lại.';

  @override
  String get restoreFromFileTitle => 'Khôi phục từ tệp';

  @override
  String get restoreFromFileSubtitle =>
      'Gộp bản sao lưu vào dữ liệu hiện có, hoặc thay thế dữ liệu hiện có bằng bản sao lưu đó';

  @override
  String get backupReminderLabel => 'Nhắc sao lưu';

  @override
  String get backupReminderSubtitle =>
      'Mỗi 30 ngày khi có từ 20 giao dịch trở lên';

  @override
  String get backupReminderNever => 'Sao lưu dữ liệu để giữ an toàn';

  @override
  String backupReminderSince(String date) {
    return 'Sao lưu lần cuối $date. Đến lúc sao lưu mới chưa?';
  }

  @override
  String get notNowTooltip => 'Để sau';

  @override
  String get keptBackupsHeader => 'Bản sao lưu tự động';

  @override
  String get keptBackupsHint =>
      'Được lưu trên thiết bị này trước mỗi lần khôi phục.';

  @override
  String get noKeptBackups => 'Chưa có bản nào.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giao dịch',
      one: '1 giao dịch',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Khôi phục bản sao lưu';

  @override
  String get mergeOption => 'Gộp';

  @override
  String get mergeOptionSubtitle =>
      'Giữ dữ liệu hiện có và thêm dữ liệu từ bản sao lưu. Nơi cả hai đều có bản ghi, thay đổi mới hơn sẽ được giữ lại.';

  @override
  String get replaceOption => 'Thay thế';

  @override
  String get replaceOptionSubtitle =>
      'Xóa dữ liệu hiện có và chỉ dùng bản sao lưu, cùng với cài đặt của nó.';

  @override
  String get restoreSafetyNote =>
      'Một bản sao dữ liệu hiện tại của bạn sẽ được lưu vào mục Bản sao lưu tự động trước.';

  @override
  String get restoreButton => 'Khôi phục';

  @override
  String get restoreKeptTitle => 'Khôi phục bản sao này?';

  @override
  String restoreKeptMessage(String date) {
    return 'Dữ liệu của bạn sẽ được thay bằng bản sao từ $date. Một bản sao dữ liệu hiện tại sẽ được lưu lại trước.';
  }

  @override
  String get backupInvalid =>
      'Tệp này không phải bản sao lưu của Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Bản sao lưu này đến từ phiên bản ứng dụng mới hơn. Hãy cập nhật ứng dụng rồi thử lại.';

  @override
  String get backupOpenFailed => 'Không thể mở tệp. Vui lòng thử lại.';

  @override
  String get backupRestoreFailed =>
      'Không thể khôi phục bản sao lưu. Dữ liệu của bạn không thay đổi.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã khôi phục $count giao dịch',
      one: 'Đã khôi phục 1 giao dịch',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Đã gộp: thêm $added, cập nhật $updated, giữ nguyên $unchanged';
  }

  @override
  String get appLockLabel => 'Khóa ứng dụng';

  @override
  String get appLockSubtitle =>
      'Mở khóa bằng vân tay, khuôn mặt, hoặc khóa màn hình';

  @override
  String get appLockUnavailable =>
      'Thiết lập khóa màn hình trên thiết bị này để dùng khóa ứng dụng';

  @override
  String get appLockReason => 'Mở khóa Monthly Expenses';

  @override
  String get appLockFailed =>
      'Không thể xác nhận đó là bạn. Khóa ứng dụng chưa được thay đổi.';

  @override
  String get lockedTitle => 'Monthly Expenses đang khóa';

  @override
  String get unlockButton => 'Mở khóa';

  @override
  String get widgetShowAmountsLabel => 'Hiện số tiền trên tiện ích';

  @override
  String get widgetShowAmountsSubtitle =>
      'Tiện ích màn hình chính sẽ ẩn số tiền khi khóa ứng dụng đang bật';

  @override
  String get widgetLeftLabel => 'Còn lại';

  @override
  String get widgetAddExpense => 'Thêm khoản chi';

  @override
  String get widgetAddIncome => 'Thêm khoản thu';

  @override
  String get widgetAmountsHidden => 'Số tiền đang bị ẩn do khóa ứng dụng';

  @override
  String get notesTitle => 'Ghi chú';

  @override
  String get addNoteTooltip => 'Thêm ghi chú';

  @override
  String get addNoteTitle => 'Thêm ghi chú';

  @override
  String get editNoteTitle => 'Sửa ghi chú';

  @override
  String get noteTextLabel => 'Ghi chú';

  @override
  String get noteTextRequired => 'Nhập nội dung';

  @override
  String get noteAmountOptionalLabel => 'Số tiền (không bắt buộc)';

  @override
  String get noteDueDateToggle => 'Đặt ngày đến hạn';

  @override
  String get noteDueDateLabel => 'Ngày đến hạn';

  @override
  String get noteReminderToggle => 'Nhắc tôi';

  @override
  String get noteReminderTimeLabel => 'Giờ nhắc';

  @override
  String get noteReminderTimeUnset => 'Chọn giờ';

  @override
  String get noteCategoryOptionalLabel => 'Danh mục (không bắt buộc)';

  @override
  String get noteCategoryNone => 'Không có';

  @override
  String get recordNoteButton => 'Ghi thành giao dịch';

  @override
  String get noteMarkDoneTooltip => 'Đánh dấu xong';

  @override
  String get noteMarkOpenTooltip => 'Đánh dấu chưa xong';

  @override
  String get notesEmptyTitle => 'Chưa có gì ở đây';

  @override
  String get notesEmptyMessage =>
      'Ghi chú giúp bạn nhớ việc cần làm hoặc cần kiểm tra, kèm ngày, số tiền và danh mục tùy chọn.';

  @override
  String get addNoteButton => 'Thêm ghi chú';

  @override
  String get notesOpenHeader => 'Chưa xong';

  @override
  String get notesDoneHeader => 'Đã xong';

  @override
  String get noteDeleted => 'Đã xóa ghi chú.';

  @override
  String get noteSaveFailed => 'Không thể lưu ghi chú. Vui lòng thử lại.';

  @override
  String get noteDeleteFailed => 'Không thể xóa ghi chú. Vui lòng thử lại.';

  @override
  String get noteRestoreFailed =>
      'Không thể khôi phục ghi chú. Vui lòng thử lại.';

  @override
  String get notesSearchHint => 'Tìm ghi chú';

  @override
  String get noteFilterAll => 'Tất cả';

  @override
  String get noteFilterOverdue => 'Quá hạn';

  @override
  String get noteFilterDueToday => 'Đến hạn hôm nay';

  @override
  String get noteFilterUpcoming => 'Sắp tới';

  @override
  String get noteFilterNoDate => 'Không có ngày';

  @override
  String get noNoteResults => 'Không có ghi chú phù hợp.';

  @override
  String get noteLinkedTransactionLabel => 'Đã ghi thành giao dịch';

  @override
  String get noteLinkedNoteLabel => 'Từ một ghi chú';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Có $count ghi chú đến hạn',
      one: 'Có 1 ghi chú đến hạn',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Ghi chú đến hạn';

  @override
  String get noteReminderTitle => 'Nhắc nhở ghi chú';

  @override
  String get noteReminderLockedTitle => 'Có một ghi chú đến hạn';

  @override
  String get noteReminderPermissionDenied =>
      'Bật thông báo trong cài đặt hệ thống để nhận nhắc nhở cho ghi chú.';

  @override
  String reportRange(String from, String to) {
    return '$from đến $to';
  }

  @override
  String reportCreated(String when) {
    return 'Tạo lúc $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Trang $page trên $pages';
  }

  @override
  String get reportNet => 'Số dư ròng';

  @override
  String get reportOpeningBalance => 'Số dư đầu kỳ';

  @override
  String get reportClosingBalance => 'Số dư cuối kỳ';

  @override
  String get reportSpendingHeader => 'Chi tiêu theo danh mục';

  @override
  String get reportEarningHeader => 'Thu nhập theo danh mục';

  @override
  String get reportTrendHeader => 'Xu hướng';

  @override
  String get reportEntriesHeader => 'Giao dịch';

  @override
  String get reportUpcomingHeader => 'Sắp tới';

  @override
  String get reportUpcomingNote =>
      'Có ngày ở tương lai nên chưa tính vào tổng ở trên.';

  @override
  String get reportAmountColumn => 'Số tiền';

  @override
  String get reportShareColumn => 'Tỷ lệ';

  @override
  String get reportBudgetColumn => 'Ngân sách';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used trên $limit';
  }

  @override
  String get reportDetailsColumn => 'Chi tiết';

  @override
  String get reportEmpty => 'Không có gì để báo cáo cho khoảng thời gian này.';

  @override
  String get exportPdfMenu => 'Xuất PDF';

  @override
  String get reportTitle => 'Xuất PDF';

  @override
  String get reportNoFontTitle => 'Chưa có trong ngôn ngữ này';

  @override
  String get reportNoFontBody =>
      'Báo cáo cần phông chữ cho hệ chữ của nó, mà phông tiếng Trung, tiếng Nhật và tiếng Hàn quá lớn để đi kèm ứng dụng. Phiên bản sau sẽ cho tải về.';

  @override
  String get reportPreviewTitle => 'Báo cáo';

  @override
  String get reportCoversHeader => 'Phạm vi báo cáo';

  @override
  String get reportRangePeriod => 'Kỳ này';

  @override
  String get reportRangeCustom => 'Khoảng ngày';

  @override
  String get reportRangeYear => 'Năm';

  @override
  String get reportFromLabel => 'Từ';

  @override
  String get reportToLabel => 'Đến';

  @override
  String get reportYearLabel => 'Năm';

  @override
  String get reportAccountLabel => 'Tài khoản';

  @override
  String get reportAllAccounts => 'Tất cả tài khoản';

  @override
  String get reportIncludeHeader => 'Nội dung bao gồm';

  @override
  String get reportIncludeSubtitle =>
      'Bỏ bớt những phần bạn không muốn chia sẻ.';

  @override
  String get reportIncludeTransactions => 'Danh sách giao dịch';

  @override
  String get reportIncludeDetails => 'Tiêu đề và ghi chú';

  @override
  String get reportIncludeAccounts => 'Tên tài khoản';

  @override
  String get reportCreateButton => 'Tạo báo cáo';

  @override
  String get reportBuilding => 'Đang tạo báo cáo';

  @override
  String get reportFailed => 'Không thể tạo báo cáo. Vui lòng thử lại.';

  @override
  String get reportRangeBackwards => 'Ngày đầu phải trước ngày cuối.';

  @override
  String get importTitle => 'Nhập tệp CSV';

  @override
  String get importSubtitle => 'Đưa giao dịch từ ứng dụng khác vào';

  @override
  String get importIntro =>
      'Chọn một tệp CSV và bạn sẽ thấy ứng dụng đọc được gì trước khi thêm bất cứ thứ gì. Nhập chỉ thêm bản ghi mới — không bao giờ thay thế hay xóa dữ liệu bạn đã có.';

  @override
  String get importChooseFile => 'Chọn tệp';

  @override
  String get importChooseAnother => 'Chọn tệp khác';

  @override
  String get importReadFailed => 'Không thể đọc tệp đó. Vui lòng thử lại.';

  @override
  String get importRefusedEmpty => 'Tệp đó không có nội dung.';

  @override
  String get importRefusedNoDate =>
      'Không có cột nào trong tệp đó đọc được như một ngày, nên không thể nhập.';

  @override
  String get importRefusedNoAmount =>
      'Không có cột nào trong tệp đó đọc được như một số tiền, nên không thể nhập.';

  @override
  String get importRefusedNoRows =>
      'Không có dòng nào trong tệp đó đọc được, nên không có gì để nhập.';

  @override
  String get importColumnsHeader => 'Cột';

  @override
  String get importColumnsSubtitle => 'Sửa lại những gì ứng dụng đọc sai.';

  @override
  String get importColumnNone => 'Không dùng';

  @override
  String get importFieldType => 'Loại';

  @override
  String get importFieldToAccount => 'Tài khoản nhận';

  @override
  String get importFieldTitle => 'Tiêu đề';

  @override
  String get importFieldNote => 'Ghi chú';

  @override
  String get importDateOrderLabel => 'Ngày dạng 03/04 nghĩa là';

  @override
  String get importDayFirst => 'Ngày trước';

  @override
  String get importMonthFirst => 'Tháng trước';

  @override
  String get importCountsHeader => 'Điều sẽ xảy ra';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sẽ nhập $count dòng',
      one: 'Sẽ nhập 1 dòng',
      zero: 'Sẽ không nhập gì',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dòng có ngày ứng dụng không đọc được',
      one: '1 dòng có ngày ứng dụng không đọc được',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dòng có số tiền ứng dụng không đọc được',
      one: '1 dòng có số tiền ứng dụng không đọc được',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dòng không có số tiền nào',
      one: '1 dòng không có số tiền nào',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dòng đã có trong ứng dụng',
      one: '1 dòng đã có trong ứng dụng',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count khoản chuyển chỉ nêu tên một tài khoản',
      one: '1 khoản chuyển chỉ nêu tên một tài khoản',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Không đọc được ngày';

  @override
  String get importRowUnreadableAmount => 'Không đọc được số tiền';

  @override
  String get importRowZero => 'Không có số tiền nào';

  @override
  String get importRowAlreadyThere => 'Đã có trong ứng dụng';

  @override
  String get importRowIncompleteTransfer => 'Chỉ nêu tên một tài khoản';

  @override
  String get importNamesHeader => 'Tên mà ứng dụng chưa có';

  @override
  String get importNamesSubtitle =>
      'Chọn mỗi tên sẽ trở thành gì. Nhập không bao giờ tạo danh mục hay tài khoản mới.';

  @override
  String get importRowsHeader =>
      'Các dòng đầu tiên, theo cách ứng dụng đọc được';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'và $count dòng nữa',
      one: 'và 1 dòng nữa',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nhập $count dòng',
      one: 'Nhập 1 dòng',
      zero: 'Không có gì để nhập',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nhập $count bản ghi',
      one: 'Đã nhập 1 bản ghi',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'Không thể nhập tệp đó. Không có gì được thêm.';

  @override
  String get attachmentsLabel => 'Tệp đính kèm';

  @override
  String get photoLabel => 'Ảnh';

  @override
  String get photoAdd => 'Thêm ảnh';

  @override
  String get photoTake => 'Chụp ảnh';

  @override
  String get photoChoose => 'Chọn ảnh';

  @override
  String get photoRemove => 'Gỡ ảnh';

  @override
  String get photoMissing => 'Ảnh này không còn nữa.';

  @override
  String get voiceNoteLabel => 'Ghi âm';

  @override
  String get voiceRecord => 'Ghi âm';

  @override
  String voiceRecording(int seconds) {
    return 'Đang ghi âm, còn $seconds giây';
  }

  @override
  String get voiceStop => 'Dừng';

  @override
  String get voicePlay => 'Phát';

  @override
  String get voicePause => 'Tạm dừng';

  @override
  String get voiceRemove => 'Gỡ bản ghi âm';

  @override
  String get voiceMissing => 'Bản ghi âm này không còn nữa.';

  @override
  String get microphoneRefused => 'Ứng dụng chưa được cấp quyền sử dụng micrô.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Bao gồm tệp đính kèm, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Ẩn mọi quảng cáo chỉ với một lần thanh toán. Gắn với tài khoản cửa hàng của bạn, nên vẫn còn khi đổi điện thoại hoặc cài lại ứng dụng.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Xóa quảng cáo với $price';
  }

  @override
  String get removeAdsOwned => 'Đã tắt quảng cáo. Cảm ơn bạn.';

  @override
  String get removeAdsPending => 'Đang chờ cửa hàng…';

  @override
  String get removeAdsUnavailable =>
      'Cửa hàng chưa có gì để bán ở đây. Vui lòng thử lại sau.';

  @override
  String get removeAdsFailed =>
      'Giao dịch không thành công và bạn chưa bị tính phí.';

  @override
  String get restorePurchasesButton => 'Khôi phục giao dịch mua';

  @override
  String get payNothingWithheld =>
      'Mọi tính năng đều miễn phí, dù có quảng cáo hay không.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Sắp ra mắt';

  @override
  String get plusBody =>
      'Kết nối ngân hàng để tự động lấy giao dịch cho bạn xác nhận. Tính năng chưa hoàn thiện nên chưa có gì để mua.';

  @override
  String get privacyOptionsTitle => 'Tùy chọn quyền riêng tư';

  @override
  String get privacyOptionsSubtitle =>
      'Thay đổi lựa chọn về quảng cáo được cá nhân hóa';

  @override
  String get dueEntryReminderTitle => 'Một mục đã đến hạn';

  @override
  String dueEntryReminderOne(String title) {
    return '$title đã đến hạn hôm nay và vẫn đang chờ.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'Một mục lặp lại đã đến hạn hôm nay và vẫn đang chờ.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Có $count mục lặp lại đến hạn hôm nay.',
      one: 'Có $count mục lặp lại đến hạn hôm nay.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Hôm nay chưa ghi gì';

  @override
  String get emptyDayReminderBody =>
      'Hãy thêm khoản chi trong khi bạn còn nhớ.';

  @override
  String get reminderLockedTitle => 'Có điều gì đó đang chờ';

  @override
  String get nudgeSettingsTitle => 'Nhắc tôi vào ngày trống';

  @override
  String get nudgeSettingsSubtitle =>
      'Một lời nhắc vào buổi tối, chỉ khi ngày đó chưa ghi gì.';

  @override
  String get nudgeOfferTitle => 'Nhắc bạn vào những ngày bạn quên?';

  @override
  String get nudgeOfferBody =>
      'Một lời nhắc vào thời điểm bạn chọn, chỉ khi ngày đó chưa ghi gì. Có thể tắt bất cứ lúc nào.';

  @override
  String get nudgeOfferYes => 'Có, nhắc tôi nhé';

  @override
  String get nudgeOfferNo => 'Không';

  @override
  String get nudgeStoppedNotice =>
      'Nhắc nhở đã dừng sau ba lần không phản hồi. Bật lại bất cứ khi nào bạn muốn.';

  @override
  String get nudgePermissionDenied =>
      'Bật thông báo trong cài đặt hệ thống để nhận nhắc nhở.';
}
