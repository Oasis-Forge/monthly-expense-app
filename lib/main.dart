import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db/db_helper.dart';
import 'l10n/app_localizations.dart';
import 'l10n/languages.dart';
import 'models/reminders.dart';
import 'models/transaction.dart';
import 'providers/ads_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/app_lock.dart';
import 'screens/first_run_gate.dart';
import 'screens/form_fields.dart' show activeUnsavedFormGuard;
import 'screens/note_form_screen.dart';
import 'screens/theme.dart';
import 'screens/notes_screen.dart';
import 'screens/recurring_screen.dart';
import 'screens/transfer_screen.dart';
import 'services/ad_service.dart';
import 'services/ads_config.dart';
import 'services/attachment_service.dart';
import 'services/authenticator.dart';
import 'services/backup_service.dart';
import 'services/home_widget_service.dart';
import 'services/home_widget_updater.dart';
import 'services/purchase_service.dart';
import 'services/reminder_service.dart';
import 'services/review_service.dart';
import 'services/update_service.dart';
import 'services/shortcut_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    // sqflite has no Windows or Linux plugin, so use its FFI implementation.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final settings = SettingsProvider(
    await SharedPreferences.getInstance(),
    deviceLocale: WidgetsBinding.instance.platformDispatcher.locale.toString(),
  );
  runApp(MonthlyExpenseApp(settings: settings));
}

class MonthlyExpenseApp extends StatelessWidget {
  /// [backup], [authenticator], [reminders], [homeWidget], [ads],
  /// [purchases], [reviews], [updates] and [db] default to the device
  /// implementations; tests
  /// pass their own.
  const MonthlyExpenseApp({
    super.key,
    required this.settings,
    this.backup,
    this.authenticator,
    this.reminders,
    this.homeWidget,
    this.ads,
    this.purchases,
    this.reviews,
    this.updates,
    this.shortcuts,
    this.db,
  });

  final SettingsProvider settings;
  final BackupService? backup;
  final Authenticator? authenticator;
  final ReminderService? reminders;
  final HomeWidgetService? homeWidget;
  final AdService? ads;
  final PurchaseService? purchases;
  final ReviewService? reviews;
  final UpdateService? updates;
  final ShortcutService? shortcuts;

  /// Overrides where [TransactionProvider] stores its data. Null means the
  /// app's own on-disk database; tests pass an isolated [DBHelper] so a full
  /// widget test never touches the real, shared production file.
  final DBHelper? db;

  /// So a tapped reminder notification can open its note (NOTE-6, LOCK-2),
  /// from outside the widget tree that the notification callback runs in.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Counts every screen opened towards the next full-screen ad
  /// (ADS-12). One instance, so rebuilding the app does not replace it.
  static final adActivity = AdActivityObserver();

