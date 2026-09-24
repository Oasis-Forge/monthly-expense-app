// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'সেটিংস';

  @override
  String get transferTooltip => 'ট্রান্সফার';

  @override
  String get searchTooltip => 'খুঁজুন';

  @override
  String get addButton => 'যোগ করুন';

  @override
  String get emptyPeriod => 'এই মেয়াদে এখনো কোনো লেনদেন নেই।';

  @override
  String get balanceLabel => 'ব্যালেন্স';

  @override
  String get expandSummaryTooltip => 'আয় ও ব্যয় দেখান';

  @override
  String get collapseSummaryTooltip => 'শুধু ব্যালেন্স দেখান';

  @override
  String get periodNetLabel => 'এই মেয়াদ';

  @override
  String carriedForwardLine(String amount) {
    return 'জের টানা $amount';
  }

  @override
  String get incomeLabel => 'আয়';

  @override
  String get expenseLabel => 'ব্যয়';

  @override
  String upcomingCategory(String category) {
    return '$category · আসন্ন';
  }

  @override
  String get upcomingLabel => 'আসন্ন';

  @override
  String detailAdded(String date) {
    return 'যোগ হয়েছে $date';
  }

  @override
  String detailChanged(String date) {
    return 'সবশেষ পরিবর্তন $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পুনরাবৃত্ত লেনদেন বাকি আছে',
      one: '1টি পুনরাবৃত্ত লেনদেন বাকি আছে',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent ব্যবহৃত · $overটি সীমা ছাড়িয়েছে',
      one: '$percent ব্যবহৃত · 1টি সীমা ছাড়িয়েছে',
      zero: '$percent ব্যবহৃত',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বাজেট ঠিক করা',
      one: '1টি বাজেট ঠিক করা',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'লেনদেন মুছে ফেলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get transactionDeleted => 'লেনদেন মুছে ফেলা হয়েছে';

  @override
  String get transferDeleted => 'ট্রান্সফার মুছে ফেলা হয়েছে';

  @override
  String get undoButton => 'আনডু';

  @override
  String get undoFailed => 'আনডু করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get restoreFailed => 'লেনদেন ফিরিয়ে আনা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get restoreTransferFailed =>
      'ট্রান্সফার ফেরানো যায়নি। আবার চেষ্টা করুন।';

  @override
  String get addTransactionTitle => 'লেনদেন যোগ করুন';

  @override
  String get editTransactionTitle => 'লেনদেন সম্পাদনা করুন';

  @override
  String get transactionDetailTitle => 'বিস্তারিত';

  @override
  String get editTooltip => 'সম্পাদনা';

  @override
  String get deleteTooltip => 'মুছুন';

  @override
  String get duplicateTooltip => 'কপি করুন';

  @override
  String get rowMenuTooltip => 'আরও কাজ';

  @override
  String get deleteTransactionTitle => 'এই লেনদেন মুছবেন?';

  @override
  String get deleteTransactionMessage =>
      'এটি ট্র্যাশে যাবে, ৩০ দিন পর্যন্ত ফেরানো যাবে।';

  @override
  String get discardChangesTitle => 'পরিবর্তন বাতিল করবেন?';

  @override
  String get discardChangesMessage => 'এখানে যা লিখেছেন তা সংরক্ষণ করা হয়নি।';

  @override
  String get discardButton => 'বাতিল করুন';

  @override
  String get keepEditingButton => 'সম্পাদনা চালিয়ে যান';

  @override
  String get titleOptionalLabel => 'শিরোনাম (ঐচ্ছিক)';

  @override
  String get amountLabel => 'পরিমাণ';

  @override
  String get amountRequired => 'একটি পরিমাণ লিখুন';

  @override
  String get amountInvalid => 'সঠিক পরিমাণ লিখুন';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'ব্যাকস্পেস';

  @override
  String get hideKeypadTooltip => 'কিপ্যাড লুকান';

  @override
  String get categoryLabel => 'ক্যাটাগরি';

  @override
  String get categoryRequired => 'একটি ক্যাটাগরি বেছে নিন';

  @override
  String get accountLabel => 'অ্যাকাউন্ট';

  @override
  String get accountRequired => 'একটি অ্যাকাউন্ট বেছে নিন';

  @override
  String get dateLabel => 'তারিখ';

  @override
  String get noteLabel => 'নোট';

  @override
  String get previousDayTooltip => 'আগের দিন';

  @override
  String get nextDayTooltip => 'পরের দিন';

  @override
  String get noteOptionalLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get saveChangesButton => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get addTransactionButton => 'লেনদেন যোগ করুন';

  @override
  String get saveAndAddAnotherButton => 'সংরক্ষণ করে আরেকটি যোগ করুন';

  @override
  String get transactionAdded => 'লেনদেন যোগ হয়েছে';

  @override
  String get saveFailed => 'লেনদেন সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get noExpensesInPeriod => 'এই মেয়াদে এখনো কোনো ব্যয় নেই।';

  @override
  String totalSpent(String amount) {
    return 'মোট ব্যয়: $amount';
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
  String get settingsTitle => 'সেটিংস';

  @override
  String get drawerAddHeader => 'যোগ করুন';

  @override
  String get drawerAddExpense => 'ব্যয় যোগ করুন';

  @override
  String get drawerAddIncome => 'আয় যোগ করুন';

  @override
  String get drawerPlanHeader => 'পরিকল্পনা';

  @override
  String get drawerReviewHeader => 'পর্যালোচনা';

  @override
  String get drawerSpending => 'ক্যাটাগরি অনুযায়ী ব্যয়';

  @override
  String get drawerManageHeader => 'ব্যবস্থাপনা';

  @override
  String get drawerDataHeader => 'ডেটা';

  @override
  String get currencyLabel => 'মুদ্রা';

  @override
  String get currencySearchHint => 'মুদ্রা খুঁজুন';

  @override
  String changeCurrencyTitle(String code) {
    return 'মুদ্রা পরিবর্তন করে $code করবেন?';
  }

  @override
  String get changeCurrencyMessage =>
      'পরিমাণ একই থাকবে; শুধু মুদ্রার লেবেল পরিবর্তন হবে।';

  @override
  String get changeButton => 'পরিবর্তন করুন';

  @override
  String get cancelButton => 'বাতিল করুন';

  @override
  String get saveButton => 'সংরক্ষণ করুন';

  @override
  String get removeButton => 'সরান';

  @override
  String get themeLabel => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get languageLabel => 'ভাষা';

  @override
  String get languageSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get monthStartLabel => 'মাসের প্রথম দিন';

  @override
  String get monthStartLastDay => 'শেষ দিন';

  @override
  String get showCarriedForwardLabel => 'ব্যালেন্স জের টানুন';

  @override
  String get showCarriedForwardSubtitle =>
      'প্রতিটি মেয়াদ আগের ব্যালেন্স থেকে শুরু হয়';

  @override
  String get trashTitle => 'ট্র্যাশ';

  @override
  String get trashEmpty => 'ট্র্যাশ খালি।';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days দিনে চিরতরে মুছে যাবে',
      one: '1 দিনে চিরতরে মুছে যাবে',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'ফিরিয়ে আনুন';

  @override
  String get categoriesTitle => 'ক্যাটাগরি';

  @override
  String get addCategoryTooltip => 'ক্যাটাগরি যোগ করুন';

  @override
  String get addCategoryTitle => 'ক্যাটাগরি যোগ করুন';

  @override
  String get editCategoryTitle => 'ক্যাটাগরি সম্পাদনা করুন';

  @override
  String get categoryNameLabel => 'নাম';

  @override
  String get categoryNameRequired => 'একটি নাম লিখুন';

  @override
  String get categoryNameTaken => 'এই নামটি আগে থেকেই ব্যবহৃত';

  @override
  String get archiveAction => 'আর্কাইভ করুন';

  @override
  String get unarchiveAction => 'আর্কাইভ থেকে সরান';

  @override
  String get deleteAction => 'মুছুন';

  @override
  String get archivedHeader => 'আর্কাইভ করা';

  @override
  String get accountsTotalLabel => 'মোট';

  @override
  String get categorySaveFailed =>
      'ক্যাটাগরি সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get accountsTitle => 'অ্যাকাউন্ট';

  @override
  String get accountCash => 'নগদ';

  @override
  String get accountTypeLabel => 'ধরন';

  @override
  String get accountTypeCash => 'নগদ';

  @override
  String get accountTypeBank => 'ব্যাংক';

  @override
  String get accountTypeCard => 'কার্ড';

  @override
  String get accountTypeOther => 'অন্যান্য';

  @override
  String get addAccountTooltip => 'অ্যাকাউন্ট যোগ করুন';

  @override
  String get addAccountTitle => 'অ্যাকাউন্ট যোগ করুন';

  @override
  String get editAccountTitle => 'অ্যাকাউন্ট সম্পাদনা করুন';

  @override
  String get openingBalanceLabel => 'শুরুর ব্যালেন্স';

  @override
  String get openingDateLabel => 'শুরুর তারিখ';

  @override
  String get accountSaveFailed =>
      'অ্যাকাউন্ট সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get transferTitle => 'ট্রান্সফার';

  @override
  String get editTransferTitle => 'ট্রান্সফার সম্পাদনা করুন';

  @override
  String get transferLabel => 'ট্রান্সফার';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'থেকে';

  @override
  String get toAccountLabel => 'প্রতি';

  @override
  String get sameAccountError => 'দুটি ভিন্ন অ্যাকাউন্ট বেছে নিন';

  @override
  String get needTwoAccounts =>
      'অ্যাকাউন্টের মধ্যে টাকা সরাতে দ্বিতীয় একটি অ্যাকাউন্ট যোগ করুন।';

  @override
  String get addTransferButton => 'ট্রান্সফার যোগ করুন';

  @override
  String get transferSaveFailed =>
      'ট্রান্সফার সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get searchHint => 'লেনদেন খুঁজুন';

  @override
  String get allTypesFilter => 'সব';

  @override
  String get allCategoriesFilter => 'সব ক্যাটাগরি';

  @override
  String get allAccountsFilter => 'সব অ্যাকাউন্ট';

  @override
  String get allTimeFilter => 'সব সময়';

  @override
  String get clearDatesTooltip => 'তারিখ মুছুন';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ফলাফল',
      one: '1টি ফলাফল',
    );
    return '$_temp0 · আয় $income · ব্যয় $expense';
  }

  @override
  String get noSearchResults => 'মিলে যাওয়া কোনো লেনদেন নেই।';

  @override
  String get budgetsTitle => 'বাজেট';

  @override
  String get budgetsTooltip => 'বাজেট';

  @override
  String get overallBudget => 'সার্বিক';

  @override
  String get noBudget => 'কোনো বাজেট নেই';

  @override
  String budgetsHint(String period) {
    return 'সীমা $period থেকে কার্যকর হবে; আগের মেয়াদগুলো নিজেরটাই রাখবে।';
  }

  @override
  String get budgetLimitLabel => 'প্রতি মেয়াদে সীমা';

  @override
  String get budgetSaveFailed => 'বাজেট সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$limit-এর মধ্যে $spent';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining বাকি · দিনে $perDay';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount খরচ · দিনে $perDay এখন পর্যন্ত';
  }

  @override
  String get homeSetBudget => 'মাসিক বাজেট নির্ধারণ করুন';

  @override
  String budgetLeft(String remaining) {
    return '$remaining বাকি';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount বেশি খরচ';
  }

  @override
  String get budgetLimitReached => 'সীমা শেষ';

  @override
  String budgetLimitOnly(String limit) {
    return 'সীমা $limit';
  }

  @override
  String get recurringTitle => 'পুনরাবৃত্তি';

  @override
  String get addRecurringTooltip => 'পুনরাবৃত্তি যোগ করুন';

  @override
  String get addRecurringTitle => 'পুনরাবৃত্তি যোগ করুন';

  @override
  String get editRecurringTitle => 'পুনরাবৃত্তি সম্পাদনা করুন';

  @override
  String get dueHeader => 'বাকি';

  @override
  String get upcomingHeader => 'আগামী 30 দিন';

  @override
  String get rulesHeader => 'নিয়ম';

  @override
  String billsPerMonth(String amount) {
    return 'মাসে বিলে $amount';
  }

  @override
  String nextBillToday(String title) {
    return 'পরবর্তী: $title, আজ';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'পরবর্তী: $title, আগামীকাল';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'পরবর্তী: $title, $days দিনে',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'আগামী 30 দিনে কিছু নেই।';

  @override
  String get noRules => 'এখনো কোনো পুনরাবৃত্ত লেনদেন নেই।';

  @override
  String get postButton => 'পোস্ট করুন';

  @override
  String get skipButton => 'এড়িয়ে যান';

  @override
  String get postFailed => 'লেনদেন পোস্ট করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get recurringSaveFailed =>
      'পুনরাবৃত্ত লেনদেন সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get everyLabel => 'প্রতি';

  @override
  String get frequencyDays => 'দিন';

  @override
  String get frequencyWeeks => 'সপ্তাহ';

  @override
  String get frequencyMonths => 'মাস';

  @override
  String get frequencyYears => 'বছর';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্রতি $count দিনে',
      one: 'প্রতিদিন',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্রতি $count সপ্তাহে',
      one: 'প্রতি সপ্তাহে',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্রতি $count মাসে',
      one: 'প্রতি মাসে',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্রতি $count বছরে',
      one: 'প্রতি বছর',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · বিরতিতে';
  }

  @override
  String get startsLabel => 'শুরু';

  @override
  String get endsLabel => 'শেষ';

  @override
  String get endNever => 'কখনো না';

  @override
  String get endAfter => 'পরে';

  @override
  String get endOnDate => 'নির্দিষ্ট তারিখে';

  @override
  String get timesLabel => 'বার';

  @override
  String get endsOnLabel => 'শেষ তারিখ';

  @override
  String get wholeNumberInvalid => '1 থেকে শুরু করে একটি পূর্ণ সংখ্যা লিখুন';

  @override
  String get endDateInvalid => 'শেষ তারিখ শুরুর তারিখের পরে হতে হবে';

  @override
  String get autoPostLabel => 'স্বয়ংক্রিয়ভাবে পোস্ট করুন';

  @override
  String get autoPostSubtitle => 'নাহলে এটি ট্যাপের অপেক্ষায় বাকি-তে থাকবে';

  @override
  String get pauseTooltip => 'বিরতি দিন';

  @override
  String get resumeTooltip => 'আবার শুরু করুন';

  @override
  String get categoryFood => 'খাবার';

  @override
  String get categoryGroceries => 'গ্রোসারি';

  @override
  String get categoryTransport => 'যাতায়াত';

  @override
  String get categoryShopping => 'কেনাকাটা';

  @override
  String get categoryBills => 'বিল';

  @override
  String get categoryRent => 'ভাড়া';

  @override
  String get categoryHealth => 'স্বাস্থ্য';

  @override
  String get categoryEducation => 'শিক্ষা';

  @override
  String get categoryEntertainment => 'বিনোদন';

  @override
  String get categorySalary => 'বেতন';

  @override
  String get categoryBusiness => 'ব্যবসা';

  @override
  String get categoryInvestment => 'বিনিয়োগ';

  @override
  String get categoryGift => 'উপহার';

  @override
  String get categoryOther => 'অন্যান্য';

  @override
  String get previousPeriodTooltip => 'আগের মেয়াদ';

  @override
  String get wholePeriodTooltip => 'পুরো মেয়াদ দেখান';

  @override
  String get nextPeriodTooltip => 'পরের মেয়াদ';

  @override
  String get insightsTooltip => 'বিশ্লেষণ';

  @override
  String get insightsTitle => 'বিশ্লেষণ';

  @override
  String get calendarTab => 'ক্যালেন্ডার';

  @override
  String get trendTab => 'ট্রেন্ড';

  @override
  String get noIncomeInPeriod => 'এই মেয়াদে এখনো কোনো আয় নেই।';

  @override
  String totalIncome(String amount) {
    return 'মোট আয়: $amount';
  }

  @override
  String comparedMore(String amount) {
    return 'গত মাসের চেয়ে $amount বেশি';
  }

  @override
  String comparedLess(String amount) {
    return 'গত মাসের চেয়ে $amount কম';
  }

  @override
  String get comparedSame => 'গত মাসের মতোই';

  @override
  String get categoryNewLabel => 'নতুন';

  @override
  String get calendarHint => 'কোনো দিনের লেনদেন দেখতে সেটিতে ট্যাপ করুন।';

  @override
  String get dayEmpty => 'এই দিনে কিছু নেই।';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মাস',
      one: '1 মাস',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'আয় $income · ব্যয় $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'প্রতি মেয়াদে গড় · আয় $income · ব্যয় $expense';
  }

  @override
  String get weekStartLabel => 'সপ্তাহের প্রথম দিন';

  @override
  String weekStartDefault(String day) {
    return 'ডিফল্ট ($day)';
  }

  @override
  String get firstRunTitle => 'Monthly Expenses-এ স্বাগতম';

  @override
  String get firstRunMessage =>
      'আপনার আয়-ব্যয়ের হিসাব রাখুন। আপনার ডেটা এই ডিভাইসেই থাকে।';

  @override
  String get addFirstTransactionButton => 'আপনার প্রথম লেনদেন যোগ করুন';

  @override
  String get setupIntro =>
      'আপনার ভাষা ও মুদ্রা বেছে নিন। পরে সেটিংস থেকে এগুলো পরিবর্তন করতে পারবেন।';

  @override
  String get setupContinueButton => 'চালিয়ে যান';

  @override
  String get setupRestoreTitle => 'ব্যাকআপ রিস্টোর করুন';

  @override
  String get setupRestoreSubtitle =>
      'ব্যাকআপ ফাইল থেকে আপনার ডেটা ও সেটিংস ফিরিয়ে আনুন';

  @override
  String get walkthroughEntryTitle => 'সেকেন্ডেই যোগ করুন';

  @override
  String get walkthroughEntryBody =>
      'যোগফল করা কিপ্যাড, রসিদের ছবি, আর টাইপ করতে দেরি হলে ভয়েস নোট।';

  @override
  String get walkthroughPlanTitle => 'মাসের পরিকল্পনা করুন';

  @override
  String get walkthroughPlanBody =>
      'ক্যাটাগরি অনুযায়ী বাজেট, নিজে থেকে পুনরাবৃত্ত বিল, আর মনে করিয়ে দেওয়া নোট।';

  @override
  String get walkthroughInsightsTitle => 'টাকা কোথায় যাচ্ছে দেখুন';

  @override
  String get walkthroughInsightsBody =>
      'চার্ট, ক্যালেন্ডার, আর যেকোনো মেয়াদের জন্য পিডিএফ বা সিএসভি রিপোর্ট।';

  @override
  String get walkthroughPrivacyTitle => 'শুধুই আপনার';

  @override
  String get walkthroughPrivacyBody =>
      'কোনো অ্যাকাউন্ট লাগে না। আপনি যা লেখেন তা এই ফোনেই থাকে; অ্যাপের খরচ চালানো বিজ্ঞাপনগুলো তা কখনো দেখে না।';

  @override
  String get walkthroughBringTitle => 'যা আছে তা নিয়ে আসুন';

  @override
  String get walkthroughBringBody =>
      'অন্য অ্যাপ বা ফোন থেকে আসছেন? খালি অ্যাপ থেকে শুরু না করে ব্যাকআপ বা সিএসভি দিয়ে শুরু করুন।';

  @override
  String get firstRunRestoreTitle => 'এই ব্যাকআপটি রিস্টোর করবেন?';

  @override
  String get firstRunRestoreMessage =>
      'এটি অ্যাপের সবকিছু প্রতিস্থাপন করবে, এবং সংরক্ষণের সময়কার ভাষা ও মুদ্রা ফিরিয়ে আনবে।';

  @override
  String get walkthroughNextButton => 'পরবর্তী';

  @override
  String get walkthroughStartButton => 'শুরু করুন';

  @override
  String get walkthroughDoneButton => 'সম্পন্ন';

  @override
  String walkthroughProgress(int current, int total) {
    return 'পৃষ্ঠা $current/$total';
  }

  @override
  String get walkthroughReplayTitle => 'ওয়াকথ্রু আবার দেখুন';

  @override
  String get walkthroughReplaySubtitle =>
      'অ্যাপ নতুন থাকাকালীন দেখানো চারটি পৃষ্ঠা';

  @override
  String get removeAdsTitle => 'বিজ্ঞাপন সরান';

  @override
  String get exportCsvMenu => 'সিএসভি এক্সপোর্ট করুন';

  @override
  String get exportCsvTooltip => 'সিএসভি এক্সপোর্ট করুন';

  @override
  String get csvExported => 'সিএসভি সংরক্ষিত হয়েছে';

  @override
  String get csvExportFailed =>
      'সিএসভি এক্সপোর্ট করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get backupTitle => 'ব্যাকআপ ও রিস্টোর';

  @override
  String get backupIntro =>
      'ব্যাকআপ হলো এমন ফাইল যা আপনি নিজের পছন্দমতো জায়গায় সংরক্ষণ করেন। স্বয়ংক্রিয়ভাবে কিছু আপলোড বা পাঠানো হয় না।';

  @override
  String get backUpNowTitle => 'এখনই ব্যাকআপ নিন';

  @override
  String lastBackupLine(String date) {
    return 'সর্বশেষ ব্যাকআপ $date';
  }

  @override
  String get neverBackedUp => 'এখনো কোনো ব্যাকআপ নেই';

  @override
  String get backupSaved => 'ব্যাকআপ সংরক্ষিত হয়েছে';

  @override
  String get backupSaveFailed =>
      'ব্যাকআপ সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get restoreFromFileTitle => 'ফাইল থেকে রিস্টোর করুন';

  @override
  String get restoreFromFileSubtitle =>
      'ব্যাকআপ আপনার ডেটার সাথে মার্জ করুন, অথবা এটি দিয়ে প্রতিস্থাপন করুন';

  @override
  String get backupReminderLabel => 'ব্যাকআপ রিমাইন্ডার';

  @override
  String get backupReminderSubtitle => '20টি লেনদেন হলে প্রতি 30 দিনে';

  @override
  String get backupReminderNever => 'নিরাপদ রাখতে আপনার ডেটার ব্যাকআপ নিন';

  @override
  String backupReminderSince(String date) {
    return 'সর্বশেষ ব্যাকআপ $date। নতুন একটি নেওয়ার সময় হয়েছে কি?';
  }

  @override
  String get notNowTooltip => 'এখন নয়';

  @override
  String get keptBackupsHeader => 'স্বয়ংক্রিয় ব্যাকআপ';

  @override
  String get keptBackupsHint => 'প্রতিটি রিস্টোরের আগে এই ডিভাইসে সংরক্ষিত।';

  @override
  String get noKeptBackups => 'এখনো কিছু নেই।';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি লেনদেন',
      one: '1টি লেনদেন',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'ব্যাকআপ রিস্টোর করুন';

  @override
  String get mergeOption => 'মার্জ';

  @override
  String get mergeOptionSubtitle =>
      'আপনার ডেটা রেখে ব্যাকআপেরটা যোগ করে। দুই জায়গায় একই রেকর্ড থাকলে নতুন পরিবর্তনটি থাকবে।';

  @override
  String get replaceOption => 'প্রতিস্থাপন';

  @override
  String get replaceOptionSubtitle =>
      'আপনার ডেটা মুছে শুধু ব্যাকআপ ও তার সেটিংস ব্যবহার করে।';

  @override
  String get restoreSafetyNote =>
      'প্রথমে আপনার বর্তমান ডেটার একটি কপি স্বয়ংক্রিয় ব্যাকআপ-এ সংরক্ষণ করা হয়।';

  @override
  String get restoreButton => 'রিস্টোর করুন';

  @override
  String get restoreKeptTitle => 'এই কপিটি রিস্টোর করবেন?';

  @override
  String restoreKeptMessage(String date) {
    return 'আপনার ডেটা $date-এর কপি দিয়ে প্রতিস্থাপিত হবে। প্রথমে বর্তমান ডেটার একটি কপি সংরক্ষণ করা হয়।';
  }

  @override
  String get backupInvalid => 'এই ফাইলটি Monthly Expenses-এর ব্যাকআপ নয়।';

  @override
  String get backupTooNew =>
      'এই ব্যাকআপটি অ্যাপের একটি নতুন সংস্করণের। অ্যাপ আপডেট করে আবার চেষ্টা করুন।';

  @override
  String get backupOpenFailed => 'ফাইলটি খোলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get backupRestoreFailed =>
      'ব্যাকআপ রিস্টোর করা যায়নি। আপনার ডেটা অপরিবর্তিত আছে।';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি লেনদেন রিস্টোর হয়েছে',
      one: '1টি লেনদেন রিস্টোর হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'মার্জ হয়েছে: $addedটি যোগ, $updatedটি আপডেট, $unchangedটি অপরিবর্তিত';
  }

  @override
  String get appLockLabel => 'অ্যাপ লক';

  @override
  String get appLockSubtitle =>
      'ফিঙ্গারপ্রিন্ট, ফেস বা স্ক্রিন লক দিয়ে আনলক করুন';

  @override
  String get appLockUnavailable =>
      'অ্যাপ লক ব্যবহার করতে এই ডিভাইসে স্ক্রিন লক সেট করুন';

  @override
  String get appLockReason => 'Monthly Expenses আনলক করুন';

  @override
  String get appLockFailed =>
      'আপনাকে শনাক্ত করা যায়নি। অ্যাপ লক পরিবর্তন হয়নি।';

  @override
  String get lockedTitle => 'Monthly Expenses লক করা আছে';

  @override
  String get unlockButton => 'আনলক করুন';

  @override
  String get widgetShowAmountsLabel => 'উইজেটে পরিমাণ দেখান';

  @override
  String get widgetShowAmountsSubtitle =>
      'অ্যাপ লক চালু থাকলে হোম-স্ক্রিন উইজেট এগুলো লুকায়';

  @override
  String get widgetLeftLabel => 'বাকি';

  @override
  String get widgetAddExpense => 'ব্যয় যোগ করুন';

  @override
  String get widgetAddIncome => 'আয় যোগ করুন';

  @override
  String get widgetAmountsHidden => 'অ্যাপ লকের কারণে পরিমাণ লুকানো আছে';

  @override
  String get notesTitle => 'নোট';

  @override
  String get addNoteTooltip => 'নোট যোগ করুন';

  @override
  String get addNoteTitle => 'নোট যোগ করুন';

  @override
  String get editNoteTitle => 'নোট সম্পাদনা করুন';

  @override
  String get noteTextLabel => 'নোট';

  @override
  String get noteTextRequired => 'কিছু টেক্সট লিখুন';

  @override
  String get noteAmountOptionalLabel => 'পরিমাণ (ঐচ্ছিক)';

  @override
  String get noteDueDateToggle => 'একটি নির্ধারিত তারিখ দিন';

  @override
  String get noteDueDateLabel => 'নির্ধারিত তারিখ';

  @override
  String get noteReminderToggle => 'আমাকে মনে করিয়ে দিন';

  @override
  String get noteReminderTimeLabel => 'রিমাইন্ডারের সময়';

  @override
  String get noteReminderTimeUnset => 'একটি সময় বেছে নিন';

  @override
  String get noteCategoryOptionalLabel => 'ক্যাটাগরি (ঐচ্ছিক)';

  @override
  String get noteCategoryNone => 'কোনোটি না';

  @override
  String get recordNoteButton => 'লেনদেন হিসেবে রেকর্ড করুন';

  @override
  String get noteMarkDoneTooltip => 'সম্পন্ন হিসেবে চিহ্নিত করুন';

  @override
  String get noteMarkOpenTooltip => 'অসম্পন্ন হিসেবে চিহ্নিত করুন';

  @override
  String get notesEmptyTitle => 'এখানে এখনো কিছু নেই';

  @override
  String get notesEmptyMessage =>
      'করণীয় বা খেয়াল রাখার বিষয় মনে রাখতে নোট ব্যবহার করুন, চাইলে তারিখ, পরিমাণ ও ক্যাটাগরিসহ।';

  @override
  String get addNoteButton => 'একটি নোট যোগ করুন';

  @override
  String get notesOpenHeader => 'অসম্পন্ন';

  @override
  String get notesDoneHeader => 'সম্পন্ন';

  @override
  String get noteDeleted => 'নোট মুছে ফেলা হয়েছে।';

  @override
  String get noteSaveFailed => 'নোট সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get noteDeleteFailed => 'নোট মুছে ফেলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get noteRestoreFailed => 'নোট ফিরিয়ে আনা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get notesSearchHint => 'নোট খুঁজুন';

  @override
  String get noteFilterAll => 'সব';

  @override
  String get noteFilterOverdue => 'মেয়াদোত্তীর্ণ';

  @override
  String get noteFilterDueToday => 'আজ বাকি';

  @override
  String get noteFilterUpcoming => 'আসন্ন';

  @override
  String get noteFilterNoDate => 'তারিখ নেই';

  @override
  String get noNoteResults => 'মিলে যাওয়া কোনো নোট নেই।';

  @override
  String get noteLinkedTransactionLabel => 'লেনদেন হিসেবে রেকর্ড করা';

  @override
  String get noteLinkedNoteLabel => 'একটি নোট থেকে';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি নোট বাকি আছে',
      one: '1টি নোট বাকি আছে',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'বাকি নোট';

  @override
  String get noteReminderTitle => 'নোট রিমাইন্ডার';

  @override
  String get noteReminderLockedTitle => 'একটি নোট বাকি আছে';

  @override
  String get noteReminderPermissionDenied =>
      'নোটের রিমাইন্ডার পেতে সিস্টেম সেটিংসে নোটিফিকেশন চালু করুন।';

  @override
  String reportRange(String from, String to) {
    return '$from থেকে $to';
  }

  @override
  String reportCreated(String when) {
    return 'তৈরি হয়েছে $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'পৃষ্ঠা $page/$pages';
  }

  @override
  String get reportNet => 'নিট';

  @override
  String get reportOpeningBalance => 'শুরুর ব্যালেন্স';

  @override
  String get reportClosingBalance => 'সমাপনী ব্যালেন্স';

  @override
  String get reportSpendingHeader => 'ক্যাটাগরি অনুযায়ী ব্যয়';

  @override
  String get reportEarningHeader => 'ক্যাটাগরি অনুযায়ী আয়';

  @override
  String get reportTrendHeader => 'ট্রেন্ড';

  @override
  String get reportEntriesHeader => 'লেনদেন';

  @override
  String get reportUpcomingHeader => 'আসন্ন';

  @override
  String get reportUpcomingNote =>
      'ভবিষ্যৎ তারিখের, তাই উপরের মোটে গণনা করা হয়নি।';

  @override
  String get reportAmountColumn => 'পরিমাণ';

  @override
  String get reportShareColumn => 'অংশ';

  @override
  String get reportBudgetColumn => 'বাজেট';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$limit-এর $used';
  }

  @override
  String get reportDetailsColumn => 'বিস্তারিত';

  @override
  String get reportEmpty => 'এই তারিখগুলোর জন্য রিপোর্ট করার কিছু নেই।';

  @override
  String get exportPdfMenu => 'পিডিএফ এক্সপোর্ট করুন';

  @override
  String get reportTitle => 'পিডিএফ এক্সপোর্ট করুন';

  @override
  String get reportNoFontTitle => 'এই ভাষায় এখনও নয়';

  @override
  String get reportNoFontBody =>
      'রিপোর্টের জন্য তার লিপির ফন্ট দরকার, আর চীনা, জাপানি ও কোরীয় ফন্ট অ্যাপে রাখার পক্ষে অনেক বড়। পরের কোনো সংস্করণে সেটি ডাউনলোড করা যাবে।';

  @override
  String get reportPreviewTitle => 'রিপোর্ট';

  @override
  String get reportCoversHeader => 'যা অন্তর্ভুক্ত থাকবে';

  @override
  String get reportRangePeriod => 'এই মেয়াদ';

  @override
  String get reportRangeCustom => 'তারিখ';

  @override
  String get reportRangeYear => 'বছর';

  @override
  String get reportFromLabel => 'থেকে';

  @override
  String get reportToLabel => 'পর্যন্ত';

  @override
  String get reportYearLabel => 'বছর';

  @override
  String get reportAccountLabel => 'অ্যাকাউন্ট';

  @override
  String get reportAllAccounts => 'সব অ্যাকাউন্ট';

  @override
  String get reportIncludeHeader => 'যা থাকবে';

  @override
  String get reportIncludeSubtitle => 'যা শেয়ার করতে চান না তা বাদ দিন।';

  @override
  String get reportIncludeTransactions => 'লেনদেনের তালিকা';

  @override
  String get reportIncludeDetails => 'শিরোনাম ও নোট';

  @override
  String get reportIncludeAccounts => 'অ্যাকাউন্টের নাম';

  @override
  String get reportCreateButton => 'রিপোর্ট তৈরি করুন';

  @override
  String get reportBuilding => 'রিপোর্ট তৈরি হচ্ছে';

  @override
  String get reportFailed => 'রিপোর্ট তৈরি করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get reportRangeBackwards => 'প্রথম তারিখ শেষ তারিখের আগে হতে হবে।';

  @override
  String get importTitle => 'সিএসভি ইম্পোর্ট করুন';

  @override
  String get importSubtitle => 'অন্য অ্যাপ থেকে লেনদেন নিয়ে আসুন';

  @override
  String get importIntro =>
      'একটি সিএসভি ফাইল বেছে নিন, কিছু যোগ হওয়ার আগেই অ্যাপ এটি কীভাবে পড়েছে তা দেখতে পাবেন। ইম্পোর্ট শুধু রেকর্ড যোগ করে — আপনার আগের কিছু প্রতিস্থাপন বা মুছে ফেলে না।';

  @override
  String get importChooseFile => 'একটি ফাইল বেছে নিন';

  @override
  String get importChooseAnother => 'অন্য একটি ফাইল বেছে নিন';

  @override
  String get importReadFailed => 'ফাইলটি পড়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get importRefusedEmpty => 'ফাইলটিতে কিছু নেই।';

  @override
  String get importRefusedNoDate =>
      'ফাইলের কোনো কলামকে তারিখ হিসেবে পড়া যায়নি, তাই এটি ইম্পোর্ট করা যাবে না।';

  @override
  String get importRefusedNoAmount =>
      'ফাইলের কোনো কলামকে পরিমাণ হিসেবে পড়া যায়নি, তাই এটি ইম্পোর্ট করা যাবে না।';

  @override
  String get importRefusedNoRows =>
      'ফাইলের কোনো সারি পড়া যায়নি, তাই ইম্পোর্ট করার কিছু নেই।';

  @override
  String get importColumnsHeader => 'কলাম';

  @override
  String get importColumnsSubtitle => 'অ্যাপ ভুল পড়লে তা পরিবর্তন করুন।';

  @override
  String get importColumnNone => 'ব্যবহৃত নয়';

  @override
  String get importFieldType => 'ধরন';

  @override
  String get importFieldToAccount => 'যে অ্যাকাউন্টে';

  @override
  String get importFieldTitle => 'শিরোনাম';

  @override
  String get importFieldNote => 'নোট';

  @override
  String get importDateOrderLabel => '03/04-এর মতো তারিখ মানে';

  @override
  String get importDayFirst => 'আগে দিন';

  @override
  String get importMonthFirst => 'আগে মাস';

  @override
  String get importCountsHeader => 'কী ঘটবে';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সারি ইম্পোর্ট হবে',
      one: '1টি সারি ইম্পোর্ট হবে',
      zero: 'কিছুই ইম্পোর্ট হবে না',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সারির তারিখ অ্যাপ পড়তে পারছে না',
      one: '1টি সারির তারিখ অ্যাপ পড়তে পারছে না',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সারির পরিমাণ অ্যাপ পড়তে পারছে না',
      one: '1টি সারির পরিমাণ অ্যাপ পড়তে পারছে না',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সারিতে কোনো টাকার পরিমাণ নেই',
      one: '1টি সারিতে কোনো টাকার পরিমাণ নেই',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সারি আগে থেকেই অ্যাপে আছে',
      one: '1টি সারি আগে থেকেই অ্যাপে আছে',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ট্রান্সফারে শুধু একটি অ্যাকাউন্টের নাম আছে',
      one: '1টি ট্রান্সফারে শুধু একটি অ্যাকাউন্টের নাম আছে',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'তারিখ পড়া যাচ্ছে না';

  @override
  String get importRowUnreadableAmount => 'পরিমাণ পড়া যাচ্ছে না';

  @override
  String get importRowZero => 'কোনো টাকার পরিমাণ নেই';

  @override
  String get importRowAlreadyThere => 'আগে থেকেই অ্যাপে আছে';

  @override
  String get importRowIncompleteTransfer => 'শুধু একটি অ্যাকাউন্টের নাম আছে';

  @override
  String get importNamesHeader => 'অ্যাপে নেই এমন নাম';

  @override
  String get importNamesSubtitle =>
      'প্রতিটি কী হবে তা বেছে নিন। ইম্পোর্ট কখনো নতুন ক্যাটাগরি বা অ্যাকাউন্ট তৈরি করে না।';

  @override
  String get importRowsHeader => 'অ্যাপ যেভাবে পড়েছে, প্রথম সারিগুলো';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আরও $countটি',
      one: 'আরও 1টি',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সারি ইম্পোর্ট করুন',
      one: '1টি সারি ইম্পোর্ট করুন',
      zero: 'ইম্পোর্ট করার কিছু নেই',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ড ইম্পোর্ট হয়েছে',
      one: '1টি রেকর্ড ইম্পোর্ট হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'ফাইলটি ইম্পোর্ট করা যায়নি। কিছু যোগ হয়নি।';

  @override
  String get attachmentsLabel => 'সংযুক্তি';

  @override
  String get photoLabel => 'ছবি';

  @override
  String get photoAdd => 'একটি ছবি যোগ করুন';

  @override
  String get photoTake => 'ছবি তুলুন';

  @override
  String get photoChoose => 'একটি ছবি বেছে নিন';

  @override
  String get photoRemove => 'ছবি সরান';

  @override
  String get photoMissing => 'এই ছবিটি খুঁজে পাওয়া যাচ্ছে না।';

  @override
  String get voiceNoteLabel => 'ভয়েস নোট';

  @override
  String get voiceRecord => 'একটি ভয়েস নোট রেকর্ড করুন';

  @override
  String voiceRecording(int seconds) {
    return 'রেকর্ড হচ্ছে, $secondsসে বাকি';
  }

  @override
  String get voiceStop => 'থামান';

  @override
  String get voicePlay => 'চালান';

  @override
  String get voicePause => 'বিরতি দিন';

  @override
  String get voiceRemove => 'ভয়েস নোট সরান';

  @override
  String get voiceMissing => 'এই ভয়েস নোটটি খুঁজে পাওয়া যাচ্ছে না।';

  @override
  String get microphoneRefused => 'এই অ্যাপের জন্য মাইক্রোফোন বন্ধ আছে।';

  @override
  String backupIncludesAttachments(String size) {
    return 'সংযুক্তিসহ, $size এমবি';
  }

  @override
  String get removeAdsBody =>
      'একবার পেমেন্টে সব বিজ্ঞাপন বন্ধ হয়ে যায়। এটি স্টোর অ্যাকাউন্টের সাথে যুক্ত, তাই নতুন ফোন বা পুনরায় ইনস্টলেও ফিরে আসে।';

  @override
  String removeAdsBuyButton(String price) {
    return '$price-এ বিজ্ঞাপন সরান';
  }

  @override
  String get removeAdsOwned => 'বিজ্ঞাপন বন্ধ আছে। ধন্যবাদ।';

  @override
  String get removeAdsPending => 'স্টোরের জন্য অপেক্ষা করা হচ্ছে…';

  @override
  String get removeAdsUnavailable =>
      'স্টোরে এখনই এখানে বিক্রির মতো কিছু নেই। পরে আবার চেষ্টা করুন।';

  @override
  String get removeAdsFailed =>
      'এটি সম্পন্ন হয়নি এবং আপনার কাছ থেকে কোনো টাকা কাটা হয়নি।';

  @override
  String get restorePurchasesButton => 'কেনাকাটা পুনরুদ্ধার করুন';

  @override
  String get payNothingWithheld =>
      'বিজ্ঞাপন থাকুক বা না থাকুক, সব ফিচার সবসময় বিনামূল্যে থাকে।';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'শীঘ্রই আসছে';

  @override
  String get plusBody =>
      'একটি ব্যাংক সংযোগ যা লেনদেন এনে নিশ্চিত করতে দেয়। এখনও সম্পূর্ণ হয়নি, তাই কেনার কিছু নেই।';

  @override
  String get privacyOptionsTitle => 'গোপনীয়তা বিকল্প';

  @override
  String get privacyOptionsSubtitle =>
      'ব্যক্তিগতকৃত বিজ্ঞাপন সম্পর্কে আপনার পছন্দ পরিবর্তন করুন';

  @override
  String get dueEntryReminderTitle => 'এন্ট্রি বকেয়া ছিল';

  @override
  String dueEntryReminderOne(String title) {
    return '$title আজ বকেয়া ছিল এবং এখনও অপেক্ষা করছে।';
  }

  @override
  String get dueEntryReminderUntitled =>
      'একটি পুনরাবৃত্ত এন্ট্রি আজ বকেয়া ছিল এবং এখনও অপেক্ষা করছে।';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পুনরাবৃত্ত এন্ট্রি আজ বকেয়া ছিল।',
      one: '1টি পুনরাবৃত্ত এন্ট্রি আজ বকেয়া ছিল।',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'আজ কিছু রেকর্ড করা হয়নি';

  @override
  String get emptyDayReminderBody =>
      'আপনি যা খরচ করেছেন তা মনে থাকতে থাকতেই যোগ করুন।';

  @override
  String get reminderLockedTitle => 'কিছু একটা অপেক্ষা করছে';

  @override
  String get nudgeSettingsTitle => 'খালি দিনে আমাকে মনে করিয়ে দিন';

  @override
  String get nudgeSettingsSubtitle =>
      'সন্ধ্যায় একটি রিমাইন্ডার, এবং শুধু সেই দিনে যেখানে কিছু রেকর্ড করা হয়নি।';

  @override
  String get nudgeOfferTitle => 'যেদিন ভুলে যান, সেদিন একটা মনে করানো?';

  @override
  String get nudgeOfferBody =>
      'আপনার পছন্দের সময়ে একটি রিমাইন্ডার, শুধু সেই দিনে যেখানে কিছু রেকর্ড করা হয়নি। যেকোনো সময় বন্ধ করুন।';

  @override
  String get nudgeOfferYes => 'হ্যাঁ, মনে করান';

  @override
  String get nudgeOfferNo => 'না ধন্যবাদ';

  @override
  String get nudgeStoppedNotice =>
      'তিনটি অনুত্তরিত থাকার পর রিমাইন্ডার বন্ধ হয়েছে। যখন ইচ্ছা আবার চালু করুন।';

  @override
  String get nudgePermissionDenied =>
      'রিমাইন্ডার পেতে সিস্টেম সেটিংসে বিজ্ঞপ্তি চালু করুন।';
}
