// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'سیٹنگز';

  @override
  String get transferTooltip => 'ٹرانسفر';

  @override
  String get searchTooltip => 'تلاش';

  @override
  String get addButton => 'شامل کریں';

  @override
  String get emptyPeriod => 'اس مدت میں ابھی کوئی ٹرانزیکشن نہیں۔';

  @override
  String get emptyPeriodFilteredByAccount =>
      'اس مدت میں اس اکاؤنٹ کے لیے کچھ نہیں۔';

  @override
  String get balanceLabel => 'بیلنس';

  @override
  String get expandSummaryTooltip => 'آمدنی اور اخراجات دکھائیں';

  @override
  String get collapseSummaryTooltip => 'صرف بیلنس دکھائیں';

  @override
  String get periodNetLabel => 'اس مدت';

  @override
  String carriedForwardLine(String amount) {
    return 'کیری فارورڈ $amount';
  }

  @override
  String get incomeLabel => 'آمدنی';

  @override
  String get expenseLabel => 'خرچ';

  @override
  String upcomingCategory(String category) {
    return '$category · آئندہ';
  }

  @override
  String get upcomingLabel => 'آئندہ';

  @override
  String detailAdded(String date) {
    return '$date کو شامل کیا گیا';
  }

  @override
  String detailChanged(String date) {
    return '$date کو آخری بار تبدیل کیا گیا';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تکراری ٹرانزیکشنز واجب الادا ہیں',
      one: '1 تکراری ٹرانزیکشن واجب الادا ہے',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent استعمال ہوا · $over حد سے تجاوز',
      one: '$percent استعمال ہوا · 1 حد سے تجاوز',
      zero: '$percent استعمال ہوا',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بجٹ مقرر',
      one: '1 بجٹ مقرر',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'ٹرانزیکشن حذف نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get transactionDeleted => 'ٹرانزیکشن حذف ہو گئی';

  @override
  String get transferDeleted => 'ٹرانسفر حذف ہو گیا';

  @override
  String get undoButton => 'واپس لیں';

  @override
  String get undoFailed => 'واپس نہیں لیا جا سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get restoreFailed => 'ٹرانزیکشن بحال نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get restoreTransferFailed =>
      'ٹرانسفر بحال نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get addTransactionTitle => 'ٹرانزیکشن شامل کریں';

  @override
  String get editTransactionTitle => 'ٹرانزیکشن میں ترمیم کریں';

  @override
  String get transactionDetailTitle => 'تفصیلات';

  @override
  String get editTooltip => 'ترمیم کریں';

  @override
  String get deleteTooltip => 'حذف کریں';

  @override
  String get duplicateTooltip => 'نقل بنائیں';

  @override
  String get rowMenuTooltip => 'مزید اختیارات';

  @override
  String get deleteTransactionTitle => 'یہ ٹرانزیکشن حذف کریں؟';

  @override
  String get deleteTransactionMessage =>
      'یہ ردی میں چلی جائے گی اور 30 دن تک بحال ہو سکتی ہے۔';

  @override
  String get discardChangesTitle => 'تبدیلیاں مسترد کریں؟';

  @override
  String get discardChangesMessage =>
      'آپ نے یہاں جو لکھا ہے وہ محفوظ نہیں ہوا۔';

  @override
  String get discardButton => 'مسترد کریں';

  @override
  String get keepEditingButton => 'ترمیم جاری رکھیں';

  @override
  String get titleOptionalLabel => 'عنوان (اختیاری)';

  @override
  String get amountLabel => 'رقم';

  @override
  String get amountRequired => 'رقم درج کریں';

  @override
  String get amountInvalid => 'درست رقم درج کریں';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'بیک اسپیس';

  @override
  String get hideKeypadTooltip => 'کی پیڈ چھپائیں';

  @override
  String get categoryLabel => 'کیٹیگری';

  @override
  String get categoryRequired => 'کیٹیگری منتخب کریں';

  @override
  String get accountLabel => 'اکاؤنٹ';

  @override
  String get accountRequired => 'اکاؤنٹ منتخب کریں';

  @override
  String get dateLabel => 'تاریخ';

  @override
  String get noteLabel => 'نوٹ';

  @override
  String get previousDayTooltip => 'پچھلا دن';

  @override
  String get nextDayTooltip => 'اگلا دن';

  @override
  String get noteOptionalLabel => 'نوٹ (اختیاری)';

  @override
  String get saveChangesButton => 'تبدیلیاں محفوظ کریں';

  @override
  String get addTransactionButton => 'ٹرانزیکشن شامل کریں';

  @override
  String get saveAndAddAnotherButton => 'محفوظ کریں اور نئی شامل کریں';

  @override
  String get transactionAdded => 'ٹرانزیکشن شامل ہو گئی';

  @override
  String get saveFailed => 'ٹرانزیکشن محفوظ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get noExpensesInPeriod => 'اس مدت میں ابھی کوئی خرچ نہیں۔';

  @override
  String totalSpent(String amount) {
    return 'کل خرچ: $amount';
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
  String get settingsTitle => 'سیٹنگز';

  @override
  String get drawerAddHeader => 'شامل کریں';

  @override
  String get drawerAddExpense => 'خرچ شامل کریں';

  @override
  String get drawerAddIncome => 'آمدنی شامل کریں';

  @override
  String get drawerPlanHeader => 'منصوبہ';

  @override
  String get drawerReviewHeader => 'جائزہ';

  @override
  String get drawerSpending => 'کیٹیگری کے مطابق خرچ';

  @override
  String get drawerManageHeader => 'انتظام';

  @override
  String get drawerDataHeader => 'ڈیٹا';

  @override
  String get currencyLabel => 'کرنسی';

  @override
  String get currencySearchHint => 'کرنسیاں تلاش کریں';

  @override
  String changeCurrencyTitle(String code) {
    return 'کرنسی $code میں تبدیل کریں؟';
  }

  @override
  String get changeCurrencyMessage =>
      'رقوم وہی رہیں گی؛ صرف ان کا کرنسی لیبل تبدیل ہوگا۔';

  @override
  String get changeButton => 'تبدیل کریں';

  @override
  String get cancelButton => 'منسوخ کریں';

  @override
  String get saveButton => 'محفوظ کریں';

  @override
  String get removeButton => 'ہٹائیں';

  @override
  String get themeLabel => 'تھیم';

  @override
  String get themeSystem => 'سسٹم';

  @override
  String get themeLight => 'لائٹ';

  @override
  String get themeDark => 'ڈارک';

  @override
  String get themeBlack => 'بلیک';

  @override
  String get languageLabel => 'زبان';

  @override
  String get languageSystem => 'سسٹم کی طے شدہ زبان';

  @override
  String get monthStartLabel => 'مہینے کا پہلا دن';

  @override
  String get monthStartLastDay => 'آخری دن';

  @override
  String get showCarriedForwardLabel => 'بیلنس کیری فارورڈ کریں';

  @override
  String get showCarriedForwardSubtitle => 'ہر مدت پچھلے بیلنس سے شروع ہوتی ہے';

  @override
  String get trashTitle => 'ٹریش';

  @override
  String get trashEmpty => 'ٹریش خالی ہے۔';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days دن میں ہمیشہ کے لیے حذف ہو جائے گا',
      one: '1 دن میں ہمیشہ کے لیے حذف ہو جائے گا',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days دن میں ہمیشہ کے لیے حذف ہو جائے گا',
      one: '1 دن میں ہمیشہ کے لیے حذف ہو جائے گا',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => 'بحال کریں';

  @override
  String get categoriesTitle => 'کیٹیگریز';

  @override
  String get addCategoryTooltip => 'کیٹیگری شامل کریں';

  @override
  String get addCategoryTitle => 'کیٹیگری شامل کریں';

  @override
  String get editCategoryTitle => 'کیٹیگری میں ترمیم کریں';

  @override
  String get categoryNameLabel => 'نام';

  @override
  String get categoryNameRequired => 'نام درج کریں';

  @override
  String get categoryNameTaken => 'یہ نام پہلے سے استعمال میں ہے';

  @override
  String get archiveAction => 'آرکائیو کریں';

  @override
  String get unarchiveAction => 'آرکائیو سے واپس لائیں';

  @override
  String get deleteAction => 'حذف کریں';

  @override
  String get archivedHeader => 'آرکائیو شدہ';

  @override
  String get accountsTotalLabel => 'کل';

  @override
  String get categorySaveFailed =>
      'کیٹیگری محفوظ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get accountsTitle => 'اکاؤنٹس';

  @override
  String get accountCash => 'نقدی';

  @override
  String get accountTypeLabel => 'قسم';

  @override
  String get accountTypeCash => 'نقدی';

  @override
  String get accountTypeBank => 'بینک';

  @override
  String get accountTypeCard => 'کارڈ';

  @override
  String get accountTypeOther => 'دیگر';

  @override
  String get addAccountTooltip => 'اکاؤنٹ شامل کریں';

  @override
  String get addAccountTitle => 'اکاؤنٹ شامل کریں';

  @override
  String get editAccountTitle => 'اکاؤنٹ میں ترمیم کریں';

  @override
  String get openingBalanceLabel => 'ابتدائی بیلنس';

  @override
  String get openingDateLabel => 'ابتدائی تاریخ';

  @override
  String get accountSaveFailed => 'اکاؤنٹ محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get transferTitle => 'ٹرانسفر';

  @override
  String get editTransferTitle => 'ٹرانسفر میں ترمیم کریں';

  @override
  String get transferLabel => 'ٹرانسفر';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'سے';

  @override
  String get toAccountLabel => 'کو';

  @override
  String get sameAccountError => 'دو مختلف اکاؤنٹس منتخب کریں';

  @override
  String get needTwoAccounts =>
      'اکاؤنٹس کے درمیان رقم منتقل کرنے کے لیے دوسرا اکاؤنٹ شامل کریں۔';

  @override
  String get addTransferButton => 'ٹرانسفر شامل کریں';

  @override
  String get transferSaveFailed =>
      'ٹرانسفر محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get searchHint => 'ٹرانزیکشنز تلاش کریں';

  @override
  String get allTypesFilter => 'تمام';

  @override
  String get allCategoriesFilter => 'تمام کیٹیگریز';

  @override
  String get allAccountsFilter => 'تمام اکاؤنٹس';

  @override
  String get allTimeFilter => 'ہر وقت';

  @override
  String get clearDatesTooltip => 'تاریخیں صاف کریں';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتائج',
      one: '1 نتیجہ',
    );
    return '$_temp0 · آمدنی $income · خرچ $expense';
  }

  @override
  String get noSearchResults => 'کوئی ملتی جلتی ٹرانزیکشن نہیں۔';

  @override
  String get budgetsTitle => 'بجٹس';

  @override
  String get budgetsTooltip => 'بجٹس';

  @override
  String get overallBudget => 'مجموعی';

  @override
  String get noBudget => 'کوئی بجٹ نہیں';

  @override
  String budgetsHint(String period) {
    return 'حدیں $period سے لاگو ہوں گی؛ پچھلی مدتیں اپنی حد برقرار رکھیں گی۔';
  }

  @override
  String get budgetLimitLabel => 'فی مدت حد';

  @override
  String get budgetSaveFailed => 'بجٹ محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$limit میں سے $spent';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining باقی · $perDay یومیہ';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount خرچ ہوئے · اب تک روزانہ $perDay';
  }

  @override
  String get homeSetBudget => 'ماہانہ بجٹ مقرر کریں';

  @override
  String budgetLeft(String remaining) {
    return '$remaining باقی';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount زیادہ خرچ ہوا';
  }

  @override
  String get budgetLimitReached => 'حد پوری ہو گئی';

  @override
  String budgetLimitOnly(String limit) {
    return 'حد $limit';
  }

  @override
  String get recurringTitle => 'تکراری';

  @override
  String get addRecurringTooltip => 'تکراری ٹرانزیکشن شامل کریں';

  @override
  String get addRecurringTitle => 'تکراری ٹرانزیکشن شامل کریں';

  @override
  String get editRecurringTitle => 'تکراری ٹرانزیکشن میں ترمیم کریں';

  @override
  String get dueHeader => 'واجب الادا';

  @override
  String get upcomingHeader => 'اگلے 30 دن';

  @override
  String get rulesHeader => 'قواعد';

  @override
  String billsPerMonth(String amount) {
    return 'بلوں میں ماہانہ $amount';
  }

  @override
  String nextBillToday(String title) {
    return 'اگلا: $title، آج';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'اگلا: $title، کل';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'اگلا: $title، $days دن میں',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'اگلے 30 دنوں میں کچھ نہیں۔';

  @override
  String get noRules => 'ابھی تک کوئی تکراری ٹرانزیکشن نہیں۔';

  @override
  String get recurringEmptyMessage =>
      'تکراری ٹرانزیکشنز آپ کے مقرر کردہ شیڈول پر کرایہ، تنخواہ یا سبسکرپشن درج کرتی ہیں، اور ہر ایک کی تصدیق کے لیے ٹیپ کا انتظار کرتی ہیں۔';

  @override
  String get addRecurringButton => 'تکراری ٹرانزیکشن شامل کریں';

  @override
  String get postButton => 'پوسٹ کریں';

  @override
  String get skipButton => 'چھوڑیں';

  @override
  String get postFailed => 'ٹرانزیکشن پوسٹ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get recurringSaveFailed =>
      'تکراری ٹرانزیکشن محفوظ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get recurringDeleted => 'تکراری ٹرانزیکشن حذف ہو گئی';

  @override
  String get everyLabel => 'ہر';

  @override
  String get frequencyDays => 'دن';

  @override
  String get frequencyWeeks => 'ہفتے';

  @override
  String get frequencyMonths => 'مہینے';

  @override
  String get frequencyYears => 'سال';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ہر $count دن',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'ہر روز';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ہر $count ہفتے',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'ہر ہفتہ';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ہر $count مہینے',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'ہر مہینہ';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ہر $count سال',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'ہر سال';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · موقوف';
  }

  @override
  String get startsLabel => 'شروع';

  @override
  String get endsLabel => 'ختم';

  @override
  String get endNever => 'کبھی نہیں';

  @override
  String get endAfter => 'بعد';

  @override
  String get endOnDate => 'تاریخ پر';

  @override
  String get timesLabel => 'دفعہ';

  @override
  String get endsOnLabel => 'اختتام کی تاریخ';

  @override
  String get wholeNumberInvalid => '1 سے پورا نمبر درج کریں';

  @override
  String wholeNumberRange(int max) {
    return '1 سے $max تک پورا عدد درج کریں';
  }

  @override
  String get endDateInvalid => 'اختتامی تاریخ شروع کی تاریخ کے بعد ہونی چاہیے';

  @override
  String get autoPostLabel => 'خودکار پوسٹ کریں';

  @override
  String get autoPostSubtitle =>
      'ورنہ یہ ٹیپ کے انتظار میں واجب الادا میں رہے گی';

  @override
  String get pauseTooltip => 'موقوف کریں';

  @override
  String get resumeTooltip => 'دوبارہ شروع کریں';

  @override
  String get categoryFood => 'کھانا';

  @override
  String get categoryGroceries => 'گروسری';

  @override
  String get categoryTransport => 'آمدورفت';

  @override
  String get categoryShopping => 'شاپنگ';

  @override
  String get categoryBills => 'بلز';

  @override
  String get categoryRent => 'کرایہ';

  @override
  String get categoryHealth => 'صحت';

  @override
  String get categoryEducation => 'تعلیم';

  @override
  String get categoryEntertainment => 'تفریح';

  @override
  String get categorySalary => 'تنخواہ';

  @override
  String get categoryBusiness => 'کاروبار';

  @override
  String get categoryInvestment => 'سرمایہ کاری';

  @override
  String get categoryGift => 'تحفہ';

  @override
  String get categoryOther => 'دیگر';

  @override
  String get previousPeriodTooltip => 'پچھلی مدت';

  @override
  String get wholePeriodTooltip => 'پوری مدت دکھائیں';

  @override
  String get nextPeriodTooltip => 'اگلی مدت';

  @override
  String get insightsTooltip => 'تجزیہ';

  @override
  String get insightsTitle => 'تجزیہ';

  @override
  String get calendarTab => 'کیلنڈر';

  @override
  String get trendTab => 'ٹرینڈ';

  @override
  String get noIncomeInPeriod => 'اس مدت میں ابھی کوئی آمدنی نہیں۔';

  @override
  String totalIncome(String amount) {
    return 'کل آمدنی: $amount';
  }

  @override
  String comparedMore(String amount) {
    return 'پچھلے مہینے سے $amount زیادہ';
  }

  @override
  String comparedLess(String amount) {
    return 'پچھلے مہینے سے $amount کم';
  }

  @override
  String get comparedSame => 'پچھلے مہینے جیسا';

  @override
  String get categoryNewLabel => 'نیا';

  @override
  String get calendarHint => 'کسی دن کی ٹرانزیکشنز دیکھنے کے لیے اسے ٹیپ کریں۔';

  @override
  String get dayEmpty => 'اس دن کچھ نہیں۔';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مہینے',
      one: '1 مہینہ',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'آمدنی $income · خرچ $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'فی مدت اوسط · آمدنی $income · خرچ $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'ٹرینڈ کے لیے ایک سے زیادہ مدت درکار ہے۔ اگلے مہینے واپس آئیں۔';

  @override
  String get weekStartLabel => 'ہفتے کا پہلا دن';

  @override
  String weekStartDefault(String day) {
    return 'طے شدہ ($day)';
  }

  @override
  String get firstRunTitle => 'Monthly Expenses میں خوش آمدید';

  @override
  String get firstRunMessage =>
      'اپنا خرچ اور آمدنی ٹریک کریں۔ آپ کا ڈیٹا اسی ڈیوائس پر رہتا ہے۔';

  @override
  String get addFirstTransactionButton => 'اپنی پہلی ٹرانزیکشن شامل کریں';

  @override
  String get setupIntro =>
      'اپنی زبان اور کرنسی منتخب کریں۔ آپ انہیں بعد میں سیٹنگز میں تبدیل کر سکتے ہیں۔';

  @override
  String get setupContinueButton => 'جاری رکھیں';

  @override
  String get setupRestoreTitle => 'بیک اپ بحال کریں';

  @override
  String get setupRestoreSubtitle =>
      'بیک اپ فائل سے اپنا ڈیٹا اور سیٹنگز واپس لائیں';

  @override
  String get walkthroughEntryTitle => 'سیکنڈوں میں اندراج';

  @override
  String get walkthroughEntryBody =>
      'خود جمع کرنے والا کی پیڈ، رسید کی تصویر، اور ٹائپنگ سست ہو تو صوتی نوٹ۔';

  @override
  String get walkthroughPlanTitle => 'مہینے کا منصوبہ بنائیں';

  @override
  String get walkthroughPlanBody =>
      'کیٹیگری کے مطابق بجٹ، خود دہرائے جانے والے بل، اور یاد دلانے والے نوٹس۔';

  @override
  String get walkthroughInsightsTitle => 'دیکھیں پیسہ کہاں جاتا ہے';

  @override
  String get walkthroughInsightsBody =>
      'چارٹس، کیلنڈر، اور کسی بھی مدت کے لیے PDF یا CSV رپورٹ۔';

  @override
  String get walkthroughPrivacyTitle => 'صرف آپ کا اپنا';

  @override
  String get walkthroughPrivacyBody =>
      'کوئی اکاؤنٹ نہیں۔ آپ کا ریکارڈ اسی فون میں محفوظ رہتا ہے؛ ایپ کو چلانے والے اشتہارات اسے کبھی نہیں دیکھتے۔';

  @override
  String get walkthroughBringTitle => 'جو آپ کے پاس ہے وہ لائیں';

  @override
  String get walkthroughBringBody =>
      'کسی اور ایپ یا فون سے آ رہے ہیں؟ خالی ایپ کی بجائے بیک اپ یا CSV سے شروع کریں۔';

  @override
  String get firstRunRestoreTitle => 'یہ بیک اپ بحال کریں؟';

  @override
  String get firstRunRestoreMessage =>
      'یہ ایپ میں موجود ہر چیز کی جگہ لے لے گا، اور جس زبان اور کرنسی کے ساتھ یہ محفوظ ہوا تھا وہ واپس لے آئے گا۔';

  @override
  String get walkthroughNextButton => 'اگلا';

  @override
  String get walkthroughStartButton => 'شروع کریں';

  @override
  String get walkthroughDoneButton => 'ہو گیا';

  @override
  String walkthroughProgress(int current, int total) {
    return 'صفحہ $current از $total';
  }

  @override
  String get walkthroughReplayTitle => 'واک تھرو دوبارہ دیکھیں';

  @override
  String get walkthroughReplaySubtitle =>
      'وہ چار صفحات جو ایپ نئی ہونے پر دکھائے گئے تھے';

  @override
  String get removeAdsTitle => 'اشتہارات ہٹائیں';

  @override
  String get exportCsvMenu => 'CSV ایکسپورٹ کریں';

  @override
  String get exportCsvTooltip => 'CSV ایکسپورٹ کریں';

  @override
  String get csvExported => 'CSV محفوظ ہو گئی';

  @override
  String get csvExportFailed => 'CSV ایکسپورٹ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get backupTitle => 'بیک اپ اور بحالی';

  @override
  String get backupIntro =>
      'بیک اپ وہ فائلیں ہیں جو آپ اپنی پسند کی جگہ محفوظ کرتے ہیں۔ کچھ بھی خودکار طور پر اپ لوڈ یا بھیجا نہیں جاتا۔';

  @override
  String get backUpNowTitle => 'ابھی بیک اپ لیں';

  @override
  String lastBackupLine(String date) {
    return 'آخری بیک اپ $date';
  }

  @override
  String get neverBackedUp => 'ابھی تک کوئی بیک اپ نہیں';

  @override
  String get backupSaved => 'بیک اپ محفوظ ہو گیا';

  @override
  String get backupSaveFailed => 'بیک اپ محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get restoreFromFileTitle => 'فائل سے بحال کریں';

  @override
  String get restoreFromFileSubtitle =>
      'بیک اپ کو اپنے ڈیٹا کے ساتھ ضم کریں، یا اپنا ڈیٹا اس سے تبدیل کریں';

  @override
  String get backupReminderLabel => 'بیک اپ یاد دہانی';

  @override
  String get backupReminderSubtitle => '20 ٹرانزیکشنز کے بعد ہر 30 دن میں';

  @override
  String get backupReminderNever => 'اپنا ڈیٹا محفوظ رکھنے کے لیے بیک اپ لیں';

  @override
  String backupReminderSince(String date) {
    return 'آخری بیک اپ $date۔ نیا بیک اپ لینے کا وقت ہے؟';
  }

  @override
  String get notNowTooltip => 'ابھی نہیں';

  @override
  String get keptBackupsHeader => 'خودکار بیک اپس';

  @override
  String get keptBackupsHint => 'ہر بحالی سے پہلے اسی ڈیوائس پر محفوظ کیے گئے۔';

  @override
  String get noKeptBackups => 'ابھی تک کوئی نہیں۔';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ٹرانزیکشنز',
      one: '1 ٹرانزیکشن',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'بیک اپ بحال کریں';

  @override
  String get mergeOption => 'ضم کریں';

  @override
  String get mergeOptionSubtitle =>
      'اپنا ڈیٹا رکھیں اور بیک اپ کا ڈیٹا بھی شامل کریں۔ جہاں دونوں میں ایک ہی ریکارڈ ہو، نئی تبدیلی برتری لے گی۔';

  @override
  String get replaceOption => 'تبدیل کریں';

  @override
  String get replaceOptionSubtitle =>
      'اپنا ڈیٹا حذف کریں اور صرف بیک اپ استعمال کریں، اس کی سیٹنگز سمیت۔';

  @override
  String get restoreSafetyNote =>
      'آپ کے موجودہ ڈیٹا کی ایک کاپی پہلے خودکار بیک اپس میں محفوظ کی جاتی ہے۔';

  @override
  String get restoreButton => 'بحال کریں';

  @override
  String get restoreKeptTitle => 'یہ کاپی بحال کریں؟';

  @override
  String restoreKeptMessage(String date) {
    return 'آپ کا ڈیٹا $date کی کاپی سے تبدیل ہو جائے گا۔ آپ کے موجودہ ڈیٹا کی کاپی پہلے محفوظ کی جاتی ہے۔';
  }

  @override
  String get backupInvalid => 'یہ فائل Monthly Expenses کا بیک اپ نہیں ہے۔';

  @override
  String get backupTooNew =>
      'یہ بیک اپ ایپ کے نئے ورژن سے ہے۔ ایپ کو اپ ڈیٹ کر کے دوبارہ کوشش کریں۔';

  @override
  String get backupOpenFailed => 'فائل نہیں کھل سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get backupRestoreFailed =>
      'بیک اپ بحال نہیں ہو سکا۔ آپ کا ڈیٹا تبدیل نہیں ہوا۔';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ٹرانزیکشنز بحال ہوئیں',
      one: '1 ٹرانزیکشن بحال ہوئی',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'ضم ہو گیا: $added شامل، $updated اپ ڈیٹ، $unchanged غیر تبدیل شدہ';
  }

  @override
  String get appLockLabel => 'ایپ لاک';

  @override
  String get appLockSubtitle => 'اپنے فنگر پرنٹ، چہرے، یا اسکرین لاک سے کھولیں';

  @override
  String get appLockUnavailable =>
      'ایپ لاک استعمال کرنے کے لیے اس ڈیوائس پر اسکرین لاک سیٹ کریں';

  @override
  String get appLockReason => 'Monthly Expenses کھولیں';

  @override
  String get appLockPromptHint => 'اپنی شناخت کی تصدیق کریں';

  @override
  String get appLockFailed =>
      'آپ کی تصدیق نہیں ہو سکی۔ ایپ لاک تبدیل نہیں ہوا۔';

  @override
  String get lockedTitle => 'Monthly Expenses مقفل ہے';

  @override
  String get unlockButton => 'کھولیں';

  @override
  String get widgetShowAmountsLabel => 'ویجٹ پر رقوم دکھائیں';

  @override
  String get widgetShowAmountsSubtitle =>
      'ایپ لاک آن ہونے پر ہوم اسکرین ویجٹ انہیں چھپا دیتا ہے';

  @override
  String get widgetLeftLabel => 'باقی';

  @override
  String get widgetAddExpense => 'خرچ شامل کریں';

  @override
  String get widgetAddIncome => 'آمدنی شامل کریں';

  @override
  String get widgetAmountsHidden => 'رقوم ایپ لاک کی وجہ سے چھپی ہوئی ہیں';

  @override
  String get notesTitle => 'نوٹس';

  @override
  String get addNoteTooltip => 'نوٹ شامل کریں';

  @override
  String get addNoteTitle => 'نوٹ شامل کریں';

  @override
  String get editNoteTitle => 'نوٹ میں ترمیم کریں';

  @override
  String get noteTextLabel => 'نوٹ';

  @override
  String get noteTextRequired => 'کچھ متن درج کریں';

  @override
  String get noteAmountOptionalLabel => 'رقم (اختیاری)';

  @override
  String get noteDueDateToggle => 'واجب الادا تاریخ مقرر کریں';

  @override
  String get noteDueDateLabel => 'واجب الادا تاریخ';

  @override
  String get noteReminderToggle => 'مجھے یاد دلائیں';

  @override
  String get noteReminderTimeLabel => 'یاد دہانی کا وقت';

  @override
  String get noteReminderTimeUnset => 'وقت منتخب کریں';

  @override
  String get reminderMayBeLate => 'آپ کا فون یہ چند منٹ دیر سے بھیج سکتا ہے۔';

  @override
  String get noteCategoryOptionalLabel => 'کیٹیگری (اختیاری)';

  @override
  String get noteCategoryNone => 'کوئی نہیں';

  @override
  String get recordNoteButton => 'ٹرانزیکشن کے طور پر ریکارڈ کریں';

  @override
  String get noteMarkDoneTooltip => 'مکمل نشان زد کریں';

  @override
  String get noteMarkOpenTooltip => 'کھلا نشان زد کریں';

  @override
  String get notesEmptyTitle => 'ابھی یہاں کچھ نہیں';

  @override
  String get notesEmptyMessage =>
      'نوٹس آپ کو کرنے یا چیک کرنے والی چیزیں یاد دلاتے ہیں، ساتھ میں اختیاری تاریخ، رقم اور کیٹیگری کے ساتھ۔';

  @override
  String get addNoteButton => 'نوٹ شامل کریں';

  @override
  String get notesOpenHeader => 'کھلے';

  @override
  String get notesDoneHeader => 'مکمل';

  @override
  String get noteDeleted => 'نوٹ حذف ہو گیا۔';

  @override
  String get noteSaveFailed => 'نوٹ محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get noteDeleteFailed => 'نوٹ حذف نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get noteRestoreFailed => 'نوٹ بحال نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get notesSearchHint => 'نوٹس تلاش کریں';

  @override
  String get noteFilterAll => 'تمام';

  @override
  String get noteFilterOverdue => 'میعاد گزشتہ';

  @override
  String get noteFilterDueToday => 'آج واجب الادا';

  @override
  String get noteFilterUpcoming => 'آئندہ';

  @override
  String get noteFilterNoDate => 'بغیر تاریخ';

  @override
  String get noNoteResults => 'کوئی ملتا جلتا نوٹ نہیں۔';

  @override
  String get noteLinkedTransactionLabel => 'ٹرانزیکشن کے طور پر ریکارڈ ہوا';

  @override
  String get noteLinkedNoteLabel => 'ایک نوٹ سے';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نوٹس واجب الادا ہیں',
      one: '1 نوٹ واجب الادا ہے',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'واجب الادا نوٹس';

  @override
  String get noteReminderTitle => 'نوٹ یاد دہانی';

  @override
  String get noteReminderLockedTitle => 'ایک نوٹ واجب الادا ہے';

  @override
  String get noteReminderChannelName => 'نوٹ کی یاد دہانیاں';

  @override
  String get noteReminderPermissionDenied =>
      'نوٹس کی یاد دہانیاں پانے کے لیے سسٹم سیٹنگز میں اطلاعات آن کریں۔';

  @override
  String reportRange(String from, String to) {
    return '$from سے $to تک';
  }

  @override
  String reportCreated(String when) {
    return '$when کو بنائی گئی';
  }

  @override
  String reportNarrowedTo(String description) {
    return 'محدود بہ: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'صفحہ $page از $pages';
  }

  @override
  String get reportNet => 'خالص';

  @override
  String get reportMatchingIncome => 'مطابق آمدنی';

  @override
  String get reportMatchingExpense => 'مطابق خرچ';

  @override
  String get reportMatchingNet => 'مطابق خالص';

  @override
  String get reportOpeningBalance => 'ابتدائی بیلنس';

  @override
  String get reportClosingBalance => 'اختتامی بیلنس';

  @override
  String get reportSpendingHeader => 'کیٹیگری کے مطابق خرچ';

  @override
  String get reportEarningHeader => 'کیٹیگری کے مطابق آمدنی';

  @override
  String get reportTrendHeader => 'ٹرینڈ';

  @override
  String get reportEntriesHeader => 'ٹرانزیکشنز';

  @override
  String get reportUpcomingHeader => 'آئندہ';

  @override
  String get reportUpcomingNote =>
      'آگے کی تاریخ کی، اس لیے اوپر کے کل میں شمار نہیں کی گئی۔';

  @override
  String get reportAmountColumn => 'رقم';

  @override
  String get reportShareColumn => 'حصہ';

  @override
  String get reportBudgetColumn => 'بجٹ';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$limit میں سے $used';
  }

  @override
  String get reportDetailsColumn => 'تفصیلات';

  @override
  String get reportEmpty => 'ان تاریخوں کے لیے رپورٹ کرنے کو کچھ نہیں۔';

  @override
  String get exportPdfMenu => 'PDF ایکسپورٹ کریں';

  @override
  String get reportTitle => 'PDF ایکسپورٹ کریں';

  @override
  String get reportNoFontTitle => 'اس زبان میں ابھی نہیں';

  @override
  String get reportNoFontBody =>
      'رپورٹ کے لیے اس رسم الخط کا فونٹ درکار ہے، اور چینی، جاپانی اور کوریائی فونٹ ایپ میں رکھنے کے لیے بہت بڑے ہیں۔ آئندہ ورژن میں انہیں ڈاؤن لوڈ کیا جا سکے گا۔';

  @override
  String get reportPreviewTitle => 'رپورٹ';

  @override
  String get reportCoversHeader => 'یہ کیا شامل کرتی ہے';

  @override
  String get reportNarrowedNotice => 'یہ رپورٹ آپ کی تلاش تک محدود رہتی ہے۔';

  @override
  String get reportRangePeriod => 'اس مدت';

  @override
  String get reportRangeCustom => 'تاریخیں';

  @override
  String get reportRangeYear => 'سال';

  @override
  String get reportFromLabel => 'سے';

  @override
  String get reportToLabel => 'تک';

  @override
  String get reportYearLabel => 'سال';

  @override
  String get reportAccountLabel => 'اکاؤنٹ';

  @override
  String get reportAllAccounts => 'تمام اکاؤنٹس';

  @override
  String get reportIncludeHeader => 'یہ کیا شامل رکھتی ہے';

  @override
  String get reportIncludeSubtitle =>
      'جو کچھ آپ شیئر نہیں کرنا چاہتے وہ چھوڑ دیں۔';

  @override
  String get reportIncludeTransactions => 'ٹرانزیکشنز کی فہرست';

  @override
  String get reportIncludeDetails => 'عنوانات اور نوٹس';

  @override
  String get reportIncludeAccounts => 'اکاؤنٹ کے نام';

  @override
  String get reportCreateButton => 'رپورٹ بنائیں';

  @override
  String get reportBuilding => 'رپورٹ بن رہی ہے';

  @override
  String get reportFailed => 'رپورٹ نہیں بن سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get reportRangeBackwards =>
      'پہلی تاریخ آخری تاریخ سے پہلے ہونی چاہیے۔';

  @override
  String get importTitle => 'CSV امپورٹ کریں';

  @override
  String get importSubtitle => 'کسی اور ایپ سے ٹرانزیکشنز لائیں';

  @override
  String get importIntro =>
      'ایک CSV فائل منتخب کریں اور کچھ بھی شامل ہونے سے پہلے دیکھیں کہ ایپ نے اسے کیسے سمجھا۔ امپورٹ صرف ریکارڈز شامل کرتا ہے — یہ کبھی آپ کا موجودہ ڈیٹا تبدیل یا حذف نہیں کرتا۔';

  @override
  String get importChooseFile => 'فائل منتخب کریں';

  @override
  String get importChooseAnother => 'دوسری فائل منتخب کریں';

  @override
  String get importReadFailed => 'وہ فائل پڑھی نہیں جا سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get importRefusedEmpty => 'اس فائل میں کچھ نہیں ہے۔';

  @override
  String get importRefusedNoDate =>
      'اس فائل میں کوئی کالم تاریخ کے طور پر نہیں پڑھا جا سکا، اس لیے اسے امپورٹ نہیں کیا جا سکتا۔';

  @override
  String get importRefusedNoAmount =>
      'اس فائل میں کوئی کالم رقم کے طور پر نہیں پڑھا جا سکا، اس لیے اسے امپورٹ نہیں کیا جا سکتا۔';

  @override
  String get importRefusedNoRows =>
      'اس فائل کی کوئی قطار نہیں پڑھی جا سکی، اس لیے امپورٹ کرنے کو کچھ نہیں۔';

  @override
  String get importColumnsHeader => 'کالمز';

  @override
  String get importColumnsSubtitle => 'جو کچھ ایپ نے غلط پڑھا اسے تبدیل کریں۔';

  @override
  String get importColumnNone => 'استعمال نہیں ہوا';

  @override
  String get importFieldType => 'قسم';

  @override
  String get importFieldToAccount => 'منزل اکاؤنٹ';

  @override
  String get importFieldTitle => 'عنوان';

  @override
  String get importFieldNote => 'نوٹ';

  @override
  String get importDateOrderLabel => '03/04 جیسی تاریخوں کا مطلب ہے';

  @override
  String get importDayFirst => 'پہلے دن';

  @override
  String get importMonthFirst => 'پہلے مہینہ';

  @override
  String get importCountsHeader => 'کیا ہوگا';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطاریں امپورٹ ہوں گی',
      one: '1 قطار امپورٹ ہوگی',
      zero: 'کچھ بھی امپورٹ نہیں ہوگا',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطاروں کی تاریخ ایپ نہیں پڑھ سکتی',
      one: '1 قطار کی تاریخ ایپ نہیں پڑھ سکتی',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطاروں کی رقم ایپ نہیں پڑھ سکتی',
      one: '1 قطار کی رقم ایپ نہیں پڑھ سکتی',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطاروں میں کوئی رقم نہیں ہے',
      one: '1 قطار میں کوئی رقم نہیں ہے',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطاریں پہلے سے ایپ میں موجود ہیں',
      one: '1 قطار پہلے سے ایپ میں موجود ہے',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ٹرانسفرز میں صرف ایک اکاؤنٹ کا نام ہے',
      one: '1 ٹرانسفر میں صرف ایک اکاؤنٹ کا نام ہے',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'تاریخ نہیں پڑھی جا سکتی';

  @override
  String get importRowUnreadableAmount => 'رقم نہیں پڑھی جا سکتی';

  @override
  String get importRowZero => 'کوئی رقم نہیں';

  @override
  String get importRowAlreadyThere => 'پہلے سے ایپ میں موجود';

  @override
  String get importRowIncompleteTransfer => 'صرف ایک اکاؤنٹ کا نام دیا گیا';

  @override
  String get importNamesHeader => 'وہ نام جو اس ایپ میں نہیں ہیں';

  @override
  String get importNamesSubtitle =>
      'ہر ایک کے لیے منتخب کریں کہ وہ کیا بنے گا۔ امپورٹ کبھی نئی کیٹیگری یا اکاؤنٹ نہیں بناتا۔';

  @override
  String get importRowsHeader => 'پہلی قطاریں، جیسے ایپ نے انہیں پڑھا';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اور $count مزید',
      one: 'اور 1 مزید',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطاریں امپورٹ کریں',
      one: '1 قطار امپورٹ کریں',
      zero: 'امپورٹ کرنے کو کچھ نہیں',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ریکارڈز امپورٹ ہوئے',
      one: '1 ریکارڈ امپورٹ ہوا',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'وہ فائل امپورٹ نہیں ہو سکی۔ کچھ بھی شامل نہیں ہوا۔';

  @override
  String get attachmentsLabel => 'اٹیچمنٹس';

  @override
  String get photoLabel => 'تصویر';

  @override
  String get photoAdd => 'تصویر شامل کریں';

  @override
  String get photoTake => 'تصویر لیں';

  @override
  String get photoChoose => 'تصویر منتخب کریں';

  @override
  String get photoRemove => 'تصویر ہٹائیں';

  @override
  String get photoMissing => 'یہ تصویر موجود نہیں ہے۔';

  @override
  String get voiceNoteLabel => 'صوتی نوٹ';

  @override
  String get voiceRecord => 'صوتی نوٹ ریکارڈ کریں';

  @override
  String voiceRecording(int seconds) {
    return 'ریکارڈ ہو رہا ہے، $seconds سیکنڈ باقی';
  }

  @override
  String get voiceStop => 'روکیں';

  @override
  String get voicePlay => 'چلائیں';

  @override
  String get voicePause => 'موقوف کریں';

  @override
  String get voiceRemove => 'صوتی نوٹ ہٹائیں';

  @override
  String get voiceMissing => 'یہ صوتی نوٹ موجود نہیں ہے۔';

  @override
  String get microphoneRefused => 'اس ایپ کے لیے مائیکروفون بند ہے۔';

  @override
  String backupIncludesAttachments(String size) {
    return 'اٹیچمنٹس شامل ہیں، $size MB';
  }

  @override
  String get removeAdsBody =>
      'ایک ادائیگی میں تمام اشتہارات چھپا دیتا ہے۔ یہ آپ کے اسٹور اکاؤنٹ سے جڑا ہوتا ہے، اس لیے نیا فون لینے یا دوبارہ انسٹال کرنے پر بھی برقرار رہتا ہے۔';

  @override
  String removeAdsBuyButton(String price) {
    return '$price میں اشتہارات ہٹائیں';
  }

  @override
  String get removeAdsOwned => 'اشتہارات بند ہیں۔ شکریہ۔';

  @override
  String get removeAdsPending => 'اسٹور کے جواب کا انتظار ہے…';

  @override
  String get removeAdsUnavailable =>
      'اسٹور پر ابھی کچھ خریدنے کے لیے موجود نہیں۔ براہ کرم بعد میں دوبارہ کوشش کریں۔';

  @override
  String get removeAdsFailed =>
      'یہ کارروائی مکمل نہیں ہوئی، اور آپ سے کوئی رقم نہیں لی گئی۔';

  @override
  String get restorePurchasesButton => 'خریداریاں بحال کریں';

  @override
  String get payNothingWithheld =>
      'اشتہارات ہوں یا نہ ہوں، تمام خصوصیات مفت رہتی ہیں۔';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'جلد آ رہا ہے';

  @override
  String get plusBody =>
      'ایک بینک کنکشن جو آپ کے لین دین لا کر تصدیق کے لیے دکھاتا ہے۔ یہ ابھی مکمل نہیں، اس لیے خریدنے کو کچھ نہیں۔';

  @override
  String get privacyOptionsTitle => 'رازداری کے اختیارات';

  @override
  String get privacyPolicyTitle => 'رازداری کی پالیسی';

  @override
  String get privacyOptionsSubtitle =>
      'ذاتی نوعیت کے اشتہارات کے بارے میں اپنی پسند تبدیل کریں';

  @override
  String get dueEntryReminderTitle => 'ایک اندراج واجب تھا';

  @override
  String get dueEntryChannelName => 'تاخیر شدہ اندراجات';

  @override
  String dueEntryReminderOne(String title) {
    return '$title آج واجب الادا تھا اور اب بھی زیر التوا ہے۔';
  }

  @override
  String get dueEntryReminderUntitled =>
      'ایک تکراری اندراج آج واجب الادا تھا اور اب بھی زیر التوا ہے۔';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تکراری اندراجات آج واجب الادا تھے۔',
      one: '1 تکراری اندراج آج واجب الادا تھا۔',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'آج کچھ بھی درج نہیں ہوا';

  @override
  String get emptyDayChannelName => 'بلا اندراج دن';

  @override
  String get emptyDayReminderBody => 'جب تک یاد ہے، اپنا خرچ درج کر لیں۔';

  @override
  String get reminderLockedTitle => 'کچھ آپ کا منتظر ہے';

  @override
  String get nudgeSettingsTitle => 'خالی دن مجھے یاد دلائیں';

  @override
  String get nudgeSettingsSubtitle =>
      'شام کو ایک یاد دہانی، اور صرف اس دن جب کچھ بھی درج نہ ہو۔';

  @override
  String get nudgeOfferTitle => 'جن دنوں آپ بھول جاتے ہیں، یاد دہانی؟';

  @override
  String get nudgeOfferBody =>
      'آپ کے وقت پر ایک یاد دہانی، صرف خالی دن میں۔ جب چاہیں بند کر دیں۔';

  @override
  String get nudgeOfferYes => 'جی ہاں، یاد دلائیں';

  @override
  String get nudgeOfferNo => 'نہیں شکریہ';

  @override
  String get nudgeStoppedNotice =>
      'تین بار جواب نہ ملنے پر یاد دہانیاں بند ہو گئیں۔ جب چاہیں دوبارہ آن کریں۔';

  @override
  String get nudgePermissionDenied =>
      'یاد دہانیاں پانے کے لیے سسٹم سیٹنگز میں اطلاعات آن کریں۔';

  @override
  String get updateDownloadedMessage => 'ایک اپ ڈیٹ ڈاؤن لوڈ ہو چکا ہے۔';

  @override
  String get updateRestartButton => 'دوبارہ شروع کریں';
}
