// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get transferTooltip => 'Trasferimento';

  @override
  String get searchTooltip => 'Cerca';

  @override
  String get addButton => 'Aggiungi';

  @override
  String get emptyPeriod => 'Ancora nessuna transazione in questo periodo.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get expandSummaryTooltip => 'Mostra entrate e uscite';

  @override
  String get collapseSummaryTooltip => 'Mostra solo il saldo';

  @override
  String get periodNetLabel => 'Questo periodo';

  @override
  String carriedForwardLine(String amount) {
    return 'Riportato $amount';
  }

  @override
  String get incomeLabel => 'Entrate';

  @override
  String get expenseLabel => 'Uscite';

  @override
  String upcomingCategory(String category) {
    return '$category · In arrivo';
  }

  @override
  String get upcomingLabel => 'In arrivo';

  @override
  String detailAdded(String date) {
    return 'Aggiunta il $date';
  }

  @override
  String detailChanged(String date) {
    return 'Ultima modifica il $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transazioni ricorrenti in scadenza',
      one: '1 transazione ricorrente in scadenza',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent usato · $over superati',
      one: '$percent usato · 1 superato',
      zero: '$percent usato',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budget impostati',
      one: '1 budget impostato',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'Impossibile eliminare la transazione. Riprova.';

  @override
  String get transactionDeleted => 'Transazione eliminata';

  @override
  String get transferDeleted => 'Trasferimento eliminato';

  @override
  String get undoButton => 'Annulla';

  @override
  String get undoFailed => 'Impossibile annullare. Riprova.';

  @override
  String get restoreFailed =>
      'Impossibile ripristinare la transazione. Riprova.';

  @override
  String get restoreTransferFailed =>
      'Impossibile ripristinare il trasferimento. Riprova.';

  @override
  String get addTransactionTitle => 'Aggiungi transazione';

  @override
  String get editTransactionTitle => 'Modifica transazione';

  @override
  String get transactionDetailTitle => 'Dettagli';

  @override
  String get editTooltip => 'Modifica';

  @override
  String get deleteTooltip => 'Elimina';

  @override
  String get duplicateTooltip => 'Duplica';

  @override
  String get rowMenuTooltip => 'Altre azioni';

  @override
  String get deleteTransactionTitle => 'Eliminare questa transazione?';

  @override
  String get deleteTransactionMessage =>
      'Va nel cestino e può essere ripristinata per 30 giorni.';

  @override
  String get discardChangesTitle => 'Ignorare le modifiche?';

  @override
  String get discardChangesMessage =>
      'Quello che hai scritto qui non è stato salvato.';

  @override
  String get discardButton => 'Ignora';

  @override
  String get keepEditingButton => 'Continua a modificare';

  @override
  String get titleOptionalLabel => 'Titolo (opzionale)';

  @override
  String get amountLabel => 'Importo';

  @override
  String get amountRequired => 'Inserisci un importo';

  @override
  String get amountInvalid => 'Inserisci un importo valido';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Cancella';

  @override
  String get hideKeypadTooltip => 'Nascondi tastierino';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryRequired => 'Scegli una categoria';

  @override
  String get accountLabel => 'Conto';

  @override
  String get accountRequired => 'Scegli un conto';

  @override
  String get dateLabel => 'Data';

  @override
  String get noteLabel => 'Nota';

  @override
  String get previousDayTooltip => 'Giorno precedente';

  @override
  String get nextDayTooltip => 'Giorno successivo';

  @override
  String get noteOptionalLabel => 'Nota (opzionale)';

  @override
  String get saveChangesButton => 'Salva modifiche';

  @override
  String get addTransactionButton => 'Aggiungi transazione';

  @override
  String get saveAndAddAnotherButton => 'Salva e aggiungi un\'altra';

  @override
  String get transactionAdded => 'Transazione aggiunta';

  @override
  String get saveFailed => 'Impossibile salvare la transazione. Riprova.';

  @override
  String get noExpensesInPeriod => 'Ancora nessuna spesa in questo periodo.';

  @override
  String totalSpent(String amount) {
    return 'Totale speso: $amount';
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
  String get settingsTitle => 'Impostazioni';

  @override
  String get drawerAddHeader => 'Aggiungi';

  @override
  String get drawerAddExpense => 'Aggiungi spesa';

  @override
  String get drawerAddIncome => 'Aggiungi entrata';

  @override
  String get drawerPlanHeader => 'Pianifica';

  @override
  String get drawerReviewHeader => 'Rivedi';

  @override
  String get drawerSpending => 'Spese per categoria';

  @override
  String get drawerManageHeader => 'Gestisci';

  @override
  String get drawerDataHeader => 'Dati';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get currencySearchHint => 'Cerca valute';

  @override
  String changeCurrencyTitle(String code) {
    return 'Cambiare valuta in $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Gli importi restano invariati; cambia solo l\'etichetta della valuta.';

  @override
  String get changeButton => 'Cambia';

  @override
  String get cancelButton => 'Annulla';

  @override
  String get saveButton => 'Salva';

  @override
  String get removeButton => 'Rimuovi';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeBlack => 'Nero';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get languageSystem => 'Predefinita di sistema';

  @override
  String get monthStartLabel => 'Primo giorno del mese';

  @override
  String get monthStartLastDay => 'Ultimo giorno';

  @override
  String get showCarriedForwardLabel => 'Riporta il saldo';

  @override
  String get showCarriedForwardSubtitle =>
      'Ogni periodo parte dal saldo precedente';

  @override
  String get trashTitle => 'Cestino';

  @override
  String get trashEmpty => 'Il cestino è vuoto.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'eliminazione definitiva tra $days giorni',
      one: 'eliminazione definitiva tra 1 giorno',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'eliminazione definitiva tra $days giorni',
      one: 'eliminazione definitiva tra 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => 'Ripristina';

  @override
  String get categoriesTitle => 'Categorie';

  @override
  String get addCategoryTooltip => 'Aggiungi categoria';

  @override
  String get addCategoryTitle => 'Aggiungi categoria';

  @override
  String get editCategoryTitle => 'Modifica categoria';

  @override
  String get categoryNameLabel => 'Nome';

  @override
  String get categoryNameRequired => 'Inserisci un nome';

  @override
  String get categoryNameTaken => 'Questo nome è già in uso';

  @override
  String get archiveAction => 'Archivia';

  @override
  String get unarchiveAction => 'Disarchivia';

  @override
  String get deleteAction => 'Elimina';

  @override
  String get archivedHeader => 'Archiviate';

  @override
  String get accountsTotalLabel => 'Totale';

  @override
  String get categorySaveFailed => 'Impossibile salvare la categoria. Riprova.';

  @override
  String get accountsTitle => 'Conti';

  @override
  String get accountCash => 'Contanti';

  @override
  String get accountTypeLabel => 'Tipo';

  @override
  String get accountTypeCash => 'Contanti';

  @override
  String get accountTypeBank => 'Banca';

  @override
  String get accountTypeCard => 'Carta';

  @override
  String get accountTypeOther => 'Altro';

  @override
  String get addAccountTooltip => 'Aggiungi conto';

  @override
  String get addAccountTitle => 'Aggiungi conto';

  @override
  String get editAccountTitle => 'Modifica conto';

  @override
  String get openingBalanceLabel => 'Saldo iniziale';

  @override
  String get openingDateLabel => 'Data di apertura';

  @override
  String get accountSaveFailed => 'Impossibile salvare il conto. Riprova.';

  @override
  String get transferTitle => 'Trasferimento';

  @override
  String get editTransferTitle => 'Modifica trasferimento';

  @override
  String get transferLabel => 'Trasferimento';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Da';

  @override
  String get toAccountLabel => 'A';

  @override
  String get sameAccountError => 'Scegli due conti diversi';

  @override
  String get needTwoAccounts =>
      'Aggiungi un secondo conto per spostare denaro tra conti.';

  @override
  String get addTransferButton => 'Aggiungi trasferimento';

  @override
  String get transferSaveFailed =>
      'Impossibile salvare il trasferimento. Riprova.';

  @override
  String get searchHint => 'Cerca transazioni';

  @override
  String get allTypesFilter => 'Tutti';

  @override
  String get allCategoriesFilter => 'Tutte le categorie';

  @override
  String get allAccountsFilter => 'Tutti i conti';

  @override
  String get allTimeFilter => 'Sempre';

  @override
  String get clearDatesTooltip => 'Cancella date';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
    );
    return '$_temp0 · Entrate $income · Uscite $expense';
  }

  @override
  String get noSearchResults => 'Nessuna transazione corrispondente.';

  @override
  String get budgetsTitle => 'Budget';

  @override
  String get budgetsTooltip => 'Budget';

  @override
  String get overallBudget => 'Totale';

  @override
  String get noBudget => 'Nessun budget';

  @override
  String budgetsHint(String period) {
    return 'I limiti si applicano da $period in poi; i periodi precedenti mantengono i propri.';
  }

  @override
  String get budgetLimitLabel => 'Limite per periodo';

  @override
  String get budgetSaveFailed => 'Impossibile salvare il budget. Riprova.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent di $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining rimanenti · $perDay al giorno';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount spesi · $perDay al giorno finora';
  }

  @override
  String get homeSetBudget => 'Imposta un budget mensile';

  @override
  String budgetLeft(String remaining) {
    return '$remaining rimanenti';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Superato di $amount';
  }

  @override
  String get budgetLimitReached => 'Limite raggiunto';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limite $limit';
  }

  @override
  String get recurringTitle => 'Ricorrenti';

  @override
  String get addRecurringTooltip => 'Aggiungi ricorrente';

  @override
  String get addRecurringTitle => 'Aggiungi ricorrente';

  @override
  String get editRecurringTitle => 'Modifica ricorrente';

  @override
  String get dueHeader => 'In scadenza';

  @override
  String get upcomingHeader => 'Prossimi 30 giorni';

  @override
  String get rulesHeader => 'Regole';

  @override
  String billsPerMonth(String amount) {
    return '$amount al mese in bollette';
  }

  @override
  String nextBillToday(String title) {
    return 'Prossima: $title, oggi';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'Prossima: $title, domani';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Prossima: $title, tra $days giorni',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Niente nei prossimi 30 giorni.';

  @override
  String get noRules => 'Ancora nessuna transazione ricorrente.';

  @override
  String get recurringEmptyMessage =>
      'Le transazioni ricorrenti registrano affitto, stipendio o un abbonamento secondo la pianificazione che imposti, e attendono un tocco per confermare ciascuna.';

  @override
  String get addRecurringButton => 'Aggiungi una transazione ricorrente';

  @override
  String get postButton => 'Registra';

  @override
  String get skipButton => 'Salta';

  @override
  String get postFailed => 'Impossibile registrare la transazione. Riprova.';

  @override
  String get recurringSaveFailed =>
      'Impossibile salvare la transazione ricorrente. Riprova.';

  @override
  String get recurringDeleted => 'Transazione ricorrente eliminata';

  @override
  String get everyLabel => 'Ogni';

  @override
  String get frequencyDays => 'Giorni';

  @override
  String get frequencyWeeks => 'Settimane';

  @override
  String get frequencyMonths => 'Mesi';

  @override
  String get frequencyYears => 'Anni';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count giorni',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'Ogni giorno';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count settimane',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'Ogni settimana';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count mesi',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'Ogni mese';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count anni',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'Ogni anno';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · In pausa';
  }

  @override
  String get startsLabel => 'Inizio';

  @override
  String get endsLabel => 'Fine';

  @override
  String get endNever => 'Mai';

  @override
  String get endAfter => 'Dopo';

  @override
  String get endOnDate => 'Alla data';

  @override
  String get timesLabel => 'Volte';

  @override
  String get endsOnLabel => 'Termina il';

  @override
  String get wholeNumberInvalid => 'Inserisci un numero intero da 1 in su';

  @override
  String wholeNumberRange(int max) {
    return 'Inserisci un numero intero da 1 a $max';
  }

  @override
  String get endDateInvalid =>
      'La data di fine deve essere successiva a quella di inizio';

  @override
  String get autoPostLabel => 'Registra automaticamente';

  @override
  String get autoPostSubtitle =>
      'Altrimenti resta in sospeso, in attesa di un tocco';

  @override
  String get pauseTooltip => 'Pausa';

  @override
  String get resumeTooltip => 'Riprendi';

  @override
  String get categoryFood => 'Cibo';

  @override
  String get categoryGroceries => 'Spesa';

  @override
  String get categoryTransport => 'Trasporti';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bollette';

  @override
  String get categoryRent => 'Affitto';

  @override
  String get categoryHealth => 'Salute';

  @override
  String get categoryEducation => 'Istruzione';

  @override
  String get categoryEntertainment => 'Intrattenimento';

  @override
  String get categorySalary => 'Stipendio';

  @override
  String get categoryBusiness => 'Attività';

  @override
  String get categoryInvestment => 'Investimenti';

  @override
  String get categoryGift => 'Regalo';

  @override
  String get categoryOther => 'Altro';

  @override
  String get previousPeriodTooltip => 'Periodo precedente';

  @override
  String get wholePeriodTooltip => 'Mostra tutto il periodo';

  @override
  String get nextPeriodTooltip => 'Periodo successivo';

  @override
  String get insightsTooltip => 'Statistiche';

  @override
  String get insightsTitle => 'Statistiche';

  @override
  String get calendarTab => 'Calendario';

  @override
  String get trendTab => 'Andamento';

  @override
  String get noIncomeInPeriod => 'Ancora nessuna entrata in questo periodo.';

  @override
  String totalIncome(String amount) {
    return 'Totale entrate: $amount';
  }

  @override
  String comparedMore(String amount) {
    return '$amount in più rispetto al mese scorso';
  }

  @override
  String comparedLess(String amount) {
    return '$amount in meno rispetto al mese scorso';
  }

  @override
  String get comparedSame => 'Uguale al mese scorso';

  @override
  String get categoryNewLabel => 'nuovo';

  @override
  String get calendarHint => 'Tocca un giorno per vedere le sue transazioni.';

  @override
  String get dayEmpty => 'Niente in questo giorno.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi',
      one: '1 mese',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Entrate $income · Uscite $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Media per periodo · Entrate $income · Uscite $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'Un andamento richiede più di un periodo. Torna il mese prossimo.';

  @override
  String get weekStartLabel => 'Primo giorno della settimana';

  @override
  String weekStartDefault(String day) {
    return 'Predefinito ($day)';
  }

  @override
  String get firstRunTitle => 'Benvenuto in Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Tieni traccia di entrate e spese. I tuoi dati restano su questo dispositivo.';

  @override
  String get addFirstTransactionButton => 'Aggiungi la tua prima transazione';

  @override
  String get setupIntro =>
      'Scegli lingua e valuta. Potrai cambiarle in seguito nelle Impostazioni.';

  @override
  String get setupContinueButton => 'Continua';

  @override
  String get setupRestoreTitle => 'Ripristina un backup';

  @override
  String get setupRestoreSubtitle =>
      'Recupera dati e impostazioni da un file di backup';

  @override
  String get walkthroughEntryTitle => 'Aggiungi in pochi secondi';

  @override
  String get walkthroughEntryBody =>
      'Un tastierino che fa i calcoli, la foto dello scontrino e una nota vocale quando scrivere è lento.';

  @override
  String get walkthroughPlanTitle => 'Pianifica il mese';

  @override
  String get walkthroughPlanBody =>
      'Budget per categoria, bollette che si ripetono da sole e note che te lo ricordano.';

  @override
  String get walkthroughInsightsTitle => 'Scopri dove vanno i tuoi soldi';

  @override
  String get walkthroughInsightsBody =>
      'Grafici, un calendario e un report PDF o CSV per qualsiasi periodo.';

  @override
  String get walkthroughPrivacyTitle => 'Solo tuoi';

  @override
  String get walkthroughPrivacyBody =>
      'Nessun account. Ciò che registri resta su questo telefono; le pubblicità che finanziano l\'app non lo vedono mai.';

  @override
  String get walkthroughBringTitle => 'Porta quello che hai già';

  @override
  String get walkthroughBringBody =>
      'Vieni da un\'altra app o da un altro telefono? Parti da un backup o da un CSV invece che da zero.';

  @override
  String get firstRunRestoreTitle => 'Ripristinare questo backup?';

  @override
  String get firstRunRestoreMessage =>
      'Sostituisce tutto ciò che è nell\'app e ripristina la lingua e la valuta con cui è stato salvato.';

  @override
  String get walkthroughNextButton => 'Avanti';

  @override
  String get walkthroughStartButton => 'Inizia';

  @override
  String get walkthroughDoneButton => 'Fine';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Pagina $current di $total';
  }

  @override
  String get walkthroughReplayTitle => 'Rivedi la guida introduttiva';

  @override
  String get walkthroughReplaySubtitle =>
      'Le quattro pagine mostrate quando hai aperto l\'app per la prima volta';

  @override
  String get removeAdsTitle => 'Rimuovi pubblicità';

  @override
  String get exportCsvMenu => 'Esporta CSV';

  @override
  String get exportCsvTooltip => 'Esporta CSV';

  @override
  String get csvExported => 'CSV salvato';

  @override
  String get csvExportFailed => 'Impossibile esportare il CSV. Riprova.';

  @override
  String get backupTitle => 'Backup e ripristino';

  @override
  String get backupIntro =>
      'I backup sono file che salvi dove preferisci. Niente viene caricato o inviato automaticamente.';

  @override
  String get backUpNowTitle => 'Esegui backup ora';

  @override
  String lastBackupLine(String date) {
    return 'Ultimo backup $date';
  }

  @override
  String get neverBackedUp => 'Nessun backup ancora';

  @override
  String get backupSaved => 'Backup salvato';

  @override
  String get backupSaveFailed => 'Impossibile salvare il backup. Riprova.';

  @override
  String get restoreFromFileTitle => 'Ripristina da un file';

  @override
  String get restoreFromFileSubtitle =>
      'Unisci un backup ai tuoi dati oppure sostituiscili con esso';

  @override
  String get backupReminderLabel => 'Promemoria backup';

  @override
  String get backupReminderSubtitle =>
      'Ogni 30 giorni, una volta raggiunte 20 transazioni';

  @override
  String get backupReminderNever =>
      'Esegui il backup dei tuoi dati per tenerli al sicuro';

  @override
  String backupReminderSince(String date) {
    return 'Ultimo backup $date. È ora di farne uno nuovo?';
  }

  @override
  String get notNowTooltip => 'Non ora';

  @override
  String get keptBackupsHeader => 'Backup automatici';

  @override
  String get keptBackupsHint =>
      'Salvati su questo dispositivo prima di ogni ripristino.';

  @override
  String get noKeptBackups => 'Ancora nessuno.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transazioni',
      one: '1 transazione',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Ripristina backup';

  @override
  String get mergeOption => 'Unisci';

  @override
  String get mergeOptionSubtitle =>
      'Mantieni i tuoi dati e aggiungi quelli del backup. Se un record è in entrambi, vince la modifica più recente.';

  @override
  String get replaceOption => 'Sostituisci';

  @override
  String get replaceOptionSubtitle =>
      'Elimina i tuoi dati e usa solo quelli del backup, con le sue impostazioni.';

  @override
  String get restoreSafetyNote =>
      'Prima viene salvata una copia dei tuoi dati attuali in Backup automatici.';

  @override
  String get restoreButton => 'Ripristina';

  @override
  String get restoreKeptTitle => 'Ripristinare questa copia?';

  @override
  String restoreKeptMessage(String date) {
    return 'I tuoi dati vengono sostituiti dalla copia del $date. Prima viene salvata una copia dei dati attuali.';
  }

  @override
  String get backupInvalid =>
      'Questo file non è un backup di Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Questo backup proviene da una versione più recente dell\'app. Aggiorna l\'app e riprova.';

  @override
  String get backupOpenFailed => 'Impossibile aprire il file. Riprova.';

  @override
  String get backupRestoreFailed =>
      'Impossibile ripristinare il backup. I tuoi dati non sono stati modificati.';

  @override
  String get dbTooNewTitle => 'Aggiornamento necessario';

  @override
  String get dbTooNewMessage =>
      'Questi dati sono stati salvati da una versione più recente dell\'app. Aggiornala dallo store per continuare.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ripristinate $count transazioni',
      one: 'Ripristinata 1 transazione',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Unione completata: $added aggiunte, $updated aggiornate, $unchanged invariate';
  }

  @override
  String get appLockLabel => 'Blocco app';

  @override
  String get appLockSubtitle => 'Sblocca con impronta, viso o blocco schermo';

  @override
  String get appLockUnavailable =>
      'Imposta un blocco schermo su questo dispositivo per usare il blocco app';

  @override
  String get appLockReason => 'Sblocca Monthly Expenses';

  @override
  String get appLockPromptHint => 'Confermare l\'identità';

  @override
  String get appLockFailed =>
      'Impossibile confermare la tua identità. Il blocco app non è stato modificato.';

  @override
  String get lockedTitle => 'Monthly Expenses è bloccata';

  @override
  String get unlockButton => 'Sblocca';

  @override
  String get widgetShowAmountsLabel => 'Mostra gli importi nel widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'Il widget nella schermata Home li nasconde quando il blocco app è attivo';

  @override
  String get widgetLeftLabel => 'Rimanente';

  @override
  String get widgetAddExpense => 'Aggiungi spesa';

  @override
  String get widgetAddIncome => 'Aggiungi entrata';

  @override
  String get widgetAmountsHidden => 'Gli importi sono nascosti dal blocco app';

  @override
  String get notesTitle => 'Note';

  @override
  String get addNoteTooltip => 'Aggiungi nota';

  @override
  String get addNoteTitle => 'Aggiungi nota';

  @override
  String get editNoteTitle => 'Modifica nota';

  @override
  String get noteTextLabel => 'Nota';

  @override
  String get noteTextRequired => 'Inserisci del testo';

  @override
  String get noteAmountOptionalLabel => 'Importo (opzionale)';

  @override
  String get noteDueDateToggle => 'Imposta una scadenza';

  @override
  String get noteDueDateLabel => 'Scadenza';

  @override
  String get noteReminderToggle => 'Ricordamelo';

  @override
  String get noteReminderTimeLabel => 'Orario del promemoria';

  @override
  String get noteReminderTimeUnset => 'Scegli un orario';

  @override
  String get reminderMayBeLate =>
      'Il telefono può ritardarlo di qualche minuto.';

  @override
  String get noteCategoryOptionalLabel => 'Categoria (opzionale)';

  @override
  String get noteCategoryNone => 'Nessuna';

  @override
  String get recordNoteButton => 'Registra come transazione';

  @override
  String get noteMarkDoneTooltip => 'Segna come fatto';

  @override
  String get noteMarkOpenTooltip => 'Segna come da fare';

  @override
  String get notesEmptyTitle => 'Ancora niente qui';

  @override
  String get notesEmptyMessage =>
      'Le note ricordano cose da fare o controllare, con data, importo e categoria facoltativi.';

  @override
  String get addNoteButton => 'Aggiungi una nota';

  @override
  String get notesOpenHeader => 'Da fare';

  @override
  String get notesDoneHeader => 'Fatte';

  @override
  String get noteDeleted => 'Nota eliminata.';

  @override
  String get noteSaveFailed => 'Impossibile salvare la nota. Riprova.';

  @override
  String get noteDeleteFailed => 'Impossibile eliminare la nota. Riprova.';

  @override
  String get noteRestoreFailed => 'Impossibile ripristinare la nota. Riprova.';

  @override
  String get notesSearchHint => 'Cerca note';

  @override
  String get noteFilterAll => 'Tutte';

  @override
  String get noteFilterOverdue => 'Scadute';

  @override
  String get noteFilterDueToday => 'In scadenza oggi';

  @override
  String get noteFilterUpcoming => 'In arrivo';

  @override
  String get noteFilterNoDate => 'Senza data';

  @override
  String get noNoteResults => 'Nessuna nota corrispondente.';

  @override
  String get noteLinkedTransactionLabel => 'Registrata come transazione';

  @override
  String get noteLinkedNoteLabel => 'Da una nota';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count note in scadenza',
      one: '1 nota in scadenza',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Note in scadenza';

  @override
  String get noteReminderTitle => 'Promemoria nota';

  @override
  String get noteReminderLockedTitle => 'Una nota è in scadenza';

  @override
  String get noteReminderChannelName => 'Promemoria note';

  @override
  String get noteReminderPermissionDenied =>
      'Attiva le notifiche nelle impostazioni di sistema per ricevere promemoria per le note.';

  @override
  String reportRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String reportCreated(String when) {
    return 'Creato il $when';
  }

  @override
  String reportNarrowedTo(String description) {
    return 'Limitato a: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Pagina $page di $pages';
  }

  @override
  String get reportNet => 'Netto';

  @override
  String get reportMatchingIncome => 'Entrate corrispondenti';

  @override
  String get reportMatchingExpense => 'Spesa corrispondente';

  @override
  String get reportMatchingNet => 'Netto corrispondente';

  @override
  String get reportOpeningBalance => 'Saldo iniziale';

  @override
  String get reportClosingBalance => 'Saldo finale';

  @override
  String get reportSpendingHeader => 'Spese per categoria';

  @override
  String get reportEarningHeader => 'Entrate per categoria';

  @override
  String get reportTrendHeader => 'Andamento';

  @override
  String get reportEntriesHeader => 'Transazioni';

  @override
  String get reportUpcomingHeader => 'In arrivo';

  @override
  String get reportUpcomingNote =>
      'Con data futura, quindi non incluse nei totali sopra.';

  @override
  String get reportAmountColumn => 'Importo';

  @override
  String get reportShareColumn => 'Quota';

  @override
  String get reportBudgetColumn => 'Budget';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used di $limit';
  }

  @override
  String get reportDetailsColumn => 'Dettagli';

  @override
  String get reportEmpty => 'Niente da segnalare per queste date.';

  @override
  String get exportPdfMenu => 'Esporta PDF';

  @override
  String get reportTitle => 'Esporta PDF';

  @override
  String get reportNoFontTitle => 'Non ancora in questa lingua';

  @override
  String get reportNoFontBody =>
      'Un report ha bisogno di un font per la sua scrittura, e quelli di cinese, giapponese e coreano sono troppo grandi per l\'app. Una versione futura ne proporrà il download.';

  @override
  String get reportPreviewTitle => 'Report';

  @override
  String get reportCoversHeader => 'Cosa comprende';

  @override
  String get reportNarrowedNotice =>
      'Questo report resta limitato alla tua ricerca.';

  @override
  String get reportRangePeriod => 'Questo periodo';

  @override
  String get reportRangeCustom => 'Date';

  @override
  String get reportRangeYear => 'Anno';

  @override
  String get reportFromLabel => 'Da';

  @override
  String get reportToLabel => 'A';

  @override
  String get reportYearLabel => 'Anno';

  @override
  String get reportAccountLabel => 'Conto';

  @override
  String get reportAllAccounts => 'Tutti i conti';

  @override
  String get reportIncludeHeader => 'Cosa contiene';

  @override
  String get reportIncludeSubtitle =>
      'Escludi ciò che preferisci non condividere.';

  @override
  String get reportIncludeTransactions => 'L\'elenco delle transazioni';

  @override
  String get reportIncludeDetails => 'Titoli e note';

  @override
  String get reportIncludeAccounts => 'Nomi dei conti';

  @override
  String get reportCreateButton => 'Crea il report';

  @override
  String get reportBuilding => 'Creazione del report in corso';

  @override
  String get reportFailed => 'Impossibile creare il report. Riprova.';

  @override
  String get reportRangeBackwards =>
      'La prima data deve essere precedente all\'ultima.';

  @override
  String get importTitle => 'Importa un CSV';

  @override
  String get importSubtitle => 'Importa transazioni da un\'altra app';

  @override
  String get importIntro =>
      'Scegli un file CSV e vedrai come l\'app lo ha interpretato prima che venga aggiunto qualcosa. L\'importazione aggiunge solo record: non sostituisce né elimina mai ciò che hai già.';

  @override
  String get importChooseFile => 'Scegli un file';

  @override
  String get importChooseAnother => 'Scegli un altro file';

  @override
  String get importReadFailed => 'Impossibile leggere quel file. Riprova.';

  @override
  String get importRefusedEmpty => 'Quel file è vuoto.';

  @override
  String get importRefusedNoDate =>
      'Nessuna colonna di quel file può essere letta come data, quindi non può essere importato.';

  @override
  String get importRefusedNoAmount =>
      'Nessuna colonna di quel file può essere letta come importo, quindi non può essere importato.';

  @override
  String get importRefusedNoRows =>
      'Nessuna riga di quel file può essere letta, quindi non c\'è nulla da importare.';

  @override
  String get importColumnsHeader => 'Colonne';

  @override
  String get importColumnsSubtitle =>
      'Correggi ciò che l\'app ha interpretato in modo errato.';

  @override
  String get importColumnNone => 'Non usata';

  @override
  String get importFieldType => 'Tipo';

  @override
  String get importFieldToAccount => 'Conto di destinazione';

  @override
  String get importFieldTitle => 'Titolo';

  @override
  String get importFieldNote => 'Nota';

  @override
  String get importDateOrderLabel => 'Le date come 03/04 significano';

  @override
  String get importDayFirst => 'Prima il giorno';

  @override
  String get importMonthFirst => 'Prima il mese';

  @override
  String get importCountsHeader => 'Cosa succederà';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verranno importate $count righe',
      one: 'Verrà importata 1 riga',
      zero: 'Non verrà importato nulla',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count righe hanno una data che l\'app non riesce a leggere',
      one: '1 riga ha una data che l\'app non riesce a leggere',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count righe hanno un importo che l\'app non riesce a leggere',
      one: '1 riga ha un importo che l\'app non riesce a leggere',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count righe non hanno alcun importo',
      one: '1 riga non ha alcun importo',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count righe sono già presenti nell\'app',
      one: '1 riga è già presente nell\'app',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trasferimenti indicano un solo conto',
      one: '1 trasferimento indica un solo conto',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Data non leggibile';

  @override
  String get importRowUnreadableAmount => 'Importo non leggibile';

  @override
  String get importRowZero => 'Nessun importo';

  @override
  String get importRowAlreadyThere => 'Già presente nell\'app';

  @override
  String get importRowIncompleteTransfer => 'Indicato un solo conto';

  @override
  String get importNamesHeader => 'Nomi che l\'app non ha';

  @override
  String get importNamesSubtitle =>
      'Scegli cosa diventa ciascuno. L\'importazione non crea mai una categoria o un conto.';

  @override
  String get importRowsHeader => 'Le prime righe, così come lette dall\'app';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e altre $count',
      one: 'e un\'altra',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importa $count righe',
      one: 'Importa 1 riga',
      zero: 'Niente da importare',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count record importati',
      one: '1 record importato',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Impossibile importare quel file. Non è stato aggiunto nulla.';

  @override
  String get attachmentsLabel => 'Allegati';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoAdd => 'Aggiungi una foto';

  @override
  String get photoTake => 'Scatta una foto';

  @override
  String get photoChoose => 'Scegli una foto';

  @override
  String get photoRemove => 'Rimuovi foto';

  @override
  String get photoMissing => 'Questa foto è mancante.';

  @override
  String get voiceNoteLabel => 'Nota vocale';

  @override
  String get voiceRecord => 'Registra una nota vocale';

  @override
  String voiceRecording(int seconds) {
    return 'Registrazione, ${seconds}s rimanenti';
  }

  @override
  String get voiceStop => 'Interrompi';

  @override
  String get voicePlay => 'Riproduci';

  @override
  String get voicePause => 'Pausa';

  @override
  String get voiceRemove => 'Rimuovi nota vocale';

  @override
  String get voiceMissing => 'Questa nota vocale è mancante.';

  @override
  String get microphoneRefused => 'Il microfono è disattivato per questa app.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Include gli allegati, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Nasconde tutte le pubblicità con un unico pagamento. È legato al tuo account dello store, quindi torna anche con un nuovo telefono o dopo una reinstallazione.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Rimuovi pubblicità per $price';
  }

  @override
  String get removeAdsOwned => 'Le pubblicità sono disattivate. Grazie.';

  @override
  String get removeAdsPending => 'In attesa dello store…';

  @override
  String get removeAdsUnavailable =>
      'Lo store non ha ancora nulla da vendere qui. Riprova più tardi.';

  @override
  String get removeAdsFailed =>
      'Non è andato a buon fine e non hai ricevuto alcun addebito.';

  @override
  String get restorePurchasesButton => 'Ripristina acquisti';

  @override
  String get payNothingWithheld =>
      'Tutte le funzioni restano gratuite, con o senza pubblicità.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Prossimamente';

  @override
  String get plusBody =>
      'Un collegamento bancario che importa le tue transazioni da confermare. Non è ancora pronto, quindi per ora non c\'è nulla da acquistare.';

  @override
  String get privacyOptionsTitle => 'Opzioni sulla privacy';

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get privacyOptionsSubtitle =>
      'Modifica la tua scelta sugli annunci personalizzati';

  @override
  String get dueEntryReminderTitle => 'Una voce era scaduta';

  @override
  String get dueEntryChannelName => 'Voci scadute';

  @override
  String dueEntryReminderOne(String title) {
    return '$title era previsto per oggi ed è ancora in attesa.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'Una voce ricorrente era prevista per oggi ed è ancora in attesa.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci ricorrenti erano previste per oggi.',
      one: '1 voce ricorrente era prevista per oggi.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Nessuna registrazione oggi';

  @override
  String get emptyDayChannelName => 'Giorni senza registrazioni';

  @override
  String get emptyDayReminderBody =>
      'Aggiungi le tue spese finché le ricordi ancora.';

  @override
  String get reminderLockedTitle => 'C\'è qualcosa in attesa';

  @override
  String get nudgeSettingsTitle => 'Ricordamelo nei giorni vuoti';

  @override
  String get nudgeSettingsSubtitle =>
      'Un promemoria alla sera, solo nei giorni senza alcuna registrazione.';

  @override
  String get nudgeOfferTitle => 'Promemoria nei giorni che dimentichi?';

  @override
  String get nudgeOfferBody =>
      'Un promemoria all\'ora che scegli tu, solo nei giorni senza registrazioni. Disattivabile quando vuoi.';

  @override
  String get nudgeOfferYes => 'Sì, ricordamelo';

  @override
  String get nudgeOfferNo => 'No grazie';

  @override
  String get nudgeStoppedNotice =>
      'I promemoria si sono fermati dopo tre senza risposta. Riattivali quando vuoi.';

  @override
  String get nudgePermissionDenied =>
      'Attiva le notifiche nelle impostazioni di sistema.';

  @override
  String get updateDownloadedMessage => 'È stato scaricato un aggiornamento.';

  @override
  String get updateRestartButton => 'Riavvia';
}
