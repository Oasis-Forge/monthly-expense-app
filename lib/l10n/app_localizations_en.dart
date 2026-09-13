// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get transferTooltip => 'Transfer';

  @override
  String get searchTooltip => 'Search';

  @override
  String get addButton => 'Add';

  @override
  String get emptyPeriod => 'No transactions in this period yet.';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get periodNetLabel => 'This period';

  @override
  String carriedForwardLine(String amount) {
    return 'Carried forward $amount';
  }

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expense';

  @override
  String upcomingCategory(String category) {
    return '$category · Upcoming';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring transactions are due',
      one: '1 recurring transaction is due',
    );
    return '$_temp0';
  }

  @override
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets are over their limit',
      one: '1 budget is over its limit',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'Couldn\'t delete the transaction. Try again.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transferDeleted => 'Transfer deleted';

  @override
  String get undoButton => 'Undo';

  @override
  String get undoFailed => 'Couldn\'t undo. Try again.';

  @override
  String get restoreFailed => 'Couldn\'t restore the transaction. Try again.';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get duplicateTooltip => 'Duplicate';

  @override
  String get titleOptionalLabel => 'Title (optional)';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Enter an amount';

  @override
  String get amountInvalid => 'Enter a valid amount';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Backspace';

  @override
  String get hideKeypadTooltip => 'Hide keypad';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryRequired => 'Choose a category';

  @override
  String get accountLabel => 'Account';

  @override
  String get accountRequired => 'Choose an account';

  @override
  String get dateLabel => 'Date';

  @override
  String get previousDayTooltip => 'Previous day';

  @override
  String get nextDayTooltip => 'Next day';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get addTransactionButton => 'Add Transaction';

  @override
  String get saveAndAddAnotherButton => 'Save & add another';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get saveFailed => 'Couldn\'t save the transaction. Try again.';

  @override
  String get noExpensesInPeriod => 'No expenses in this period yet.';

  @override
  String totalSpent(String amount) {
    return 'Total spent: $amount';
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
  String get settingsTitle => 'Settings';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get currencySearchHint => 'Search currencies';

  @override
  String changeCurrencyTitle(String code) {
    return 'Change currency to $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Amounts stay the same; only their currency label changes.';

  @override
  String get changeButton => 'Change';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get removeButton => 'Remove';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get monthStartLabel => 'First day of the month';

  @override
  String get monthStartLastDay => 'Last day';

  @override
  String get showCarriedForwardLabel => 'Carry balance forward';

  @override
  String get showCarriedForwardSubtitle =>
      'Each period starts from the previous balance';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmpty => 'Trash is empty.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'deleted for good in $days days',
      one: 'deleted for good in 1 day',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Restore';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategoryTooltip => 'Add category';

  @override
  String get addCategoryTitle => 'Add category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameRequired => 'Enter a name';

  @override
  String get categoryNameTaken => 'That name is already used';

  @override
  String get archiveAction => 'Archive';

  @override
  String get unarchiveAction => 'Unarchive';

  @override
  String get deleteAction => 'Delete';

  @override
  String get archivedHeader => 'Archived';

  @override
  String get categorySaveFailed => 'Couldn\'t save the category. Try again.';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountCash => 'Cash';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get addAccountTooltip => 'Add account';

  @override
  String get addAccountTitle => 'Add account';

  @override
  String get editAccountTitle => 'Edit account';

  @override
  String get openingBalanceLabel => 'Opening balance';

  @override
  String get openingDateLabel => 'Opening date';

  @override
  String get accountSaveFailed => 'Couldn\'t save the account. Try again.';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get editTransferTitle => 'Edit transfer';

  @override
  String get transferLabel => 'Transfer';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'From';

  @override
  String get toAccountLabel => 'To';

  @override
  String get sameAccountError => 'Choose two different accounts';

  @override
  String get needTwoAccounts =>
      'Add a second account to move money between accounts.';

  @override
  String get addTransferButton => 'Add Transfer';

  @override
  String get transferSaveFailed => 'Couldn\'t save the transfer. Try again.';

  @override
  String get searchHint => 'Search transactions';

  @override
  String get allTypesFilter => 'All';

  @override
  String get allCategoriesFilter => 'All categories';

  @override
  String get allAccountsFilter => 'All accounts';

  @override
  String get allTimeFilter => 'All time';

  @override
  String get clearDatesTooltip => 'Clear dates';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0 · Income $income · Expense $expense';
  }

  @override
  String get noSearchResults => 'No matching transactions.';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsTooltip => 'Budgets';

  @override
  String get overallBudget => 'Overall';

  @override
  String get noBudget => 'No budget';

  @override
  String budgetsHint(String period) {
    return 'Limits apply from $period on; earlier periods keep theirs.';
  }

  @override
  String get budgetLimitLabel => 'Limit per period';

  @override
  String get budgetSaveFailed => 'Couldn\'t save the budget. Try again.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining left · $perDay a day';
  }

  @override
  String budgetLeft(String remaining) {
    return '$remaining left';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String get budgetLimitReached => 'Limit reached';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limit $limit';
  }

  @override
  String get recurringTitle => 'Recurring';

  @override
  String get addRecurringTooltip => 'Add recurring';

  @override
  String get addRecurringTitle => 'Add recurring';

  @override
  String get editRecurringTitle => 'Edit recurring';

  @override
  String get dueHeader => 'Due';

  @override
  String get upcomingHeader => 'Next 30 days';

  @override
  String get rulesHeader => 'Rules';

  @override
  String get nothingUpcoming => 'Nothing in the next 30 days.';

  @override
  String get noRules => 'No recurring transactions yet.';

  @override
  String get postButton => 'Post';

  @override
  String get skipButton => 'Skip';

  @override
  String get postFailed => 'Couldn\'t post the transaction. Try again.';

  @override
  String get recurringSaveFailed =>
      'Couldn\'t save the recurring transaction. Try again.';

  @override
  String get everyLabel => 'Every';

  @override
  String get frequencyDays => 'Days';

  @override
  String get frequencyWeeks => 'Weeks';

  @override
  String get frequencyMonths => 'Months';

  @override
  String get frequencyYears => 'Years';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Paused';
  }

  @override
  String get startsLabel => 'Starts';

  @override
  String get endsLabel => 'Ends';

  @override
  String get endNever => 'Never';

  @override
  String get endAfter => 'After';

  @override
  String get endOnDate => 'On date';

  @override
  String get timesLabel => 'Times';

  @override
  String get endsOnLabel => 'Ends on';

  @override
  String get wholeNumberInvalid => 'Enter a whole number from 1';

  @override
  String get endDateInvalid => 'The end date must be after the start';

  @override
  String get autoPostLabel => 'Post automatically';

  @override
  String get autoPostSubtitle => 'Otherwise it waits in Due for a tap';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Resume';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get categoryGift => 'Gift';

  @override
  String get categoryOther => 'Other';

  @override
  String get previousPeriodTooltip => 'Previous period';

  @override
  String get nextPeriodTooltip => 'Next period';

  @override
  String get insightsTooltip => 'Insights';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get trendTab => 'Trend';

  @override
  String get noIncomeInPeriod => 'No income in this period yet.';

  @override
  String totalIncome(String amount) {
    return 'Total income: $amount';
  }

  @override
  String get calendarHint => 'Tap a day to see its transactions.';

  @override
  String get dayEmpty => 'Nothing on this day.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Income $income · Expense $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Average per period · Income $income · Expense $expense';
  }

  @override
  String get weekStartLabel => 'First day of the week';

  @override
  String weekStartDefault(String day) {
    return 'Default ($day)';
  }

  @override
  String get firstRunTitle => 'Welcome to Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Track what you spend and earn. Your data stays on this device.';

  @override
  String get addFirstTransactionButton => 'Add your first transaction';

  @override
  String get exportCsvMenu => 'Export CSV';

  @override
  String get exportCsvTooltip => 'Export CSV';

  @override
  String get csvExported => 'CSV saved';

  @override
  String get csvExportFailed => 'Couldn\'t export the CSV. Try again.';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupIntro =>
      'Backups are files you save where you choose. Nothing is uploaded or sent automatically.';

  @override
  String get backUpNowTitle => 'Back up now';

  @override
  String lastBackupLine(String date) {
    return 'Last backup $date';
  }

  @override
  String get neverBackedUp => 'No backup yet';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupSaveFailed => 'Couldn\'t save the backup. Try again.';

  @override
  String get restoreFromFileTitle => 'Restore from a file';

  @override
  String get restoreFromFileSubtitle =>
      'Merge a backup into your data, or replace your data with it';

  @override
  String get backupReminderLabel => 'Backup reminder';

  @override
  String get backupReminderSubtitle =>
      'Every 30 days once you have 20 transactions';

  @override
  String get backupReminderNever => 'Back up your data to keep it safe';

  @override
  String backupReminderSince(String date) {
    return 'Last backup $date. Time for a new one?';
  }

  @override
  String get notNowTooltip => 'Not now';

  @override
  String get keptBackupsHeader => 'Automatic backups';

  @override
  String get keptBackupsHint => 'Saved on this device before each restore.';

  @override
  String get noKeptBackups => 'None yet.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Restore backup';

  @override
  String get mergeOption => 'Merge';

  @override
  String get mergeOptionSubtitle =>
      'Keep your data and add the backup\'s. Where both have a record, the newer change wins.';

  @override
  String get replaceOption => 'Replace';

  @override
  String get replaceOptionSubtitle =>
      'Delete your data and use only the backup, with its settings.';

  @override
  String get restoreSafetyNote =>
      'A copy of your current data is saved under Automatic backups first.';

  @override
  String get restoreButton => 'Restore';

  @override
  String get restoreKeptTitle => 'Restore this copy?';

  @override
  String restoreKeptMessage(String date) {
    return 'Your data is replaced by the copy from $date. A copy of your current data is saved first.';
  }

  @override
  String get backupInvalid => 'This file isn\'t a Monthly Expenses backup.';

  @override
  String get backupTooNew =>
      'This backup is from a newer version of the app. Update the app, then try again.';

  @override
  String get backupOpenFailed => 'Couldn\'t open the file. Try again.';

  @override
  String get backupRestoreFailed =>
      'Couldn\'t restore the backup. Your data wasn\'t changed.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored $count transactions',
      one: 'Restored 1 transaction',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Merged: $added added, $updated updated, $unchanged unchanged';
  }

  @override
  String get appLockLabel => 'App lock';

  @override
  String get appLockSubtitle =>
      'Unlock with your fingerprint, face, or screen lock';

  @override
  String get appLockUnavailable =>
      'Set up a screen lock on this device to use app lock';

  @override
  String get appLockReason => 'Unlock Monthly Expenses';

  @override
  String get appLockFailed =>
      'Couldn\'t confirm it\'s you. App lock wasn\'t changed.';

  @override
  String get lockedTitle => 'Monthly Expenses is locked';

  @override
  String get unlockButton => 'Unlock';
}
