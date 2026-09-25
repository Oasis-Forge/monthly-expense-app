import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/screens/app_lock.dart';
import 'package:monthly_expense_app/services/authenticator.dart';

import 'helpers.dart';

void main() {
  late SettingsProvider settings;
  late FakeAuthenticator authenticator;
  late DateTime now;

  final locked = find.text('Monthly Expenses is locked');
  final content = find.text('Balance \$100');

  setUp(() {
    authenticator = FakeAuthenticator();
    now = DateTime(2026, 9, 15, 10);
  });

  Future<void> showApp(WidgetTester tester, {required bool appLock}) async {
    settings = await testSettings({'app_lock': appLock});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          Provider<Authenticator>.value(value: authenticator),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppLock(clock: () => now, child: child!),
          home: const Scaffold(body: Text('Balance \$100')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Sends the app to the background for [away], then back.
  Future<void> leaveFor(WidgetTester tester, Duration away) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(away);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }

  testWidgets('with app lock off, the app never asks (LOCK-1)', (tester) async {
    await showApp(tester, appLock: false);
    await leaveFor(tester, const Duration(hours: 1));

    expect(locked, findsNothing);
    expect(content.hitTestable(), findsOneWidget);
    expect(authenticator.requests, 0);
  });

  testWidgets('the app locks at launch and stays locked until unlocked '
      '(LOCK-2)', (tester) async {
    authenticator.result = AuthResult.failed;
    await showApp(tester, appLock: true);

    expect(locked, findsOneWidget);
    expect(content.hitTestable(), findsNothing);
    expect(authenticator.requests, 1);

    authenticator.result = AuthResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(locked, findsNothing);
    expect(content.hitTestable(), findsOneWidget);
    expect(authenticator.requests, 2);
  });

  testWidgets('it locks again after a minute in the background (LOCK-2)', (
    tester,
  ) async {
    await showApp(tester, appLock: true);
    expect(locked, findsNothing);

    await leaveFor(tester, const Duration(seconds: 30));
    expect(authenticator.requests, 1);

    authenticator.result = AuthResult.failed;
    await leaveFor(tester, const Duration(minutes: 2));
    expect(locked, findsOneWidget);
    expect(authenticator.requests, 2);
  });

  testWidgets(
    'backgrounding the app hides its content immediately in Dart itself, '
    "before the OS's own screenshot protection would ever draw a fresh "
    'frame (LOCK-2)',
    (tester) async {
      await showApp(tester, appLock: true);
      expect(content.hitTestable(), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();

      // Not actually locked yet — under the timeout — so no prompt, just
      // nothing readable while backgrounded.
      expect(locked, findsNothing);
      expect(content.hitTestable(), findsNothing);

      now = now.add(const Duration(seconds: 30));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(locked, findsNothing);
      expect(content.hitTestable(), findsOneWidget);
    },
  );

  testWidgets('without a screen lock, app lock turns itself off (LOCK-3)', (
    tester,
  ) async {
    authenticator.available = false;
    await showApp(tester, appLock: true);

    expect(locked, findsNothing);
    expect(settings.appLock, isFalse);
  });

  group('what the lock tells the rest of the app (ADS-9)', () {
    tearDown(() => appIsLocked.value = false);

    testWidgets('it is on from the first frame of a locked launch', (
      tester,
    ) async {
      // The screens underneath are built while the lock is up, so they have
      // to be able to see it straight away, before any ad is asked for.
      authenticator.result = AuthResult.failed;
      await showApp(tester, appLock: true);

      expect(locked, findsOneWidget);
      expect(appIsLocked.value, isTrue);
    });

    testWidgets('it goes off once the app is unlocked', (tester) async {
      authenticator.result = AuthResult.failed;
      await showApp(tester, appLock: true);
      expect(appIsLocked.value, isTrue);

      authenticator.result = AuthResult.success;
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(locked, findsNothing);
      expect(appIsLocked.value, isFalse);
    });

    testWidgets('it comes back when the app locks itself again (LOCK-2)', (
      tester,
    ) async {
      await showApp(tester, appLock: true);
      expect(appIsLocked.value, isFalse);
      authenticator.result = AuthResult.failed;

      await leaveFor(tester, const Duration(minutes: 2));

      expect(locked, findsOneWidget);
      expect(appIsLocked.value, isTrue);
    });

    testWidgets('with app lock off it stays off', (tester) async {
      await showApp(tester, appLock: false);

      await leaveFor(tester, const Duration(hours: 1));

      expect(appIsLocked.value, isFalse);
    });
  });

  group('telling the OS not to keep a readable snapshot of the app while App '
      'Lock is on (LOCK-2)', () {
    final channel = const MethodChannel(
      'com.oasisforge.monthlyexpenses/security',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    testWidgets('a locked launch turns it on', (tester) async {
      await showApp(tester, appLock: true);

      expect(calls.single.method, 'setSecure');
      expect(calls.single.arguments, isTrue);
    });

    testWidgets('app lock off never turns it on', (tester) async {
      await showApp(tester, appLock: false);

      expect(calls.single.method, 'setSecure');
      expect(calls.single.arguments, isFalse);
    });

    testWidgets(
      'app lock turning itself off (LOCK-3) turns this off too, without '
      'waiting for the app to background and come back',
      (tester) async {
        authenticator.available = false;
        await showApp(tester, appLock: true);

        expect(calls.map((call) => call.arguments as bool), [true, false]);
      },
    );
  });
}
