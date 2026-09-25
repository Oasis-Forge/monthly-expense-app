// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get transferTooltip => 'Transferencia';

  @override
  String get searchTooltip => 'Buscar';

  @override
  String get addButton => 'Añadir';

  @override
  String get emptyPeriod => 'Aún no hay transacciones en este periodo.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get expandSummaryTooltip => 'Mostrar ingresos y gastos';

  @override
  String get collapseSummaryTooltip => 'Mostrar solo el saldo';

  @override
  String get periodNetLabel => 'Este periodo';

  @override
  String carriedForwardLine(String amount) {
    return 'Saldo anterior $amount';
  }

  @override
  String get incomeLabel => 'Ingresos';

  @override
  String get expenseLabel => 'Gastos';

  @override
  String upcomingCategory(String category) {
    return '$category · Próxima';
  }

  @override
  String get upcomingLabel => 'Próximo';

  @override
  String detailAdded(String date) {
    return 'Añadido el $date';
  }

  @override
  String detailChanged(String date) {
    return 'Modificado el $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones recurrentes pendientes',
      one: '1 transacción recurrente pendiente',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent usado · $over superados',
      one: '$percent usado · 1 superado',
      zero: '$percent usado',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presupuestos fijados',
      one: '1 presupuesto fijado',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed =>
      'No se pudo eliminar la transacción. Inténtalo de nuevo.';

  @override
  String get transactionDeleted => 'Transacción eliminada';

  @override
  String get transferDeleted => 'Transferencia eliminada';

  @override
  String get undoButton => 'Deshacer';

  @override
  String get undoFailed => 'No se pudo deshacer. Inténtalo de nuevo.';

  @override
  String get restoreFailed =>
      'No se pudo restaurar la transacción. Inténtalo de nuevo.';

  @override
  String get restoreTransferFailed =>
      'No se pudo restaurar la transferencia. Inténtalo de nuevo.';

  @override
  String get addTransactionTitle => 'Añadir transacción';

  @override
  String get editTransactionTitle => 'Editar transacción';

  @override
  String get transactionDetailTitle => 'Detalles';

  @override
  String get editTooltip => 'Editar';

  @override
  String get deleteTooltip => 'Eliminar';

  @override
  String get duplicateTooltip => 'Duplicar';

  @override
  String get rowMenuTooltip => 'Más acciones';

  @override
  String get deleteTransactionTitle => '¿Eliminar esta transacción?';

  @override
  String get deleteTransactionMessage =>
      'Va a la papelera y puede restaurarse durante 30 días.';

  @override
  String get discardChangesTitle => '¿Descartar los cambios?';

  @override
  String get discardChangesMessage =>
      'Lo que escribiste aquí no se ha guardado.';

  @override
  String get discardButton => 'Descartar';

  @override
  String get keepEditingButton => 'Seguir editando';

  @override
  String get titleOptionalLabel => 'Título (opcional)';

  @override
  String get amountLabel => 'Importe';

  @override
  String get amountRequired => 'Introduce un importe';

  @override
  String get amountInvalid => 'Introduce un importe válido';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Borrar';

  @override
  String get hideKeypadTooltip => 'Ocultar teclado';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryRequired => 'Elige una categoría';

  @override
  String get accountLabel => 'Cuenta';

  @override
  String get accountRequired => 'Elige una cuenta';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get noteLabel => 'Nota';

  @override
  String get previousDayTooltip => 'Día anterior';

  @override
  String get nextDayTooltip => 'Día siguiente';

  @override
  String get noteOptionalLabel => 'Nota (opcional)';

  @override
  String get saveChangesButton => 'Guardar cambios';

  @override
  String get addTransactionButton => 'Añadir transacción';

  @override
  String get saveAndAddAnotherButton => 'Guardar y añadir otra';

  @override
  String get transactionAdded => 'Transacción añadida';

  @override
  String get saveFailed =>
      'No se pudo guardar la transacción. Inténtalo de nuevo.';

  @override
  String get noExpensesInPeriod => 'Aún no hay gastos en este periodo.';

  @override
  String totalSpent(String amount) {
    return 'Total gastado: $amount';
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
  String get settingsTitle => 'Ajustes';

  @override
  String get drawerAddHeader => 'Añadir';

  @override
  String get drawerAddExpense => 'Añadir gasto';

  @override
  String get drawerAddIncome => 'Añadir ingreso';

  @override
  String get drawerPlanHeader => 'Planificar';

  @override
  String get drawerReviewHeader => 'Revisar';

  @override
  String get drawerSpending => 'Gastos por categoría';

  @override
  String get drawerManageHeader => 'Gestionar';

  @override
  String get drawerDataHeader => 'Datos';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get currencySearchHint => 'Buscar monedas';

  @override
  String changeCurrencyTitle(String code) {
    return '¿Cambiar la moneda a $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Los importes no cambian; solo cambia la etiqueta de la moneda.';

  @override
  String get changeButton => 'Cambiar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get removeButton => 'Quitar';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeBlack => 'Negro';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get monthStartLabel => 'Primer día del mes';

  @override
  String get monthStartLastDay => 'Último día';

  @override
  String get showCarriedForwardLabel => 'Arrastrar el saldo';

  @override
  String get showCarriedForwardSubtitle =>
      'Cada periodo empieza con el saldo anterior';

  @override
  String get trashTitle => 'Papelera';

  @override
  String get trashEmpty => 'La papelera está vacía.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'se borrará definitivamente en $days días',
      one: 'se borrará definitivamente en 1 día',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Restaurar';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get addCategoryTooltip => 'Añadir categoría';

  @override
  String get addCategoryTitle => 'Añadir categoría';

  @override
  String get editCategoryTitle => 'Editar categoría';

  @override
  String get categoryNameLabel => 'Nombre';

  @override
  String get categoryNameRequired => 'Introduce un nombre';

  @override
  String get categoryNameTaken => 'Ese nombre ya está en uso';

  @override
  String get archiveAction => 'Archivar';

  @override
  String get unarchiveAction => 'Desarchivar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get archivedHeader => 'Archivadas';

  @override
  String get accountsTotalLabel => 'Total';

  @override
  String get categorySaveFailed =>
      'No se pudo guardar la categoría. Inténtalo de nuevo.';

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get accountCash => 'Efectivo';

  @override
  String get accountTypeLabel => 'Tipo';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeBank => 'Banco';

  @override
  String get accountTypeCard => 'Tarjeta';

  @override
  String get accountTypeOther => 'Otra';

  @override
  String get addAccountTooltip => 'Añadir cuenta';

  @override
  String get addAccountTitle => 'Añadir cuenta';

  @override
  String get editAccountTitle => 'Editar cuenta';

  @override
  String get openingBalanceLabel => 'Saldo inicial';

  @override
  String get openingDateLabel => 'Fecha de apertura';

  @override
  String get accountSaveFailed =>
      'No se pudo guardar la cuenta. Inténtalo de nuevo.';

  @override
  String get transferTitle => 'Transferencia';

  @override
  String get editTransferTitle => 'Editar transferencia';

  @override
  String get transferLabel => 'Transferencia';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Desde';

  @override
  String get toAccountLabel => 'Hacia';

  @override
  String get sameAccountError => 'Elige dos cuentas distintas';

  @override
  String get needTwoAccounts =>
      'Añade una segunda cuenta para mover dinero entre cuentas.';

  @override
  String get addTransferButton => 'Añadir transferencia';

  @override
  String get transferSaveFailed =>
      'No se pudo guardar la transferencia. Inténtalo de nuevo.';

  @override
  String get searchHint => 'Buscar transacciones';

  @override
  String get allTypesFilter => 'Todo';

  @override
  String get allCategoriesFilter => 'Todas las categorías';

  @override
  String get allAccountsFilter => 'Todas las cuentas';

  @override
  String get allTimeFilter => 'Siempre';

  @override
  String get clearDatesTooltip => 'Borrar fechas';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0 · Ingresos $income · Gastos $expense';
  }

  @override
  String get noSearchResults => 'No hay transacciones que coincidan.';

  @override
  String get budgetsTitle => 'Presupuestos';

  @override
  String get budgetsTooltip => 'Presupuestos';

  @override
  String get overallBudget => 'General';

  @override
  String get noBudget => 'Sin presupuesto';

  @override
  String budgetsHint(String period) {
    return 'Los límites se aplican desde $period; los periodos anteriores conservan los suyos.';
  }

  @override
  String get budgetLimitLabel => 'Límite por periodo';

  @override
  String get budgetSaveFailed =>
      'No se pudo guardar el presupuesto. Inténtalo de nuevo.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'Quedan $remaining · $perDay al día';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'Gastados $amount · $perDay al día hasta ahora';
  }

  @override
  String get homeSetBudget => 'Fijar presupuesto mensual';

  @override
  String budgetLeft(String remaining) {
    return 'Quedan $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Superado en $amount';
  }

  @override
  String get budgetLimitReached => 'Límite alcanzado';

  @override
  String budgetLimitOnly(String limit) {
    return 'Límite $limit';
  }

  @override
  String get recurringTitle => 'Recurrentes';

  @override
  String get addRecurringTooltip => 'Añadir recurrente';

  @override
  String get addRecurringTitle => 'Añadir recurrente';

  @override
  String get editRecurringTitle => 'Editar recurrente';

  @override
  String get dueHeader => 'Pendientes';

  @override
  String get upcomingHeader => 'Próximos 30 días';

  @override
  String get rulesHeader => 'Reglas';

  @override
  String billsPerMonth(String amount) {
    return '$amount al mes en facturas';
  }

  @override
  String nextBillToday(String title) {
    return 'Próximo: $title, hoy';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'Próximo: $title, mañana';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Próximo: $title, en $days días',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Nada en los próximos 30 días.';

  @override
  String get noRules => 'Aún no hay transacciones recurrentes.';

  @override
  String get recurringEmptyMessage =>
      'Las transacciones recurrentes registran el alquiler, un salario o una suscripción según el calendario que definas, y esperan un toque para confirmar cada una.';

  @override
  String get addRecurringButton => 'Añadir una transacción recurrente';

  @override
  String get postButton => 'Registrar';

  @override
  String get skipButton => 'Omitir';

  @override
  String get postFailed =>
      'No se pudo registrar la transacción. Inténtalo de nuevo.';

  @override
  String get recurringSaveFailed =>
      'No se pudo guardar la transacción recurrente. Inténtalo de nuevo.';

  @override
  String get everyLabel => 'Cada';

  @override
  String get frequencyDays => 'Días';

  @override
  String get frequencyWeeks => 'Semanas';

  @override
  String get frequencyMonths => 'Meses';

  @override
  String get frequencyYears => 'Años';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count días',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'Cada día';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count semanas',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'Cada semana';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count meses',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'Cada mes';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count años',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'Cada año';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · En pausa';
  }

  @override
  String get startsLabel => 'Empieza';

  @override
  String get endsLabel => 'Termina';

  @override
  String get endNever => 'Nunca';

  @override
  String get endAfter => 'Tras';

  @override
  String get endOnDate => 'En una fecha';

  @override
  String get timesLabel => 'Veces';

  @override
  String get endsOnLabel => 'Termina el';

  @override
  String get wholeNumberInvalid => 'Introduce un número entero desde 1';

  @override
  String get endDateInvalid => 'La fecha de fin debe ser posterior al inicio';

  @override
  String get autoPostLabel => 'Registrar automáticamente';

  @override
  String get autoPostSubtitle =>
      'Si no, espera en Pendientes hasta que la toques';

  @override
  String get pauseTooltip => 'Pausar';

  @override
  String get resumeTooltip => 'Reanudar';

  @override
  String get categoryFood => 'Comida';

  @override
  String get categoryGroceries => 'Supermercado';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryBills => 'Facturas';

  @override
  String get categoryRent => 'Alquiler';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryEntertainment => 'Ocio';

  @override
  String get categorySalary => 'Salario';

  @override
  String get categoryBusiness => 'Negocio';

  @override
  String get categoryInvestment => 'Inversiones';

  @override
  String get categoryGift => 'Regalo';

  @override
  String get categoryOther => 'Otros';

  @override
  String get previousPeriodTooltip => 'Periodo anterior';

  @override
  String get wholePeriodTooltip => 'Mostrar todo el periodo';

  @override
  String get nextPeriodTooltip => 'Periodo siguiente';

  @override
  String get insightsTooltip => 'Análisis';

  @override
  String get insightsTitle => 'Análisis';

  @override
  String get calendarTab => 'Calendario';

  @override
  String get trendTab => 'Tendencia';

  @override
  String get noIncomeInPeriod => 'Aún no hay ingresos en este periodo.';

  @override
  String totalIncome(String amount) {
    return 'Total de ingresos: $amount';
  }

  @override
  String comparedMore(String amount) {
    return '$amount más que el mes pasado';
  }

  @override
  String comparedLess(String amount) {
    return '$amount menos que el mes pasado';
  }

  @override
  String get comparedSame => 'Igual que el mes pasado';

  @override
  String get categoryNewLabel => 'nuevo';

  @override
  String get calendarHint => 'Toca un día para ver sus transacciones.';

  @override
  String get dayEmpty => 'Nada este día.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Ingresos $income · Gastos $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Media por periodo · Ingresos $income · Gastos $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'Una tendencia necesita más de un periodo. Vuelve el próximo mes.';

  @override
  String get weekStartLabel => 'Primer día de la semana';

  @override
  String weekStartDefault(String day) {
    return 'Predeterminado ($day)';
  }

  @override
  String get firstRunTitle => 'Te damos la bienvenida a Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Controla lo que gastas y lo que ganas. Tus datos se quedan en este dispositivo.';

  @override
  String get addFirstTransactionButton => 'Añade tu primera transacción';

  @override
  String get setupIntro =>
      'Elige tu idioma y tu moneda. Puedes cambiarlos más tarde en Ajustes.';

  @override
  String get setupContinueButton => 'Continuar';

  @override
  String get setupRestoreTitle => 'Restaurar una copia';

  @override
  String get setupRestoreSubtitle =>
      'Recupera tus datos y ajustes desde un archivo de copia';

  @override
  String get walkthroughEntryTitle => 'Añade en segundos';

  @override
  String get walkthroughEntryBody =>
      'Un teclado que suma, una foto del recibo y una nota de voz cuando escribir es lento.';

  @override
  String get walkthroughPlanTitle => 'Planifica el mes';

  @override
  String get walkthroughPlanBody =>
      'Presupuestos por categoría, recibos que se repiten solos y notas que te avisan.';

  @override
  String get walkthroughInsightsTitle => 'Mira a dónde va';

  @override
  String get walkthroughInsightsBody =>
      'Gráficos, un calendario y un informe en PDF o CSV de cualquier periodo.';

  @override
  String get walkthroughPrivacyTitle => 'Solo tuyo';

  @override
  String get walkthroughPrivacyBody =>
      'Sin cuenta. Lo que registras se queda en este teléfono; los anuncios que pagan la app nunca lo ven.';

  @override
  String get walkthroughBringTitle => 'Trae lo que ya tienes';

  @override
  String get walkthroughBringBody =>
      '¿Vienes de otra aplicación o de otro teléfono? Empieza desde una copia de seguridad o un CSV en lugar de una aplicación vacía.';

  @override
  String get firstRunRestoreTitle => '¿Restaurar esta copia de seguridad?';

  @override
  String get firstRunRestoreMessage =>
      'Sustituye todo lo que hay en la aplicación y restaura el idioma y la moneda con los que se guardó.';

  @override
  String get walkthroughNextButton => 'Siguiente';

  @override
  String get walkthroughStartButton => 'Empezar';

  @override
  String get walkthroughDoneButton => 'Listo';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get walkthroughReplayTitle => 'Ver de nuevo la introducción';

  @override
  String get walkthroughReplaySubtitle =>
      'Las cuatro páginas del primer inicio';

  @override
  String get removeAdsTitle => 'Quitar anuncios';

  @override
  String get exportCsvMenu => 'Exportar CSV';

  @override
  String get exportCsvTooltip => 'Exportar CSV';

  @override
  String get csvExported => 'CSV guardado';

  @override
  String get csvExportFailed =>
      'No se pudo exportar el CSV. Inténtalo de nuevo.';

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get backupIntro =>
      'Las copias de seguridad son archivos que guardas donde quieras. No se sube ni se envía nada automáticamente.';

  @override
  String get backUpNowTitle => 'Hacer una copia ahora';

  @override
  String lastBackupLine(String date) {
    return 'Última copia $date';
  }

  @override
  String get neverBackedUp => 'Aún no hay copias';

  @override
  String get backupSaved => 'Copia guardada';

  @override
  String get backupSaveFailed =>
      'No se pudo guardar la copia. Inténtalo de nuevo.';

  @override
  String get restoreFromFileTitle => 'Restaurar desde un archivo';

  @override
  String get restoreFromFileSubtitle =>
      'Combina una copia con tus datos o sustituye tus datos por ella';

  @override
  String get backupReminderLabel => 'Recordatorio de copia';

  @override
  String get backupReminderSubtitle =>
      'Cada 30 días a partir de 20 transacciones';

  @override
  String get backupReminderNever =>
      'Haz una copia de tus datos para protegerlos';

  @override
  String backupReminderSince(String date) {
    return 'Última copia $date. ¿Toca hacer otra?';
  }

  @override
  String get notNowTooltip => 'Ahora no';

  @override
  String get keptBackupsHeader => 'Copias automáticas';

  @override
  String get keptBackupsHint =>
      'Se guardan en este dispositivo antes de cada restauración.';

  @override
  String get noKeptBackups => 'Todavía ninguna.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones',
      one: '1 transacción',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Restaurar copia';

  @override
  String get mergeOption => 'Combinar';

  @override
  String get mergeOptionSubtitle =>
      'Conserva tus datos y añade los de la copia. Si un registro está en ambos, gana el cambio más reciente.';

  @override
  String get replaceOption => 'Sustituir';

  @override
  String get replaceOptionSubtitle =>
      'Elimina tus datos y usa solo la copia, con sus ajustes.';

  @override
  String get restoreSafetyNote =>
      'Antes se guarda una copia de tus datos actuales en Copias automáticas.';

  @override
  String get restoreButton => 'Restaurar';

  @override
  String get restoreKeptTitle => '¿Restaurar esta copia?';

  @override
  String restoreKeptMessage(String date) {
    return 'Tus datos se sustituyen por la copia del $date. Antes se guarda una copia de tus datos actuales.';
  }

  @override
  String get backupInvalid =>
      'Este archivo no es una copia de Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Esta copia es de una versión más reciente de la app. Actualiza la app y vuelve a intentarlo.';

  @override
  String get backupOpenFailed =>
      'No se pudo abrir el archivo. Inténtalo de nuevo.';

  @override
  String get backupRestoreFailed =>
      'No se pudo restaurar la copia. Tus datos no han cambiado.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones restauradas',
      one: '1 transacción restaurada',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Combinado: $added añadidos, $updated actualizados, $unchanged sin cambios';
  }

  @override
  String get appLockLabel => 'Bloqueo de la app';

  @override
  String get appLockSubtitle =>
      'Desbloquea con tu huella, tu cara o el bloqueo de pantalla';

  @override
  String get appLockUnavailable =>
      'Configura un bloqueo de pantalla en este dispositivo para usar el bloqueo de la app';

  @override
  String get appLockReason => 'Desbloquear Monthly Expenses';

  @override
  String get appLockFailed =>
      'No se pudo confirmar tu identidad. El bloqueo de la app no ha cambiado.';

  @override
  String get lockedTitle => 'Monthly Expenses está bloqueada';

  @override
  String get unlockButton => 'Desbloquear';

  @override
  String get widgetShowAmountsLabel => 'Mostrar los importes en el widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'El widget de la pantalla de inicio los oculta mientras el bloqueo esté activado';

  @override
  String get widgetLeftLabel => 'Restante';

  @override
  String get widgetAddExpense => 'Añadir gasto';

  @override
  String get widgetAddIncome => 'Añadir ingreso';

  @override
  String get widgetAmountsHidden => 'Importes ocultos por el bloqueo';

  @override
  String get notesTitle => 'Notas';

  @override
  String get addNoteTooltip => 'Añadir nota';

  @override
  String get addNoteTitle => 'Añadir nota';

  @override
  String get editNoteTitle => 'Editar nota';

  @override
  String get noteTextLabel => 'Nota';

  @override
  String get noteTextRequired => 'Introduce un texto';

  @override
  String get noteAmountOptionalLabel => 'Importe (opcional)';

  @override
  String get noteDueDateToggle => 'Establecer una fecha límite';

  @override
  String get noteDueDateLabel => 'Fecha límite';

  @override
  String get noteReminderToggle => 'Recordármelo';

  @override
  String get noteReminderTimeLabel => 'Hora del recordatorio';

  @override
  String get noteReminderTimeUnset => 'Elegir una hora';

  @override
  String get reminderMayBeLate =>
      'Tu teléfono puede entregar esto con unos minutos de retraso.';

  @override
  String get noteCategoryOptionalLabel => 'Categoría (opcional)';

  @override
  String get noteCategoryNone => 'Ninguna';

  @override
  String get recordNoteButton => 'Registrar como transacción';

  @override
  String get noteMarkDoneTooltip => 'Marcar como hecha';

  @override
  String get noteMarkOpenTooltip => 'Marcar como pendiente';

  @override
  String get notesEmptyTitle => 'Nada por aquí todavía';

  @override
  String get notesEmptyMessage =>
      'Las notas recuerdan cosas por hacer o comprobar, con una fecha, un importe y una categoría opcionales.';

  @override
  String get addNoteButton => 'Añadir una nota';

  @override
  String get notesOpenHeader => 'Pendientes';

  @override
  String get notesDoneHeader => 'Hechas';

  @override
  String get noteDeleted => 'Nota eliminada.';

  @override
  String get noteSaveFailed =>
      'No se pudo guardar la nota. Inténtalo de nuevo.';

  @override
  String get noteDeleteFailed =>
      'No se pudo eliminar la nota. Inténtalo de nuevo.';

  @override
  String get noteRestoreFailed =>
      'No se pudo restaurar la nota. Inténtalo de nuevo.';

  @override
  String get notesSearchHint => 'Buscar notas';

  @override
  String get noteFilterAll => 'Todas';

  @override
  String get noteFilterOverdue => 'Atrasada';

  @override
  String get noteFilterDueToday => 'Vence hoy';

  @override
  String get noteFilterUpcoming => 'Próximas';

  @override
  String get noteFilterNoDate => 'Sin fecha';

  @override
  String get noNoteResults => 'No hay notas coincidentes.';

  @override
  String get noteLinkedTransactionLabel => 'Registrada como transacción';

  @override
  String get noteLinkedNoteLabel => 'Desde una nota';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas vencen',
      one: '1 nota vence',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Notas que vencen';

  @override
  String get noteReminderTitle => 'Recordatorio de nota';

  @override
  String get noteReminderLockedTitle => 'Hay una nota que vence';

  @override
  String get noteReminderPermissionDenied =>
      'Activa las notificaciones en los ajustes del sistema para recibir recordatorios de notas.';

  @override
  String reportRange(String from, String to) {
    return 'Del $from al $to';
  }

  @override
  String reportCreated(String when) {
    return 'Creado el $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Página $page de $pages';
  }

  @override
  String get reportNet => 'Neto';

  @override
  String get reportOpeningBalance => 'Saldo inicial';

  @override
  String get reportClosingBalance => 'Saldo final';

  @override
  String get reportSpendingHeader => 'Gastos por categoría';

  @override
  String get reportEarningHeader => 'Ingresos por categoría';

  @override
  String get reportTrendHeader => 'Tendencia';

  @override
  String get reportEntriesHeader => 'Transacciones';

  @override
  String get reportUpcomingHeader => 'Próximos';

  @override
  String get reportUpcomingNote =>
      'Con fecha posterior, así que no cuentan en los totales de arriba.';

  @override
  String get reportAmountColumn => 'Importe';

  @override
  String get reportShareColumn => 'Proporción';

  @override
  String get reportBudgetColumn => 'Presupuesto';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used de $limit';
  }

  @override
  String get reportDetailsColumn => 'Detalles';

  @override
  String get reportEmpty => 'No hay nada que informar en estas fechas.';

  @override
  String get exportPdfMenu => 'Exportar PDF';

  @override
  String get reportTitle => 'Exportar PDF';

  @override
  String get reportNoFontTitle => 'Todavía no en este idioma';

  @override
  String get reportNoFontBody =>
      'Un informe necesita una fuente para su escritura, y las de chino, japonés y coreano son demasiado grandes para llevarlas en la app. Una versión posterior ofrecerá descargarla.';

  @override
  String get reportPreviewTitle => 'Informe';

  @override
  String get reportCoversHeader => 'Qué abarca';

  @override
  String get reportRangePeriod => 'Este periodo';

  @override
  String get reportRangeCustom => 'Fechas';

  @override
  String get reportRangeYear => 'Año';

  @override
  String get reportFromLabel => 'Desde';

  @override
  String get reportToLabel => 'Hasta';

  @override
  String get reportYearLabel => 'Año';

  @override
  String get reportAccountLabel => 'Cuenta';

  @override
  String get reportAllAccounts => 'Todas las cuentas';

  @override
  String get reportIncludeHeader => 'Qué incluye';

  @override
  String get reportIncludeSubtitle =>
      'Deja fuera lo que prefieras no compartir.';

  @override
  String get reportIncludeTransactions => 'La lista de transacciones';

  @override
  String get reportIncludeDetails => 'Títulos y notas';

  @override
  String get reportIncludeAccounts => 'Nombres de las cuentas';

  @override
  String get reportCreateButton => 'Crear el informe';

  @override
  String get reportBuilding => 'Creando el informe';

  @override
  String get reportFailed => 'No se pudo crear el informe. Inténtalo de nuevo.';

  @override
  String get reportRangeBackwards =>
      'La primera fecha debe ser anterior a la última.';

  @override
  String get importTitle => 'Importar un CSV';

  @override
  String get importSubtitle => 'Trae tus movimientos desde otra aplicación';

  @override
  String get importIntro =>
      'Elige un archivo CSV y verás qué ha entendido la aplicación antes de añadir nada. La importación solo añade registros: nunca sustituye ni borra lo que ya tienes.';

  @override
  String get importChooseFile => 'Elegir un archivo';

  @override
  String get importChooseAnother => 'Elegir otro archivo';

  @override
  String get importReadFailed =>
      'No se pudo leer ese archivo. Inténtalo de nuevo.';

  @override
  String get importRefusedEmpty => 'Ese archivo no contiene nada.';

  @override
  String get importRefusedNoDate =>
      'Ninguna columna de ese archivo se pudo leer como fecha, así que no se puede importar.';

  @override
  String get importRefusedNoAmount =>
      'Ninguna columna de ese archivo se pudo leer como importe, así que no se puede importar.';

  @override
  String get importRefusedNoRows =>
      'No se pudo leer ninguna fila de ese archivo, así que no hay nada que importar.';

  @override
  String get importColumnsHeader => 'Columnas';

  @override
  String get importColumnsSubtitle =>
      'Corrige todo lo que la aplicación haya leído mal.';

  @override
  String get importColumnNone => 'Sin usar';

  @override
  String get importFieldType => 'Tipo';

  @override
  String get importFieldToAccount => 'Cuenta destino';

  @override
  String get importFieldTitle => 'Título';

  @override
  String get importFieldNote => 'Nota';

  @override
  String get importDateOrderLabel => 'Una fecha como 03/04 significa';

  @override
  String get importDayFirst => 'Día primero';

  @override
  String get importMonthFirst => 'Mes primero';

  @override
  String get importCountsHeader => 'Qué va a pasar';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importarán $count filas',
      one: 'Se importará 1 fila',
      zero: 'No se importará nada',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas tienen una fecha que la aplicación no puede leer',
      one: '1 fila tiene una fecha que la aplicación no puede leer',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas tienen un importe que la aplicación no puede leer',
      one: '1 fila tiene un importe que la aplicación no puede leer',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas no llevan ningún importe',
      one: '1 fila no lleva ningún importe',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas ya están en la aplicación',
      one: '1 fila ya está en la aplicación',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transferencias nombran solo una cuenta',
      one: '1 transferencia nombra solo una cuenta',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'No se puede leer la fecha';

  @override
  String get importRowUnreadableAmount => 'No se puede leer el importe';

  @override
  String get importRowZero => 'Sin importe';

  @override
  String get importRowAlreadyThere => 'Ya está en la aplicación';

  @override
  String get importRowIncompleteTransfer => 'Solo se nombra una cuenta';

  @override
  String get importNamesHeader => 'Nombres que esta aplicación no tiene';

  @override
  String get importNamesSubtitle =>
      'Elige en qué se convierte cada uno. La importación nunca crea categorías ni cuentas.';

  @override
  String get importRowsHeader => 'Las primeras filas, tal como se han leído';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'y $count más',
      one: 'y 1 más',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count filas',
      one: 'Importar 1 fila',
      zero: 'Nada que importar',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros importados',
      one: '1 registro importado',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'No se pudo importar ese archivo. No se ha añadido nada.';

  @override
  String get attachmentsLabel => 'Adjuntos';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoAdd => 'Añadir una foto';

  @override
  String get photoTake => 'Hacer una foto';

  @override
  String get photoChoose => 'Elegir una foto';

  @override
  String get photoRemove => 'Quitar la foto';

  @override
  String get photoMissing => 'Esta foto no se encuentra.';

  @override
  String get voiceNoteLabel => 'Nota de voz';

  @override
  String get voiceRecord => 'Grabar una nota de voz';

  @override
  String voiceRecording(int seconds) {
    return 'Grabando, quedan $seconds s';
  }

  @override
  String get voiceStop => 'Detener';

  @override
  String get voicePlay => 'Reproducir';

  @override
  String get voicePause => 'Pausa';

  @override
  String get voiceRemove => 'Quitar la nota de voz';

  @override
  String get voiceMissing => 'Esta nota de voz no se encuentra.';

  @override
  String get microphoneRefused =>
      'El micrófono está desactivado para esta aplicación.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Incluye los adjuntos, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Oculta todos los anuncios con un solo pago. Queda vinculado a tu cuenta de la tienda, así que se mantiene si cambias de teléfono o reinstalas.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Quitar anuncios por $price';
  }

  @override
  String get removeAdsOwned => 'Los anuncios están desactivados. Gracias.';

  @override
  String get removeAdsPending => 'Esperando respuesta de la tienda…';

  @override
  String get removeAdsUnavailable =>
      'La tienda todavía no tiene nada disponible aquí. Inténtalo de nuevo más tarde.';

  @override
  String get removeAdsFailed =>
      'Eso no se pudo completar y no se te cobró nada.';

  @override
  String get restorePurchasesButton => 'Restaurar compras';

  @override
  String get payNothingWithheld =>
      'Todas las funciones siguen siendo gratis, con o sin anuncios.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Próximamente';

  @override
  String get plusBody =>
      'Una conexión bancaria que trae tus transacciones para que las confirmes. Aún no está lista, así que no hay nada que comprar.';

  @override
  String get privacyOptionsTitle => 'Opciones de privacidad';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get privacyOptionsSubtitle =>
      'Cambia tu elección sobre los anuncios personalizados';

  @override
  String get dueEntryReminderTitle => 'Un registro venció';

  @override
  String dueEntryReminderOne(String title) {
    return '$title vencía hoy y sigue pendiente.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'Una entrada recurrente vencía hoy y sigue pendiente.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas recurrentes vencieron hoy.',
      one: '1 entrada recurrente venció hoy.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Nada registrado hoy';

  @override
  String get emptyDayReminderBody =>
      'Añade lo que gastaste mientras aún lo recuerdas.';

  @override
  String get reminderLockedTitle => 'Algo está esperando';

  @override
  String get nudgeSettingsTitle => 'Recordarme en un día vacío';

  @override
  String get nudgeSettingsSubtitle =>
      'Un recordatorio por la noche, solo en un día sin ningún registro.';

  @override
  String get nudgeOfferTitle => '¿Un recordatorio los días que olvidas?';

  @override
  String get nudgeOfferBody =>
      'Un recordatorio a la hora que elijas, solo en un día sin registro. Puedes desactivarlo cuando quieras.';

  @override
  String get nudgeOfferYes => 'Sí, recuérdamelo';

  @override
  String get nudgeOfferNo => 'No, gracias';

  @override
  String get nudgeStoppedNotice =>
      'Los recordatorios se detuvieron tras tres sin respuesta. Actívalos cuando quieras.';

  @override
  String get nudgePermissionDenied =>
      'Activa las notificaciones en la configuración del sistema.';

  @override
  String get updateDownloadedMessage => 'Se ha descargado una actualización.';

  @override
  String get updateRestartButton => 'Reiniciar';
}
