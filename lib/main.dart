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
import 'services/authenticator.dart';
import 'services/backup_service.dart';

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
  /// [backup] and [authenticator] default to the device implementations;
  /// tests pass their own.
  const MonthlyExpenseApp({
    super.key,
    required this.settings,
    this.backup,
    this.authenticator,
  });

  final SettingsProvider settings;
  final BackupService? backup;
  final Authenticator? authenticator;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(startDay: settings.startDay)..load(),
        ),
        Provider<BackupService>(create: (_) => backup ?? BackupService()),
        Provider<Authenticator>(
          create: (_) => authenticator ?? DeviceAuthenticator(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
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
          builder: (context, child) => AppLock(child: child!),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
