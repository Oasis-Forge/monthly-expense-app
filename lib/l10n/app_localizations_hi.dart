// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'सेटिंग्स';

  @override
  String get transferTooltip => 'ट्रांसफर';

  @override
  String get searchTooltip => 'खोजें';

  @override
  String get addButton => 'जोड़ें';

  @override
  String get emptyPeriod => 'इस अवधि में अभी तक कोई लेनदेन नहीं।';

  @override
  String get balanceLabel => 'बैलेंस';

  @override
  String get expandSummaryTooltip => 'आय और व्यय दिखाएँ';

  @override
  String get collapseSummaryTooltip => 'केवल बैलेंस दिखाएँ';

  @override
  String get periodNetLabel => 'इस अवधि में';

  @override
  String carriedForwardLine(String amount) {
    return 'कैरी फॉरवर्ड $amount';
  }

  @override
  String get incomeLabel => 'आय';

  @override
  String get expenseLabel => 'खर्च';

  @override
  String upcomingCategory(String category) {
    return '$category · आगामी';
  }

  @override
  String get upcomingLabel => 'आगामी';

  @override
  String detailAdded(String date) {
    return '$date को जोड़ा गया';
  }

  @override
  String detailChanged(String date) {
    return 'आखिरी बदलाव $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकरिंग लेनदेन देय हैं',
      one: '1 रिकरिंग लेनदेन देय है',
      zero: '$count रिकरिंग लेनदेन देय हैं',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent इस्तेमाल · $over सीमा से ऊपर',
      one: '$percent इस्तेमाल · 1 सीमा से ऊपर',
      zero: '$percent इस्तेमाल',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बजट तय',
      one: '1 बजट तय',
      zero: '$count बजट तय',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'लेनदेन हटाया नहीं जा सका। फिर कोशिश करें।';

  @override
  String get transactionDeleted => 'लेनदेन हटाया गया';

  @override
  String get transferDeleted => 'ट्रांसफर हटाया गया';

  @override
  String get undoButton => 'पूर्ववत करें';

  @override
  String get undoFailed => 'पूर्ववत नहीं हो सका। फिर कोशिश करें।';

  @override
  String get restoreFailed => 'लेनदेन रीस्टोर नहीं हो सका। फिर कोशिश करें।';

  @override
  String get restoreTransferFailed =>
      'ट्रांसफ़र वापस नहीं लाया जा सका। फिर कोशिश करें।';

  @override
  String get addTransactionTitle => 'लेनदेन जोड़ें';

  @override
  String get editTransactionTitle => 'लेनदेन एडिट करें';

  @override
  String get transactionDetailTitle => 'विवरण';

  @override
  String get editTooltip => 'एडिट';

  @override
  String get deleteTooltip => 'हटाएं';

  @override
  String get duplicateTooltip => 'डुप्लीकेट';

  @override
  String get rowMenuTooltip => 'और विकल्प';

  @override
  String get deleteTransactionTitle => 'यह लेनदेन हटाएँ?';

  @override
  String get deleteTransactionMessage =>
      'यह ट्रैश में जाएगा और 30 दिनों तक वापस लाया जा सकता है।';

  @override
  String get discardChangesTitle => 'बदलाव छोड़ दें?';

  @override
  String get discardChangesMessage =>
      'आपने यहाँ जो लिखा है वह सहेजा नहीं गया है।';

  @override
  String get discardButton => 'छोड़ें';

  @override
  String get keepEditingButton => 'संपादन जारी रखें';

  @override
  String get titleOptionalLabel => 'शीर्षक (वैकल्पिक)';

  @override
  String get amountLabel => 'राशि';

  @override
  String get amountRequired => 'राशि दर्ज करें';

  @override
  String get amountInvalid => 'मान्य राशि दर्ज करें';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'बैकस्पेस';

  @override
  String get hideKeypadTooltip => 'कीपैड छिपाएं';

  @override
  String get categoryLabel => 'श्रेणी';

  @override
  String get categoryRequired => 'श्रेणी चुनें';

  @override
  String get accountLabel => 'खाता';

  @override
  String get accountRequired => 'खाता चुनें';

  @override
  String get dateLabel => 'तारीख़';

  @override
  String get noteLabel => 'नोट';

  @override
  String get previousDayTooltip => 'पिछला दिन';

  @override
  String get nextDayTooltip => 'अगला दिन';

  @override
  String get noteOptionalLabel => 'नोट (वैकल्पिक)';

  @override
  String get saveChangesButton => 'बदलाव सेव करें';

  @override
  String get addTransactionButton => 'लेनदेन जोड़ें';

  @override
  String get saveAndAddAnotherButton => 'सेव करें और एक और जोड़ें';

  @override
  String get transactionAdded => 'लेनदेन जोड़ा गया';

  @override
  String get saveFailed => 'लेनदेन सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String get noExpensesInPeriod => 'इस अवधि में अभी तक कोई खर्च नहीं।';

  @override
  String totalSpent(String amount) {
    return 'कुल खर्च: $amount';
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
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get drawerAddHeader => 'जोड़ें';

  @override
  String get drawerAddExpense => 'खर्च जोड़ें';

  @override
  String get drawerAddIncome => 'आय जोड़ें';

  @override
  String get drawerPlanHeader => 'योजना';

  @override
  String get drawerReviewHeader => 'समीक्षा';

  @override
  String get drawerSpending => 'श्रेणी अनुसार खर्च';

  @override
  String get drawerManageHeader => 'मैनेज';

  @override
  String get drawerDataHeader => 'डेटा';

  @override
  String get currencyLabel => 'मुद्रा';

  @override
  String get currencySearchHint => 'मुद्रा खोजें';

  @override
  String changeCurrencyTitle(String code) {
    return 'मुद्रा $code में बदलें?';
  }

  @override
  String get changeCurrencyMessage =>
      'राशियां वही रहेंगी; केवल मुद्रा का लेबल बदलेगा।';

  @override
  String get changeButton => 'बदलें';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get saveButton => 'सेव करें';

  @override
  String get removeButton => 'हटाएं';

  @override
  String get themeLabel => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeBlack => 'ब्लैक';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get monthStartLabel => 'महीने का पहला दिन';

  @override
  String get monthStartLastDay => 'आखिरी दिन';

  @override
  String get showCarriedForwardLabel => 'बैलेंस आगे बढ़ाएं';

  @override
  String get showCarriedForwardSubtitle =>
      'हर अवधि पिछले बैलेंस से शुरू होती है';

  @override
  String get trashTitle => 'ट्रैश';

  @override
  String get trashEmpty => 'ट्रैश खाली है।';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों में हमेशा के लिए हट जाएगा',
      one: '1 दिन में हमेशा के लिए हट जाएगा',
      zero: '$days दिनों में हमेशा के लिए हट जाएगा',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों में हमेशा के लिए हट जाएगा',
      one: '1 दिन में हमेशा के लिए हट जाएगा',
      zero: '$days दिनों में हमेशा के लिए हट जाएगा',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => 'रीस्टोर';

  @override
  String get categoriesTitle => 'श्रेणियां';

  @override
  String get addCategoryTooltip => 'श्रेणी जोड़ें';

  @override
  String get addCategoryTitle => 'श्रेणी जोड़ें';

  @override
  String get editCategoryTitle => 'श्रेणी एडिट करें';

  @override
  String get categoryNameLabel => 'नाम';

  @override
  String get categoryNameRequired => 'नाम दर्ज करें';

  @override
  String get categoryNameTaken => 'यह नाम पहले से इस्तेमाल हो रहा है';

  @override
  String get archiveAction => 'आर्काइव करें';

  @override
  String get unarchiveAction => 'आर्काइव से हटाएं';

  @override
  String get deleteAction => 'हटाएं';

  @override
  String get archivedHeader => 'आर्काइव की गईं';

  @override
  String get accountsTotalLabel => 'कुल';

  @override
  String get categorySaveFailed => 'श्रेणी सेव नहीं हो सकी। फिर कोशिश करें।';

  @override
  String get accountsTitle => 'खाते';

  @override
  String get accountCash => 'नकद';

  @override
  String get accountTypeLabel => 'प्रकार';

  @override
  String get accountTypeCash => 'नकद';

  @override
  String get accountTypeBank => 'बैंक';

  @override
  String get accountTypeCard => 'कार्ड';

  @override
  String get accountTypeOther => 'अन्य';

  @override
  String get addAccountTooltip => 'खाता जोड़ें';

  @override
  String get addAccountTitle => 'खाता जोड़ें';

  @override
  String get editAccountTitle => 'खाता एडिट करें';

  @override
  String get openingBalanceLabel => 'शुरुआती बैलेंस';

  @override
  String get openingDateLabel => 'शुरुआत की तारीख़';

  @override
  String get accountSaveFailed => 'खाता सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String get transferTitle => 'ट्रांसफर';

  @override
  String get editTransferTitle => 'ट्रांसफर एडिट करें';

  @override
  String get transferLabel => 'ट्रांसफर';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'किससे';

  @override
  String get toAccountLabel => 'किसको';

  @override
  String get sameAccountError => 'दो अलग खाते चुनें';

  @override
  String get needTwoAccounts =>
      'खातों के बीच पैसे भेजने के लिए एक और खाता जोड़ें।';

  @override
  String get addTransferButton => 'ट्रांसफर जोड़ें';

  @override
  String get transferSaveFailed => 'ट्रांसफर सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String get searchHint => 'लेनदेन खोजें';

  @override
  String get allTypesFilter => 'सभी';

  @override
  String get allCategoriesFilter => 'सभी श्रेणियां';

  @override
  String get allAccountsFilter => 'सभी खाते';

  @override
  String get allTimeFilter => 'हर समय';

  @override
  String get clearDatesTooltip => 'तारीख़ें हटाएं';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नतीजे',
      one: '1 नतीजा',
      zero: '$count नतीजे',
    );
    return '$_temp0 · आय $income · खर्च $expense';
  }

  @override
  String get noSearchResults => 'कोई मिलता-जुलता लेनदेन नहीं।';

  @override
  String get budgetsTitle => 'बजट';

  @override
  String get budgetsTooltip => 'बजट';

  @override
  String get overallBudget => 'कुल';

  @override
  String get noBudget => 'कोई बजट नहीं';

  @override
  String budgetsHint(String period) {
    return 'सीमाएं $period से लागू होंगी; पुरानी अवधियां अपनी सीमा रखेंगी।';
  }

  @override
  String get budgetLimitLabel => 'प्रति अवधि सीमा';

  @override
  String get budgetSaveFailed => 'बजट सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$limit में से $spent';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining बचे · $perDay/दिन';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount खर्च · अब तक $perDay/दिन';
  }

  @override
  String get homeSetBudget => 'मासिक बजट सेट करें';

  @override
  String budgetLeft(String remaining) {
    return '$remaining बचे';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount अधिक खर्च';
  }

  @override
  String get budgetLimitReached => 'सीमा पूरी हो गई';

  @override
  String budgetLimitOnly(String limit) {
    return 'सीमा $limit';
  }

  @override
  String get recurringTitle => 'रिकरिंग';

  @override
  String get addRecurringTooltip => 'रिकरिंग जोड़ें';

  @override
  String get addRecurringTitle => 'रिकरिंग जोड़ें';

  @override
  String get editRecurringTitle => 'रिकरिंग एडिट करें';

  @override
  String get dueHeader => 'देय';

  @override
  String get upcomingHeader => 'अगले 30 दिन';

  @override
  String get rulesHeader => 'नियम';

  @override
  String billsPerMonth(String amount) {
    return 'बिलों में $amount प्रति माह';
  }

  @override
  String nextBillToday(String title) {
    return 'अगला: $title, आज';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'अगला: $title, कल';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'अगला: $title, $days दिनों में',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'अगले 30 दिनों में कुछ नहीं।';

  @override
  String get noRules => 'अभी तक कोई रिकरिंग लेनदेन नहीं।';

  @override
  String get recurringEmptyMessage =>
      'रिकरिंग लेनदेन आपके तय शेड्यूल पर किराया, वेतन या सब्सक्रिप्शन दर्ज करते हैं, और हर बार पुष्टि के लिए एक टैप का इंतज़ार करते हैं।';

  @override
  String get addRecurringButton => 'रिकरिंग लेनदेन जोड़ें';

  @override
  String get postButton => 'पोस्ट करें';

  @override
  String get skipButton => 'छोड़ें';

  @override
  String get postFailed => 'लेनदेन पोस्ट नहीं हो सका। फिर कोशिश करें।';

  @override
  String get recurringSaveFailed =>
      'रिकरिंग लेनदेन सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String get recurringDeleted => 'रिकरिंग लेनदेन हटाया गया';

  @override
  String get everyLabel => 'हर';

  @override
  String get frequencyDays => 'दिन';

  @override
  String get frequencyWeeks => 'हफ्ते';

  @override
  String get frequencyMonths => 'महीने';

  @override
  String get frequencyYears => 'साल';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count दिन',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'हर दिन';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count हफ्ते',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'हर हफ्ते';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count महीने',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'हर महीने';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count साल',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'हर साल';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · रुका हुआ';
  }

  @override
  String get startsLabel => 'शुरुआत';

  @override
  String get endsLabel => 'समाप्ति';

  @override
  String get endNever => 'कभी नहीं';

  @override
  String get endAfter => 'बाद में';

  @override
  String get endOnDate => 'तारीख़ पर';

  @override
  String get timesLabel => 'बार';

  @override
  String get endsOnLabel => 'समाप्ति तारीख़';

  @override
  String get wholeNumberInvalid => '1 से पूरी संख्या दर्ज करें';

  @override
  String wholeNumberRange(int max) {
    return '1 से $max तक पूरी संख्या दर्ज करें';
  }

  @override
  String get endDateInvalid => 'समाप्ति तारीख़ शुरुआत के बाद होनी चाहिए';

  @override
  String get autoPostLabel => 'अपने आप पोस्ट करें';

  @override
  String get autoPostSubtitle => 'वरना यह टैप के लिए देय में रहेगा';

  @override
  String get pauseTooltip => 'पॉज़ करें';

  @override
  String get resumeTooltip => 'फिर शुरू करें';

  @override
  String get categoryFood => 'खाना';

  @override
  String get categoryGroceries => 'किराना';

  @override
  String get categoryTransport => 'ट्रांसपोर्ट';

  @override
  String get categoryShopping => 'शॉपिंग';

  @override
  String get categoryBills => 'बिल';

  @override
  String get categoryRent => 'किराया';

  @override
  String get categoryHealth => 'स्वास्थ्य';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categorySalary => 'सैलरी';

  @override
  String get categoryBusiness => 'बिज़नेस';

  @override
  String get categoryInvestment => 'निवेश';

  @override
  String get categoryGift => 'गिफ्ट';

  @override
  String get categoryOther => 'अन्य';

  @override
  String get previousPeriodTooltip => 'पिछली अवधि';

  @override
  String get wholePeriodTooltip => 'पूरी अवधि दिखाएँ';

  @override
  String get nextPeriodTooltip => 'अगली अवधि';

  @override
  String get insightsTooltip => 'इनसाइट्स';

  @override
  String get insightsTitle => 'इनसाइट्स';

  @override
  String get calendarTab => 'कैलेंडर';

  @override
  String get trendTab => 'ट्रेंड';

  @override
  String get noIncomeInPeriod => 'इस अवधि में अभी तक कोई आय नहीं।';

  @override
  String totalIncome(String amount) {
    return 'कुल आय: $amount';
  }

  @override
  String comparedMore(String amount) {
    return 'पिछले महीने से $amount अधिक';
  }

  @override
  String comparedLess(String amount) {
    return 'पिछले महीने से $amount कम';
  }

  @override
  String get comparedSame => 'पिछले महीने जितना ही';

  @override
  String get categoryNewLabel => 'नया';

  @override
  String get calendarHint => 'लेनदेन देखने के लिए किसी दिन पर टैप करें।';

  @override
  String get dayEmpty => 'इस दिन कुछ नहीं।';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महीने',
      one: '1 महीना',
      zero: '$count महीने',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'आय $income · खर्च $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'प्रति अवधि औसत · आय $income · खर्च $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'ट्रेंड के लिए एक से ज़्यादा अवधि चाहिए। अगले महीने वापस आएं।';

  @override
  String get weekStartLabel => 'हफ्ते का पहला दिन';

  @override
  String weekStartDefault(String day) {
    return 'डिफ़ॉल्ट ($day)';
  }

  @override
  String get firstRunTitle => 'Monthly Expenses में आपका स्वागत है';

  @override
  String get firstRunMessage =>
      'अपना खर्च और कमाई ट्रैक करें। आपका डेटा इसी डिवाइस पर रहता है।';

  @override
  String get addFirstTransactionButton => 'अपना पहला लेनदेन जोड़ें';

  @override
  String get setupIntro =>
      'अपनी भाषा और मुद्रा चुनें। इन्हें बाद में सेटिंग्स में बदला जा सकता है।';

  @override
  String get setupContinueButton => 'जारी रखें';

  @override
  String get setupRestoreTitle => 'बैकअप रीस्टोर करें';

  @override
  String get setupRestoreSubtitle =>
      'बैकअप फ़ाइल से अपना डेटा और सेटिंग्स वापस लाएं';

  @override
  String get walkthroughEntryTitle => 'सेकंडों में जोड़ें';

  @override
  String get walkthroughEntryBody =>
      'जोड़ने वाला कीपैड, रसीद की फोटो, और टाइप करना धीमा हो तो वॉइस नोट।';

  @override
  String get walkthroughPlanTitle => 'महीने की योजना बनाएं';

  @override
  String get walkthroughPlanBody =>
      'श्रेणी अनुसार बजट, अपने आप दोहराने वाले बिल, और याद दिलाने वाले नोट।';

  @override
  String get walkthroughInsightsTitle => 'देखें पैसा कहां जाता है';

  @override
  String get walkthroughInsightsBody =>
      'चार्ट, कैलेंडर, और किसी भी अवधि के लिए PDF या CSV रिपोर्ट।';

  @override
  String get walkthroughPrivacyTitle => 'सिर्फ़ आपका';

  @override
  String get walkthroughPrivacyBody =>
      'किसी खाते की ज़रूरत नहीं। आप जो दर्ज करते हैं वह इसी फ़ोन में रहता है; ऐप को चलाने वाले विज्ञापन इसे कभी नहीं देखते।';

  @override
  String get walkthroughBringTitle => 'जो है उसे साथ लाएं';

  @override
  String get walkthroughBringBody =>
      'किसी और ऐप या फ़ोन से आ रहे हैं? खाली ऐप की जगह बैकअप या CSV से शुरू करें।';

  @override
  String get firstRunRestoreTitle => 'यह बैकअप रीस्टोर करें?';

  @override
  String get firstRunRestoreMessage =>
      'यह ऐप में मौजूद सब कुछ बदल देगा, और जिस भाषा व मुद्रा में यह सेव हुआ था वे वापस लाएगा।';

  @override
  String get walkthroughNextButton => 'अगला';

  @override
  String get walkthroughStartButton => 'शुरू करें';

  @override
  String get walkthroughDoneButton => 'हो गया';

  @override
  String walkthroughProgress(int current, int total) {
    return 'पेज $current / $total';
  }

  @override
  String get walkthroughReplayTitle => 'वॉकथ्रू फिर देखें';

  @override
  String get walkthroughReplaySubtitle => 'ऐप नया होने पर दिखाए गए चार पेज';

  @override
  String get removeAdsTitle => 'विज्ञापन हटाएं';

  @override
  String get exportCsvMenu => 'CSV एक्सपोर्ट करें';

  @override
  String get exportCsvTooltip => 'CSV एक्सपोर्ट करें';

  @override
  String get csvExported => 'CSV सेव हुई';

  @override
  String get csvExportFailed => 'CSV एक्सपोर्ट नहीं हो सकी। फिर कोशिश करें।';

  @override
  String get backupTitle => 'बैकअप और रीस्टोर';

  @override
  String get backupIntro =>
      'बैकअप ऐसी फ़ाइलें हैं जिन्हें आप खुद चुनी जगह पर सेव करते हैं। कुछ भी अपने आप अपलोड या भेजा नहीं जाता।';

  @override
  String get backUpNowTitle => 'अभी बैकअप लें';

  @override
  String lastBackupLine(String date) {
    return 'आखिरी बैकअप $date';
  }

  @override
  String get neverBackedUp => 'अभी तक कोई बैकअप नहीं';

  @override
  String get backupSaved => 'बैकअप सेव हुआ';

  @override
  String get backupSaveFailed => 'बैकअप सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String get restoreFromFileTitle => 'फ़ाइल से रीस्टोर करें';

  @override
  String get restoreFromFileSubtitle =>
      'बैकअप को अपने डेटा में मर्ज करें, या अपने डेटा को इससे बदलें';

  @override
  String get backupReminderLabel => 'बैकअप रिमाइंडर';

  @override
  String get backupReminderSubtitle => '20 लेनदेन होने के बाद हर 30 दिनों में';

  @override
  String get backupReminderNever => 'डेटा सुरक्षित रखने के लिए बैकअप लें';

  @override
  String backupReminderSince(String date) {
    return 'आखिरी बैकअप $date। नया बैकअप लेने का समय?';
  }

  @override
  String get notNowTooltip => 'अभी नहीं';

  @override
  String get keptBackupsHeader => 'ऑटोमैटिक बैकअप';

  @override
  String get keptBackupsHint => 'हर रीस्टोर से पहले इसी डिवाइस पर सेव किए गए।';

  @override
  String get noKeptBackups => 'अभी तक कोई नहीं।';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लेनदेन',
      one: '1 लेनदेन',
      zero: '$count लेनदेन',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'बैकअप रीस्टोर करें';

  @override
  String get mergeOption => 'मर्ज करें';

  @override
  String get mergeOptionSubtitle =>
      'अपना डेटा रखें और बैकअप का डेटा जोड़ें। जहां दोनों में एक ही रिकॉर्ड हो, वहां नया बदलाव मान्य होगा।';

  @override
  String get replaceOption => 'रिप्लेस करें';

  @override
  String get replaceOptionSubtitle =>
      'अपना डेटा हटाएं और सिर्फ़ बैकअप का डेटा व सेटिंग्स इस्तेमाल करें।';

  @override
  String get restoreSafetyNote =>
      'आपके मौजूदा डेटा की एक कॉपी पहले ऑटोमैटिक बैकअप में सेव होती है।';

  @override
  String get restoreButton => 'रीस्टोर करें';

  @override
  String get restoreKeptTitle => 'यह कॉपी रीस्टोर करें?';

  @override
  String restoreKeptMessage(String date) {
    return 'आपका डेटा $date की कॉपी से बदल जाएगा। आपके मौजूदा डेटा की एक कॉपी पहले सेव होगी।';
  }

  @override
  String get backupInvalid => 'यह फ़ाइल Monthly Expenses का बैकअप नहीं है।';

  @override
  String get backupTooNew =>
      'यह बैकअप ऐप के नए वर्शन से है। ऐप अपडेट करें, फिर कोशिश करें।';

  @override
  String get backupOpenFailed => 'फ़ाइल नहीं खुल सकी। फिर कोशिश करें।';

  @override
  String get backupRestoreFailed =>
      'बैकअप रीस्टोर नहीं हो सका। आपका डेटा नहीं बदला गया।';

  @override
  String get dbTooNewTitle => 'अपडेट आवश्यक है';

  @override
  String get dbTooNewMessage =>
      'यह डेटा ऐप के नए संस्करण द्वारा सहेजा गया था। जारी रखने के लिए स्टोर से ऐप को अपडेट करें।';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लेनदेन रीस्टोर हुए',
      one: '1 लेनदेन रीस्टोर हुआ',
      zero: '$count लेनदेन रीस्टोर हुए',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'मर्ज हुआ: $added जोड़े गए, $updated अपडेट हुए, $unchanged अपरिवर्तित';
  }

  @override
  String get appLockLabel => 'ऐप लॉक';

  @override
  String get appLockSubtitle => 'फिंगरप्रिंट, फेस या स्क्रीन लॉक से अनलॉक करें';

  @override
  String get appLockUnavailable =>
      'ऐप लॉक इस्तेमाल करने के लिए इस डिवाइस पर स्क्रीन लॉक सेट करें';

  @override
  String get appLockReason => 'Monthly Expenses अनलॉक करें';

  @override
  String get appLockPromptHint => 'अपनी पहचान की पुष्टि करें';

  @override
  String get appLockFailed =>
      'आपकी पहचान की पुष्टि नहीं हो सकी। ऐप लॉक नहीं बदला गया।';

  @override
  String get lockedTitle => 'Monthly Expenses लॉक है';

  @override
  String get unlockButton => 'अनलॉक करें';

  @override
  String get widgetShowAmountsLabel => 'विजेट पर राशि दिखाएं';

  @override
  String get widgetShowAmountsSubtitle =>
      'ऐप लॉक चालू होने पर होम-स्क्रीन विजेट राशि छिपाता है';

  @override
  String get widgetLeftLabel => 'बचा हुआ';

  @override
  String get widgetAddExpense => 'खर्च जोड़ें';

  @override
  String get widgetAddIncome => 'आय जोड़ें';

  @override
  String get widgetAmountsHidden => 'ऐप लॉक के कारण राशि छिपी है';

  @override
  String get notesTitle => 'नोट्स';

  @override
  String get addNoteTooltip => 'नोट जोड़ें';

  @override
  String get addNoteTitle => 'नोट जोड़ें';

  @override
  String get editNoteTitle => 'नोट एडिट करें';

  @override
  String get noteTextLabel => 'नोट';

  @override
  String get noteTextRequired => 'कुछ टेक्स्ट लिखें';

  @override
  String get noteAmountOptionalLabel => 'राशि (वैकल्पिक)';

  @override
  String get noteDueDateToggle => 'देय तारीख़ तय करें';

  @override
  String get noteDueDateLabel => 'देय तारीख़';

  @override
  String get noteReminderToggle => 'मुझे याद दिलाएं';

  @override
  String get noteReminderTimeLabel => 'रिमाइंडर का समय';

  @override
  String get noteReminderTimeUnset => 'समय चुनें';

  @override
  String get reminderMayBeLate => 'आपका फ़ोन इसे कुछ मिनट देर से भेज सकता है।';

  @override
  String get noteCategoryOptionalLabel => 'श्रेणी (वैकल्पिक)';

  @override
  String get noteCategoryNone => 'कोई नहीं';

  @override
  String get recordNoteButton => 'लेनदेन के रूप में दर्ज करें';

  @override
  String get noteMarkDoneTooltip => 'पूरा करें';

  @override
  String get noteMarkOpenTooltip => 'फिर से खोलें';

  @override
  String get notesEmptyTitle => 'अभी यहां कुछ नहीं';

  @override
  String get notesEmptyMessage =>
      'नोट्स आपको करने या जांचने वाली बातें याद दिलाते हैं, साथ में तारीख़, राशि और श्रेणी वैकल्पिक हैं।';

  @override
  String get addNoteButton => 'एक नोट जोड़ें';

  @override
  String get notesOpenHeader => 'खुले';

  @override
  String get notesDoneHeader => 'पूरे हुए';

  @override
  String get noteDeleted => 'नोट हटाया गया।';

  @override
  String get noteSaveFailed => 'नोट सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String get noteDeleteFailed => 'नोट हटाया नहीं जा सका। फिर कोशिश करें।';

  @override
  String get noteRestoreFailed => 'नोट रीस्टोर नहीं हो सका। फिर कोशिश करें।';

  @override
  String get notesSearchHint => 'नोट्स खोजें';

  @override
  String get noteFilterAll => 'सभी';

  @override
  String get noteFilterOverdue => 'ओवरड्यू';

  @override
  String get noteFilterDueToday => 'आज देय';

  @override
  String get noteFilterUpcoming => 'आगामी';

  @override
  String get noteFilterNoDate => 'बिना तारीख़';

  @override
  String get noNoteResults => 'कोई मिलता-जुलता नोट नहीं।';

  @override
  String get noteLinkedTransactionLabel => 'लेनदेन के रूप में दर्ज किया गया';

  @override
  String get noteLinkedNoteLabel => 'एक नोट से';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नोट देय हैं',
      one: '1 नोट देय है',
      zero: '$count नोट देय हैं',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'देय नोट्स';

  @override
  String get noteReminderTitle => 'नोट रिमाइंडर';

  @override
  String get noteReminderLockedTitle => 'एक नोट देय है';

  @override
  String get noteReminderChannelName => 'नोट रिमाइंडर';

  @override
  String get noteReminderPermissionDenied =>
      'नोट रिमाइंडर पाने के लिए सिस्टम सेटिंग्स में नोटिफिकेशन चालू करें।';

  @override
  String reportRange(String from, String to) {
    return '$from से $to';
  }

  @override
  String reportCreated(String when) {
    return '$when को बनाई गई';
  }

  @override
  String reportNarrowedTo(String description) {
    return 'सीमित: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'पेज $page / $pages';
  }

  @override
  String get reportNet => 'नेट';

  @override
  String get reportMatchingIncome => 'मिलान आय';

  @override
  String get reportMatchingExpense => 'मिलान व्यय';

  @override
  String get reportMatchingNet => 'मिलान शुद्ध';

  @override
  String get reportOpeningBalance => 'शुरुआती बैलेंस';

  @override
  String get reportClosingBalance => 'अंतिम बैलेंस';

  @override
  String get reportSpendingHeader => 'श्रेणी अनुसार खर्च';

  @override
  String get reportEarningHeader => 'श्रेणी अनुसार आय';

  @override
  String get reportTrendHeader => 'ट्रेंड';

  @override
  String get reportEntriesHeader => 'लेनदेन';

  @override
  String get reportUpcomingHeader => 'आगामी';

  @override
  String get reportUpcomingNote =>
      'आगे की तारीख़ का, इसलिए ऊपर के कुल में नहीं गिना गया।';

  @override
  String get reportAmountColumn => 'राशि';

  @override
  String get reportShareColumn => 'हिस्सा';

  @override
  String get reportBudgetColumn => 'बजट';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$limit में से $used';
  }

  @override
  String get reportDetailsColumn => 'विवरण';

  @override
  String get reportEmpty => 'इन तारीख़ों के लिए कुछ भी रिपोर्ट करने को नहीं।';

  @override
  String get exportPdfMenu => 'PDF एक्सपोर्ट करें';

  @override
  String get reportTitle => 'PDF एक्सपोर्ट करें';

  @override
  String get reportNoFontTitle => 'इस भाषा में अभी नहीं';

  @override
  String get reportNoFontBody =>
      'रिपोर्ट के लिए उसकी लिपि का फ़ॉन्ट चाहिए, और चीनी, जापानी तथा कोरियाई फ़ॉन्ट ऐप में रखने के लिए बहुत बड़े हैं। आगे का कोई संस्करण इसे डाउनलोड करने का विकल्प देगा।';

  @override
  String get reportPreviewTitle => 'रिपोर्ट';

  @override
  String get reportCoversHeader => 'इसमें क्या शामिल है';

  @override
  String get reportNarrowedNotice => 'यह रिपोर्ट आपकी खोज तक सीमित रहती है।';

  @override
  String get reportRangePeriod => 'इस अवधि';

  @override
  String get reportRangeCustom => 'तारीख़ें';

  @override
  String get reportRangeYear => 'साल';

  @override
  String get reportFromLabel => 'से';

  @override
  String get reportToLabel => 'तक';

  @override
  String get reportYearLabel => 'साल';

  @override
  String get reportAccountLabel => 'खाता';

  @override
  String get reportAllAccounts => 'सभी खाते';

  @override
  String get reportIncludeHeader => 'इसमें क्या जोड़ें';

  @override
  String get reportIncludeSubtitle => 'जो साझा नहीं करना चाहते उसे हटा दें।';

  @override
  String get reportIncludeTransactions => 'लेनदेन की सूची';

  @override
  String get reportIncludeDetails => 'शीर्षक और नोट';

  @override
  String get reportIncludeAccounts => 'खातों के नाम';

  @override
  String get reportCreateButton => 'रिपोर्ट बनाएं';

  @override
  String get reportBuilding => 'रिपोर्ट बन रही है';

  @override
  String get reportFailed => 'रिपोर्ट नहीं बन सकी। फिर कोशिश करें।';

  @override
  String get reportRangeBackwards =>
      'पहली तारीख़ आखिरी तारीख़ से पहले होनी चाहिए।';

  @override
  String get importTitle => 'CSV इम्पोर्ट करें';

  @override
  String get importSubtitle => 'किसी और ऐप से लेनदेन लाएं';

  @override
  String get importIntro =>
      'एक CSV फ़ाइल चुनें और कुछ भी जोड़े जाने से पहले देखें कि ऐप ने उसे कैसे पढ़ा। इम्पोर्ट सिर्फ़ रिकॉर्ड जोड़ता है — यह आपका मौजूदा डेटा कभी नहीं बदलता या हटाता।';

  @override
  String get importChooseFile => 'फ़ाइल चुनें';

  @override
  String get importChooseAnother => 'दूसरी फ़ाइल चुनें';

  @override
  String get importReadFailed => 'वह फ़ाइल नहीं पढ़ी जा सकी। फिर कोशिश करें।';

  @override
  String get importRefusedEmpty => 'उस फ़ाइल में कुछ भी नहीं है।';

  @override
  String get importRefusedNoDate =>
      'उस फ़ाइल का कोई कॉलम तारीख़ के रूप में नहीं पढ़ा जा सका, इसलिए इसे इम्पोर्ट नहीं किया जा सकता।';

  @override
  String get importRefusedNoAmount =>
      'उस फ़ाइल का कोई कॉलम राशि के रूप में नहीं पढ़ा जा सका, इसलिए इसे इम्पोर्ट नहीं किया जा सकता।';

  @override
  String get importRefusedNoRows =>
      'उस फ़ाइल की कोई भी पंक्ति नहीं पढ़ी जा सकी, इसलिए इम्पोर्ट करने को कुछ नहीं है।';

  @override
  String get importColumnsHeader => 'कॉलम';

  @override
  String get importColumnsSubtitle => 'ऐप ने जो गलत पढ़ा उसे बदलें।';

  @override
  String get importColumnNone => 'इस्तेमाल नहीं';

  @override
  String get importFieldType => 'प्रकार';

  @override
  String get importFieldToAccount => 'किस खाते में';

  @override
  String get importFieldTitle => 'शीर्षक';

  @override
  String get importFieldNote => 'नोट';

  @override
  String get importDateOrderLabel => '03/04 जैसी तारीख़ों का मतलब';

  @override
  String get importDayFirst => 'पहले दिन';

  @override
  String get importMonthFirst => 'पहले महीना';

  @override
  String get importCountsHeader => 'क्या होगा';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियां इम्पोर्ट होंगी',
      one: '1 पंक्ति इम्पोर्ट होगी',
      zero: 'कुछ भी इम्पोर्ट नहीं होगा',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियों की तारीख़ ऐप नहीं पढ़ सकता',
      one: '1 पंक्ति की तारीख़ ऐप नहीं पढ़ सकता',
      zero: '$count पंक्तियों की तारीख़ ऐप नहीं पढ़ सकता',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियों की राशि ऐप नहीं पढ़ सकता',
      one: '1 पंक्ति की राशि ऐप नहीं पढ़ सकता',
      zero: '$count पंक्तियों की राशि ऐप नहीं पढ़ सकता',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियों में कोई राशि नहीं है',
      one: '1 पंक्ति में कोई राशि नहीं है',
      zero: '$count पंक्तियों में कोई राशि नहीं है',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियां पहले से ऐप में हैं',
      one: '1 पंक्ति पहले से ऐप में है',
      zero: '$count पंक्तियां पहले से ऐप में हैं',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रांसफर में सिर्फ़ एक खाता है',
      one: '1 ट्रांसफर में सिर्फ़ एक खाता है',
      zero: '$count ट्रांसफर में सिर्फ़ एक खाता है',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'तारीख़ नहीं पढ़ी जा सकी';

  @override
  String get importRowUnreadableAmount => 'राशि नहीं पढ़ी जा सकी';

  @override
  String get importRowZero => 'कोई राशि नहीं';

  @override
  String get importRowAlreadyThere => 'पहले से ऐप में है';

  @override
  String get importRowIncompleteTransfer => 'सिर्फ़ एक खाता बताया गया';

  @override
  String get importNamesHeader => 'नाम जो इस ऐप में नहीं हैं';

  @override
  String get importNamesSubtitle =>
      'चुनें हर एक क्या बनेगा। इम्पोर्ट कभी कोई श्रेणी या खाता नहीं बनाता।';

  @override
  String get importRowsHeader => 'पहली पंक्तियां, जैसे ऐप ने पढ़ीं';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count और',
      one: '1 और',
      zero: '$count और',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियां इम्पोर्ट करें',
      one: '1 पंक्ति इम्पोर्ट करें',
      zero: 'इम्पोर्ट करने को कुछ नहीं',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्ड इम्पोर्ट हुए',
      one: '1 रिकॉर्ड इम्पोर्ट हुआ',
      zero: '$count रिकॉर्ड इम्पोर्ट हुए',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'वह फ़ाइल इम्पोर्ट नहीं हो सकी। कुछ भी नहीं जोड़ा गया।';

  @override
  String get attachmentsLabel => 'अटैचमेंट';

  @override
  String get photoLabel => 'फोटो';

  @override
  String get photoAdd => 'फोटो जोड़ें';

  @override
  String get photoTake => 'फोटो खींचें';

  @override
  String get photoChoose => 'फोटो चुनें';

  @override
  String get photoRemove => 'फोटो हटाएं';

  @override
  String get photoMissing => 'यह फोटो मौजूद नहीं है।';

  @override
  String get voiceNoteLabel => 'वॉइस नोट';

  @override
  String get voiceRecord => 'वॉइस नोट रिकॉर्ड करें';

  @override
  String voiceRecording(int seconds) {
    return 'रिकॉर्ड हो रहा है, $seconds सेकंड बाकी';
  }

  @override
  String get voiceStop => 'रोकें';

  @override
  String get voicePlay => 'चलाएं';

  @override
  String get voicePause => 'पॉज़ करें';

  @override
  String get voiceRemove => 'वॉइस नोट हटाएं';

  @override
  String get voiceMissing => 'यह वॉइस नोट मौजूद नहीं है।';

  @override
  String get microphoneRefused => 'इस ऐप के लिए माइक्रोफ़ोन बंद है।';

  @override
  String backupIncludesAttachments(String size) {
    return 'अटैचमेंट शामिल हैं, $size MB';
  }

  @override
  String get removeAdsBody =>
      'एक बार भुगतान करते ही सभी विज्ञापन हट जाते हैं। यह आपके स्टोर खाते से जुड़ा है, इसलिए नया फ़ोन लेने या फिर से इंस्टॉल करने पर भी वापस आ जाता है।';

  @override
  String removeAdsBuyButton(String price) {
    return '$price में विज्ञापन हटाएं';
  }

  @override
  String get removeAdsOwned => 'विज्ञापन बंद हैं। धन्यवाद।';

  @override
  String get removeAdsPending => 'स्टोर की प्रतीक्षा हो रही है…';

  @override
  String get removeAdsUnavailable =>
      'स्टोर में अभी यहाँ बेचने के लिए कुछ नहीं है। बाद में फिर कोशिश करें।';

  @override
  String get removeAdsFailed =>
      'यह पूरा नहीं हुआ, और आपसे कोई शुल्क नहीं लिया गया।';

  @override
  String get restorePurchasesButton => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get payNothingWithheld =>
      'विज्ञापन हों या न हों, सभी सुविधाएं हमेशा मुफ़्त रहेंगी।';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'जल्द आ रहा है';

  @override
  String get plusBody =>
      'एक बैंक कनेक्शन जो लेन-देन लाकर पुष्टि के लिए दिखाता है। यह अभी पूरा नहीं हुआ, इसलिए खरीदने के लिए कुछ नहीं है।';

  @override
  String get privacyOptionsTitle => 'गोपनीयता विकल्प';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get privacyOptionsSubtitle =>
      'व्यक्तिगत विज्ञापनों के बारे में अपनी पसंद बदलें';

  @override
  String get dueEntryReminderTitle => 'एक प्रविष्टि बाकी थी';

  @override
  String get dueEntryChannelName => 'बकाया प्रविष्टियाँ';

  @override
  String dueEntryReminderOne(String title) {
    return '$title आज देय था और अभी भी प्रतीक्षा में है।';
  }

  @override
  String get dueEntryReminderUntitled =>
      'एक आवर्ती प्रविष्टि आज देय थी और अभी भी प्रतीक्षा में है।';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आवर्ती प्रविष्टियाँ आज देय थीं।',
      one: '1 आवर्ती प्रविष्टि आज देय थी।',
      zero: '$count आवर्ती प्रविष्टियाँ आज देय थीं।',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'आज कुछ भी दर्ज नहीं हुआ';

  @override
  String get emptyDayChannelName => 'बिना रिकॉर्ड वाले दिन';

  @override
  String get emptyDayReminderBody => 'जब तक याद है, अपना खर्च जोड़ लें।';

  @override
  String get reminderLockedTitle => 'कुछ आपका इंतज़ार कर रहा है';

  @override
  String get nudgeSettingsTitle => 'खाली दिन मुझे याद दिलाएं';

  @override
  String get nudgeSettingsSubtitle =>
      'शाम को एक याद दिलाना, और केवल उस दिन जब कुछ भी दर्ज न हो।';

  @override
  String get nudgeOfferTitle => 'जिन दिनों आप भूल जाते हैं, याद दिलाना?';

  @override
  String get nudgeOfferBody =>
      'आपके चुने समय पर एक याद दिलाना, केवल उस दिन जब कुछ भी दर्ज न हो। जब चाहें बंद कर दें।';

  @override
  String get nudgeOfferYes => 'हां, याद दिलाएं';

  @override
  String get nudgeOfferNo => 'नहीं';

  @override
  String get nudgeStoppedNotice =>
      'तीन बार अनुत्तरित रहने पर याद दिलाना बंद हो गया। जब चाहें फिर चालू करें।';

  @override
  String get nudgePermissionDenied =>
      'याद दिलाने के लिए सिस्टम सेटिंग्स में सूचनाएं चालू करें।';

  @override
  String get updateDownloadedMessage => 'एक अपडेट डाउनलोड हो चुका है।';

  @override
  String get updateRestartButton => 'रीस्टार्ट करें';
}
