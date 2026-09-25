// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get transferTooltip => 'Umbuchung';

  @override
  String get searchTooltip => 'Suchen';

  @override
  String get addButton => 'Hinzufügen';

  @override
  String get emptyPeriod => 'Noch keine Buchungen in diesem Zeitraum.';

  @override
  String get emptyPeriodFilteredByAccount =>
      'Nichts für dieses Konto in diesem Zeitraum.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get expandSummaryTooltip => 'Einnahmen und Ausgaben anzeigen';

  @override
  String get collapseSummaryTooltip => 'Nur den Saldo anzeigen';

  @override
  String get periodNetLabel => 'Dieser Zeitraum';

  @override
  String carriedForwardLine(String amount) {
    return 'Übertrag $amount';
  }

  @override
  String get incomeLabel => 'Einnahmen';

  @override
  String get expenseLabel => 'Ausgaben';

  @override
  String upcomingCategory(String category) {
    return '$category · Geplant';
  }

  @override
  String get upcomingLabel => 'Bevorstehend';

  @override
  String detailAdded(String date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String detailChanged(String date) {
    return 'Zuletzt geändert am $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wiederkehrende Buchungen sind fällig',
      one: '1 wiederkehrende Buchung ist fällig',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent verbraucht · $over überschritten',
      one: '$percent verbraucht · 1 überschritten',
      zero: '$percent verbraucht',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Budgets festgelegt',
      one: '1 Budget festgelegt',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed =>
      'Die Buchung konnte nicht gelöscht werden. Versuche es erneut.';

  @override
  String get transactionDeleted => 'Buchung gelöscht';

  @override
  String get transferDeleted => 'Umbuchung gelöscht';

  @override
  String get undoButton => 'Rückgängig';

  @override
  String get undoFailed =>
      'Rückgängig machen fehlgeschlagen. Versuche es erneut.';

  @override
  String get restoreFailed =>
      'Die Buchung konnte nicht wiederhergestellt werden. Versuche es erneut.';

  @override
  String get restoreTransferFailed =>
      'Umbuchung konnte nicht wiederhergestellt werden. Versuch es erneut.';

  @override
  String get addTransactionTitle => 'Buchung hinzufügen';

  @override
  String get editTransactionTitle => 'Buchung bearbeiten';

  @override
  String get transactionDetailTitle => 'Details';

  @override
  String get editTooltip => 'Bearbeiten';

  @override
  String get deleteTooltip => 'Löschen';

  @override
  String get duplicateTooltip => 'Duplizieren';

  @override
  String get rowMenuTooltip => 'Weitere Aktionen';

  @override
  String get deleteTransactionTitle => 'Diese Buchung löschen?';

  @override
  String get deleteTransactionMessage =>
      'Sie kommt in den Papierkorb und kann 30 Tage lang wiederhergestellt werden.';

  @override
  String get discardChangesTitle => 'Änderungen verwerfen?';

  @override
  String get discardChangesMessage =>
      'Was du hier eingegeben hast, ist nicht gespeichert.';

  @override
  String get discardButton => 'Verwerfen';

  @override
  String get keepEditingButton => 'Weiter bearbeiten';

  @override
  String get titleOptionalLabel => 'Titel (optional)';

  @override
  String get amountLabel => 'Betrag';

  @override
  String get amountRequired => 'Gib einen Betrag ein';

  @override
  String get amountInvalid => 'Gib einen gültigen Betrag ein';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Rücktaste';

  @override
  String get hideKeypadTooltip => 'Tastenfeld ausblenden';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get categoryRequired => 'Wähle eine Kategorie';

  @override
  String get accountLabel => 'Konto';

  @override
  String get accountRequired => 'Wähle ein Konto';

  @override
  String get dateLabel => 'Datum';

  @override
  String get noteLabel => 'Notiz';

  @override
  String get previousDayTooltip => 'Vorheriger Tag';

  @override
  String get nextDayTooltip => 'Nächster Tag';

  @override
  String get noteOptionalLabel => 'Notiz (optional)';

  @override
  String get saveChangesButton => 'Änderungen speichern';

  @override
  String get addTransactionButton => 'Buchung hinzufügen';

  @override
  String get saveAndAddAnotherButton => 'Speichern & weitere';

  @override
  String get transactionAdded => 'Buchung hinzugefügt';

  @override
  String get saveFailed =>
      'Die Buchung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get noExpensesInPeriod => 'Noch keine Ausgaben in diesem Zeitraum.';

  @override
  String totalSpent(String amount) {
    return 'Ausgaben gesamt: $amount';
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
  String get settingsTitle => 'Einstellungen';

  @override
  String get drawerAddHeader => 'Hinzufügen';

  @override
  String get drawerAddExpense => 'Ausgabe hinzufügen';

  @override
  String get drawerAddIncome => 'Einnahme hinzufügen';

  @override
  String get drawerPlanHeader => 'Planen';

  @override
  String get drawerReviewHeader => 'Rückblick';

  @override
  String get drawerSpending => 'Ausgaben nach Kategorie';

  @override
  String get drawerManageHeader => 'Verwalten';

  @override
  String get drawerDataHeader => 'Daten';

  @override
  String get currencyLabel => 'Währung';

  @override
  String get currencySearchHint => 'Währungen suchen';

  @override
  String changeCurrencyTitle(String code) {
    return 'Währung zu $code ändern?';
  }

  @override
  String get changeCurrencyMessage =>
      'Die Beträge bleiben gleich; nur die Währungsangabe ändert sich.';

  @override
  String get changeButton => 'Ändern';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get removeButton => 'Entfernen';

  @override
  String get themeLabel => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeBlack => 'Schwarz';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get monthStartLabel => 'Erster Tag des Monats';

  @override
  String get monthStartLastDay => 'Letzter Tag';

  @override
  String get showCarriedForwardLabel => 'Saldo übertragen';

  @override
  String get showCarriedForwardSubtitle =>
      'Jeder Zeitraum beginnt mit dem vorherigen Saldo';

  @override
  String get trashTitle => 'Papierkorb';

  @override
  String get trashEmpty => 'Der Papierkorb ist leer.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'wird in $days Tagen endgültig gelöscht',
      one: 'wird in 1 Tag endgültig gelöscht',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'wird in $days Tagen endgültig gelöscht',
      one: 'wird in 1 Tag endgültig gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => 'Wiederherstellen';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String get addCategoryTooltip => 'Kategorie hinzufügen';

  @override
  String get addCategoryTitle => 'Kategorie hinzufügen';

  @override
  String get editCategoryTitle => 'Kategorie bearbeiten';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameRequired => 'Gib einen Namen ein';

  @override
  String get categoryNameTaken => 'Dieser Name wird bereits verwendet';

  @override
  String get archiveAction => 'Archivieren';

  @override
  String get unarchiveAction => 'Dearchivieren';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get archivedHeader => 'Archiviert';

  @override
  String get accountsTotalLabel => 'Gesamt';

  @override
  String get categorySaveFailed =>
      'Die Kategorie konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get accountsTitle => 'Konten';

  @override
  String get accountCash => 'Bargeld';

  @override
  String get accountTypeLabel => 'Typ';

  @override
  String get accountTypeCash => 'Bargeld';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Karte';

  @override
  String get accountTypeOther => 'Sonstiges';

  @override
  String get addAccountTooltip => 'Konto hinzufügen';

  @override
  String get addAccountTitle => 'Konto hinzufügen';

  @override
  String get editAccountTitle => 'Konto bearbeiten';

  @override
  String get openingBalanceLabel => 'Anfangssaldo';

  @override
  String get openingDateLabel => 'Eröffnungsdatum';

  @override
  String get accountSaveFailed =>
      'Das Konto konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get transferTitle => 'Umbuchung';

  @override
  String get editTransferTitle => 'Umbuchung bearbeiten';

  @override
  String get transferLabel => 'Umbuchung';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Von';

  @override
  String get toAccountLabel => 'An';

  @override
  String get sameAccountError => 'Wähle zwei verschiedene Konten';

  @override
  String get needTwoAccounts =>
      'Füge ein zweites Konto hinzu, um Geld zwischen Konten zu verschieben.';

  @override
  String get addTransferButton => 'Umbuchung hinzufügen';

  @override
  String get transferSaveFailed =>
      'Die Umbuchung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get searchHint => 'Buchungen suchen';

  @override
  String get allTypesFilter => 'Alle';

  @override
  String get allCategoriesFilter => 'Alle Kategorien';

  @override
  String get allAccountsFilter => 'Alle Konten';

  @override
  String get allTimeFilter => 'Gesamter Zeitraum';

  @override
  String get clearDatesTooltip => 'Daten löschen';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
    );
    return '$_temp0 · Einnahmen $income · Ausgaben $expense';
  }

  @override
  String get noSearchResults => 'Keine passenden Buchungen.';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsTooltip => 'Budgets';

  @override
  String get overallBudget => 'Gesamt';

  @override
  String get noBudget => 'Kein Budget';

  @override
  String budgetsHint(String period) {
    return 'Limits gelten ab $period; frühere Zeiträume behalten ihre.';
  }

  @override
  String get budgetLimitLabel => 'Limit pro Zeitraum';

  @override
  String get budgetSaveFailed =>
      'Das Budget konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent von $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining übrig · $perDay pro Tag';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount ausgegeben · $perDay pro Tag bisher';
  }

  @override
  String get homeSetBudget => 'Monatsbudget festlegen';

  @override
  String budgetLeft(String remaining) {
    return '$remaining übrig';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount überschritten';
  }

  @override
  String get budgetLimitReached => 'Limit erreicht';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limit $limit';
  }

  @override
  String get recurringTitle => 'Wiederkehrend';

  @override
  String get addRecurringTooltip => 'Wiederkehrende hinzufügen';

  @override
  String get addRecurringTitle => 'Wiederkehrende Buchung';

  @override
  String get editRecurringTitle => 'Wiederkehrende bearbeiten';

  @override
  String get dueHeader => 'Fällig';

  @override
  String get upcomingHeader => 'Nächste 30 Tage';

  @override
  String get rulesHeader => 'Regeln';

  @override
  String billsPerMonth(String amount) {
    return '$amount im Monat an Rechnungen';
  }

  @override
  String nextBillToday(String title) {
    return 'Nächste: $title, heute';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'Nächste: $title, morgen';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Nächste: $title, in $days Tagen',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Nichts in den nächsten 30 Tagen.';

  @override
  String get noRules => 'Noch keine wiederkehrenden Buchungen.';

  @override
  String get recurringEmptyMessage =>
      'Wiederkehrende Buchungen erfassen Miete, Gehalt oder ein Abo nach dem Zeitplan, den du festlegst, und warten auf ein Antippen zur Bestätigung jeder einzelnen.';

  @override
  String get addRecurringButton => 'Wiederkehrende Buchung hinzufügen';

  @override
  String get postButton => 'Buchen';

  @override
  String get skipButton => 'Überspringen';

  @override
  String get postFailed =>
      'Die Buchung konnte nicht erstellt werden. Versuche es erneut.';

  @override
  String get recurringSaveFailed =>
      'Die wiederkehrende Buchung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get recurringDeleted => 'Wiederkehrende Buchung gelöscht';

  @override
  String get everyLabel => 'Alle';

  @override
  String get frequencyDays => 'Tage';

  @override
  String get frequencyWeeks => 'Wochen';

  @override
  String get frequencyMonths => 'Monate';

  @override
  String get frequencyYears => 'Jahre';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Tage',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'Täglich';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Wochen',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'Wöchentlich';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Monate',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'Monatlich';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Jahre',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'Jährlich';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Pausiert';
  }

  @override
  String get startsLabel => 'Beginn';

  @override
  String get endsLabel => 'Ende';

  @override
  String get endNever => 'Nie';

  @override
  String get endAfter => 'Nach';

  @override
  String get endOnDate => 'Am Datum';

  @override
  String get timesLabel => 'Mal';

  @override
  String get endsOnLabel => 'Endet am';

  @override
  String get wholeNumberInvalid => 'Gib eine ganze Zahl ab 1 ein';

  @override
  String wholeNumberRange(int max) {
    return 'Gib eine ganze Zahl von 1 bis $max ein';
  }

  @override
  String get endDateInvalid => 'Das Enddatum muss nach dem Beginn liegen';

  @override
  String get autoPostLabel => 'Automatisch buchen';

  @override
  String get autoPostSubtitle => 'Sonst wartet sie unter Fällig auf einen Tipp';

  @override
  String get pauseTooltip => 'Pausieren';

  @override
  String get resumeTooltip => 'Fortsetzen';

  @override
  String get categoryFood => 'Essen';

  @override
  String get categoryGroceries => 'Lebensmittel';

  @override
  String get categoryTransport => 'Verkehr';

  @override
  String get categoryShopping => 'Einkäufe';

  @override
  String get categoryBills => 'Rechnungen';

  @override
  String get categoryRent => 'Miete';

  @override
  String get categoryHealth => 'Gesundheit';

  @override
  String get categoryEducation => 'Bildung';

  @override
  String get categoryEntertainment => 'Freizeit';

  @override
  String get categorySalary => 'Gehalt';

  @override
  String get categoryBusiness => 'Geschäftlich';

  @override
  String get categoryInvestment => 'Geldanlage';

  @override
  String get categoryGift => 'Geschenk';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get previousPeriodTooltip => 'Vorheriger Zeitraum';

  @override
  String get wholePeriodTooltip => 'Ganzen Zeitraum anzeigen';

  @override
  String get nextPeriodTooltip => 'Nächster Zeitraum';

  @override
  String get insightsTooltip => 'Auswertungen';

  @override
  String get insightsTitle => 'Auswertungen';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get trendTab => 'Verlauf';

  @override
  String get noIncomeInPeriod => 'Noch keine Einnahmen in diesem Zeitraum.';

  @override
  String totalIncome(String amount) {
    return 'Einnahmen gesamt: $amount';
  }

  @override
  String comparedMore(String amount) {
    return '$amount mehr als letzten Monat';
  }

  @override
  String comparedLess(String amount) {
    return '$amount weniger als letzten Monat';
  }

  @override
  String get comparedSame => 'Gleich wie letzten Monat';

  @override
  String get categoryNewLabel => 'neu';

  @override
  String get calendarHint =>
      'Tippe auf einen Tag, um seine Buchungen zu sehen.';

  @override
  String get dayEmpty => 'An diesem Tag nichts.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Einnahmen $income · Ausgaben $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Durchschnitt pro Zeitraum · Einnahmen $income · Ausgaben $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'Ein Verlauf braucht mehr als einen Zeitraum. Komm nächsten Monat wieder.';

  @override
  String get weekStartLabel => 'Erster Tag der Woche';

  @override
  String weekStartDefault(String day) {
    return 'Standard ($day)';
  }

  @override
  String get firstRunTitle => 'Willkommen bei Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Behalte deine Ausgaben und Einnahmen im Blick. Deine Daten bleiben auf diesem Gerät.';

  @override
  String get addFirstTransactionButton => 'Erste Buchung hinzufügen';

  @override
  String get setupIntro =>
      'Wähle deine Sprache und Währung. Du kannst sie später in den Einstellungen ändern.';

  @override
  String get setupContinueButton => 'Weiter';

  @override
  String get setupRestoreTitle => 'Backup wiederherstellen';

  @override
  String get setupRestoreSubtitle =>
      'Daten und Einstellungen aus einer Backup-Datei zurückholen';

  @override
  String get walkthroughEntryTitle => 'In Sekunden erfasst';

  @override
  String get walkthroughEntryBody =>
      'Ein Ziffernfeld, das rechnet, ein Foto vom Beleg und eine Sprachnotiz, wenn Tippen zu lange dauert.';

  @override
  String get walkthroughPlanTitle => 'Den Monat planen';

  @override
  String get walkthroughPlanBody =>
      'Budgets je Kategorie, Rechnungen, die sich selbst wiederholen, und Notizen, die dich erinnern.';

  @override
  String get walkthroughInsightsTitle => 'Sieh, wohin es fließt';

  @override
  String get walkthroughInsightsBody =>
      'Diagramme, ein Kalender und ein PDF- oder CSV-Bericht für jeden Zeitraum.';

  @override
  String get walkthroughPrivacyTitle => 'Nur deins';

  @override
  String get walkthroughPrivacyBody =>
      'Kein Konto nötig. Was du einträgst, bleibt auf diesem Handy; die Werbung, die die App finanziert, sieht es nie.';

  @override
  String get walkthroughBringTitle => 'Bring mit, was du hast';

  @override
  String get walkthroughBringBody =>
      'Kommst du von einer anderen App oder einem anderen Handy? Fang mit einem Backup oder einer CSV an statt mit einer leeren App.';

  @override
  String get firstRunRestoreTitle => 'Dieses Backup wiederherstellen?';

  @override
  String get firstRunRestoreMessage =>
      'Es ersetzt alles in der App und stellt die Sprache und Währung wieder her, mit denen es gespeichert wurde.';

  @override
  String get walkthroughNextButton => 'Weiter';

  @override
  String get walkthroughStartButton => 'Los geht\'s';

  @override
  String get walkthroughDoneButton => 'Fertig';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Seite $current von $total';
  }

  @override
  String get walkthroughReplayTitle => 'Rundgang erneut ansehen';

  @override
  String get walkthroughReplaySubtitle => 'Die vier Seiten vom ersten Start';

  @override
  String get removeAdsTitle => 'Werbung entfernen';

  @override
  String get exportCsvMenu => 'CSV exportieren';

  @override
  String get exportCsvTooltip => 'CSV exportieren';

  @override
  String get csvExported => 'CSV gespeichert';

  @override
  String get csvExportFailed =>
      'Die CSV-Datei konnte nicht exportiert werden. Versuche es erneut.';

  @override
  String get backupTitle => 'Sichern & wiederherstellen';

  @override
  String get backupIntro =>
      'Sicherungen sind Dateien, die du speicherst, wo du möchtest. Nichts wird automatisch hochgeladen oder gesendet.';

  @override
  String get backUpNowTitle => 'Jetzt sichern';

  @override
  String lastBackupLine(String date) {
    return 'Letzte Sicherung $date';
  }

  @override
  String get neverBackedUp => 'Noch keine Sicherung';

  @override
  String get backupSaved => 'Sicherung gespeichert';

  @override
  String get backupSaveFailed =>
      'Die Sicherung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get restoreFromFileTitle => 'Aus Datei wiederherstellen';

  @override
  String get restoreFromFileSubtitle =>
      'Eine Sicherung mit deinen Daten zusammenführen oder deine Daten dadurch ersetzen';

  @override
  String get backupReminderLabel => 'Sicherungserinnerung';

  @override
  String get backupReminderSubtitle => 'Alle 30 Tage ab 20 Buchungen';

  @override
  String get backupReminderNever =>
      'Sichere deine Daten, damit sie nicht verloren gehen';

  @override
  String backupReminderSince(String date) {
    return 'Letzte Sicherung $date. Zeit für eine neue?';
  }

  @override
  String get notNowTooltip => 'Nicht jetzt';

  @override
  String get keptBackupsHeader => 'Automatische Sicherungen';

  @override
  String get keptBackupsHint =>
      'Vor jeder Wiederherstellung auf diesem Gerät gespeichert.';

  @override
  String get noKeptBackups => 'Noch keine.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Buchungen',
      one: '1 Buchung',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Sicherung wiederherstellen';

  @override
  String get mergeOption => 'Zusammenführen';

  @override
  String get mergeOptionSubtitle =>
      'Behalte deine Daten und füge die der Sicherung hinzu. Gibt es einen Eintrag auf beiden Seiten, gewinnt die neuere Änderung.';

  @override
  String get replaceOption => 'Ersetzen';

  @override
  String get replaceOptionSubtitle =>
      'Lösche deine Daten und verwende nur die Sicherung samt ihren Einstellungen.';

  @override
  String get restoreSafetyNote =>
      'Vorher wird eine Kopie deiner aktuellen Daten unter Automatische Sicherungen gespeichert.';

  @override
  String get restoreButton => 'Wiederherstellen';

  @override
  String get restoreKeptTitle => 'Diese Kopie wiederherstellen?';

  @override
  String restoreKeptMessage(String date) {
    return 'Deine Daten werden durch die Kopie vom $date ersetzt. Vorher wird eine Kopie deiner aktuellen Daten gespeichert.';
  }

  @override
  String get backupInvalid =>
      'Diese Datei ist keine Sicherung von Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Diese Sicherung stammt aus einer neueren App-Version. Aktualisiere die App und versuche es erneut.';

  @override
  String get backupOpenFailed =>
      'Die Datei konnte nicht geöffnet werden. Versuche es erneut.';

  @override
  String get backupRestoreFailed =>
      'Die Sicherung konnte nicht wiederhergestellt werden. Deine Daten wurden nicht geändert.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Buchungen wiederhergestellt',
      one: '1 Buchung wiederhergestellt',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Zusammengeführt: $added hinzugefügt, $updated aktualisiert, $unchanged unverändert';
  }

  @override
  String get appLockLabel => 'App-Sperre';

  @override
  String get appLockSubtitle =>
      'Mit Fingerabdruck, Gesicht oder Displaysperre entsperren';

  @override
  String get appLockUnavailable =>
      'Richte auf diesem Gerät eine Displaysperre ein, um die App-Sperre zu nutzen';

  @override
  String get appLockReason => 'Monthly Expenses entsperren';

  @override
  String get appLockPromptHint => 'Identität bestätigen';

  @override
  String get appLockFailed =>
      'Deine Identität konnte nicht bestätigt werden. Die App-Sperre wurde nicht geändert.';

  @override
  String get lockedTitle => 'Monthly Expenses ist gesperrt';

  @override
  String get unlockButton => 'Entsperren';

  @override
  String get widgetShowAmountsLabel => 'Beträge im Widget anzeigen';

  @override
  String get widgetShowAmountsSubtitle =>
      'Das Startbildschirm-Widget blendet sie aus, solange die App-Sperre an ist';

  @override
  String get widgetLeftLabel => 'Übrig';

  @override
  String get widgetAddExpense => 'Ausgabe hinzufügen';

  @override
  String get widgetAddIncome => 'Einnahme hinzufügen';

  @override
  String get widgetAmountsHidden => 'Beträge durch die App-Sperre ausgeblendet';

  @override
  String get notesTitle => 'Notizen';

  @override
  String get addNoteTooltip => 'Notiz hinzufügen';

  @override
  String get addNoteTitle => 'Notiz hinzufügen';

  @override
  String get editNoteTitle => 'Notiz bearbeiten';

  @override
  String get noteTextLabel => 'Notiz';

  @override
  String get noteTextRequired => 'Text eingeben';

  @override
  String get noteAmountOptionalLabel => 'Betrag (optional)';

  @override
  String get noteDueDateToggle => 'Fälligkeitsdatum festlegen';

  @override
  String get noteDueDateLabel => 'Fälligkeitsdatum';

  @override
  String get noteReminderToggle => 'Erinnern';

  @override
  String get noteReminderTimeLabel => 'Erinnerungszeit';

  @override
  String get noteReminderTimeUnset => 'Uhrzeit wählen';

  @override
  String get reminderMayBeLate =>
      'Ihr Telefon kann dies ein paar Minuten später liefern.';

  @override
  String get noteCategoryOptionalLabel => 'Kategorie (optional)';

  @override
  String get noteCategoryNone => 'Keine';

  @override
  String get recordNoteButton => 'Als Transaktion erfassen';

  @override
  String get noteMarkDoneTooltip => 'Als erledigt markieren';

  @override
  String get noteMarkOpenTooltip => 'Als offen markieren';

  @override
  String get notesEmptyTitle => 'Hier ist noch nichts';

  @override
  String get notesEmptyMessage =>
      'Notizen erinnern an Dinge, die zu erledigen oder zu prüfen sind, mit optionalem Datum, Betrag und Kategorie.';

  @override
  String get addNoteButton => 'Notiz hinzufügen';

  @override
  String get notesOpenHeader => 'Offen';

  @override
  String get notesDoneHeader => 'Erledigt';

  @override
  String get noteDeleted => 'Notiz gelöscht.';

  @override
  String get noteSaveFailed =>
      'Die Notiz konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get noteDeleteFailed =>
      'Die Notiz konnte nicht gelöscht werden. Versuche es erneut.';

  @override
  String get noteRestoreFailed =>
      'Die Notiz konnte nicht wiederhergestellt werden. Versuche es erneut.';

  @override
  String get notesSearchHint => 'Notizen durchsuchen';

  @override
  String get noteFilterAll => 'Alle';

  @override
  String get noteFilterOverdue => 'Überfällig';

  @override
  String get noteFilterDueToday => 'Heute fällig';

  @override
  String get noteFilterUpcoming => 'Anstehend';

  @override
  String get noteFilterNoDate => 'Ohne Datum';

  @override
  String get noNoteResults => 'Keine passenden Notizen.';

  @override
  String get noteLinkedTransactionLabel => 'Als Transaktion erfasst';

  @override
  String get noteLinkedNoteLabel => 'Aus einer Notiz';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notizen sind fällig',
      one: '1 Notiz ist fällig',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Fällige Notizen';

  @override
  String get noteReminderTitle => 'Notiz-Erinnerung';

  @override
  String get noteReminderLockedTitle => 'Eine Notiz ist fällig';

  @override
  String get noteReminderChannelName => 'Notiz-Erinnerungen';

  @override
  String get noteReminderPermissionDenied =>
      'Aktiviere Benachrichtigungen in den Systemeinstellungen, um Erinnerungen für Notizen zu erhalten.';

  @override
  String reportRange(String from, String to) {
    return '$from bis $to';
  }

  @override
  String reportCreated(String when) {
    return 'Erstellt am $when';
  }

  @override
  String reportNarrowedTo(String description) {
    return 'Eingegrenzt auf: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Seite $page von $pages';
  }

  @override
  String get reportNet => 'Netto';

  @override
  String get reportMatchingIncome => 'Passendes Einkommen';

  @override
  String get reportMatchingExpense => 'Passende Ausgabe';

  @override
  String get reportMatchingNet => 'Passender Saldo';

  @override
  String get reportOpeningBalance => 'Anfangssaldo';

  @override
  String get reportClosingBalance => 'Endsaldo';

  @override
  String get reportSpendingHeader => 'Ausgaben nach Kategorie';

  @override
  String get reportEarningHeader => 'Einnahmen nach Kategorie';

  @override
  String get reportTrendHeader => 'Verlauf';

  @override
  String get reportEntriesHeader => 'Transaktionen';

  @override
  String get reportUpcomingHeader => 'Bevorstehend';

  @override
  String get reportUpcomingNote =>
      'Später datiert und daher nicht in den Summen oben enthalten.';

  @override
  String get reportAmountColumn => 'Betrag';

  @override
  String get reportShareColumn => 'Anteil';

  @override
  String get reportBudgetColumn => 'Budget';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used von $limit';
  }

  @override
  String get reportDetailsColumn => 'Details';

  @override
  String get reportEmpty => 'Für diese Daten gibt es nichts zu berichten.';

  @override
  String get exportPdfMenu => 'PDF exportieren';

  @override
  String get reportTitle => 'PDF exportieren';

  @override
  String get reportNoFontTitle => 'Noch nicht in dieser Sprache';

  @override
  String get reportNoFontBody =>
      'Ein Bericht braucht eine Schrift für sein Schriftsystem, und die für Chinesisch, Japanisch und Koreanisch sind zu groß für die App. Eine spätere Version bietet den Download an.';

  @override
  String get reportPreviewTitle => 'Bericht';

  @override
  String get reportCoversHeader => 'Was er abdeckt';

  @override
  String get reportNarrowedNotice =>
      'Dieser Bericht bleibt auf deine Suche eingegrenzt.';

  @override
  String get reportRangePeriod => 'Dieser Zeitraum';

  @override
  String get reportRangeCustom => 'Daten';

  @override
  String get reportRangeYear => 'Jahr';

  @override
  String get reportFromLabel => 'Von';

  @override
  String get reportToLabel => 'Bis';

  @override
  String get reportYearLabel => 'Jahr';

  @override
  String get reportAccountLabel => 'Konto';

  @override
  String get reportAllAccounts => 'Alle Konten';

  @override
  String get reportIncludeHeader => 'Was er enthält';

  @override
  String get reportIncludeSubtitle =>
      'Lass weg, was du lieber nicht teilen möchtest.';

  @override
  String get reportIncludeTransactions => 'Die Transaktionsliste';

  @override
  String get reportIncludeDetails => 'Titel und Notizen';

  @override
  String get reportIncludeAccounts => 'Kontonamen';

  @override
  String get reportCreateButton => 'Bericht erstellen';

  @override
  String get reportBuilding => 'Bericht wird erstellt';

  @override
  String get reportFailed =>
      'Bericht konnte nicht erstellt werden. Versuche es erneut.';

  @override
  String get reportRangeBackwards =>
      'Das erste Datum muss vor dem letzten liegen.';

  @override
  String get importTitle => 'CSV importieren';

  @override
  String get importSubtitle => 'Buchungen aus einer anderen App übernehmen';

  @override
  String get importIntro =>
      'Wähle eine CSV-Datei aus; bevor etwas hinzugefügt wird, siehst du, was die App darin erkannt hat. Ein Import fügt nur Einträge hinzu — er ersetzt oder löscht nie, was schon da ist.';

  @override
  String get importChooseFile => 'Datei auswählen';

  @override
  String get importChooseAnother => 'Andere Datei auswählen';

  @override
  String get importReadFailed =>
      'Diese Datei konnte nicht gelesen werden. Versuche es erneut.';

  @override
  String get importRefusedEmpty => 'In dieser Datei steht nichts.';

  @override
  String get importRefusedNoDate =>
      'Keine Spalte dieser Datei ließ sich als Datum lesen, sie kann nicht importiert werden.';

  @override
  String get importRefusedNoAmount =>
      'Keine Spalte dieser Datei ließ sich als Betrag lesen, sie kann nicht importiert werden.';

  @override
  String get importRefusedNoRows =>
      'Keine Zeile dieser Datei ließ sich lesen, es gibt nichts zu importieren.';

  @override
  String get importColumnsHeader => 'Spalten';

  @override
  String get importColumnsSubtitle =>
      'Ändere alles, was die App falsch gelesen hat.';

  @override
  String get importColumnNone => 'Nicht verwendet';

  @override
  String get importFieldType => 'Art';

  @override
  String get importFieldToAccount => 'Zielkonto';

  @override
  String get importFieldTitle => 'Titel';

  @override
  String get importFieldNote => 'Notiz';

  @override
  String get importDateOrderLabel => 'Ein Datum wie 03/04 bedeutet';

  @override
  String get importDayFirst => 'Tag zuerst';

  @override
  String get importMonthFirst => 'Monat zuerst';

  @override
  String get importCountsHeader => 'Was passieren wird';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen werden importiert',
      one: '1 Zeile wird importiert',
      zero: 'Es wird nichts importiert',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen haben ein Datum, das die App nicht lesen kann',
      one: '1 Zeile hat ein Datum, das die App nicht lesen kann',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen haben einen Betrag, den die App nicht lesen kann',
      one: '1 Zeile hat einen Betrag, den die App nicht lesen kann',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen enthalten gar keinen Betrag',
      one: '1 Zeile enthält gar keinen Betrag',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen sind bereits in der App',
      one: '1 Zeile ist bereits in der App',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Umbuchungen nennen nur ein Konto',
      one: '1 Umbuchung nennt nur ein Konto',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Datum nicht lesbar';

  @override
  String get importRowUnreadableAmount => 'Betrag nicht lesbar';

  @override
  String get importRowZero => 'Gar kein Betrag';

  @override
  String get importRowAlreadyThere => 'Schon in der App';

  @override
  String get importRowIncompleteTransfer => 'Nur ein Konto genannt';

  @override
  String get importNamesHeader => 'Namen, die es in dieser App nicht gibt';

  @override
  String get importNamesSubtitle =>
      'Wähle, was aus jedem wird. Ein Import legt nie eine Kategorie oder ein Konto an.';

  @override
  String get importRowsHeader =>
      'Die ersten Zeilen, so wie die App sie gelesen hat';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'und $count weitere',
      one: 'und 1 weitere',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen importieren',
      one: '1 Zeile importieren',
      zero: 'Nichts zu importieren',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge importiert',
      one: '1 Eintrag importiert',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Diese Datei konnte nicht importiert werden. Es wurde nichts hinzugefügt.';

  @override
  String get attachmentsLabel => 'Anhänge';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoAdd => 'Foto hinzufügen';

  @override
  String get photoTake => 'Foto aufnehmen';

  @override
  String get photoChoose => 'Foto auswählen';

  @override
  String get photoRemove => 'Foto entfernen';

  @override
  String get photoMissing => 'Dieses Foto fehlt.';

  @override
  String get voiceNoteLabel => 'Sprachnotiz';

  @override
  String get voiceRecord => 'Sprachnotiz aufnehmen';

  @override
  String voiceRecording(int seconds) {
    return 'Aufnahme, noch $seconds s';
  }

  @override
  String get voiceStop => 'Stopp';

  @override
  String get voicePlay => 'Abspielen';

  @override
  String get voicePause => 'Pause';

  @override
  String get voiceRemove => 'Sprachnotiz entfernen';

  @override
  String get voiceMissing => 'Diese Sprachnotiz fehlt.';

  @override
  String get microphoneRefused => 'Das Mikrofon ist für diese App deaktiviert.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Enthält Anhänge, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Blendet mit einer einmaligen Zahlung alle Werbung aus. Der Kauf ist an dein Store-Konto gebunden und kehrt bei einem neuen Handy oder einer Neuinstallation zurück.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Werbung entfernen für $price';
  }

  @override
  String get removeAdsOwned => 'Werbung ist aus. Danke.';

  @override
  String get removeAdsPending => 'Warten auf den Store…';

  @override
  String get removeAdsUnavailable =>
      'Der Store hat hier noch nichts zu verkaufen. Bitte versuche es später erneut.';

  @override
  String get removeAdsFailed =>
      'Das hat nicht geklappt, es wurde nichts abgebucht.';

  @override
  String get restorePurchasesButton => 'Käufe wiederherstellen';

  @override
  String get payNothingWithheld =>
      'Alle Funktionen bleiben kostenlos, mit oder ohne Werbung.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Demnächst verfügbar';

  @override
  String get plusBody =>
      'Eine Bankverbindung, die deine Buchungen zur Bestätigung einliest. Noch nicht fertig, also gibt es noch nichts zu kaufen.';

  @override
  String get privacyOptionsTitle => 'Datenschutzoptionen';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get privacyOptionsSubtitle =>
      'Ändere deine Wahl zu personalisierter Werbung';

  @override
  String get dueEntryReminderTitle => 'Eintrag fällig';

  @override
  String get dueEntryChannelName => 'Fällige Einträge';

  @override
  String dueEntryReminderOne(String title, String amount) {
    return '$title ($amount) war heute fällig und wartet noch.';
  }

  @override
  String dueEntryReminderOneOverdue(String title, String amount, String date) {
    return '$title ($amount) war am $date fällig und wartet noch.';
  }

  @override
  String dueEntryReminderUntitled(String amount) {
    return 'Ein wiederkehrender Eintrag ($amount) war heute fällig und wartet noch.';
  }

  @override
  String dueEntryReminderUntitledOverdue(String amount, String date) {
    return 'Ein wiederkehrender Eintrag ($amount) war am $date fällig und wartet noch.';
  }

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wiederkehrende Einträge waren heute fällig.',
      one: '1 wiederkehrender Eintrag war heute fällig.',
    );
    return '$_temp0';
  }

  @override
  String dueEntryReminderManyWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wiederkehrende Einträge warten noch.',
      one: '1 wiederkehrender Eintrag wartet noch.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Heute nichts erfasst';

  @override
  String get emptyDayChannelName => 'Tage ohne Erfassung';

  @override
  String get emptyDayReminderBody =>
      'Trage deine Ausgaben ein, solange du dich noch erinnerst.';

  @override
  String get reminderLockedTitle => 'Etwas wartet auf dich';

  @override
  String get nudgeSettingsTitle => 'An leeren Tagen erinnern';

  @override
  String get nudgeSettingsSubtitle =>
      'Eine Erinnerung am Abend, nur an Tagen ohne Einträge.';

  @override
  String get nudgeOfferTitle => 'Erinnerung an Tagen, die du vergisst?';

  @override
  String get nudgeOfferBody =>
      'Eine Erinnerung zu einer Zeit deiner Wahl, nur an Tagen ohne Einträge. Jederzeit wieder abschaltbar.';

  @override
  String get nudgeOfferYes => 'Ja, erinnere mich';

  @override
  String get nudgeOfferNo => 'Nein danke';

  @override
  String get nudgeStoppedNotice =>
      'Erinnerungen wurden nach drei unbeantworteten gestoppt. Schalte sie jederzeit wieder ein.';

  @override
  String get nudgePermissionDenied =>
      'Aktiviere Benachrichtigungen in den Systemeinstellungen.';

  @override
  String get updateDownloadedMessage => 'Ein Update wurde heruntergeladen.';

  @override
  String get updateRestartButton => 'Neu starten';
}
