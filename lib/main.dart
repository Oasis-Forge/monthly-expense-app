import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n/app_localizations.dart';
import 'l10n/languages.dart';
import 'models/transaction.dart';
import 'providers/ads_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/app_lock.dart';
import 'screens/first_run_gate.dart';
import 'screens/note_form_screen.dart';
import 'screens/notes_screen.dart';
import 'services/ad_service.dart';
import 'services/ads_config.dart';
import 'services/attachment_service.dart';
import 'services/authenticator.dart';
import 'services/backup_service.dart';
import 'services/home_widget_service.dart';
import 'services/home_widget_updater.dart';
import 'services/purchase_service.dart';
import 'services/reminder_service.dart';

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
  /// [backup], [authenticator], [reminders], [homeWidget], [ads], and
  /// [purchases] default to the device implementations; tests pass their own.
  const MonthlyExpenseApp({
    super.key,
    required this.settings,
    this.backup,
    this.authenticator,
    this.reminders,
    this.homeWidget,
    this.ads,
    this.purchases,
  });

  final SettingsProvider settings;
  final BackupService? backup;
  final Authenticator? authenticator;
  final ReminderService? reminders;
  final HomeWidgetService? homeWidget;
  final AdService? ads;
  final PurchaseService? purchases;

  /// So a tapped reminder notification can open its note (NOTE-6, LOCK-2),
  /// from outside the widget tree that the notification callback runs in.
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final reminderService = reminders ?? DeviceReminderService();
    final attachmentService = AttachmentService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(
                  startDay: settings.startDay,
                  reminders: reminderService,
                  attachments: attachmentService,
                )
                // ACC-6: open on the account Home was last left showing.
                ..selectAccountFilter(settings.accountFilterId)
                ..load(
                  appLockOn: settings.appLock,
                  locale: effectiveAppLocale(settings.locale),
                ),
        ),
        Provider<BackupService>(create: (_) => backup ?? BackupService()),
        Provider<Authenticator>(
          create: (_) => authenticator ?? DeviceAuthenticator(),
        ),
        Provider<ReminderService>(create: (_) => reminderService),
        Provider<AttachmentService>.value(value: attachmentService),
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
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) => MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settings.locale,
            localeListResolutionCallback: (locales, _) =>
                resolveAppLocale(locales),
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C5CE7),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C5CE7),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            builder: (context, child) => AppLock(
              child: _NoteReminderTaps(child: _WidgetTaps(child: child!)),
            ),
            home: const FirstRunGate(),
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
    // Whatever was open before the tap is not what was asked for.
    navigator.popUntil((route) => route.isFirst);
    // The numbers on the widget are the current period's, so Home shows that
    // one however it was left (WID-2, WID-3).
    navigator.context.read<TransactionProvider>().showCurrentPeriod();
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

class _NoteReminderTapsState extends State<_NoteReminderTaps> {
  @override
  void initState() {
    super.initState();
    tappedNoteId.addListener(_open);
    // A tap that launched the app from cold may already be pending.
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    tappedNoteId.removeListener(_open);
    super.dispose();
  }

  void _open() {
    final id = tappedNoteId.value;
    if (id == null) return;
    tappedNoteId.value = null;
    MonthlyExpenseApp.navigatorKey.currentState?.push(
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

  @override
  Widget build(BuildContext context) => widget.child;
}
