import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n/app_localizations.dart';
import 'l10n/languages.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/app_lock.dart';
import 'screens/home_screen.dart';
import 'screens/note_form_screen.dart';
import 'screens/notes_screen.dart';
import 'services/authenticator.dart';
import 'services/backup_service.dart';
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
  /// [backup], [authenticator], and [reminders] default to the device
  /// implementations; tests pass their own.
  const MonthlyExpenseApp({
    super.key,
    required this.settings,
    this.backup,
    this.authenticator,
    this.reminders,
  });

  final SettingsProvider settings;
  final BackupService? backup;
  final Authenticator? authenticator;
  final ReminderService? reminders;

  /// So a tapped reminder notification can open its note (NOTE-6, LOCK-2),
  /// from outside the widget tree that the notification callback runs in.
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final reminderService = reminders ?? DeviceReminderService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(
                startDay: settings.startDay,
                reminders: reminderService,
              )..load(
                appLockOn: settings.appLock,
                locale:
                    settings.locale ??
                    resolveAppLocale(
                      WidgetsBinding.instance.platformDispatcher.locales,
                    ),
              ),
        ),
        Provider<BackupService>(create: (_) => backup ?? BackupService()),
        Provider<Authenticator>(
          create: (_) => authenticator ?? DeviceAuthenticator(),
        ),
        Provider<ReminderService>(create: (_) => reminderService),
      ],
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
          builder: (context, child) =>
              AppLock(child: _NoteReminderTaps(child: child!)),
          home: const HomeScreen(),
        ),
      ),
    );
  }
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
