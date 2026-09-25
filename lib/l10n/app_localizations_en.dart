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
  String get expandSummaryTooltip => 'Show income and expense';

  @override
  String get collapseSummaryTooltip => 'Show only the balance';

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
  String get upcomingLabel => 'Upcoming';

  @override
  String detailAdded(String date) {
    return 'Added $date';
  }

  @override
  String detailChanged(String date) {
    return 'Last changed $date';
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
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent used · $over over',
      one: '$percent used · 1 over',
      zero: '$percent used',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets set',
      one: '1 budget set',
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
  String get restoreTransferFailed =>
      'Couldn\'t restore the transfer. Try again.';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get transactionDetailTitle => 'Details';

  @override
  String get editTooltip => 'Edit';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get duplicateTooltip => 'Duplicate';

  @override
  String get rowMenuTooltip => 'More actions';

  @override
  String get deleteTransactionTitle => 'Delete this transaction?';

  @override
  String get deleteTransactionMessage =>
      'It goes to the trash, and can be restored for 30 days.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'What you typed here hasn\'t been saved.';

  @override
  String get discardButton => 'Discard';

  @override
  String get keepEditingButton => 'Keep editing';

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
  String get noteLabel => 'Note';

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
  String get drawerAddHeader => 'Add';

  @override
  String get drawerAddExpense => 'Add expense';

  @override
  String get drawerAddIncome => 'Add income';

  @override
  String get drawerPlanHeader => 'Plan';

  @override
  String get drawerReviewHeader => 'Look back';

  @override
  String get drawerSpending => 'Spending by category';

  @override
  String get drawerManageHeader => 'Manage';

  @override
  String get drawerDataHeader => 'Data';

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
  String get themeBlack => 'Black';

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
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'deleted for good in $days days',
      one: 'deleted for good in 1 day',
    );
    return '$_temp0';
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
  String get accountsTotalLabel => 'Total';

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
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount spent · $perDay a day so far';
  }

  @override
  String get homeSetBudget => 'Set a monthly budget';

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
  String billsPerMonth(String amount) {
    return '$amount a month in bills';
  }

  @override
  String nextBillToday(String title) {
    return 'Next: $title, today';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'Next: $title, tomorrow';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Next: $title, in $days days',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Nothing in the next 30 days.';

  @override
  String get noRules => 'No recurring transactions yet.';

  @override
  String get recurringEmptyMessage =>
      'Recurring transactions post rent, a salary or a subscription on the schedule you set, and wait for a tap to confirm each one.';

  @override
  String get addRecurringButton => 'Add a recurring transaction';

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
  String get recurringDeleted => 'Recurring transaction deleted';

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
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'Every day';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'Every week';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'Every month';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'Every year';

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
  String wholeNumberRange(int max) {
    return 'Enter a whole number from 1 to $max';
  }

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
  String get wholePeriodTooltip => 'Show the whole period';

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
  String comparedMore(String amount) {
    return '$amount more than last month';
  }

  @override
  String comparedLess(String amount) {
    return '$amount less than last month';
  }

  @override
  String get comparedSame => 'The same as last month';

  @override
  String get categoryNewLabel => 'new';

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
  String get trendNeedsMorePeriods =>
      'A trend needs more than one period. Come back next month.';

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
  String get setupIntro =>
      'Choose your language and currency. You can change them later in Settings.';

  @override
  String get setupContinueButton => 'Continue';

  @override
  String get setupRestoreTitle => 'Restore a backup';

  @override
  String get setupRestoreSubtitle =>
      'Bring your data and settings back from a backup file';

  @override
  String get walkthroughEntryTitle => 'Add in seconds';

  @override
  String get walkthroughEntryBody =>
      'A keypad that adds up, a photo of the receipt, and a voice note when typing is slow.';

  @override
  String get walkthroughPlanTitle => 'Plan the month';

  @override
  String get walkthroughPlanBody =>
      'Budgets by category, bills that repeat by themselves, and notes that remind you.';

  @override
  String get walkthroughInsightsTitle => 'See where it goes';

  @override
  String get walkthroughInsightsBody =>
      'Charts, a calendar, and a PDF or CSV report for any period.';

  @override
  String get walkthroughPrivacyTitle => 'Yours alone';

  @override
  String get walkthroughPrivacyBody =>
      'No account. What you record stays on this phone; the ads that pay for the app never see it.';

  @override
  String get walkthroughBringTitle => 'Bring what you have';

  @override
  String get walkthroughBringBody =>
      'Coming from another app or another phone? Start from a backup or a CSV instead of an empty app.';

  @override
  String get firstRunRestoreTitle => 'Restore this backup?';

  @override
  String get firstRunRestoreMessage =>
      'It replaces everything in the app, and brings back the language and currency it was saved with.';

  @override
  String get walkthroughNextButton => 'Next';

  @override
  String get walkthroughStartButton => 'Get started';

  @override
  String get walkthroughDoneButton => 'Done';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get walkthroughReplayTitle => 'Replay the walkthrough';

  @override
  String get walkthroughReplaySubtitle =>
      'The four pages shown when the app was new';

  @override
  String get removeAdsTitle => 'Remove ads';

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
  String get appLockPromptHint => 'Confirm it\'s you';

  @override
  String get appLockFailed =>
      'Couldn\'t confirm it\'s you. App lock wasn\'t changed.';

  @override
  String get lockedTitle => 'Monthly Expenses is locked';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get widgetShowAmountsLabel => 'Show amounts on the widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'The home-screen widget hides them while app lock is on';

  @override
  String get widgetLeftLabel => 'Left';

  @override
  String get widgetAddExpense => 'Add expense';

  @override
  String get widgetAddIncome => 'Add income';

  @override
  String get widgetAmountsHidden => 'Amounts are hidden by app lock';

  @override
  String get notesTitle => 'Notes';

  @override
  String get addNoteTooltip => 'Add note';

  @override
  String get addNoteTitle => 'Add note';

  @override
  String get editNoteTitle => 'Edit note';

  @override
  String get noteTextLabel => 'Note';

  @override
  String get noteTextRequired => 'Enter some text';

  @override
  String get noteAmountOptionalLabel => 'Amount (optional)';

  @override
  String get noteDueDateToggle => 'Set a due date';

  @override
  String get noteDueDateLabel => 'Due date';

  @override
  String get noteReminderToggle => 'Remind me';

  @override
  String get noteReminderTimeLabel => 'Reminder time';

  @override
  String get noteReminderTimeUnset => 'Choose a time';

  @override
  String get reminderMayBeLate =>
      'Your phone may deliver this a few minutes late.';

  @override
  String get noteCategoryOptionalLabel => 'Category (optional)';

  @override
  String get noteCategoryNone => 'None';

  @override
  String get recordNoteButton => 'Record as transaction';

  @override
  String get noteMarkDoneTooltip => 'Mark done';

  @override
  String get noteMarkOpenTooltip => 'Mark open';

  @override
  String get notesEmptyTitle => 'Nothing here yet';

  @override
  String get notesEmptyMessage =>
      'Notes remember things to do or check on, with an optional date, amount, and category.';

  @override
  String get addNoteButton => 'Add a note';

  @override
  String get notesOpenHeader => 'Open';

  @override
  String get notesDoneHeader => 'Done';

  @override
  String get noteDeleted => 'Note deleted.';

  @override
  String get noteSaveFailed => 'Couldn\'t save the note. Try again.';

  @override
  String get noteDeleteFailed => 'Couldn\'t delete the note. Try again.';

  @override
  String get noteRestoreFailed => 'Couldn\'t restore the note. Try again.';

  @override
  String get notesSearchHint => 'Search notes';

  @override
  String get noteFilterAll => 'All';

  @override
  String get noteFilterOverdue => 'Overdue';

  @override
  String get noteFilterDueToday => 'Due today';

  @override
  String get noteFilterUpcoming => 'Upcoming';

  @override
  String get noteFilterNoDate => 'No date';

  @override
  String get noNoteResults => 'No matching notes.';

  @override
  String get noteLinkedTransactionLabel => 'Recorded as a transaction';

  @override
  String get noteLinkedNoteLabel => 'From a note';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes are due',
      one: '1 note is due',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Notes due';

  @override
  String get noteReminderTitle => 'Note reminder';

  @override
  String get noteReminderLockedTitle => 'A note is due';

  @override
  String get noteReminderChannelName => 'Note reminders';

  @override
  String get noteReminderPermissionDenied =>
      'Turn on notifications in system settings to get reminders for notes.';

  @override
  String reportRange(String from, String to) {
    return '$from to $to';
  }

  @override
  String reportCreated(String when) {
    return 'Created $when';
  }

  @override
  String reportNarrowedTo(String description) {
    return 'Narrowed to: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get reportNet => 'Net';

  @override
  String get reportMatchingIncome => 'Matching income';

  @override
  String get reportMatchingExpense => 'Matching expense';

  @override
  String get reportMatchingNet => 'Matching net';

  @override
  String get reportOpeningBalance => 'Opening balance';

  @override
  String get reportClosingBalance => 'Closing balance';

  @override
  String get reportSpendingHeader => 'Spending by category';

  @override
  String get reportEarningHeader => 'Income by category';

  @override
  String get reportTrendHeader => 'Trend';

  @override
  String get reportEntriesHeader => 'Transactions';

  @override
  String get reportUpcomingHeader => 'Upcoming';

  @override
  String get reportUpcomingNote =>
      'Dated ahead, so not counted in the totals above.';

  @override
  String get reportAmountColumn => 'Amount';

  @override
  String get reportShareColumn => 'Share';

  @override
  String get reportBudgetColumn => 'Budget';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used of $limit';
  }

  @override
  String get reportDetailsColumn => 'Details';

  @override
  String get reportEmpty => 'Nothing to report for these dates.';

  @override
  String get exportPdfMenu => 'Export PDF';

  @override
  String get reportTitle => 'Export PDF';

  @override
  String get reportNoFontTitle => 'Not yet in this language';

  @override
  String get reportNoFontBody =>
      'A report needs a font for its script, and the Chinese, Japanese and Korean faces are too large to carry in the app. A later version will offer to download one.';

  @override
  String get reportPreviewTitle => 'Report';

  @override
  String get reportCoversHeader => 'What it covers';

  @override
  String get reportNarrowedNotice =>
      'This report stays narrowed to your search.';

  @override
  String get reportRangePeriod => 'This period';

  @override
  String get reportRangeCustom => 'Dates';

  @override
  String get reportRangeYear => 'Year';

  @override
  String get reportFromLabel => 'From';

  @override
  String get reportToLabel => 'To';

  @override
  String get reportYearLabel => 'Year';

  @override
  String get reportAccountLabel => 'Account';

  @override
  String get reportAllAccounts => 'All accounts';

  @override
  String get reportIncludeHeader => 'What it includes';

  @override
  String get reportIncludeSubtitle =>
      'Leave out anything you would rather not share.';

  @override
  String get reportIncludeTransactions => 'The transaction list';

  @override
  String get reportIncludeDetails => 'Titles and notes';

  @override
  String get reportIncludeAccounts => 'Account names';

  @override
  String get reportCreateButton => 'Create the report';

  @override
  String get reportBuilding => 'Building the report';

  @override
  String get reportFailed => 'Couldn\'t build the report. Try again.';

  @override
  String get reportRangeBackwards =>
      'The first date has to come before the last.';

  @override
  String get importTitle => 'Import a CSV';

  @override
  String get importSubtitle => 'Bring transactions in from another app';

  @override
  String get importIntro =>
      'Pick a CSV file and you\'ll see what the app made of it before anything is added. Importing only adds records — it never replaces or deletes what you already have.';

  @override
  String get importChooseFile => 'Choose a file';

  @override
  String get importChooseAnother => 'Choose another file';

  @override
  String get importReadFailed => 'Couldn\'t read that file. Try again.';

  @override
  String get importRefusedEmpty => 'There is nothing in that file.';

  @override
  String get importRefusedNoDate =>
      'No column in that file could be read as a date, so it can\'t be imported.';

  @override
  String get importRefusedNoAmount =>
      'No column in that file could be read as an amount, so it can\'t be imported.';

  @override
  String get importRefusedNoRows =>
      'None of the rows in that file could be read, so there is nothing to import.';

  @override
  String get importColumnsHeader => 'Columns';

  @override
  String get importColumnsSubtitle => 'Change anything the app read wrongly.';

  @override
  String get importColumnNone => 'Not used';

  @override
  String get importFieldType => 'Type';

  @override
  String get importFieldToAccount => 'To account';

  @override
  String get importFieldTitle => 'Title';

  @override
  String get importFieldNote => 'Note';

  @override
  String get importDateOrderLabel => 'Dates like 03/04 mean';

  @override
  String get importDayFirst => 'Day first';

  @override
  String get importMonthFirst => 'Month first';

  @override
  String get importCountsHeader => 'What will happen';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows will be imported',
      one: '1 row will be imported',
      zero: 'Nothing will be imported',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows have a date the app can\'t read',
      one: '1 row has a date the app can\'t read',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows have an amount the app can\'t read',
      one: '1 row has an amount the app can\'t read',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows are for no money at all',
      one: '1 row is for no money at all',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows are already in the app',
      one: '1 row is already in the app',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfers name only one account',
      one: '1 transfer names only one account',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Date can\'t be read';

  @override
  String get importRowUnreadableAmount => 'Amount can\'t be read';

  @override
  String get importRowZero => 'No money at all';

  @override
  String get importRowAlreadyThere => 'Already in the app';

  @override
  String get importRowIncompleteTransfer => 'Only one account named';

  @override
  String get importNamesHeader => 'Names this app hasn\'t got';

  @override
  String get importNamesSubtitle =>
      'Pick what each one becomes. Importing never creates a category or an account.';

  @override
  String get importRowsHeader => 'The first rows, as the app read them';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count more',
      one: 'and 1 more',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count rows',
      one: 'Import 1 row',
      zero: 'Nothing to import',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records imported',
      one: '1 record imported',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'Couldn\'t import that file. Nothing was added.';

  @override
  String get attachmentsLabel => 'Attachments';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoAdd => 'Add a photo';

  @override
  String get photoTake => 'Take a photo';

  @override
  String get photoChoose => 'Choose a photo';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoMissing => 'This photo is missing.';

  @override
  String get voiceNoteLabel => 'Voice note';

  @override
  String get voiceRecord => 'Record a voice note';

  @override
  String voiceRecording(int seconds) {
    return 'Recording, ${seconds}s left';
  }

  @override
  String get voiceStop => 'Stop';

  @override
  String get voicePlay => 'Play';

  @override
  String get voicePause => 'Pause';

  @override
  String get voiceRemove => 'Remove voice note';

  @override
  String get voiceMissing => 'This voice note is missing.';

  @override
  String get microphoneRefused => 'The microphone is off for this app.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Includes attachments, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Hides every ad, for one payment. It follows your store account, so a new phone or a reinstall brings it back.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Remove ads for $price';
  }

  @override
  String get removeAdsOwned => 'Ads are off. Thank you.';

  @override
  String get removeAdsPending => 'Waiting for the store…';

  @override
  String get removeAdsUnavailable =>
      'The store has nothing to sell here yet. Please try again later.';

  @override
  String get removeAdsFailed =>
      'That didn\'t go through, and you haven\'t been charged.';

  @override
  String get restorePurchasesButton => 'Restore purchases';

  @override
  String get payNothingWithheld =>
      'Every feature stays free, with or without ads.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Coming soon';

  @override
  String get plusBody =>
      'A bank connection that brings your transactions in for you to confirm. It isn\'t finished, so there is nothing to buy yet.';

  @override
  String get privacyOptionsTitle => 'Privacy options';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyOptionsSubtitle =>
      'Change your choice about personalised ads';

  @override
  String get dueEntryReminderTitle => 'An entry was due';

  @override
  String get dueEntryChannelName => 'Entries that fell due';

  @override
  String dueEntryReminderOne(String title, String amount) {
    return '$title ($amount) was due today and is still waiting.';
  }

  @override
  String dueEntryReminderOneOverdue(String title, String amount, String date) {
    return '$title ($amount) was due $date and is still waiting.';
  }

  @override
  String dueEntryReminderUntitled(String amount) {
    return 'A repeating entry ($amount) was due today and is still waiting.';
  }

  @override
  String dueEntryReminderUntitledOverdue(String amount, String date) {
    return 'A repeating entry ($amount) was due $date and is still waiting.';
  }

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeating entries were due today.',
      one: '1 repeating entry was due today.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Nothing recorded today';

  @override
  String get emptyDayChannelName => 'Days with nothing recorded';

  @override
  String get emptyDayReminderBody =>
      'Add what you spent while you still remember it.';

  @override
  String get reminderLockedTitle => 'Something is waiting';

  @override
  String get nudgeSettingsTitle => 'Remind me on an empty day';

  @override
  String get nudgeSettingsSubtitle =>
      'One reminder in the evening, and only on a day with nothing recorded in it.';

  @override
  String get nudgeOfferTitle => 'A nudge on the days you forget?';

  @override
  String get nudgeOfferBody =>
      'One reminder at a time you choose, only on a day with nothing recorded. Off again whenever you like.';

  @override
  String get nudgeOfferYes => 'Yes, remind me';

  @override
  String get nudgeOfferNo => 'No thanks';

  @override
  String get nudgeStoppedNotice =>
      'Reminders stopped after three went unanswered. Turn them back on whenever you like.';

  @override
  String get nudgePermissionDenied =>
      'Turn on notifications in system settings to get reminders.';

  @override
  String get updateDownloadedMessage => 'An update has been downloaded.';

  @override
  String get updateRestartButton => 'Restart';
}
