// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String get transferTooltip => 'Virement';

  @override
  String get searchTooltip => 'Rechercher';

  @override
  String get addButton => 'Ajouter';

  @override
  String get emptyPeriod => 'Aucune transaction pour cette période.';

  @override
  String get balanceLabel => 'Solde';

  @override
  String get periodNetLabel => 'Cette période';

  @override
  String carriedForwardLine(String amount) {
    return 'Report $amount';
  }

  @override
  String get incomeLabel => 'Revenus';

  @override
  String get expenseLabel => 'Dépenses';

  @override
  String upcomingCategory(String category) {
    return '$category · À venir';
  }

  @override
  String get upcomingLabel => 'À venir';

  @override
  String detailAdded(String date) {
    return 'Ajouté le $date';
  }

  @override
  String detailChanged(String date) {
    return 'Modifié le $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions récurrentes sont dues',
      one: '1 transaction récurrente est due',
    );
    return '$_temp0';
  }

  @override
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets ont dépassé leur limite',
      one: '1 budget a dépassé sa limite',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent utilisé · $over dépassés',
      one: '$percent utilisé · 1 dépassé',
      zero: '$percent utilisé',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets prévus',
      one: '1 budget prévu',
    );
    return '$_temp0';
  }

  @override
  String get editBudgetsButton => 'Modifier les budgets';

  @override
  String get deleteFailed =>
      'Impossible de supprimer la transaction. Réessayez.';

  @override
  String get transactionDeleted => 'Transaction supprimée';

  @override
  String get transferDeleted => 'Virement supprimé';

  @override
  String get undoButton => 'Annuler';

  @override
  String get undoFailed => 'Impossible d’annuler. Réessayez.';

  @override
  String get restoreFailed =>
      'Impossible de restaurer la transaction. Réessayez.';

  @override
  String get addTransactionTitle => 'Ajouter une transaction';

  @override
  String get editTransactionTitle => 'Modifier la transaction';

  @override
  String get transactionDetailTitle => 'Détails';

  @override
  String get editTooltip => 'Modifier';

  @override
  String get deleteTooltip => 'Supprimer';

  @override
  String get duplicateTooltip => 'Dupliquer';

  @override
  String get titleOptionalLabel => 'Titre (facultatif)';

  @override
  String get amountLabel => 'Montant';

  @override
  String get amountRequired => 'Saisissez un montant';

  @override
  String get amountInvalid => 'Saisissez un montant valide';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Effacer';

  @override
  String get hideKeypadTooltip => 'Masquer le clavier';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get categoryRequired => 'Choisissez une catégorie';

  @override
  String get accountLabel => 'Compte';

  @override
  String get accountRequired => 'Choisissez un compte';

  @override
  String get dateLabel => 'Date';

  @override
  String get noteLabel => 'Note';

  @override
  String get previousDayTooltip => 'Jour précédent';

  @override
  String get nextDayTooltip => 'Jour suivant';

  @override
  String get noteOptionalLabel => 'Note (facultative)';

  @override
  String get saveChangesButton => 'Enregistrer';

  @override
  String get addTransactionButton => 'Ajouter la transaction';

  @override
  String get saveAndAddAnotherButton => 'Enregistrer et ajouter';

  @override
  String get transactionAdded => 'Transaction ajoutée';

  @override
  String get saveFailed =>
      'Impossible d’enregistrer la transaction. Réessayez.';

  @override
  String get noExpensesInPeriod => 'Aucune dépense pour cette période.';

  @override
  String totalSpent(String amount) {
    return 'Total dépensé : $amount';
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
  String get settingsTitle => 'Paramètres';

  @override
  String get drawerAddHeader => 'Ajouter';

  @override
  String get drawerAddExpense => 'Ajouter une dépense';

  @override
  String get drawerAddIncome => 'Ajouter un revenu';

  @override
  String get drawerPlanHeader => 'Planifier';

  @override
  String get drawerReviewHeader => 'Revoir';

  @override
  String get drawerSpending => 'Dépenses par catégorie';

  @override
  String get drawerManageHeader => 'Gérer';

  @override
  String get drawerDataHeader => 'Données';

  @override
  String get currencyLabel => 'Devise';

  @override
  String get currencySearchHint => 'Rechercher une devise';

  @override
  String changeCurrencyTitle(String code) {
    return 'Passer à la devise $code ?';
  }

  @override
  String get changeCurrencyMessage =>
      'Les montants restent identiques ; seul le libellé de la devise change.';

  @override
  String get changeButton => 'Changer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get removeButton => 'Retirer';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get monthStartLabel => 'Premier jour du mois';

  @override
  String get monthStartLastDay => 'Dernier jour';

  @override
  String get showCarriedForwardLabel => 'Reporter le solde';

  @override
  String get showCarriedForwardSubtitle =>
      'Chaque période commence avec le solde précédent';

  @override
  String get trashTitle => 'Corbeille';

  @override
  String get trashEmpty => 'La corbeille est vide.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'supprimé définitivement dans $days jours',
      one: 'supprimé définitivement dans 1 jour',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Restaurer';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get addCategoryTooltip => 'Ajouter une catégorie';

  @override
  String get addCategoryTitle => 'Ajouter une catégorie';

  @override
  String get editCategoryTitle => 'Modifier la catégorie';

  @override
  String get categoryNameLabel => 'Nom';

  @override
  String get categoryNameRequired => 'Saisissez un nom';

  @override
  String get categoryNameTaken => 'Ce nom est déjà utilisé';

  @override
  String get archiveAction => 'Archiver';

  @override
  String get unarchiveAction => 'Désarchiver';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get archivedHeader => 'Archivées';

  @override
  String get categorySaveFailed =>
      'Impossible d’enregistrer la catégorie. Réessayez.';

  @override
  String get accountsTitle => 'Comptes';

  @override
  String get accountCash => 'Espèces';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get accountTypeCash => 'Espèces';

  @override
  String get accountTypeBank => 'Banque';

  @override
  String get accountTypeCard => 'Carte';

  @override
  String get accountTypeOther => 'Autre';

  @override
  String get addAccountTooltip => 'Ajouter un compte';

  @override
  String get addAccountTitle => 'Ajouter un compte';

  @override
  String get editAccountTitle => 'Modifier le compte';

  @override
  String get openingBalanceLabel => 'Solde initial';

  @override
  String get openingDateLabel => 'Date d’ouverture';

  @override
  String get accountSaveFailed =>
      'Impossible d’enregistrer le compte. Réessayez.';

  @override
  String get transferTitle => 'Virement';

  @override
  String get editTransferTitle => 'Modifier le virement';

  @override
  String get transferLabel => 'Virement';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'De';

  @override
  String get toAccountLabel => 'Vers';

  @override
  String get sameAccountError => 'Choisissez deux comptes différents';

  @override
  String get needTwoAccounts =>
      'Ajoutez un deuxième compte pour déplacer de l’argent entre comptes.';

  @override
  String get addTransferButton => 'Ajouter le virement';

  @override
  String get transferSaveFailed =>
      'Impossible d’enregistrer le virement. Réessayez.';

  @override
  String get searchHint => 'Rechercher des transactions';

  @override
  String get allTypesFilter => 'Tout';

  @override
  String get allCategoriesFilter => 'Toutes les catégories';

  @override
  String get allAccountsFilter => 'Tous les comptes';

  @override
  String get allTimeFilter => 'Toutes les dates';

  @override
  String get clearDatesTooltip => 'Effacer les dates';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0 · Revenus $income · Dépenses $expense';
  }

  @override
  String get noSearchResults => 'Aucune transaction correspondante.';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsTooltip => 'Budgets';

  @override
  String get overallBudget => 'Global';

  @override
  String get noBudget => 'Aucun budget';

  @override
  String budgetsHint(String period) {
    return 'Les limites s’appliquent à partir de $period ; les périodes précédentes gardent les leurs.';
  }

  @override
  String get budgetLimitLabel => 'Limite par période';

  @override
  String get budgetSaveFailed =>
      'Impossible d’enregistrer le budget. Réessayez.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent sur $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining restant · $perDay par jour';
  }

  @override
  String budgetLeft(String remaining) {
    return '$remaining restant';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Dépassé de $amount';
  }

  @override
  String get budgetLimitReached => 'Limite atteinte';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limite $limit';
  }

  @override
  String get recurringTitle => 'Récurrentes';

  @override
  String get addRecurringTooltip => 'Ajouter une récurrence';

  @override
  String get addRecurringTitle => 'Ajouter une récurrence';

  @override
  String get editRecurringTitle => 'Modifier la récurrence';

  @override
  String get dueHeader => 'À traiter';

  @override
  String get upcomingHeader => '30 prochains jours';

  @override
  String get rulesHeader => 'Règles';

  @override
  String get nothingUpcoming => 'Rien dans les 30 prochains jours.';

  @override
  String get noRules => 'Aucune transaction récurrente pour l’instant.';

  @override
  String get postButton => 'Enregistrer';

  @override
  String get skipButton => 'Ignorer';

  @override
  String get postFailed =>
      'Impossible d’enregistrer la transaction. Réessayez.';

  @override
  String get recurringSaveFailed =>
      'Impossible d’enregistrer la transaction récurrente. Réessayez.';

  @override
  String get everyLabel => 'Tous les';

  @override
  String get frequencyDays => 'Jours';

  @override
  String get frequencyWeeks => 'Semaines';

  @override
  String get frequencyMonths => 'Mois';

  @override
  String get frequencyYears => 'Ans';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count jours',
      one: 'Tous les jours',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count semaines',
      one: 'Toutes les semaines',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count mois',
      one: 'Tous les mois',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count ans',
      one: 'Tous les ans',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · En pause';
  }

  @override
  String get startsLabel => 'Début';

  @override
  String get endsLabel => 'Fin';

  @override
  String get endNever => 'Jamais';

  @override
  String get endAfter => 'Après';

  @override
  String get endOnDate => 'À une date';

  @override
  String get timesLabel => 'Fois';

  @override
  String get endsOnLabel => 'Se termine le';

  @override
  String get wholeNumberInvalid => 'Saisissez un nombre entier à partir de 1';

  @override
  String get endDateInvalid => 'La date de fin doit être après le début';

  @override
  String get autoPostLabel => 'Enregistrer automatiquement';

  @override
  String get autoPostSubtitle => 'Sinon, elle attend dans À traiter';

  @override
  String get pauseTooltip => 'Mettre en pause';

  @override
  String get resumeTooltip => 'Reprendre';

  @override
  String get categoryFood => 'Repas';

  @override
  String get categoryGroceries => 'Courses';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Factures';

  @override
  String get categoryRent => 'Loyer';

  @override
  String get categoryHealth => 'Santé';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categoryEntertainment => 'Loisirs';

  @override
  String get categorySalary => 'Salaire';

  @override
  String get categoryBusiness => 'Activité pro';

  @override
  String get categoryInvestment => 'Placements';

  @override
  String get categoryGift => 'Cadeau';

  @override
  String get categoryOther => 'Autre';

  @override
  String get previousPeriodTooltip => 'Période précédente';

  @override
  String get nextPeriodTooltip => 'Période suivante';

  @override
  String get insightsTooltip => 'Analyses';

  @override
  String get insightsTitle => 'Analyses';

  @override
  String get calendarTab => 'Calendrier';

  @override
  String get trendTab => 'Tendance';

  @override
  String get noIncomeInPeriod => 'Aucun revenu pour cette période.';

  @override
  String totalIncome(String amount) {
    return 'Total des revenus : $amount';
  }

  @override
  String get calendarHint => 'Touchez un jour pour voir ses transactions.';

  @override
  String get dayEmpty => 'Rien ce jour-là.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Revenus $income · Dépenses $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Moyenne par période · Revenus $income · Dépenses $expense';
  }

  @override
  String get weekStartLabel => 'Premier jour de la semaine';

  @override
  String weekStartDefault(String day) {
    return 'Par défaut ($day)';
  }

  @override
  String get firstRunTitle => 'Bienvenue dans Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Suivez vos dépenses et vos revenus. Vos données restent sur cet appareil.';

  @override
  String get addFirstTransactionButton => 'Ajouter votre première transaction';

  @override
  String get setupIntro =>
      'Choisissez votre langue et votre devise. Vous pourrez les changer plus tard dans les réglages.';

  @override
  String get setupContinueButton => 'Continuer';

  @override
  String get setupRestoreTitle => 'Restaurer une sauvegarde';

  @override
  String get setupRestoreSubtitle =>
      'Récupérez vos données et vos réglages depuis un fichier de sauvegarde';

  @override
  String get walkthroughEntryTitle => 'Ajoutez en quelques secondes';

  @override
  String get walkthroughEntryBody =>
      'Un pavé numérique qui calcule, une photo du reçu et une note vocale quand taper est trop lent.';

  @override
  String get walkthroughPlanTitle => 'Planifiez le mois';

  @override
  String get walkthroughPlanBody =>
      'Des budgets par catégorie, des factures qui se répètent seules et des notes qui vous rappellent.';

  @override
  String get walkthroughInsightsTitle => 'Voyez où va votre argent';

  @override
  String get walkthroughInsightsBody =>
      'Des graphiques, un calendrier et un rapport PDF ou CSV pour n\'importe quelle période.';

  @override
  String get walkthroughPrivacyTitle => 'Rien qu\'à vous';

  @override
  String get walkthroughPrivacyBody =>
      'Aucun compte requis. Ce que vous enregistrez reste sur ce téléphone ; les publicités qui financent l\'appli ne le voient jamais.';

  @override
  String get walkthroughBringTitle => 'Reprenez vos données';

  @override
  String get walkthroughBringBody =>
      'Vous venez d\'une autre application ou d\'un autre téléphone ? Commencez par une sauvegarde ou un CSV plutôt que par une application vide.';

  @override
  String get firstRunRestoreTitle => 'Restaurer cette sauvegarde ?';

  @override
  String get firstRunRestoreMessage =>
      'Elle remplace tout ce qui se trouve dans l\'application et rétablit la langue et la devise enregistrées avec elle.';

  @override
  String get walkthroughNextButton => 'Suivant';

  @override
  String get walkthroughStartButton => 'Commencer';

  @override
  String get walkthroughDoneButton => 'Terminé';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get walkthroughReplayTitle => 'Revoir la présentation';

  @override
  String get walkthroughReplaySubtitle =>
      'Les quatre pages affichées au premier lancement';

  @override
  String get removeAdsTitle => 'Supprimer les publicités';

  @override
  String get exportCsvMenu => 'Exporter en CSV';

  @override
  String get exportCsvTooltip => 'Exporter en CSV';

  @override
  String get csvExported => 'CSV enregistré';

  @override
  String get csvExportFailed => 'Impossible d’exporter le CSV. Réessayez.';

  @override
  String get backupTitle => 'Sauvegarde et restauration';

  @override
  String get backupIntro =>
      'Les sauvegardes sont des fichiers que vous enregistrez où vous voulez. Rien n’est envoyé automatiquement.';

  @override
  String get backUpNowTitle => 'Sauvegarder maintenant';

  @override
  String lastBackupLine(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get neverBackedUp => 'Aucune sauvegarde';

  @override
  String get backupSaved => 'Sauvegarde enregistrée';

  @override
  String get backupSaveFailed =>
      'Impossible d’enregistrer la sauvegarde. Réessayez.';

  @override
  String get restoreFromFileTitle => 'Restaurer depuis un fichier';

  @override
  String get restoreFromFileSubtitle =>
      'Fusionnez une sauvegarde avec vos données, ou remplacez vos données par celle-ci';

  @override
  String get backupReminderLabel => 'Rappel de sauvegarde';

  @override
  String get backupReminderSubtitle => 'Tous les 30 jours dès 20 transactions';

  @override
  String get backupReminderNever => 'Sauvegardez vos données pour les protéger';

  @override
  String backupReminderSince(String date) {
    return 'Dernière sauvegarde : $date. Il est temps d’en faire une nouvelle ?';
  }

  @override
  String get notNowTooltip => 'Plus tard';

  @override
  String get keptBackupsHeader => 'Sauvegardes automatiques';

  @override
  String get keptBackupsHint =>
      'Enregistrées sur cet appareil avant chaque restauration.';

  @override
  String get noKeptBackups => 'Aucune pour l’instant.';

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
  String get restoreTitle => 'Restaurer la sauvegarde';

  @override
  String get mergeOption => 'Fusionner';

  @override
  String get mergeOptionSubtitle =>
      'Gardez vos données et ajoutez celles de la sauvegarde. Si un enregistrement existe des deux côtés, la modification la plus récente l’emporte.';

  @override
  String get replaceOption => 'Remplacer';

  @override
  String get replaceOptionSubtitle =>
      'Supprimez vos données et utilisez uniquement la sauvegarde, avec ses paramètres.';

  @override
  String get restoreSafetyNote =>
      'Une copie de vos données actuelles est d’abord enregistrée dans Sauvegardes automatiques.';

  @override
  String get restoreButton => 'Restaurer';

  @override
  String get restoreKeptTitle => 'Restaurer cette copie ?';

  @override
  String restoreKeptMessage(String date) {
    return 'Vos données sont remplacées par la copie du $date. Une copie de vos données actuelles est enregistrée avant.';
  }

  @override
  String get backupInvalid =>
      'Ce fichier n’est pas une sauvegarde Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Cette sauvegarde vient d’une version plus récente de l’application. Mettez l’application à jour, puis réessayez.';

  @override
  String get backupOpenFailed => 'Impossible d’ouvrir le fichier. Réessayez.';

  @override
  String get backupRestoreFailed =>
      'Impossible de restaurer la sauvegarde. Vos données n’ont pas été modifiées.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions restaurées',
      one: '1 transaction restaurée',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Fusion : $added ajoutés, $updated mis à jour, $unchanged inchangés';
  }

  @override
  String get appLockLabel => 'Verrouillage de l’app';

  @override
  String get appLockSubtitle =>
      'Déverrouillez avec votre empreinte, votre visage ou le verrouillage de l’écran';

  @override
  String get appLockUnavailable =>
      'Configurez un verrouillage d’écran sur cet appareil pour utiliser le verrouillage de l’app';

  @override
  String get appLockReason => 'Déverrouiller Monthly Expenses';

  @override
  String get appLockFailed =>
      'Impossible de confirmer votre identité. Le verrouillage de l’app n’a pas changé.';

  @override
  String get lockedTitle => 'Monthly Expenses est verrouillé';

  @override
  String get unlockButton => 'Déverrouiller';

  @override
  String get widgetShowAmountsLabel => 'Afficher les montants sur le widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'Le widget d\'écran d\'accueil les masque tant que le verrouillage est activé';

  @override
  String get widgetLeftLabel => 'Restant';

  @override
  String get widgetAddExpense => 'Ajouter une dépense';

  @override
  String get widgetAddIncome => 'Ajouter un revenu';

  @override
  String get widgetAmountsHidden => 'Montants masqués par le verrouillage';

  @override
  String get notesTitle => 'Notes';

  @override
  String get addNoteTooltip => 'Ajouter une note';

  @override
  String get addNoteTitle => 'Ajouter une note';

  @override
  String get editNoteTitle => 'Modifier la note';

  @override
  String get noteTextLabel => 'Note';

  @override
  String get noteTextRequired => 'Saisissez du texte';

  @override
  String get noteAmountOptionalLabel => 'Montant (facultatif)';

  @override
  String get noteDueDateToggle => 'Définir une échéance';

  @override
  String get noteDueDateLabel => 'Échéance';

  @override
  String get noteReminderToggle => 'Me le rappeler';

  @override
  String get noteReminderTimeLabel => 'Heure du rappel';

  @override
  String get noteReminderTimeUnset => 'Choisir une heure';

  @override
  String get noteCategoryOptionalLabel => 'Catégorie (facultatif)';

  @override
  String get noteCategoryNone => 'Aucune';

  @override
  String get recordNoteButton => 'Enregistrer comme transaction';

  @override
  String get noteMarkDoneTooltip => 'Marquer comme terminée';

  @override
  String get noteMarkOpenTooltip => 'Marquer comme à faire';

  @override
  String get notesEmptyTitle => 'Rien pour l’instant';

  @override
  String get notesEmptyMessage =>
      'Les notes permettent de se souvenir de choses à faire ou à vérifier, avec une date, un montant et une catégorie facultatifs.';

  @override
  String get addNoteButton => 'Ajouter une note';

  @override
  String get notesOpenHeader => 'À faire';

  @override
  String get notesDoneHeader => 'Terminées';

  @override
  String get noteDeleted => 'Note supprimée.';

  @override
  String get noteSaveFailed => 'Impossible d’enregistrer la note. Réessayez.';

  @override
  String get noteDeleteFailed => 'Impossible de supprimer la note. Réessayez.';

  @override
  String get noteRestoreFailed => 'Impossible de restaurer la note. Réessayez.';

  @override
  String get notesSearchHint => 'Rechercher des notes';

  @override
  String get noteFilterAll => 'Toutes';

  @override
  String get noteFilterOverdue => 'En retard';

  @override
  String get noteFilterDueToday => 'À échéance aujourd’hui';

  @override
  String get noteFilterUpcoming => 'À venir';

  @override
  String get noteFilterNoDate => 'Sans date';

  @override
  String get noNoteResults => 'Aucune note correspondante.';

  @override
  String get noteLinkedTransactionLabel => 'Enregistrée comme transaction';

  @override
  String get noteLinkedNoteLabel => 'Depuis une note';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes sont dues',
      one: '1 note est due',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Notes à échéance';

  @override
  String get noteReminderTitle => 'Rappel de note';

  @override
  String get noteReminderLockedTitle => 'Une note arrive à échéance';

  @override
  String get noteReminderPermissionDenied =>
      'Activez les notifications dans les réglages système pour recevoir des rappels de notes.';

  @override
  String reportRange(String from, String to) {
    return 'Du $from au $to';
  }

  @override
  String reportCreated(String when) {
    return 'Créé le $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Page $page sur $pages';
  }

  @override
  String get reportNet => 'Net';

  @override
  String get reportOpeningBalance => 'Solde d\'ouverture';

  @override
  String get reportClosingBalance => 'Solde de clôture';

  @override
  String get reportSpendingHeader => 'Dépenses par catégorie';

  @override
  String get reportEarningHeader => 'Revenus par catégorie';

  @override
  String get reportTrendHeader => 'Tendance';

  @override
  String get reportEntriesHeader => 'Transactions';

  @override
  String get reportUpcomingHeader => 'À venir';

  @override
  String get reportUpcomingNote =>
      'Daté plus tard, donc non compté dans les totaux ci-dessus.';

  @override
  String get reportAmountColumn => 'Montant';

  @override
  String get reportShareColumn => 'Part';

  @override
  String get reportBudgetColumn => 'Budget';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used de $limit';
  }

  @override
  String get reportDetailsColumn => 'Détails';

  @override
  String get reportEmpty => 'Rien à signaler pour ces dates.';

  @override
  String get exportPdfMenu => 'Exporter en PDF';

  @override
  String get reportTitle => 'Exporter en PDF';

  @override
  String get reportNoFontTitle => 'Pas encore dans cette langue';

  @override
  String get reportNoFontBody =>
      'Un rapport a besoin d\'une police pour son écriture, et celles du chinois, du japonais et du coréen sont trop lourdes pour être embarquées. Une version ultérieure proposera de la télécharger.';

  @override
  String get reportPreviewTitle => 'Rapport';

  @override
  String get reportCoversHeader => 'Ce qu\'il couvre';

  @override
  String get reportRangePeriod => 'Cette période';

  @override
  String get reportRangeCustom => 'Dates';

  @override
  String get reportRangeYear => 'Année';

  @override
  String get reportFromLabel => 'Du';

  @override
  String get reportToLabel => 'Au';

  @override
  String get reportYearLabel => 'Année';

  @override
  String get reportAccountLabel => 'Compte';

  @override
  String get reportAllAccounts => 'Tous les comptes';

  @override
  String get reportIncludeHeader => 'Ce qu\'il contient';

  @override
  String get reportIncludeSubtitle =>
      'Retirez tout ce que vous préférez ne pas partager.';

  @override
  String get reportIncludeTransactions => 'La liste des transactions';

  @override
  String get reportIncludeDetails => 'Titres et notes';

  @override
  String get reportIncludeAccounts => 'Noms des comptes';

  @override
  String get reportCreateButton => 'Créer le rapport';

  @override
  String get reportBuilding => 'Création du rapport';

  @override
  String get reportFailed => 'Impossible de créer le rapport. Réessayez.';

  @override
  String get reportRangeBackwards =>
      'La première date doit précéder la dernière.';

  @override
  String get importTitle => 'Importer un CSV';

  @override
  String get importSubtitle =>
      'Récupérez vos opérations depuis une autre application';

  @override
  String get importIntro =>
      'Choisissez un fichier CSV : vous verrez ce que l\'application en a compris avant que quoi que ce soit soit ajouté. L\'import ne fait qu\'ajouter des enregistrements — il ne remplace ni ne supprime jamais ce que vous avez déjà.';

  @override
  String get importChooseFile => 'Choisir un fichier';

  @override
  String get importChooseAnother => 'Choisir un autre fichier';

  @override
  String get importReadFailed => 'Impossible de lire ce fichier. Réessayez.';

  @override
  String get importRefusedEmpty => 'Ce fichier ne contient rien.';

  @override
  String get importRefusedNoDate =>
      'Aucune colonne de ce fichier n\'a pu être lue comme une date : il ne peut pas être importé.';

  @override
  String get importRefusedNoAmount =>
      'Aucune colonne de ce fichier n\'a pu être lue comme un montant : il ne peut pas être importé.';

  @override
  String get importRefusedNoRows =>
      'Aucune ligne de ce fichier n\'a pu être lue : il n\'y a rien à importer.';

  @override
  String get importColumnsHeader => 'Colonnes';

  @override
  String get importColumnsSubtitle =>
      'Corrigez tout ce que l\'application a mal lu.';

  @override
  String get importColumnNone => 'Non utilisée';

  @override
  String get importFieldType => 'Type';

  @override
  String get importFieldToAccount => 'Compte destinataire';

  @override
  String get importFieldTitle => 'Titre';

  @override
  String get importFieldNote => 'Note';

  @override
  String get importDateOrderLabel => 'Une date comme 03/04 signifie';

  @override
  String get importDayFirst => 'Jour d\'abord';

  @override
  String get importMonthFirst => 'Mois d\'abord';

  @override
  String get importCountsHeader => 'Ce qui va se passer';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes seront importées',
      one: '1 ligne sera importée',
      zero: 'Rien ne sera importé',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes ont une date que l\'application ne sait pas lire',
      one: '1 ligne a une date que l\'application ne sait pas lire',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes ont un montant que l\'application ne sait pas lire',
      one: '1 ligne a un montant que l\'application ne sait pas lire',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes ne portent aucun montant',
      one: '1 ligne ne porte aucun montant',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes sont déjà dans l\'application',
      one: '1 ligne est déjà dans l\'application',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count virements ne nomment qu\'un seul compte',
      one: '1 virement ne nomme qu\'un seul compte',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Date illisible';

  @override
  String get importRowUnreadableAmount => 'Montant illisible';

  @override
  String get importRowZero => 'Aucun montant';

  @override
  String get importRowAlreadyThere => 'Déjà dans l\'application';

  @override
  String get importRowIncompleteTransfer => 'Un seul compte nommé';

  @override
  String get importNamesHeader => 'Noms que cette application n\'a pas';

  @override
  String get importNamesSubtitle =>
      'Choisissez ce que devient chacun. L\'import ne crée jamais de catégorie ni de compte.';

  @override
  String get importRowsHeader => 'Les premières lignes, telles que lues';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'et $count autres',
      one: 'et 1 autre',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count lignes',
      one: 'Importer 1 ligne',
      zero: 'Rien à importer',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements importés',
      one: '1 enregistrement importé',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Impossible d\'importer ce fichier. Rien n\'a été ajouté.';

  @override
  String get attachmentsLabel => 'Pièces jointes';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoAdd => 'Ajouter une photo';

  @override
  String get photoTake => 'Prendre une photo';

  @override
  String get photoChoose => 'Choisir une photo';

  @override
  String get photoRemove => 'Supprimer la photo';

  @override
  String get photoMissing => 'Cette photo est introuvable.';

  @override
  String get voiceNoteLabel => 'Note vocale';

  @override
  String get voiceRecord => 'Enregistrer une note vocale';

  @override
  String voiceRecording(int seconds) {
    return 'Enregistrement, $seconds s restantes';
  }

  @override
  String get voiceStop => 'Arrêter';

  @override
  String get voicePlay => 'Lire';

  @override
  String get voicePause => 'Pause';

  @override
  String get voiceRemove => 'Supprimer la note vocale';

  @override
  String get voiceMissing => 'Cette note vocale est introuvable.';

  @override
  String get microphoneRefused =>
      'Le microphone est désactivé pour cette application.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Inclut les pièces jointes, $size Mo';
  }

  @override
  String get removeAdsBody =>
      'Masque toutes les publicités avec un seul paiement. Lié à votre compte du store, il revient même sur un nouveau téléphone ou après une réinstallation.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Supprimer les publicités pour $price';
  }

  @override
  String get removeAdsOwned => 'Les publicités sont désactivées. Merci.';

  @override
  String get removeAdsPending => 'En attente du store…';

  @override
  String get removeAdsUnavailable =>
      'Le store n\'a encore rien à vendre ici. Réessayez plus tard.';

  @override
  String get removeAdsFailed =>
      'Ça n\'a pas abouti, et vous n\'avez pas été débité.';

  @override
  String get restorePurchasesButton => 'Restaurer les achats';

  @override
  String get payNothingWithheld =>
      'Toutes les fonctionnalités restent gratuites, avec ou sans publicités.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Bientôt disponible';

  @override
  String get plusBody =>
      'Une connexion bancaire qui importe vos transactions pour confirmation. Ce n\'est pas encore terminé, donc rien à acheter pour l\'instant.';

  @override
  String get privacyOptionsTitle => 'Options de confidentialité';

  @override
  String get privacyOptionsSubtitle =>
      'Modifiez votre choix concernant les publicités personnalisées';
}
