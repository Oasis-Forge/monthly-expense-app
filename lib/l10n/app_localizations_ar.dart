// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'الإعدادات';

  @override
  String get transferTooltip => 'تحويل';

  @override
  String get searchTooltip => 'بحث';

  @override
  String get addButton => 'إضافة';

  @override
  String get emptyPeriod => 'لا توجد معاملات في هذه الفترة بعد.';

  @override
  String get balanceLabel => 'الرصيد';

  @override
  String get expandSummaryTooltip => 'عرض الدخل والمصروفات';

  @override
  String get collapseSummaryTooltip => 'عرض الرصيد فقط';

  @override
  String get periodNetLabel => 'هذه الفترة';

  @override
  String carriedForwardLine(String amount) {
    return 'رصيد مُرحّل $amount';
  }

  @override
  String get incomeLabel => 'الدخل';

  @override
  String get expenseLabel => 'المصروفات';

  @override
  String upcomingCategory(String category) {
    return '$category · قادمة';
  }

  @override
  String get upcomingLabel => 'قادم';

  @override
  String detailAdded(String date) {
    return 'أُضيف في $date';
  }

  @override
  String detailChanged(String date) {
    return 'آخر تعديل في $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة متكررة مستحقة',
      many: '$count معاملة متكررة مستحقة',
      few: '$count معاملات متكررة مستحقة',
      two: 'معاملتان متكررتان مستحقتان',
      one: 'معاملة متكررة واحدة مستحقة',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: 'استُخدم $percent · $over ميزانية متجاوزة',
      many: 'استُخدم $percent · $over ميزانية متجاوزة',
      few: 'استُخدم $percent · $over ميزانيات متجاوزة',
      two: 'استُخدم $percent · ميزانيتان متجاوزتان',
      one: 'استُخدم $percent · ميزانية متجاوزة',
      zero: 'استُخدم $percent',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ميزانية محددة',
      many: '$count ميزانية محددة',
      few: '$count ميزانيات محددة',
      two: 'ميزانيتان محددتان',
      one: 'ميزانية واحدة محددة',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'تعذّر حذف المعاملة. حاول مرة أخرى.';

  @override
  String get transactionDeleted => 'تم حذف المعاملة';

  @override
  String get transferDeleted => 'تم حذف التحويل';

  @override
  String get undoButton => 'تراجع';

  @override
  String get undoFailed => 'تعذّر التراجع. حاول مرة أخرى.';

  @override
  String get restoreFailed => 'تعذّرت استعادة المعاملة. حاول مرة أخرى.';

  @override
  String get restoreTransferFailed => 'تعذّرت استعادة التحويل. حاول مرة أخرى.';

  @override
  String get addTransactionTitle => 'إضافة معاملة';

  @override
  String get editTransactionTitle => 'تعديل المعاملة';

  @override
  String get transactionDetailTitle => 'التفاصيل';

  @override
  String get editTooltip => 'تعديل';

  @override
  String get deleteTooltip => 'حذف';

  @override
  String get duplicateTooltip => 'تكرار';

  @override
  String get rowMenuTooltip => 'خيارات أخرى';

  @override
  String get deleteTransactionTitle => 'حذف هذه المعاملة؟';

  @override
  String get deleteTransactionMessage =>
      'تنتقل إلى المحذوفات، ويمكن استعادتها خلال ٣٠ يومًا.';

  @override
  String get discardChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get discardChangesMessage => 'ما كتبته هنا لم يُحفظ.';

  @override
  String get discardButton => 'تجاهل';

  @override
  String get keepEditingButton => 'متابعة التعديل';

  @override
  String get titleOptionalLabel => 'العنوان (اختياري)';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get amountRequired => 'أدخل مبلغًا';

  @override
  String get amountInvalid => 'أدخل مبلغًا صالحًا';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'مسح';

  @override
  String get hideKeypadTooltip => 'إخفاء لوحة الأرقام';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get categoryRequired => 'اختر فئة';

  @override
  String get accountLabel => 'الحساب';

  @override
  String get accountRequired => 'اختر حسابًا';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get noteLabel => 'ملاحظة';

  @override
  String get previousDayTooltip => 'اليوم السابق';

  @override
  String get nextDayTooltip => 'اليوم التالي';

  @override
  String get noteOptionalLabel => 'ملاحظة (اختياري)';

  @override
  String get saveChangesButton => 'حفظ التغييرات';

  @override
  String get addTransactionButton => 'إضافة المعاملة';

  @override
  String get saveAndAddAnotherButton => 'حفظ وإضافة أخرى';

  @override
  String get transactionAdded => 'تمت إضافة المعاملة';

  @override
  String get saveFailed => 'تعذّر حفظ المعاملة. حاول مرة أخرى.';

  @override
  String get noExpensesInPeriod => 'لا توجد مصروفات في هذه الفترة بعد.';

  @override
  String totalSpent(String amount) {
    return 'إجمالي الإنفاق: $amount';
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
  String get settingsTitle => 'الإعدادات';

  @override
  String get drawerAddHeader => 'إضافة';

  @override
  String get drawerAddExpense => 'إضافة مصروف';

  @override
  String get drawerAddIncome => 'إضافة دخل';

  @override
  String get drawerPlanHeader => 'تخطيط';

  @override
  String get drawerReviewHeader => 'مراجعة';

  @override
  String get drawerSpending => 'الإنفاق حسب الفئة';

  @override
  String get drawerManageHeader => 'إدارة';

  @override
  String get drawerDataHeader => 'البيانات';

  @override
  String get currencyLabel => 'العملة';

  @override
  String get currencySearchHint => 'ابحث عن عملة';

  @override
  String changeCurrencyTitle(String code) {
    return 'تغيير العملة إلى $code؟';
  }

  @override
  String get changeCurrencyMessage =>
      'تبقى المبالغ كما هي؛ يتغير رمز العملة فقط.';

  @override
  String get changeButton => 'تغيير';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveButton => 'حفظ';

  @override
  String get removeButton => 'إزالة';

  @override
  String get themeLabel => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeBlack => 'أسود';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get monthStartLabel => 'أول يوم في الشهر';

  @override
  String get monthStartLastDay => 'آخر يوم';

  @override
  String get showCarriedForwardLabel => 'ترحيل الرصيد';

  @override
  String get showCarriedForwardSubtitle => 'تبدأ كل فترة من الرصيد السابق';

  @override
  String get trashTitle => 'المحذوفات';

  @override
  String get trashEmpty => 'لا توجد عناصر محذوفة.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'يُحذف نهائيًا خلال $days يوم',
      many: 'يُحذف نهائيًا خلال $days يومًا',
      few: 'يُحذف نهائيًا خلال $days أيام',
      two: 'يُحذف نهائيًا خلال يومين',
      one: 'يُحذف نهائيًا خلال يوم واحد',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'يُحذف نهائيًا خلال $days يوم',
      many: 'يُحذف نهائيًا خلال $days يومًا',
      few: 'يُحذف نهائيًا خلال $days أيام',
      two: 'يُحذف نهائيًا خلال يومين',
      one: 'يُحذف نهائيًا خلال يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => 'استعادة';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get addCategoryTooltip => 'إضافة فئة';

  @override
  String get addCategoryTitle => 'إضافة فئة';

  @override
  String get editCategoryTitle => 'تعديل الفئة';

  @override
  String get categoryNameLabel => 'الاسم';

  @override
  String get categoryNameRequired => 'أدخل اسمًا';

  @override
  String get categoryNameTaken => 'هذا الاسم مستخدم بالفعل';

  @override
  String get archiveAction => 'أرشفة';

  @override
  String get unarchiveAction => 'إلغاء الأرشفة';

  @override
  String get deleteAction => 'حذف';

  @override
  String get archivedHeader => 'المؤرشفة';

  @override
  String get accountsTotalLabel => 'الإجمالي';

  @override
  String get categorySaveFailed => 'تعذّر حفظ الفئة. حاول مرة أخرى.';

  @override
  String get accountsTitle => 'الحسابات';

  @override
  String get accountCash => 'نقدًا';

  @override
  String get accountTypeLabel => 'النوع';

  @override
  String get accountTypeCash => 'نقد';

  @override
  String get accountTypeBank => 'بنك';

  @override
  String get accountTypeCard => 'بطاقة';

  @override
  String get accountTypeOther => 'أخرى';

  @override
  String get addAccountTooltip => 'إضافة حساب';

  @override
  String get addAccountTitle => 'إضافة حساب';

  @override
  String get editAccountTitle => 'تعديل الحساب';

  @override
  String get openingBalanceLabel => 'الرصيد الافتتاحي';

  @override
  String get openingDateLabel => 'تاريخ الافتتاح';

  @override
  String get accountSaveFailed => 'تعذّر حفظ الحساب. حاول مرة أخرى.';

  @override
  String get transferTitle => 'تحويل';

  @override
  String get editTransferTitle => 'تعديل التحويل';

  @override
  String get transferLabel => 'تحويل';

  @override
  String transferRoute(String from, String to) {
    return '$from ← $to';
  }

  @override
  String get fromAccountLabel => 'من';

  @override
  String get toAccountLabel => 'إلى';

  @override
  String get sameAccountError => 'اختر حسابين مختلفين';

  @override
  String get needTwoAccounts => 'أضف حسابًا ثانيًا لنقل الأموال بين الحسابات.';

  @override
  String get addTransferButton => 'إضافة التحويل';

  @override
  String get transferSaveFailed => 'تعذّر حفظ التحويل. حاول مرة أخرى.';

  @override
  String get searchHint => 'ابحث في المعاملات';

  @override
  String get allTypesFilter => 'الكل';

  @override
  String get allCategoriesFilter => 'كل الفئات';

  @override
  String get allAccountsFilter => 'كل الحسابات';

  @override
  String get allTimeFilter => 'كل الأوقات';

  @override
  String get clearDatesTooltip => 'مسح التواريخ';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
    );
    return '$_temp0 · الدخل $income · المصروفات $expense';
  }

  @override
  String get noSearchResults => 'لا توجد معاملات مطابقة.';

  @override
  String get budgetsTitle => 'الميزانيات';

  @override
  String get budgetsTooltip => 'الميزانيات';

  @override
  String get overallBudget => 'الإجمالية';

  @override
  String get noBudget => 'بلا ميزانية';

  @override
  String budgetsHint(String period) {
    return 'تُطبَّق الحدود بدءًا من $period، وتحتفظ الفترات السابقة بحدودها.';
  }

  @override
  String get budgetLimitLabel => 'الحد لكل فترة';

  @override
  String get budgetSaveFailed => 'تعذّر حفظ الميزانية. حاول مرة أخرى.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent من $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'المتبقي $remaining · $perDay يوميًا';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'أُنفق $amount · $perDay يوميًا حتى الآن';
  }

  @override
  String get homeSetBudget => 'حدد ميزانية شهرية';

  @override
  String budgetLeft(String remaining) {
    return 'المتبقي $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'تجاوز بمقدار $amount';
  }

  @override
  String get budgetLimitReached => 'تم بلوغ الحد';

  @override
  String budgetLimitOnly(String limit) {
    return 'الحد $limit';
  }

  @override
  String get recurringTitle => 'المتكررة';

  @override
  String get addRecurringTooltip => 'إضافة معاملة متكررة';

  @override
  String get addRecurringTitle => 'إضافة معاملة متكررة';

  @override
  String get editRecurringTitle => 'تعديل المعاملة المتكررة';

  @override
  String get dueHeader => 'المستحقة';

  @override
  String get upcomingHeader => 'الأيام الثلاثون القادمة';

  @override
  String get rulesHeader => 'القواعد';

  @override
  String billsPerMonth(String amount) {
    return '$amount شهريًا للفواتير';
  }

  @override
  String nextBillToday(String title) {
    return 'التالي: $title، اليوم';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'التالي: $title، غدًا';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'التالي: $title، خلال $days يوم',
      many: 'التالي: $title، خلال $days يومًا',
      few: 'التالي: $title، خلال $days أيام',
      two: 'التالي: $title، خلال يومين',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'لا شيء في الأيام الثلاثين القادمة.';

  @override
  String get noRules => 'لا توجد معاملات متكررة بعد.';

  @override
  String get recurringEmptyMessage =>
      'تسجّل المعاملات المتكررة الإيجار أو الراتب أو الاشتراك في الموعد الذي تحدده، وتنتظر نقرة لتأكيد كل مرة.';

  @override
  String get addRecurringButton => 'إضافة معاملة متكررة';

  @override
  String get postButton => 'تسجيل';

  @override
  String get skipButton => 'تخطٍّ';

  @override
  String get postFailed => 'تعذّر تسجيل المعاملة. حاول مرة أخرى.';

  @override
  String get recurringSaveFailed =>
      'تعذّر حفظ المعاملة المتكررة. حاول مرة أخرى.';

  @override
  String get recurringDeleted => 'تم حذف المعاملة المتكررة';

  @override
  String get everyLabel => 'كل';

  @override
  String get frequencyDays => 'أيام';

  @override
  String get frequencyWeeks => 'أسابيع';

  @override
  String get frequencyMonths => 'أشهر';

  @override
  String get frequencyYears => 'سنوات';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count يوم',
      many: 'كل $count يومًا',
      few: 'كل $count أيام',
      two: 'كل يومين',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'كل يوم';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count أسبوع',
      many: 'كل $count أسبوعًا',
      few: 'كل $count أسابيع',
      two: 'كل أسبوعين',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'كل أسبوع';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count شهر',
      many: 'كل $count شهرًا',
      few: 'كل $count أشهر',
      two: 'كل شهرين',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'كل شهر';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count سنة',
      many: 'كل $count سنة',
      few: 'كل $count سنوات',
      two: 'كل سنتين',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'كل سنة';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · متوقفة مؤقتًا';
  }

  @override
  String get startsLabel => 'تبدأ';

  @override
  String get endsLabel => 'تنتهي';

  @override
  String get endNever => 'أبدًا';

  @override
  String get endAfter => 'بعد';

  @override
  String get endOnDate => 'في تاريخ';

  @override
  String get timesLabel => 'مرات';

  @override
  String get endsOnLabel => 'تنتهي في';

  @override
  String get wholeNumberInvalid => 'أدخل عددًا صحيحًا من 1 فأكثر';

  @override
  String wholeNumberRange(int max) {
    return 'أدخل عددًا صحيحًا من 1 إلى $max';
  }

  @override
  String get endDateInvalid => 'يجب أن يكون تاريخ الانتهاء بعد البداية';

  @override
  String get autoPostLabel => 'تسجيل تلقائي';

  @override
  String get autoPostSubtitle => 'وإلا فستنتظر في المستحقة حتى تنقر عليها';

  @override
  String get pauseTooltip => 'إيقاف مؤقت';

  @override
  String get resumeTooltip => 'استئناف';

  @override
  String get categoryFood => 'طعام';

  @override
  String get categoryGroceries => 'بقالة';

  @override
  String get categoryTransport => 'مواصلات';

  @override
  String get categoryShopping => 'تسوّق';

  @override
  String get categoryBills => 'فواتير';

  @override
  String get categoryRent => 'إيجار';

  @override
  String get categoryHealth => 'صحة';

  @override
  String get categoryEducation => 'تعليم';

  @override
  String get categoryEntertainment => 'ترفيه';

  @override
  String get categorySalary => 'راتب';

  @override
  String get categoryBusiness => 'أعمال';

  @override
  String get categoryInvestment => 'استثمار';

  @override
  String get categoryGift => 'هدية';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get previousPeriodTooltip => 'الفترة السابقة';

  @override
  String get wholePeriodTooltip => 'عرض الفترة كاملة';

  @override
  String get nextPeriodTooltip => 'الفترة التالية';

  @override
  String get insightsTooltip => 'التحليلات';

  @override
  String get insightsTitle => 'التحليلات';

  @override
  String get calendarTab => 'التقويم';

  @override
  String get trendTab => 'الاتجاه';

  @override
  String get noIncomeInPeriod => 'لا يوجد دخل في هذه الفترة بعد.';

  @override
  String totalIncome(String amount) {
    return 'إجمالي الدخل: $amount';
  }

  @override
  String comparedMore(String amount) {
    return '$amount أكثر من الشهر الماضي';
  }

  @override
  String comparedLess(String amount) {
    return '$amount أقل من الشهر الماضي';
  }

  @override
  String get comparedSame => 'مثل الشهر الماضي';

  @override
  String get categoryNewLabel => 'جديد';

  @override
  String get calendarHint => 'انقر على يوم لعرض معاملاته.';

  @override
  String get dayEmpty => 'لا شيء في هذا اليوم.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شهر',
      many: '$count شهرًا',
      few: '$count أشهر',
      two: 'شهران',
      one: 'شهر واحد',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'الدخل $income · المصروفات $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'المتوسط لكل فترة · الدخل $income · المصروفات $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'يحتاج الاتجاه إلى أكثر من فترة واحدة. عُد الشهر القادم.';

  @override
  String get weekStartLabel => 'أول يوم في الأسبوع';

  @override
  String weekStartDefault(String day) {
    return 'الافتراضي ($day)';
  }

  @override
  String get firstRunTitle => 'مرحبًا بك في Monthly Expenses';

  @override
  String get firstRunMessage =>
      'تابع ما تنفقه وما تكسبه. تبقى بياناتك على هذا الجهاز.';

  @override
  String get addFirstTransactionButton => 'أضف معاملتك الأولى';

  @override
  String get setupIntro =>
      'اختر لغتك وعملتك. يمكنك تغييرهما لاحقًا من الإعدادات.';

  @override
  String get setupContinueButton => 'متابعة';

  @override
  String get setupRestoreTitle => 'استعادة نسخة احتياطية';

  @override
  String get setupRestoreSubtitle =>
      'أعد بياناتك وإعداداتك من ملف نسخة احتياطية';

  @override
  String get walkthroughEntryTitle => 'أضف في ثوانٍ';

  @override
  String get walkthroughEntryBody =>
      'لوحة أرقام تحسب المجموع، وصورة للإيصال، وملاحظة صوتية حين تكون الكتابة بطيئة.';

  @override
  String get walkthroughPlanTitle => 'خطّط للشهر';

  @override
  String get walkthroughPlanBody =>
      'ميزانيات لكل فئة، وفواتير تتكرر من تلقاء نفسها، وملاحظات تذكّرك.';

  @override
  String get walkthroughInsightsTitle => 'اعرف أين تذهب نقودك';

  @override
  String get walkthroughInsightsBody =>
      'رسوم بيانية وتقويم وتقرير PDF أو CSV لأي فترة.';

  @override
  String get walkthroughPrivacyTitle => 'لك وحدك';

  @override
  String get walkthroughPrivacyBody =>
      'لا حاجة لحساب. ما تسجّله يبقى على هذا الهاتف، ولا تراه الإعلانات التي تموّل التطبيق أبدًا.';

  @override
  String get walkthroughBringTitle => 'أحضر ما لديك';

  @override
  String get walkthroughBringBody =>
      'أتنتقل من تطبيق آخر أو هاتف آخر؟ ابدأ من نسخة احتياطية أو ملف CSV بدل تطبيق فارغ.';

  @override
  String get firstRunRestoreTitle => 'أتريد استعادة هذه النسخة الاحتياطية؟';

  @override
  String get firstRunRestoreMessage =>
      'ستحل محل كل ما في التطبيق، وتعيد اللغة والعملة المحفوظتين فيها.';

  @override
  String get walkthroughNextButton => 'التالي';

  @override
  String get walkthroughStartButton => 'لنبدأ';

  @override
  String get walkthroughDoneButton => 'تم';

  @override
  String walkthroughProgress(int current, int total) {
    return 'الصفحة $current من $total';
  }

  @override
  String get walkthroughReplayTitle => 'إعادة عرض الجولة';

  @override
  String get walkthroughReplaySubtitle =>
      'الصفحات الأربع التي ظهرت عند تثبيت التطبيق';

  @override
  String get removeAdsTitle => 'إزالة الإعلانات';

  @override
  String get exportCsvMenu => 'تصدير CSV';

  @override
  String get exportCsvTooltip => 'تصدير CSV';

  @override
  String get csvExported => 'تم حفظ ملف CSV';

  @override
  String get csvExportFailed => 'تعذّر تصدير ملف CSV. حاول مرة أخرى.';

  @override
  String get backupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupIntro =>
      'النسخ الاحتياطية ملفات تحفظها حيث تختار. لا يُرفع أي شيء ولا يُرسل تلقائيًا.';

  @override
  String get backUpNowTitle => 'نسخ احتياطي الآن';

  @override
  String lastBackupLine(String date) {
    return 'آخر نسخة احتياطية $date';
  }

  @override
  String get neverBackedUp => 'لا توجد نسخة احتياطية بعد';

  @override
  String get backupSaved => 'تم حفظ النسخة الاحتياطية';

  @override
  String get backupSaveFailed => 'تعذّر حفظ النسخة الاحتياطية. حاول مرة أخرى.';

  @override
  String get restoreFromFileTitle => 'الاستعادة من ملف';

  @override
  String get restoreFromFileSubtitle =>
      'ادمج نسخة احتياطية مع بياناتك، أو استبدل بياناتك بها';

  @override
  String get backupReminderLabel => 'تذكير النسخ الاحتياطي';

  @override
  String get backupReminderSubtitle => 'كل 30 يومًا بعد تسجيل 20 معاملة';

  @override
  String get backupReminderNever => 'انسخ بياناتك احتياطيًا للحفاظ عليها';

  @override
  String backupReminderSince(String date) {
    return 'آخر نسخة احتياطية $date. هل حان وقت نسخة جديدة؟';
  }

  @override
  String get notNowTooltip => 'ليس الآن';

  @override
  String get keptBackupsHeader => 'النسخ الاحتياطية التلقائية';

  @override
  String get keptBackupsHint => 'تُحفظ على هذا الجهاز قبل كل استعادة.';

  @override
  String get noKeptBackups => 'لا يوجد بعد.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة',
      many: '$count معاملة',
      few: '$count معاملات',
      two: 'معاملتان',
      one: 'معاملة واحدة',
      zero: 'لا توجد معاملات',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'استعادة النسخة الاحتياطية';

  @override
  String get mergeOption => 'دمج';

  @override
  String get mergeOptionSubtitle =>
      'احتفظ ببياناتك وأضف بيانات النسخة. عندما يوجد السجل في الجهتين، يُعتمد التغيير الأحدث.';

  @override
  String get replaceOption => 'استبدال';

  @override
  String get replaceOptionSubtitle =>
      'احذف بياناتك واستخدم النسخة الاحتياطية وحدها مع إعداداتها.';

  @override
  String get restoreSafetyNote =>
      'تُحفظ أولًا نسخة من بياناتك الحالية ضمن النسخ الاحتياطية التلقائية.';

  @override
  String get restoreButton => 'استعادة';

  @override
  String get restoreKeptTitle => 'استعادة هذه النسخة؟';

  @override
  String restoreKeptMessage(String date) {
    return 'ستُستبدل بياناتك بالنسخة المؤرخة $date. تُحفظ نسخة من بياناتك الحالية أولًا.';
  }

  @override
  String get backupInvalid =>
      'هذا الملف ليس نسخة احتياطية من Monthly Expenses.';

  @override
  String get backupTooNew =>
      'هذه النسخة الاحتياطية من إصدار أحدث من التطبيق. حدّث التطبيق ثم حاول مرة أخرى.';

  @override
  String get backupOpenFailed => 'تعذّر فتح الملف. حاول مرة أخرى.';

  @override
  String get backupRestoreFailed =>
      'تعذّرت استعادة النسخة الاحتياطية. لم تتغير بياناتك.';

  @override
  String get dbTooNewTitle => 'التحديث مطلوب';

  @override
  String get dbTooNewMessage =>
      'تم حفظ هذه البيانات بواسطة إصدار أحدث من التطبيق. حدّثه من المتجر للمتابعة.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت استعادة $count معاملة',
      many: 'تمت استعادة $count معاملة',
      few: 'تمت استعادة $count معاملات',
      two: 'تمت استعادة معاملتين',
      one: 'تمت استعادة معاملة واحدة',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'تم الدمج: أُضيف $added، وحُدِّث $updated، ولم يتغير $unchanged';
  }

  @override
  String get appLockLabel => 'قفل التطبيق';

  @override
  String get appLockSubtitle => 'افتح القفل ببصمتك أو وجهك أو قفل الشاشة';

  @override
  String get appLockUnavailable =>
      'اضبط قفل شاشة على هذا الجهاز لاستخدام قفل التطبيق';

  @override
  String get appLockReason => 'افتح قفل Monthly Expenses';

  @override
  String get appLockPromptHint => 'تأكيد الهوية';

  @override
  String get appLockFailed => 'تعذّر التحقق من هويتك. لم يتغير قفل التطبيق.';

  @override
  String get lockedTitle => 'Monthly Expenses مقفل';

  @override
  String get unlockButton => 'فتح القفل';

  @override
  String get widgetShowAmountsLabel => 'إظهار المبالغ في الأداة';

  @override
  String get widgetShowAmountsSubtitle =>
      'تخفي أداة الشاشة الرئيسية المبالغ عندما يكون قفل التطبيق مفعّلاً';

  @override
  String get widgetLeftLabel => 'المتبقي';

  @override
  String get widgetAddExpense => 'إضافة مصروف';

  @override
  String get widgetAddIncome => 'إضافة دخل';

  @override
  String get widgetAmountsHidden => 'المبالغ مخفية بقفل التطبيق';

  @override
  String get notesTitle => 'الملاحظات';

  @override
  String get addNoteTooltip => 'إضافة ملاحظة';

  @override
  String get addNoteTitle => 'إضافة ملاحظة';

  @override
  String get editNoteTitle => 'تعديل الملاحظة';

  @override
  String get noteTextLabel => 'الملاحظة';

  @override
  String get noteTextRequired => 'أدخل نصًا';

  @override
  String get noteAmountOptionalLabel => 'المبلغ (اختياري)';

  @override
  String get noteDueDateToggle => 'تحديد تاريخ استحقاق';

  @override
  String get noteDueDateLabel => 'تاريخ الاستحقاق';

  @override
  String get noteReminderToggle => 'ذكّرني';

  @override
  String get noteReminderTimeLabel => 'وقت التذكير';

  @override
  String get noteReminderTimeUnset => 'اختر وقتًا';

  @override
  String get reminderMayBeLate => 'قد يوصّل هاتفك هذا متأخرًا ببضع دقائق.';

  @override
  String get noteCategoryOptionalLabel => 'الفئة (اختياري)';

  @override
  String get noteCategoryNone => 'بلا';

  @override
  String get recordNoteButton => 'تسجيل كمعاملة';

  @override
  String get noteMarkDoneTooltip => 'وضع علامة تم';

  @override
  String get noteMarkOpenTooltip => 'وضع علامة مفتوح';

  @override
  String get notesEmptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get notesEmptyMessage =>
      'تُستخدم الملاحظات لتذكّر أمور يجب فعلها أو التحقق منها، مع تاريخ ومبلغ وفئة اختيارية.';

  @override
  String get addNoteButton => 'إضافة ملاحظة';

  @override
  String get notesOpenHeader => 'مفتوحة';

  @override
  String get notesDoneHeader => 'منجزة';

  @override
  String get noteDeleted => 'تم حذف الملاحظة.';

  @override
  String get noteSaveFailed => 'تعذّر حفظ الملاحظة. حاول مرة أخرى.';

  @override
  String get noteDeleteFailed => 'تعذّر حذف الملاحظة. حاول مرة أخرى.';

  @override
  String get noteRestoreFailed => 'تعذّرت استعادة الملاحظة. حاول مرة أخرى.';

  @override
  String get notesSearchHint => 'البحث في الملاحظات';

  @override
  String get noteFilterAll => 'الكل';

  @override
  String get noteFilterOverdue => 'متأخرة';

  @override
  String get noteFilterDueToday => 'مستحقة اليوم';

  @override
  String get noteFilterUpcoming => 'قادمة';

  @override
  String get noteFilterNoDate => 'بلا تاريخ';

  @override
  String get noNoteResults => 'لا توجد ملاحظات مطابقة.';

  @override
  String get noteLinkedTransactionLabel => 'سُجّلت كمعاملة';

  @override
  String get noteLinkedNoteLabel => 'من ملاحظة';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاحظة مستحقة',
      many: '$count ملاحظة مستحقة',
      few: '$count ملاحظات مستحقة',
      two: 'ملاحظتان مستحقتان',
      one: 'ملاحظة واحدة مستحقة',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'الملاحظات المستحقة';

  @override
  String get noteReminderTitle => 'تذكير بملاحظة';

  @override
  String get noteReminderLockedTitle => 'هناك ملاحظة مستحقة';

  @override
  String get noteReminderChannelName => 'تذكيرات بالملاحظات';

  @override
  String get noteReminderPermissionDenied =>
      'فعّل الإشعارات من إعدادات النظام لتلقي تذكيرات الملاحظات.';

  @override
  String reportRange(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String reportCreated(String when) {
    return 'أُنشئ في $when';
  }

  @override
  String reportNarrowedTo(String description) {
    return 'مقتصر على: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'صفحة $page من $pages';
  }

  @override
  String get reportNet => 'الصافي';

  @override
  String get reportMatchingIncome => 'الدخل المطابق';

  @override
  String get reportMatchingExpense => 'المصروف المطابق';

  @override
  String get reportMatchingNet => 'الصافي المطابق';

  @override
  String get reportOpeningBalance => 'الرصيد الافتتاحي';

  @override
  String get reportClosingBalance => 'الرصيد الختامي';

  @override
  String get reportSpendingHeader => 'الإنفاق حسب الفئة';

  @override
  String get reportEarningHeader => 'الدخل حسب الفئة';

  @override
  String get reportTrendHeader => 'الاتجاه';

  @override
  String get reportEntriesHeader => 'المعاملات';

  @override
  String get reportUpcomingHeader => 'القادمة';

  @override
  String get reportUpcomingNote =>
      'مؤرخة لاحقًا، لذا لا تُحتسب ضمن الإجماليات أعلاه.';

  @override
  String get reportAmountColumn => 'المبلغ';

  @override
  String get reportShareColumn => 'النسبة';

  @override
  String get reportBudgetColumn => 'الميزانية';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used من $limit';
  }

  @override
  String get reportDetailsColumn => 'التفاصيل';

  @override
  String get reportEmpty => 'لا شيء لعرضه في هذه التواريخ.';

  @override
  String get exportPdfMenu => 'تصدير PDF';

  @override
  String get reportTitle => 'تصدير PDF';

  @override
  String get reportNoFontTitle => 'غير متاح بهذه اللغة بعد';

  @override
  String get reportNoFontBody =>
      'يحتاج التقرير إلى خط لنظام كتابته، وخطوط الصينية واليابانية والكورية أكبر من أن يحملها التطبيق. سيعرض إصدار لاحق تنزيلها.';

  @override
  String get reportPreviewTitle => 'التقرير';

  @override
  String get reportCoversHeader => 'ما يشمله';

  @override
  String get reportNarrowedNotice => 'يظل هذا التقرير مقتصرًا على بحثك.';

  @override
  String get reportRangePeriod => 'هذه الفترة';

  @override
  String get reportRangeCustom => 'تواريخ';

  @override
  String get reportRangeYear => 'سنة';

  @override
  String get reportFromLabel => 'من';

  @override
  String get reportToLabel => 'إلى';

  @override
  String get reportYearLabel => 'السنة';

  @override
  String get reportAccountLabel => 'الحساب';

  @override
  String get reportAllAccounts => 'كل الحسابات';

  @override
  String get reportIncludeHeader => 'ما يتضمنه';

  @override
  String get reportIncludeSubtitle => 'استبعد أي شيء تفضل عدم مشاركته.';

  @override
  String get reportIncludeTransactions => 'قائمة المعاملات';

  @override
  String get reportIncludeDetails => 'العناوين والملاحظات';

  @override
  String get reportIncludeAccounts => 'أسماء الحسابات';

  @override
  String get reportCreateButton => 'إنشاء التقرير';

  @override
  String get reportBuilding => 'جارٍ إنشاء التقرير';

  @override
  String get reportFailed => 'تعذّر إنشاء التقرير. حاول مرة أخرى.';

  @override
  String get reportRangeBackwards =>
      'يجب أن يسبق التاريخ الأول التاريخ الأخير.';

  @override
  String get importTitle => 'استيراد ملف CSV';

  @override
  String get importSubtitle => 'أحضر معاملاتك من تطبيق آخر';

  @override
  String get importIntro =>
      'اختر ملف CSV وسترى ما فهمه التطبيق منه قبل إضافة أي شيء. الاستيراد يضيف السجلات فقط — ولا يستبدل أو يحذف ما لديك أبدًا.';

  @override
  String get importChooseFile => 'اختيار ملف';

  @override
  String get importChooseAnother => 'اختيار ملف آخر';

  @override
  String get importReadFailed => 'تعذّرت قراءة هذا الملف. حاول مرة أخرى.';

  @override
  String get importRefusedEmpty => 'لا يوجد شيء في هذا الملف.';

  @override
  String get importRefusedNoDate =>
      'لم يُقرأ أي عمود في هذا الملف كتاريخ، لذا لا يمكن استيراده.';

  @override
  String get importRefusedNoAmount =>
      'لم يُقرأ أي عمود في هذا الملف كمبلغ، لذا لا يمكن استيراده.';

  @override
  String get importRefusedNoRows =>
      'لم تُقرأ أي صفوف في هذا الملف، لذا لا يوجد ما يُستورد.';

  @override
  String get importColumnsHeader => 'الأعمدة';

  @override
  String get importColumnsSubtitle => 'غيّر أي شيء قرأه التطبيق بشكل خاطئ.';

  @override
  String get importColumnNone => 'غير مستخدم';

  @override
  String get importFieldType => 'النوع';

  @override
  String get importFieldToAccount => 'الحساب الوجهة';

  @override
  String get importFieldTitle => 'العنوان';

  @override
  String get importFieldNote => 'ملاحظة';

  @override
  String get importDateOrderLabel => 'تواريخ مثل 03/04 تعني';

  @override
  String get importDayFirst => 'اليوم أولًا';

  @override
  String get importMonthFirst => 'الشهر أولًا';

  @override
  String get importCountsHeader => 'ما الذي سيحدث';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيُستورد $count صف',
      many: 'سيُستورد $count صفًا',
      few: 'ستُستورد $count صفوف',
      two: 'سيُستورد صفان',
      one: 'سيُستورد صف واحد',
      zero: 'لن يُستورد أي شيء',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف يحمل تاريخًا لا يستطيع التطبيق قراءته',
      many: '$count صفًا تحمل تاريخًا لا يستطيع التطبيق قراءته',
      few: '$count صفوف تحمل تاريخًا لا يستطيع التطبيق قراءته',
      two: 'صفان يحملان تاريخًا لا يستطيع التطبيق قراءته',
      one: 'صف واحد يحمل تاريخًا لا يستطيع التطبيق قراءته',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف يحمل مبلغًا لا يستطيع التطبيق قراءته',
      many: '$count صفًا تحمل مبلغًا لا يستطيع التطبيق قراءته',
      few: '$count صفوف تحمل مبلغًا لا يستطيع التطبيق قراءته',
      two: 'صفان يحملان مبلغًا لا يستطيع التطبيق قراءته',
      one: 'صف واحد يحمل مبلغًا لا يستطيع التطبيق قراءته',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف بلا أي مبلغ',
      many: '$count صفًا بلا أي مبلغ',
      few: '$count صفوف بلا أي مبلغ',
      two: 'صفان بلا أي مبلغ',
      one: 'صف واحد بلا أي مبلغ',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف موجود في التطبيق بالفعل',
      many: '$count صفًا موجودة في التطبيق بالفعل',
      few: '$count صفوف موجودة في التطبيق بالفعل',
      two: 'صفان موجودان في التطبيق بالفعل',
      one: 'صف واحد موجود في التطبيق بالفعل',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تحويل يذكر حسابًا واحدًا فقط',
      many: '$count تحويلًا تذكر حسابًا واحدًا فقط',
      few: '$count تحويلات تذكر حسابًا واحدًا فقط',
      two: 'تحويلان يذكران حسابًا واحدًا فقط',
      one: 'تحويل واحد يذكر حسابًا واحدًا فقط',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'تعذّرت قراءة التاريخ';

  @override
  String get importRowUnreadableAmount => 'تعذّرت قراءة المبلغ';

  @override
  String get importRowZero => 'بلا أي مبلغ';

  @override
  String get importRowAlreadyThere => 'موجود في التطبيق بالفعل';

  @override
  String get importRowIncompleteTransfer => 'حساب واحد فقط مذكور';

  @override
  String get importNamesHeader => 'أسماء لا يملكها هذا التطبيق';

  @override
  String get importNamesSubtitle =>
      'اختر ما يصبح عليه كل اسم. الاستيراد لا ينشئ فئة أو حسابًا أبدًا.';

  @override
  String get importRowsHeader => 'الصفوف الأولى، كما قرأها التطبيق';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'و$count أخرى',
      many: 'و$count أخرى',
      few: 'و$count أخرى',
      two: 'واثنان آخران',
      one: 'وواحد آخر',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استيراد $count صف',
      many: 'استيراد $count صفًا',
      few: 'استيراد $count صفوف',
      two: 'استيراد صفين',
      one: 'استيراد صف واحد',
      zero: 'لا شيء لاستيراده',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count سجل',
      many: 'تم استيراد $count سجلًا',
      few: 'تم استيراد $count سجلات',
      two: 'تم استيراد سجلين',
      one: 'تم استيراد سجل واحد',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'تعذّر استيراد هذا الملف. لم تتم إضافة أي شيء.';

  @override
  String get attachmentsLabel => 'المرفقات';

  @override
  String get photoLabel => 'صورة';

  @override
  String get photoAdd => 'إضافة صورة';

  @override
  String get photoTake => 'التقاط صورة';

  @override
  String get photoChoose => 'اختيار صورة';

  @override
  String get photoRemove => 'إزالة الصورة';

  @override
  String get photoMissing => 'هذه الصورة غير موجودة.';

  @override
  String get voiceNoteLabel => 'ملاحظة صوتية';

  @override
  String get voiceRecord => 'تسجيل ملاحظة صوتية';

  @override
  String voiceRecording(int seconds) {
    return 'جارٍ التسجيل، بقي $seconds ث';
  }

  @override
  String get voiceStop => 'إيقاف';

  @override
  String get voicePlay => 'تشغيل';

  @override
  String get voicePause => 'إيقاف مؤقت';

  @override
  String get voiceRemove => 'إزالة الملاحظة الصوتية';

  @override
  String get voiceMissing => 'هذه الملاحظة الصوتية غير موجودة.';

  @override
  String get microphoneRefused => 'الميكروفون معطّل لهذا التطبيق.';

  @override
  String backupIncludesAttachments(String size) {
    return 'يشمل المرفقات، $size ميجابايت';
  }

  @override
  String get removeAdsBody =>
      'يُخفي كل الإعلانات بدفعة واحدة. يرتبط بحساب متجرك، فيعود مع هاتف جديد أو إعادة التثبيت.';

  @override
  String removeAdsBuyButton(String price) {
    return 'إزالة الإعلانات مقابل $price';
  }

  @override
  String get removeAdsOwned => 'الإعلانات متوقفة. شكرًا لك.';

  @override
  String get removeAdsPending => 'بانتظار المتجر…';

  @override
  String get removeAdsUnavailable =>
      'لا يوجد شيء للبيع هنا حاليًا. يُرجى المحاولة لاحقًا.';

  @override
  String get removeAdsFailed => 'لم تتم العملية، ولم يُخصم منك أي مبلغ.';

  @override
  String get restorePurchasesButton => 'استعادة عمليات الشراء';

  @override
  String get payNothingWithheld =>
      'تبقى جميع الميزات مجانية، مع الإعلانات أو بدونها.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'قريبًا';

  @override
  String get plusBody =>
      'ربط مع البنك يجلب معاملاتك لتأكيدها. لم يكتمل بعد، فلا يوجد شيء للشراء حاليًا.';

  @override
  String get privacyOptionsTitle => 'خيارات الخصوصية';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyOptionsSubtitle => 'غيّر اختيارك بشأن الإعلانات المخصصة';

  @override
  String get dueEntryReminderTitle => 'إدخال متكرر مستحق';

  @override
  String get dueEntryChannelName => 'إدخالات مستحقة';

  @override
  String dueEntryReminderOne(String title) {
    return '$title كان مستحقًا اليوم ولا يزال بانتظارك.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'إدخال متكرر كان مستحقًا اليوم ولا يزال بانتظارك.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إدخال متكرر كان مستحقًا اليوم.',
      many: '$count إدخالًا متكررًا كانت مستحقة اليوم.',
      few: '$count إدخالات متكررة كانت مستحقة اليوم.',
      two: 'إدخالان متكرران كانا مستحقين اليوم.',
      one: 'إدخال متكرر واحد كان مستحقًا اليوم.',
      zero: 'لا توجد إدخالات متكررة مستحقة اليوم.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'لا شيء مسجل اليوم';

  @override
  String get emptyDayChannelName => 'أيام بدون تسجيل';

  @override
  String get emptyDayReminderBody => 'أضف ما أنفقته بينما ما زلت تتذكره.';

  @override
  String get reminderLockedTitle => 'هناك شيء بانتظارك';

  @override
  String get nudgeSettingsTitle => 'ذكّرني في يوم بلا تسجيلات';

  @override
  String get nudgeSettingsSubtitle =>
      'تذكير واحد في المساء، وفقط في يوم لم يُسجَّل فيه شيء.';

  @override
  String get nudgeOfferTitle => 'تذكير في الأيام التي تنسى فيها؟';

  @override
  String get nudgeOfferBody =>
      'تذكير واحد في وقت تختاره، فقط في يوم بلا تسجيلات. أوقفه متى شئت.';

  @override
  String get nudgeOfferYes => 'نعم، ذكّرني';

  @override
  String get nudgeOfferNo => 'لا، شكرًا';

  @override
  String get nudgeStoppedNotice =>
      'توقفت التذكيرات بعد ثلاث مرات دون رد. أعد تفعيلها متى شئت.';

  @override
  String get nudgePermissionDenied =>
      'فعّل الإشعارات في إعدادات النظام لتلقي التذكيرات.';

  @override
  String get updateDownloadedMessage => 'تم تنزيل تحديث.';

  @override
  String get updateRestartButton => 'إعادة التشغيل';
}
