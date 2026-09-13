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
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ميزانية تجاوزت حدودها',
      many: '$count ميزانية تجاوزت حدودها',
      few: '$count ميزانيات تجاوزت حدودها',
      two: 'ميزانيتان تجاوزتا حدهما',
      one: 'ميزانية واحدة تجاوزت حدها',
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
  String get addTransactionTitle => 'إضافة معاملة';

  @override
  String get editTransactionTitle => 'تعديل المعاملة';

  @override
  String get deleteTooltip => 'حذف';

  @override
  String get duplicateTooltip => 'تكرار';

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
  String get nothingUpcoming => 'لا شيء في الأيام الثلاثين القادمة.';

  @override
  String get noRules => 'لا توجد معاملات متكررة بعد.';

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
      one: 'كل يوم',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count أسبوع',
      many: 'كل $count أسبوعًا',
      few: 'كل $count أسابيع',
      two: 'كل أسبوعين',
      one: 'كل أسبوع',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count شهر',
      many: 'كل $count شهرًا',
      few: 'كل $count أشهر',
      two: 'كل شهرين',
      one: 'كل شهر',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count سنة',
      many: 'كل $count سنة',
      few: 'كل $count سنوات',
      two: 'كل سنتين',
      one: 'كل سنة',
    );
    return '$_temp0';
  }

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
  String get appLockFailed => 'تعذّر التحقق من هويتك. لم يتغير قفل التطبيق.';

  @override
  String get lockedTitle => 'Monthly Expenses مقفل';

  @override
  String get unlockButton => 'فتح القفل';
}