  @override
  Widget build(BuildContext context) {
    final reminderService = SafeReminderService(
      reminders ?? DeviceReminderService(),
    );
    final attachmentService = AttachmentService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(
                  db: db,
                  startDay: settings.startDay,
                  reminders: reminderService,
                  attachments: attachmentService,
                )
                // ACC-6: open on the account Home was last left showing.
                ..selectAccountFilter(settings.accountFilterId)
                ..load(
                  appLockOn: settings.appLock,
                  locale: effectiveAppLocale(settings.locale),
                  nudge: settings.nudgeSettings,
                  currency: settings.currencyFormat(
                    effectiveAppLocale(settings.locale).toLanguageTag(),
                  ),
                ),
        ),
        Provider<BackupService>(create: (_) => backup ?? BackupService()),
        Provider<Authenticator>(
          create: (_) => authenticator ?? DeviceAuthenticator(),
        ),
        Provider<ReminderService>(create: (_) => reminderService),
        Provider<AttachmentService>.value(value: attachmentService),
        // The store's rating sheet, and nothing at all on desktop (RATE-5).
        Provider<ReviewService>(create: (_) => reviews ?? deviceOrNoReviews()),
        Provider<UpdateService>(create: (_) => updates ?? deviceOrNoUpdates()),
        // The slots and the one purchase, in one place (ADS-8). `start`
        // waits for setup and the walkthrough by itself (ADS-4).
        ChangeNotifierProvider(
          create: (_) => AdsProvider(
            settings,
            // Windows and Linux have neither SDK, and asking them for
            // anything would throw.
            ads: ads ?? (AdsConfig.supportsAds ? DeviceAdService() : null),
            purchases:
                purchases ??
                (AdsConfig.supportsAds ? DevicePurchaseService() : null),
            locked: appIsLocked,
          )..start(),
        ),
      ],
      child: _HomeWidgetSync(
        service: homeWidget,
        child: DynamicColorBuilder(
          builder: (lightFromPhone, darkFromPhone) => Consumer<SettingsProvider>(
            builder: (context, settings, _) => MaterialApp(
              navigatorKey: navigatorKey,
              navigatorObservers: [adActivity],
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: settings.locale,
              localeListResolutionCallback: (locales, _) =>
                  resolveAppLocale(locales),
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              // The wallpaper palette where the phone offers one, the app's own
              // colour where it does not (THEME-2).
              theme: appTheme(
                fromPhone: lightFromPhone,
                brightness: Brightness.light,
              ),
              darkTheme: appTheme(
                fromPhone: darkFromPhone,
                brightness: Brightness.dark,
                black: settings.blackBackground,
              ),
              builder: (context, child) => AppLock(
                child: _NoteReminderTaps(
                  child: _WidgetTaps(
                    child: _ShortcutTaps(service: shortcuts, child: child!),
                  ),
                ),
              ),
              home: const FirstRunGate(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Owns the [HomeWidgetUpdater], where both providers are in reach, and
/// starts listening for widget taps (WID-3, WID-5).
class _HomeWidgetSync extends StatefulWidget {
  const _HomeWidgetSync({required this.service, required this.child});

  /// The device implementation when null; tests pass their own.
  final HomeWidgetService? service;
  final Widget child;

  @override
  State<_HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends State<_HomeWidgetSync> {
  // Built once here rather than in the parent's build, so a rebuild can't
  // leave a second one talking to the same widget.
  late final HomeWidgetService _service =
      widget.service ?? DeviceHomeWidgetService();
  HomeWidgetUpdater? _updater;

  @override
  void initState() {
    super.initState();
    unawaited(_service.listenForTaps());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updater ??= HomeWidgetUpdater(
      service: _service,
      transactions: context.read<TransactionProvider>(),
      settings: context.read<SettingsProvider>(),
    )..start();
  }

  @override
  void dispose() {
    _updater?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Acts on a tap from the home-screen widget, through the lock (WID-3,
/// LOCK-2), the same way a tapped reminder opens its note.

/// The three things a long press on the app's icon offers (NAV-8), and what
/// happens when one is chosen. The labels are the drawer's own and follow the
/// app's language, so they are written again whenever that changes. The push
/// happens straight away, exactly as a tapped reminder's does, so a locked
/// app opens onto the form once it is unlocked and not before (LOCK-1).
class _ShortcutTaps extends StatefulWidget {
  const _ShortcutTaps({required this.service, required this.child});

  /// The device implementation when null; tests pass their own.
  final ShortcutService? service;
  final Widget child;

  static const addExpense = 'add_expense';
  static const addIncome = 'add_income';
  static const transfer = 'transfer';

  @override
  State<_ShortcutTaps> createState() => _ShortcutTapsState();
}

class _ShortcutTapsState extends State<_ShortcutTaps> {
  // Built once here rather than in the parent's build, so a rebuild cannot
  // leave a second menu talking to the same icon.
  late final ShortcutService _service = widget.service ?? deviceOrNoShortcuts();

  /// The language the menu is currently written in, so it is only written
  /// again when that changes (LANG-1).
  String? _written;

  @override
  void initState() {
    super.initState();
    _service.onSelected(_open);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_service.supported) return;
    final l10n = AppLocalizations.of(context);
    if (_written == l10n.localeName) return;
    _written = l10n.localeName;
    unawaited(
      _service.setItems([
        (type: _ShortcutTaps.addExpense, label: l10n.drawerAddExpense),
        (type: _ShortcutTaps.addIncome, label: l10n.drawerAddIncome),
        (type: _ShortcutTaps.transfer, label: l10n.transferTitle),
      ]),
    );
  }

  void _open(String type) {
    final navigator = MonthlyExpenseApp.navigatorKey.currentState;
    if (navigator == null) return;
    final settings = navigator.context.read<SettingsProvider>();
    // Setup and the walkthrough come first (RUN-5): a shortcut chosen before
    // either is done would let an entry be recorded before the currency and
    // language are even chosen, and would open the form over that screen.
    if (!settings.setupDone || !settings.walkthroughSeen) return;
    final provider = navigator.context.read<TransactionProvider>();
    unawaited(_openWhenLoaded(navigator, provider, type));
  }

  /// The category and account the form opens with come from the loaded data
  /// (ADD-3), so a shortcut chosen before the load finishes -- the usual
  /// case for a process the OS had killed -- waits for it, rather than
  /// opening on defaults that stay empty forever (WID-3).
  Future<void> _openWhenLoaded(
    NavigatorState navigator,
    TransactionProvider provider,
    String type,
  ) async {
    await provider.whenLoaded;
    if (!navigator.mounted) return;
    // A refused downgrade open never read any data (x-downgrade-message):
    // opening the form here would land it over DatabaseTooNewScreen with
    // nothing to fill it and nowhere to save.
    if (provider.openRefused) return;
    // Whatever was open before is not what was asked for, but a form with
    // something typed into it asks the same ADD-9 question the back button
    // would, rather than being silently dropped (pr57#3).
    final guard = activeUnsavedFormGuard;
    if (guard != null && guard.hasUnsavedEdits()) {
      final discard = await guard.confirmDiscard();
      if (!discard || !navigator.mounted) return;
    }
    // Marked before the pop, so an Insights seam still waiting on its route
    // future treats this as a fresh navigation even when it lands back on
    // Home with nothing pushed over it (rules-22-25-31-35#6).
    navigator.context.read<AdsProvider>().noteExternalNavigation();
    navigator.popUntil((route) => route.isFirst);
    // A shortcut is a fresh start, so the form opens on the period the app
    // is for today rather than wherever Home was last left (DAY-9).
    provider.showCurrentPeriod();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => switch (type) {
          _ShortcutTaps.addIncome => const AddTransactionScreen(
            startAs: TransactionType.income,
          ),
          _ShortcutTaps.transfer => const TransferScreen(),
          _ => const AddTransactionScreen(startAs: TransactionType.expense),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _WidgetTaps extends StatefulWidget {
  const _WidgetTaps({required this.child});

  final Widget child;

  @override
  State<_WidgetTaps> createState() => _WidgetTapsState();
}

class _WidgetTapsState extends State<_WidgetTaps> {
  @override
  void initState() {
    super.initState();
    tappedWidgetAction.addListener(_open);
    // A tap that launched the app from cold may already be pending.
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    tappedWidgetAction.removeListener(_open);
    super.dispose();
  }

  void _open() {
    final action = tappedWidgetAction.value;
    if (action == null) return;
    tappedWidgetAction.value = null;
    final navigator = MonthlyExpenseApp.navigatorKey.currentState;
    if (navigator == null) return;
    final settings = navigator.context.read<SettingsProvider>();
    // Setup and the walkthrough come first (RUN-5): a widget tap before
    // either is done would let an entry be recorded before the currency and
    // language are even chosen, and would open the form over that screen.
    if (!settings.setupDone || !settings.walkthroughSeen) return;
    final provider = navigator.context.read<TransactionProvider>();
    unawaited(_openWhenLoaded(navigator, provider, action));
  }

  /// The category and account the form opens with come from the loaded data
  /// (ADD-3), so a widget tap that arrives before the load finishes -- the
  /// usual case for a process the OS had killed -- waits for it, rather than
  /// opening on defaults that stay empty forever (WID-3).
  Future<void> _openWhenLoaded(
    NavigatorState navigator,
    TransactionProvider provider,
    HomeWidgetAction action,
  ) async {
    await provider.whenLoaded;
    if (!navigator.mounted) return;
    // A refused downgrade open never read any data (x-downgrade-message):
    // opening the form here would land it over DatabaseTooNewScreen with
    // nothing to fill it and nowhere to save.
    if (provider.openRefused) return;
    // Whatever was open before the tap is not what was asked for, but a
    // form with something typed into it asks the same ADD-9 question the
    // back button would, rather than being silently dropped (pr57#3).
    final guard = activeUnsavedFormGuard;
    if (guard != null && guard.hasUnsavedEdits()) {
      final discard = await guard.confirmDiscard();
      if (!discard || !navigator.mounted) return;
    }
    // Marked before the pop, so an Insights seam still waiting on its route
    // future treats this as a fresh navigation even when it lands back on
    // Home with nothing pushed over it, as HomeWidgetAction.openHome does
    // (rules-22-25-31-35#6).
    navigator.context.read<AdsProvider>().noteExternalNavigation();
    navigator.popUntil((route) => route.isFirst);
    // The numbers on the widget are the current period's, so Home shows that
    // one however it was left (WID-2, WID-3).
    provider.showCurrentPeriod();
    if (action == HomeWidgetAction.openHome) return;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          startAs: action == HomeWidgetAction.addIncome
              ? TransactionType.income
              : TransactionType.expense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Opens the tapped reminder's note, through the lock (NOTE-6, LOCK-2): the
/// push happens right away, so it's already on screen once the app unlocks.
class _NoteReminderTaps extends StatefulWidget {
  const _NoteReminderTaps({required this.child});

  final Widget child;

  @override
  State<_NoteReminderTaps> createState() => _NoteReminderTapsState();
}

class _NoteReminderTapsState extends State<_NoteReminderTaps>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tappedNoteId.addListener(_open);
    tappedReminder.addListener(_openReminder);
    // A tap that launched the app from cold may already be pending.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _open();
      _openReminder();
      unawaited(_checkNotificationsThenIgnored());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tappedNoteId.removeListener(_open);
    tappedReminder.removeListener(_openReminder);
    super.dispose();
  }

  /// Back in the app on a later day, Home moves on to today (DAY-1) and any
  /// automatic occurrence due since then posts (RCR-4). Also rechecked here:
  /// the phone's notification permission (NUDGE-7), since it can be taken
  /// back in the phone's own settings while the app sits in the background,
  /// not only through this app.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(context.read<TransactionProvider>().returnToToday());
    unawaited(_refreshNotificationsBlocked());
  }

  /// Whether the phone is currently blocking notifications, so Settings can
  /// say so (NUDGE-7) and the ignored-nudge count can leave that stretch out
  /// of it (NUDGE-5). Only asked while the nudge is on: nothing to warn
  /// about otherwise.
  Future<void> _refreshNotificationsBlocked() async {
    final settings = context.read<SettingsProvider>();
    if (!settings.emptyDayNudge) {
      settings.setNotificationsBlocked(false);
      return;
    }
    final reminders = context.read<ReminderService>();
    final enabled = await reminders.areNotificationsEnabled();
    if (!mounted) return;
    context.read<SettingsProvider>().setNotificationsBlocked(!enabled);
  }

  void _open() {
    final id = tappedNoteId.value;
    if (id == null) return;
    tappedNoteId.value = null;
    unawaited(_openNote(id));
  }

  /// The tapped note comes from the loaded database (NOTE-6), so a tap that
  /// arrives before the load finishes -- the usual case for a cold start,
  /// including one that delivered a launch payload before the load had even
  /// opened the database -- waits for it, rather than reading an empty list
  /// and opening the notes screen in the note's place (pr59#8).
  Future<void> _openNote(String id) async {
    final navigator = MonthlyExpenseApp.navigatorKey.currentState;
    if (navigator == null) return;
    final provider = navigator.context.read<TransactionProvider>();
    await provider.whenLoaded;
    if (!navigator.mounted) return;
    // A refused downgrade open never read any notes (x-downgrade-message):
    // opening NotesScreen here would show an empty list over
    // DatabaseTooNewScreen instead of the update message.
    if (provider.openRefused) return;
    navigator.push(
      MaterialPageRoute(
        builder: (context) {
          final note = context.read<TransactionProvider>().noteById(id);
          return note == null
              ? const NotesScreen()
              : NoteFormScreen(editing: note);
        },
      ),
    );
  }

  /// Opens what the app's own reminder was about (NUDGE-2). A tap is an
  /// answer, so a nudge that had started counting against itself begins
  /// again (NUDGE-5).
  void _openReminder() {
    final kind = tappedReminder.value;
    if (kind == null) return;
    tappedReminder.value = null;
    unawaited(context.read<SettingsProvider>().answerNudge());
    // The empty day has nowhere of its own to go: opening the app is the
    // whole of it. What fell due has the upcoming list.
    if (kind != ReminderKind.dueEntry) return;
    MonthlyExpenseApp.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const RecurringScreen()),
    );
  }

  /// Checks the phone's notification permission before counting anything
  /// (NUDGE-7), so a phone that is currently blocking notifications never
  /// has this stretch counted as ignored (NUDGE-5).
  Future<void> _checkNotificationsThenIgnored() async {
    await _refreshNotificationsBlocked();
    await _countIgnoredNudges();
  }

  /// Counts the nudges that fired while the app was closed and went
  /// unanswered, and lets the nudge stop itself after three in a row
  /// (NUDGE-5). Stopping cancels what was still scheduled.
  Future<void> _countIgnoredNudges() async {
    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionProvider>();
    final reminders = context.read<ReminderService>();
    // Days with entries are the answer to a nudge; counted before they are
    // read, every day looks ignored and the nudge stops itself (NUDGE-5).
    await transactions.whenLoaded;
    // A refused downgrade open never read the transactions
    // (x-downgrade-message): daysUsed would be empty, so every scheduled
    // nudge since the last check would count as ignored and could reach the
    // NUDGE-5 give-up, which would persist after the user updates.
    if (transactions.openRefused) return;
    // A phone that is blocking notifications never had a chance to see one,
    // so nothing here counts as ignored while it does (NUDGE-5, NUDGE-7).
    // The day is still marked checked, so this stretch is never counted
    // once the block lifts either.
    if (settings.notificationsBlocked) {
      await settings.recordNudgeCheckedAt(DateTime.now());
      return;
    }
    final since = settings.nudgeCheckedAt;
    final wasOn = settings.emptyDayNudge;
    // A nudge the phone dropped at a restart was never shown, so it was
    // never ignored either (NUDGE-5, NUDGE-9).
    final dropped = wasOn && since != null
        ? await reminders.droppedEmptyDayNudges()
        : const <DateTime>[];
    final now = DateTime.now();
    await settings.recordNudgesIgnored(
      wasOn && since != null
          ? countIgnoredNudges(
              now: now,
              since: since,
              hour: settings.nudgeHour,
              minute: settings.nudgeMinute,
              daysWithEntries: transactions.daysUsed,
              ignoredSoFar: settings.nudgeIgnored,
              dropped: dropped,
            )
          : settings.nudgeIgnored,
      now,
    );
    if (wasOn && !settings.emptyDayNudge) {
      await transactions.rescheduleReminders(
        appLockOn: settings.appLock,
        locale: effectiveAppLocale(settings.locale),
        nudge: settings.nudgeSettings,
        currency: settings.currencyFormat(
          effectiveAppLocale(settings.locale).toLanguageTag(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
