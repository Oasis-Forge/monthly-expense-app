// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Ρυθμίσεις';

  @override
  String get transferTooltip => 'Μεταφορά';

  @override
  String get searchTooltip => 'Αναζήτηση';

  @override
  String get addButton => 'Προσθήκη';

  @override
  String get emptyPeriod => 'Δεν υπάρχουν συναλλαγές σε αυτή την περίοδο.';

  @override
  String get balanceLabel => 'Υπόλοιπο';

  @override
  String get periodNetLabel => 'Αυτή η περίοδος';

  @override
  String carriedForwardLine(String amount) {
    return 'Μεταφορά υπολοίπου $amount';
  }

  @override
  String get incomeLabel => 'Έσοδα';

  @override
  String get expenseLabel => 'Έξοδα';

  @override
  String upcomingCategory(String category) {
    return '$category · Προσεχώς';
  }

  @override
  String get upcomingLabel => 'Προσεχώς';

  @override
  String detailAdded(String date) {
    return 'Προστέθηκε $date';
  }

  @override
  String detailChanged(String date) {
    return 'Τελευταία αλλαγή $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count επαναλαμβανόμενες συναλλαγές εκκρεμούν',
      one: '1 επαναλαμβανόμενη συναλλαγή εκκρεμεί',
    );
    return '$_temp0';
  }

  @override
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count προϋπολογισμοί ξεπέρασαν το όριό τους',
      one: '1 προϋπολογισμός ξεπέρασε το όριό του',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent σε χρήση · $over πάνω από το όριο',
      one: '$percent σε χρήση · 1 πάνω από το όριο',
      zero: '$percent σε χρήση',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count προϋπολογισμοί ορίστηκαν',
      one: '1 προϋπολογισμός ορίστηκε',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed =>
      'Δεν ήταν δυνατή η διαγραφή της συναλλαγής. Δοκιμάστε ξανά.';

  @override
  String get transactionDeleted => 'Η συναλλαγή διαγράφηκε';

  @override
  String get transferDeleted => 'Η μεταφορά διαγράφηκε';

  @override
  String get undoButton => 'Αναίρεση';

  @override
  String get undoFailed => 'Δεν ήταν δυνατή η αναίρεση. Δοκιμάστε ξανά.';

  @override
  String get restoreFailed =>
      'Δεν ήταν δυνατή η επαναφορά της συναλλαγής. Δοκιμάστε ξανά.';

  @override
  String get addTransactionTitle => 'Προσθήκη συναλλαγής';

  @override
  String get editTransactionTitle => 'Επεξεργασία συναλλαγής';

  @override
  String get transactionDetailTitle => 'Λεπτομέρειες';

  @override
  String get editTooltip => 'Επεξεργασία';

  @override
  String get deleteTooltip => 'Διαγραφή';

  @override
  String get duplicateTooltip => 'Αντιγραφή';

  @override
  String get titleOptionalLabel => 'Τίτλος (προαιρετικό)';

  @override
  String get amountLabel => 'Ποσό';

  @override
  String get amountRequired => 'Εισαγάγετε ένα ποσό';

  @override
  String get amountInvalid => 'Εισαγάγετε έγκυρο ποσό';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Διαγραφή';

  @override
  String get hideKeypadTooltip => 'Απόκρυψη πληκτρολογίου';

  @override
  String get categoryLabel => 'Κατηγορία';

  @override
  String get categoryRequired => 'Επιλέξτε κατηγορία';

  @override
  String get accountLabel => 'Λογαριασμός';

  @override
  String get accountRequired => 'Επιλέξτε λογαριασμό';

  @override
  String get dateLabel => 'Ημερομηνία';

  @override
  String get noteLabel => 'Σημείωση';

  @override
  String get previousDayTooltip => 'Προηγούμενη ημέρα';

  @override
  String get nextDayTooltip => 'Επόμενη ημέρα';

  @override
  String get noteOptionalLabel => 'Σημείωση (προαιρετικό)';

  @override
  String get saveChangesButton => 'Αποθήκευση αλλαγών';

  @override
  String get addTransactionButton => 'Προσθήκη συναλλαγής';

  @override
  String get saveAndAddAnotherButton => 'Αποθήκευση & προσθήκη άλλης';

  @override
  String get transactionAdded => 'Η συναλλαγή προστέθηκε';

  @override
  String get saveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση της συναλλαγής. Δοκιμάστε ξανά.';

  @override
  String get noExpensesInPeriod => 'Δεν υπάρχουν έξοδα σε αυτή την περίοδο.';

  @override
  String totalSpent(String amount) {
    return 'Σύνολο εξόδων: $amount';
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
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get drawerAddHeader => 'Προσθήκη';

  @override
  String get drawerAddExpense => 'Προσθήκη εξόδου';

  @override
  String get drawerAddIncome => 'Προσθήκη εσόδου';

  @override
  String get drawerPlanHeader => 'Σχεδιασμός';

  @override
  String get drawerReviewHeader => 'Ανασκόπηση';

  @override
  String get drawerSpending => 'Έξοδα ανά κατηγορία';

  @override
  String get drawerManageHeader => 'Διαχείριση';

  @override
  String get drawerDataHeader => 'Δεδομένα';

  @override
  String get currencyLabel => 'Νόμισμα';

  @override
  String get currencySearchHint => 'Αναζήτηση νομισμάτων';

  @override
  String changeCurrencyTitle(String code) {
    return 'Αλλαγή νομίσματος σε $code;';
  }

  @override
  String get changeCurrencyMessage =>
      'Τα ποσά παραμένουν ίδια, αλλάζει μόνο η ετικέτα νομίσματος.';

  @override
  String get changeButton => 'Αλλαγή';

  @override
  String get cancelButton => 'Ακύρωση';

  @override
  String get saveButton => 'Αποθήκευση';

  @override
  String get removeButton => 'Αφαίρεση';

  @override
  String get themeLabel => 'Θέμα';

  @override
  String get themeSystem => 'Συστήματος';

  @override
  String get themeLight => 'Ανοιχτό';

  @override
  String get themeDark => 'Σκούρο';

  @override
  String get languageLabel => 'Γλώσσα';

  @override
  String get languageSystem => 'Προεπιλογή συστήματος';

  @override
  String get monthStartLabel => 'Πρώτη ημέρα του μήνα';

  @override
  String get monthStartLastDay => 'Τελευταία ημέρα';

  @override
  String get showCarriedForwardLabel => 'Μεταφορά υπολοίπου';

  @override
  String get showCarriedForwardSubtitle =>
      'Κάθε περίοδος ξεκινά από το προηγούμενο υπόλοιπο';

  @override
  String get trashTitle => 'Κάδος απορριμμάτων';

  @override
  String get trashEmpty => 'Ο κάδος είναι άδειος.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'διαγράφεται οριστικά σε $days ημέρες',
      one: 'διαγράφεται οριστικά σε 1 ημέρα',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Επαναφορά';

  @override
  String get categoriesTitle => 'Κατηγορίες';

  @override
  String get addCategoryTooltip => 'Προσθήκη κατηγορίας';

  @override
  String get addCategoryTitle => 'Προσθήκη κατηγορίας';

  @override
  String get editCategoryTitle => 'Επεξεργασία κατηγορίας';

  @override
  String get categoryNameLabel => 'Όνομα';

  @override
  String get categoryNameRequired => 'Εισαγάγετε ένα όνομα';

  @override
  String get categoryNameTaken => 'Αυτό το όνομα χρησιμοποιείται ήδη';

  @override
  String get archiveAction => 'Αρχειοθέτηση';

  @override
  String get unarchiveAction => 'Αναίρεση αρχειοθέτησης';

  @override
  String get deleteAction => 'Διαγραφή';

  @override
  String get archivedHeader => 'Αρχειοθετημένα';

  @override
  String get categorySaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση της κατηγορίας. Δοκιμάστε ξανά.';

  @override
  String get accountsTitle => 'Λογαριασμοί';

  @override
  String get accountCash => 'Μετρητά';

  @override
  String get accountTypeLabel => 'Τύπος';

  @override
  String get accountTypeCash => 'Μετρητά';

  @override
  String get accountTypeBank => 'Τράπεζα';

  @override
  String get accountTypeCard => 'Κάρτα';

  @override
  String get accountTypeOther => 'Άλλο';

  @override
  String get addAccountTooltip => 'Προσθήκη λογαριασμού';

  @override
  String get addAccountTitle => 'Προσθήκη λογαριασμού';

  @override
  String get editAccountTitle => 'Επεξεργασία λογαριασμού';

  @override
  String get openingBalanceLabel => 'Αρχικό υπόλοιπο';

  @override
  String get openingDateLabel => 'Ημερομηνία έναρξης';

  @override
  String get accountSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση του λογαριασμού. Δοκιμάστε ξανά.';

  @override
  String get transferTitle => 'Μεταφορά';

  @override
  String get editTransferTitle => 'Επεξεργασία μεταφοράς';

  @override
  String get transferLabel => 'Μεταφορά';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Από';

  @override
  String get toAccountLabel => 'Προς';

  @override
  String get sameAccountError => 'Επιλέξτε δύο διαφορετικούς λογαριασμούς';

  @override
  String get needTwoAccounts =>
      'Προσθέστε δεύτερο λογαριασμό για μεταφορά χρημάτων μεταξύ λογαριασμών.';

  @override
  String get addTransferButton => 'Προσθήκη μεταφοράς';

  @override
  String get transferSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση της μεταφοράς. Δοκιμάστε ξανά.';

  @override
  String get searchHint => 'Αναζήτηση συναλλαγών';

  @override
  String get allTypesFilter => 'Όλα';

  @override
  String get allCategoriesFilter => 'Όλες οι κατηγορίες';

  @override
  String get allAccountsFilter => 'Όλοι οι λογαριασμοί';

  @override
  String get allTimeFilter => 'Οποτεδήποτε';

  @override
  String get clearDatesTooltip => 'Καθαρισμός ημερομηνιών';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αποτελέσματα',
      one: '1 αποτέλεσμα',
    );
    return '$_temp0 · Έσοδα $income · Έξοδα $expense';
  }

  @override
  String get noSearchResults => 'Δεν βρέθηκαν συναλλαγές.';

  @override
  String get budgetsTitle => 'Προϋπολογισμοί';

  @override
  String get budgetsTooltip => 'Προϋπολογισμοί';

  @override
  String get overallBudget => 'Συνολικά';

  @override
  String get noBudget => 'Χωρίς προϋπολογισμό';

  @override
  String budgetsHint(String period) {
    return 'Τα όρια ισχύουν από $period και μετά· οι προηγούμενες περίοδοι κρατούν τα δικά τους.';
  }

  @override
  String get budgetLimitLabel => 'Όριο ανά περίοδο';

  @override
  String get budgetSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση του προϋπολογισμού. Δοκιμάστε ξανά.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent από $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining απομένουν · $perDay τη μέρα';
  }

  @override
  String budgetLeft(String remaining) {
    return '$remaining απομένουν';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Υπέρβαση κατά $amount';
  }

  @override
  String get budgetLimitReached => 'Το όριο συμπληρώθηκε';

  @override
  String budgetLimitOnly(String limit) {
    return 'Όριο $limit';
  }

  @override
  String get recurringTitle => 'Επαναλαμβανόμενα';

  @override
  String get addRecurringTooltip => 'Προσθήκη επαναλαμβανόμενης';

  @override
  String get addRecurringTitle => 'Προσθήκη επαναλαμβανόμενης';

  @override
  String get editRecurringTitle => 'Επεξεργασία επαναλαμβανόμενης';

  @override
  String get dueHeader => 'Εκκρεμή';

  @override
  String get upcomingHeader => 'Επόμενες 30 ημέρες';

  @override
  String get rulesHeader => 'Κανόνες';

  @override
  String get nothingUpcoming => 'Τίποτα τις επόμενες 30 ημέρες.';

  @override
  String get noRules => 'Δεν υπάρχουν ακόμη επαναλαμβανόμενες συναλλαγές.';

  @override
  String get postButton => 'Καταχώριση';

  @override
  String get skipButton => 'Παράλειψη';

  @override
  String get postFailed =>
      'Δεν ήταν δυνατή η καταχώριση της συναλλαγής. Δοκιμάστε ξανά.';

  @override
  String get recurringSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση της επαναλαμβανόμενης συναλλαγής. Δοκιμάστε ξανά.';

  @override
  String get everyLabel => 'Κάθε';

  @override
  String get frequencyDays => 'Ημέρες';

  @override
  String get frequencyWeeks => 'Εβδομάδες';

  @override
  String get frequencyMonths => 'Μήνες';

  @override
  String get frequencyYears => 'Χρόνια';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Κάθε $count ημέρες',
      one: 'Κάθε ημέρα',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Κάθε $count εβδομάδες',
      one: 'Κάθε εβδομάδα',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Κάθε $count μήνες',
      one: 'Κάθε μήνα',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Κάθε $count χρόνια',
      one: 'Κάθε χρόνο',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Σε παύση';
  }

  @override
  String get startsLabel => 'Έναρξη';

  @override
  String get endsLabel => 'Λήξη';

  @override
  String get endNever => 'Ποτέ';

  @override
  String get endAfter => 'Μετά από';

  @override
  String get endOnDate => 'Σε ημερομηνία';

  @override
  String get timesLabel => 'Φορές';

  @override
  String get endsOnLabel => 'Λήξη στις';

  @override
  String get wholeNumberInvalid => 'Εισαγάγετε ακέραιο αριθμό από το 1';

  @override
  String get endDateInvalid =>
      'Η ημερομηνία λήξης πρέπει να είναι μετά την έναρξη';

  @override
  String get autoPostLabel => 'Αυτόματη καταχώριση';

  @override
  String get autoPostSubtitle =>
      'Διαφορετικά περιμένει στα Εκκρεμή για επιβεβαίωση';

  @override
  String get pauseTooltip => 'Παύση';

  @override
  String get resumeTooltip => 'Συνέχιση';

  @override
  String get categoryFood => 'Φαγητό';

  @override
  String get categoryGroceries => 'Σούπερ μάρκετ';

  @override
  String get categoryTransport => 'Μετακίνηση';

  @override
  String get categoryShopping => 'Ψώνια';

  @override
  String get categoryBills => 'Λογαριασμοί';

  @override
  String get categoryRent => 'Ενοίκιο';

  @override
  String get categoryHealth => 'Υγεία';

  @override
  String get categoryEducation => 'Εκπαίδευση';

  @override
  String get categoryEntertainment => 'Ψυχαγωγία';

  @override
  String get categorySalary => 'Μισθός';

  @override
  String get categoryBusiness => 'Επιχείρηση';

  @override
  String get categoryInvestment => 'Επένδυση';

  @override
  String get categoryGift => 'Δώρο';

  @override
  String get categoryOther => 'Άλλο';

  @override
  String get previousPeriodTooltip => 'Προηγούμενη περίοδος';

  @override
  String get nextPeriodTooltip => 'Επόμενη περίοδος';

  @override
  String get insightsTooltip => 'Στατιστικά';

  @override
  String get insightsTitle => 'Στατιστικά';

  @override
  String get calendarTab => 'Ημερολόγιο';

  @override
  String get trendTab => 'Τάση';

  @override
  String get noIncomeInPeriod => 'Δεν υπάρχουν έσοδα σε αυτή την περίοδο.';

  @override
  String totalIncome(String amount) {
    return 'Σύνολο εσόδων: $amount';
  }

  @override
  String get calendarHint =>
      'Πατήστε σε μια ημέρα για να δείτε τις συναλλαγές της.';

  @override
  String get dayEmpty => 'Τίποτα αυτή την ημέρα.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count μήνες',
      one: '1 μήνας',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Έσοδα $income · Έξοδα $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Μέσος όρος ανά περίοδο · Έσοδα $income · Έξοδα $expense';
  }

  @override
  String get weekStartLabel => 'Πρώτη ημέρα της εβδομάδας';

  @override
  String weekStartDefault(String day) {
    return 'Προεπιλογή ($day)';
  }

  @override
  String get firstRunTitle => 'Καλώς ήρθατε στο Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Παρακολουθήστε τα έξοδα και τα έσοδά σας. Τα δεδομένα σας παραμένουν σε αυτή τη συσκευή.';

  @override
  String get addFirstTransactionButton => 'Προσθήκη πρώτης συναλλαγής';

  @override
  String get setupIntro =>
      'Επιλέξτε γλώσσα και νόμισμα. Μπορείτε να τα αλλάξετε αργότερα από τις Ρυθμίσεις.';

  @override
  String get setupContinueButton => 'Συνέχεια';

  @override
  String get setupRestoreTitle => 'Επαναφορά αντιγράφου ασφαλείας';

  @override
  String get setupRestoreSubtitle =>
      'Επαναφέρετε τα δεδομένα και τις ρυθμίσεις σας από αρχείο αντιγράφου ασφαλείας';

  @override
  String get walkthroughEntryTitle => 'Καταχώριση σε δευτερόλεπτα';

  @override
  String get walkthroughEntryBody =>
      'Πληκτρολόγιο που κάνει τις πράξεις, φωτογραφία της απόδειξης, και φωνητική σημείωση όταν η πληκτρολόγηση αργεί.';

  @override
  String get walkthroughPlanTitle => 'Σχεδιάστε τον μήνα';

  @override
  String get walkthroughPlanBody =>
      'Προϋπολογισμοί ανά κατηγορία, λογαριασμοί που επαναλαμβάνονται μόνοι τους, και σημειώσεις που σας υπενθυμίζουν.';

  @override
  String get walkthroughInsightsTitle => 'Δείτε πού πάνε';

  @override
  String get walkthroughInsightsBody =>
      'Γραφήματα, ημερολόγιο, και αναφορά PDF ή CSV για κάθε περίοδο.';

  @override
  String get walkthroughPrivacyTitle => 'Μόνο δικά σας';

  @override
  String get walkthroughPrivacyBody =>
      'Χωρίς λογαριασμό. Ό,τι καταγράφεις παραμένει σε αυτό το τηλέφωνο· οι διαφημίσεις που χρηματοδοτούν την εφαρμογή δεν το βλέπουν ποτέ.';

  @override
  String get walkthroughBringTitle => 'Φέρτε ό,τι έχετε';

  @override
  String get walkthroughBringBody =>
      'Έρχεστε από άλλη εφαρμογή ή κινητό; Ξεκινήστε από αντίγραφο ασφαλείας ή CSV αντί για κενή εφαρμογή.';

  @override
  String get firstRunRestoreTitle => 'Επαναφορά αυτού του αντιγράφου;';

  @override
  String get firstRunRestoreMessage =>
      'Αντικαθιστά όλα όσα υπάρχουν στην εφαρμογή και επαναφέρει τη γλώσσα και το νόμισμα με τα οποία αποθηκεύτηκε.';

  @override
  String get walkthroughNextButton => 'Επόμενο';

  @override
  String get walkthroughStartButton => 'Ας ξεκινήσουμε';

  @override
  String get walkthroughDoneButton => 'Τέλος';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Σελίδα $current από $total';
  }

  @override
  String get walkthroughReplayTitle => 'Επανάληψη περιήγησης';

  @override
  String get walkthroughReplaySubtitle =>
      'Οι τέσσερις σελίδες που εμφανίστηκαν όταν η εφαρμογή ήταν καινούργια';

  @override
  String get removeAdsTitle => 'Κατάργηση διαφημίσεων';

  @override
  String get exportCsvMenu => 'Εξαγωγή CSV';

  @override
  String get exportCsvTooltip => 'Εξαγωγή CSV';

  @override
  String get csvExported => 'Το CSV αποθηκεύτηκε';

  @override
  String get csvExportFailed =>
      'Δεν ήταν δυνατή η εξαγωγή του CSV. Δοκιμάστε ξανά.';

  @override
  String get backupTitle => 'Αντίγραφα ασφαλείας & επαναφορά';

  @override
  String get backupIntro =>
      'Τα αντίγραφα ασφαλείας είναι αρχεία που αποθηκεύετε όπου θέλετε. Τίποτα δεν αποστέλλεται αυτόματα.';

  @override
  String get backUpNowTitle => 'Δημιουργία αντιγράφου τώρα';

  @override
  String lastBackupLine(String date) {
    return 'Τελευταίο αντίγραφο $date';
  }

  @override
  String get neverBackedUp => 'Δεν υπάρχει ακόμη αντίγραφο';

  @override
  String get backupSaved => 'Το αντίγραφο αποθηκεύτηκε';

  @override
  String get backupSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση του αντιγράφου. Δοκιμάστε ξανά.';

  @override
  String get restoreFromFileTitle => 'Επαναφορά από αρχείο';

  @override
  String get restoreFromFileSubtitle =>
      'Συγχωνεύστε ένα αντίγραφο με τα δεδομένα σας ή αντικαταστήστε τα με αυτό';

  @override
  String get backupReminderLabel => 'Υπενθύμιση αντιγράφου ασφαλείας';

  @override
  String get backupReminderSubtitle =>
      'Κάθε 30 ημέρες μόλις φτάσετε τις 20 συναλλαγές';

  @override
  String get backupReminderNever =>
      'Δημιουργήστε αντίγραφο ασφαλείας για να προστατέψετε τα δεδομένα σας';

  @override
  String backupReminderSince(String date) {
    return 'Τελευταίο αντίγραφο $date. Ώρα για νέο;';
  }

  @override
  String get notNowTooltip => 'Όχι τώρα';

  @override
  String get keptBackupsHeader => 'Αυτόματα αντίγραφα';

  @override
  String get keptBackupsHint =>
      'Αποθηκεύονται σε αυτή τη συσκευή πριν από κάθε επαναφορά.';

  @override
  String get noKeptBackups => 'Κανένα ακόμη.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count συναλλαγές',
      one: '1 συναλλαγή',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Επαναφορά αντιγράφου';

  @override
  String get mergeOption => 'Συγχώνευση';

  @override
  String get mergeOptionSubtitle =>
      'Κρατήστε τα δεδομένα σας και προσθέστε αυτά του αντιγράφου. Όπου υπάρχει και στα δύο, επικρατεί η πιο πρόσφατη αλλαγή.';

  @override
  String get replaceOption => 'Αντικατάσταση';

  @override
  String get replaceOptionSubtitle =>
      'Διαγράψτε τα δεδομένα σας και χρησιμοποιήστε μόνο το αντίγραφο, με τις ρυθμίσεις του.';

  @override
  String get restoreSafetyNote =>
      'Πρώτα αποθηκεύεται αντίγραφο των τρεχόντων δεδομένων σας στα Αυτόματα αντίγραφα.';

  @override
  String get restoreButton => 'Επαναφορά';

  @override
  String get restoreKeptTitle => 'Επαναφορά αυτού του αντιγράφου;';

  @override
  String restoreKeptMessage(String date) {
    return 'Τα δεδομένα σας αντικαθίστανται από το αντίγραφο της $date. Πρώτα αποθηκεύεται αντίγραφο των τρεχόντων δεδομένων σας.';
  }

  @override
  String get backupInvalid =>
      'Αυτό το αρχείο δεν είναι αντίγραφο ασφαλείας του Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Αυτό το αντίγραφο προέρχεται από νεότερη έκδοση της εφαρμογής. Ενημερώστε την εφαρμογή και δοκιμάστε ξανά.';

  @override
  String get backupOpenFailed =>
      'Δεν ήταν δυνατό το άνοιγμα του αρχείου. Δοκιμάστε ξανά.';

  @override
  String get backupRestoreFailed =>
      'Δεν ήταν δυνατή η επαναφορά του αντιγράφου. Τα δεδομένα σας δεν άλλαξαν.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Έγινε επαναφορά $count συναλλαγών',
      one: 'Έγινε επαναφορά 1 συναλλαγής',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Συγχωνεύθηκαν: $added προστέθηκαν, $updated ενημερώθηκαν, $unchanged αμετάβλητες';
  }

  @override
  String get appLockLabel => 'Κλείδωμα εφαρμογής';

  @override
  String get appLockSubtitle =>
      'Ξεκλειδώστε με δαχτυλικό αποτύπωμα, πρόσωπο ή κλείδωμα οθόνης';

  @override
  String get appLockUnavailable =>
      'Ρυθμίστε κλείδωμα οθόνης σε αυτή τη συσκευή για να χρησιμοποιήσετε το κλείδωμα εφαρμογής';

  @override
  String get appLockReason => 'Ξεκλείδωμα Monthly Expenses';

  @override
  String get appLockFailed =>
      'Δεν ήταν δυνατή η επιβεβαίωση ταυτότητας. Το κλείδωμα εφαρμογής δεν άλλαξε.';

  @override
  String get lockedTitle => 'Το Monthly Expenses είναι κλειδωμένο';

  @override
  String get unlockButton => 'Ξεκλείδωμα';

  @override
  String get widgetShowAmountsLabel => 'Εμφάνιση ποσών στο γραφικό στοιχείο';

  @override
  String get widgetShowAmountsSubtitle =>
      'Το γραφικό στοιχείο της αρχικής οθόνης τα κρύβει όσο το κλείδωμα εφαρμογής είναι ενεργό';

  @override
  String get widgetLeftLabel => 'Απομένουν';

  @override
  String get widgetAddExpense => 'Προσθήκη εξόδου';

  @override
  String get widgetAddIncome => 'Προσθήκη εσόδου';

  @override
  String get widgetAmountsHidden =>
      'Τα ποσά είναι κρυφά λόγω κλειδώματος εφαρμογής';

  @override
  String get notesTitle => 'Σημειώσεις';

  @override
  String get addNoteTooltip => 'Προσθήκη σημείωσης';

  @override
  String get addNoteTitle => 'Προσθήκη σημείωσης';

  @override
  String get editNoteTitle => 'Επεξεργασία σημείωσης';

  @override
  String get noteTextLabel => 'Σημείωση';

  @override
  String get noteTextRequired => 'Εισαγάγετε κείμενο';

  @override
  String get noteAmountOptionalLabel => 'Ποσό (προαιρετικό)';

  @override
  String get noteDueDateToggle => 'Ορισμός ημερομηνίας λήξης';

  @override
  String get noteDueDateLabel => 'Ημερομηνία λήξης';

  @override
  String get noteReminderToggle => 'Υπενθύμισέ μου';

  @override
  String get noteReminderTimeLabel => 'Ώρα υπενθύμισης';

  @override
  String get noteReminderTimeUnset => 'Επιλέξτε ώρα';

  @override
  String get noteCategoryOptionalLabel => 'Κατηγορία (προαιρετικό)';

  @override
  String get noteCategoryNone => 'Καμία';

  @override
  String get recordNoteButton => 'Καταχώριση ως συναλλαγή';

  @override
  String get noteMarkDoneTooltip => 'Σήμανση ως ολοκληρωμένη';

  @override
  String get noteMarkOpenTooltip => 'Σήμανση ως ανοιχτή';

  @override
  String get notesEmptyTitle => 'Τίποτα εδώ ακόμη';

  @override
  String get notesEmptyMessage =>
      'Οι σημειώσεις θυμούνται πράγματα προς εκτέλεση ή έλεγχο, με προαιρετική ημερομηνία, ποσό και κατηγορία.';

  @override
  String get addNoteButton => 'Προσθήκη σημείωσης';

  @override
  String get notesOpenHeader => 'Ανοιχτές';

  @override
  String get notesDoneHeader => 'Ολοκληρωμένες';

  @override
  String get noteDeleted => 'Η σημείωση διαγράφηκε.';

  @override
  String get noteSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση της σημείωσης. Δοκιμάστε ξανά.';

  @override
  String get noteDeleteFailed =>
      'Δεν ήταν δυνατή η διαγραφή της σημείωσης. Δοκιμάστε ξανά.';

  @override
  String get noteRestoreFailed =>
      'Δεν ήταν δυνατή η επαναφορά της σημείωσης. Δοκιμάστε ξανά.';

  @override
  String get notesSearchHint => 'Αναζήτηση σημειώσεων';

  @override
  String get noteFilterAll => 'Όλες';

  @override
  String get noteFilterOverdue => 'Ληξιπρόθεσμες';

  @override
  String get noteFilterDueToday => 'Λήγουν σήμερα';

  @override
  String get noteFilterUpcoming => 'Προσεχώς';

  @override
  String get noteFilterNoDate => 'Χωρίς ημερομηνία';

  @override
  String get noNoteResults => 'Δεν βρέθηκαν σημειώσεις.';

  @override
  String get noteLinkedTransactionLabel => 'Καταχωρίστηκε ως συναλλαγή';

  @override
  String get noteLinkedNoteLabel => 'Από σημείωση';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count σημειώσεις λήγουν',
      one: '1 σημείωση λήγει',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Σημειώσεις που λήγουν';

  @override
  String get noteReminderTitle => 'Υπενθύμιση σημείωσης';

  @override
  String get noteReminderLockedTitle => 'Μια σημείωση λήγει';

  @override
  String get noteReminderPermissionDenied =>
      'Ενεργοποιήστε τις ειδοποιήσεις στις ρυθμίσεις συστήματος για να λαμβάνετε υπενθυμίσεις σημειώσεων.';

  @override
  String reportRange(String from, String to) {
    return '$from έως $to';
  }

  @override
  String reportCreated(String when) {
    return 'Δημιουργήθηκε $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Σελίδα $page από $pages';
  }

  @override
  String get reportNet => 'Καθαρό';

  @override
  String get reportOpeningBalance => 'Αρχικό υπόλοιπο';

  @override
  String get reportClosingBalance => 'Τελικό υπόλοιπο';

  @override
  String get reportSpendingHeader => 'Έξοδα ανά κατηγορία';

  @override
  String get reportEarningHeader => 'Έσοδα ανά κατηγορία';

  @override
  String get reportTrendHeader => 'Τάση';

  @override
  String get reportEntriesHeader => 'Συναλλαγές';

  @override
  String get reportUpcomingHeader => 'Προσεχώς';

  @override
  String get reportUpcomingNote =>
      'Με μελλοντική ημερομηνία, άρα δεν προσμετρώνται στα παραπάνω σύνολα.';

  @override
  String get reportAmountColumn => 'Ποσό';

  @override
  String get reportShareColumn => 'Ποσοστό';

  @override
  String get reportBudgetColumn => 'Προϋπολογισμός';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used από $limit';
  }

  @override
  String get reportDetailsColumn => 'Λεπτομέρειες';

  @override
  String get reportEmpty =>
      'Δεν υπάρχει τίποτα να αναφερθεί για αυτές τις ημερομηνίες.';

  @override
  String get exportPdfMenu => 'Εξαγωγή PDF';

  @override
  String get reportTitle => 'Εξαγωγή PDF';

  @override
  String get reportNoFontTitle => 'Όχι ακόμη σε αυτή τη γλώσσα';

  @override
  String get reportNoFontBody =>
      'Μια αναφορά χρειάζεται γραμματοσειρά για τη γραφή της, και αυτές για κινεζικά, ιαπωνικά και κορεατικά είναι πολύ μεγάλες για την εφαρμογή. Μια επόμενη έκδοση θα προσφέρει τη λήψη τους.';

  @override
  String get reportPreviewTitle => 'Αναφορά';

  @override
  String get reportCoversHeader => 'Τι περιλαμβάνει';

  @override
  String get reportRangePeriod => 'Αυτή η περίοδος';

  @override
  String get reportRangeCustom => 'Ημερομηνίες';

  @override
  String get reportRangeYear => 'Έτος';

  @override
  String get reportFromLabel => 'Από';

  @override
  String get reportToLabel => 'Έως';

  @override
  String get reportYearLabel => 'Έτος';

  @override
  String get reportAccountLabel => 'Λογαριασμός';

  @override
  String get reportAllAccounts => 'Όλοι οι λογαριασμοί';

  @override
  String get reportIncludeHeader => 'Τι περιέχει';

  @override
  String get reportIncludeSubtitle =>
      'Παραλείψτε ό,τι δεν θέλετε να μοιραστείτε.';

  @override
  String get reportIncludeTransactions => 'Τη λίστα συναλλαγών';

  @override
  String get reportIncludeDetails => 'Τίτλους και σημειώσεις';

  @override
  String get reportIncludeAccounts => 'Ονόματα λογαριασμών';

  @override
  String get reportCreateButton => 'Δημιουργία αναφοράς';

  @override
  String get reportBuilding => 'Δημιουργία αναφοράς';

  @override
  String get reportFailed =>
      'Δεν ήταν δυνατή η δημιουργία της αναφοράς. Δοκιμάστε ξανά.';

  @override
  String get reportRangeBackwards =>
      'Η πρώτη ημερομηνία πρέπει να είναι πριν την τελευταία.';

  @override
  String get importTitle => 'Εισαγωγή CSV';

  @override
  String get importSubtitle => 'Φέρτε συναλλαγές από άλλη εφαρμογή';

  @override
  String get importIntro =>
      'Επιλέξτε ένα αρχείο CSV και θα δείτε τι κατάλαβε η εφαρμογή πριν προστεθεί οτιδήποτε. Η εισαγωγή μόνο προσθέτει εγγραφές — ποτέ δεν αντικαθιστά ή διαγράφει όσα ήδη έχετε.';

  @override
  String get importChooseFile => 'Επιλογή αρχείου';

  @override
  String get importChooseAnother => 'Επιλογή άλλου αρχείου';

  @override
  String get importReadFailed =>
      'Δεν ήταν δυνατή η ανάγνωση του αρχείου. Δοκιμάστε ξανά.';

  @override
  String get importRefusedEmpty => 'Αυτό το αρχείο δεν περιέχει τίποτα.';

  @override
  String get importRefusedNoDate =>
      'Καμία στήλη σε αυτό το αρχείο δεν αναγνωρίστηκε ως ημερομηνία, οπότε δεν μπορεί να γίνει εισαγωγή.';

  @override
  String get importRefusedNoAmount =>
      'Καμία στήλη σε αυτό το αρχείο δεν αναγνωρίστηκε ως ποσό, οπότε δεν μπορεί να γίνει εισαγωγή.';

  @override
  String get importRefusedNoRows =>
      'Καμία γραμμή σε αυτό το αρχείο δεν αναγνωρίστηκε, οπότε δεν υπάρχει τίποτα να εισαχθεί.';

  @override
  String get importColumnsHeader => 'Στήλες';

  @override
  String get importColumnsSubtitle => 'Αλλάξτε ό,τι διάβασε λάθος η εφαρμογή.';

  @override
  String get importColumnNone => 'Δεν χρησιμοποιείται';

  @override
  String get importFieldType => 'Τύπος';

  @override
  String get importFieldToAccount => 'Προς λογαριασμό';

  @override
  String get importFieldTitle => 'Τίτλος';

  @override
  String get importFieldNote => 'Σημείωση';

  @override
  String get importDateOrderLabel => 'Ημερομηνίες όπως 03/04 σημαίνουν';

  @override
  String get importDayFirst => 'Πρώτα η ημέρα';

  @override
  String get importMonthFirst => 'Πρώτα ο μήνας';

  @override
  String get importCountsHeader => 'Τι θα συμβεί';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Θα εισαχθούν $count γραμμές',
      one: 'Θα εισαχθεί 1 γραμμή',
      zero: 'Δεν θα εισαχθεί τίποτα',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count γραμμές έχουν ημερομηνία που η εφαρμογή δεν μπορεί να διαβάσει',
      one: '1 γραμμή έχει ημερομηνία που η εφαρμογή δεν μπορεί να διαβάσει',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count γραμμές έχουν ποσό που η εφαρμογή δεν μπορεί να διαβάσει',
      one: '1 γραμμή έχει ποσό που η εφαρμογή δεν μπορεί να διαβάσει',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count γραμμές δεν αφορούν κανένα χρηματικό ποσό',
      one: '1 γραμμή δεν αφορά κανένα χρηματικό ποσό',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count γραμμές υπάρχουν ήδη στην εφαρμογή',
      one: '1 γραμμή υπάρχει ήδη στην εφαρμογή',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count μεταφορές αναφέρουν μόνο έναν λογαριασμό',
      one: '1 μεταφορά αναφέρει μόνο έναν λογαριασμό',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Η ημερομηνία δεν μπορεί να διαβαστεί';

  @override
  String get importRowUnreadableAmount => 'Το ποσό δεν μπορεί να διαβαστεί';

  @override
  String get importRowZero => 'Κανένα χρηματικό ποσό';

  @override
  String get importRowAlreadyThere => 'Υπάρχει ήδη στην εφαρμογή';

  @override
  String get importRowIncompleteTransfer => 'Αναφέρεται μόνο ένας λογαριασμός';

  @override
  String get importNamesHeader => 'Ονόματα που δεν έχει η εφαρμογή';

  @override
  String get importNamesSubtitle =>
      'Επιλέξτε τι θα γίνει το καθένα. Η εισαγωγή ποτέ δεν δημιουργεί κατηγορία ή λογαριασμό.';

  @override
  String get importRowsHeader =>
      'Οι πρώτες γραμμές, όπως τις διάβασε η εφαρμογή';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'και $count ακόμη',
      one: 'και 1 ακόμη',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Εισαγωγή $count γραμμών',
      one: 'Εισαγωγή 1 γραμμής',
      zero: 'Τίποτα για εισαγωγή',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Έγινε εισαγωγή $count εγγραφών',
      one: 'Έγινε εισαγωγή 1 εγγραφής',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Δεν ήταν δυνατή η εισαγωγή του αρχείου. Δεν προστέθηκε τίποτα.';

  @override
  String get attachmentsLabel => 'Συνημμένα';

  @override
  String get photoLabel => 'Φωτογραφία';

  @override
  String get photoAdd => 'Προσθήκη φωτογραφίας';

  @override
  String get photoTake => 'Λήψη φωτογραφίας';

  @override
  String get photoChoose => 'Επιλογή φωτογραφίας';

  @override
  String get photoRemove => 'Αφαίρεση φωτογραφίας';

  @override
  String get photoMissing => 'Αυτή η φωτογραφία λείπει.';

  @override
  String get voiceNoteLabel => 'Φωνητική σημείωση';

  @override
  String get voiceRecord => 'Ηχογράφηση φωνητικής σημείωσης';

  @override
  String voiceRecording(int seconds) {
    return 'Ηχογράφηση, απομένουν $secondsδ';
  }

  @override
  String get voiceStop => 'Διακοπή';

  @override
  String get voicePlay => 'Αναπαραγωγή';

  @override
  String get voicePause => 'Παύση';

  @override
  String get voiceRemove => 'Αφαίρεση φωνητικής σημείωσης';

  @override
  String get voiceMissing => 'Αυτή η φωνητική σημείωση λείπει.';

  @override
  String get microphoneRefused =>
      'Το μικρόφωνο είναι απενεργοποιημένο για αυτή την εφαρμογή.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Περιλαμβάνει συνημμένα, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Αποκρύπτει όλες τις διαφημίσεις με μία πληρωμή. Συνδέεται με τον λογαριασμό σου στο κατάστημα, οπότε επιστρέφει σε νέο τηλέφωνο ή επανεγκατάσταση.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Κατάργηση διαφημίσεων για $price';
  }

  @override
  String get removeAdsOwned =>
      'Οι διαφημίσεις είναι απενεργοποιημένες. Ευχαριστούμε.';

  @override
  String get removeAdsPending => 'Αναμονή για το κατάστημα…';

  @override
  String get removeAdsUnavailable =>
      'Το κατάστημα δεν έχει ακόμη κάτι διαθέσιμο εδώ. Δοκίμασε ξανά αργότερα.';

  @override
  String get removeAdsFailed => 'Δεν ολοκληρώθηκε και δεν έγινε καμία χρέωση.';

  @override
  String get restorePurchasesButton => 'Επαναφορά αγορών';

  @override
  String get payNothingWithheld =>
      'Όλες οι λειτουργίες παραμένουν δωρεάν, με ή χωρίς διαφημίσεις.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Σύντομα διαθέσιμο';

  @override
  String get plusBody =>
      'Μια τραπεζική σύνδεση που φέρνει τις συναλλαγές σου για επιβεβαίωση. Δεν έχει ολοκληρωθεί ακόμη, οπότε δεν υπάρχει κάτι προς αγορά.';

  @override
  String get privacyOptionsTitle => 'Επιλογές απορρήτου';

  @override
  String get privacyOptionsSubtitle =>
      'Άλλαξε την επιλογή σου για εξατομικευμένες διαφημίσεις';
}
