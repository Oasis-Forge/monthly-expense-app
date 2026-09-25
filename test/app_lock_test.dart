import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
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
  final cover = find.byKey(const ValueKey('appLockObscureCover'));

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
      // The engine itself does not draw frames while genuinely backgrounded
      // (SchedulerBinding disables frame scheduling on hidden/paused): force
      // one so the test can see the state the next real frame will show.
      tester.binding.scheduleForcedFrame();
      await tester.pump();

      // Not actually locked yet — under the timeout — so no prompt, just
      // nothing readable while backgrounded.
      expect(locked, findsNothing);
      expect(cover, findsOneWidget);

      now = now.add(const Duration(seconds: 30));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(locked, findsNothing);
      expect(cover, findsNothing);
      expect(content.hitTestable(), findsOneWidget);
    },
  );

  testWidgets(
    'hidden alone covers the app, and resuming within the timeout uncovers '
    'it (LOCK-2)',
    (tester) async {
      await showApp(tester, appLock: true);
      expect(content.hitTestable(), findsOneWidget);
      expect(cover, findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      // See the comment in the previous test: force the frame the engine
      // would otherwise withhold while backgrounded.
      tester.binding.scheduleForcedFrame();
      await tester.pump();

      // Not actually locked yet — under the timeout — but hidden is real
      // backgrounding, so the cover goes up.
      expect(locked, findsNothing);
      expect(cover, findsOneWidget);

      now = now.add(const Duration(seconds: 30));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(locked, findsNothing);
      expect(content.hitTestable(), findsOneWidget);
    },
  );

  testWidgets('a window merely losing focus (inactive) does not drop a focused '
      "field's focus or blank the app: it is not real backgrounding "
      '(LOCK-2, review-ads-1)', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    settings = await testSettings({'app_lock': true});
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
          home: Scaffold(body: TextField(focusNode: focusNode)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Focused once already unlocked: an autofocus racing the initial lock
    // screen is a separate concern from this test.
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    // A dialog, a permission prompt, the notification shade or a
    // split-screen neighbour taking focus: the window loses focus but the
    // app is still visible.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
    expect(find.byType(TextField).hitTestable(), findsOneWidget);

    now = now.add(const Duration(seconds: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(locked, findsNothing);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets(
    'desktop: a window merely losing focus (inactive) does not blank the '
    'whole app (LOCK-2, review-ads-2)',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      settings = await testSettings({'app_lock': true});
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            Provider<Authenticator>.value(value: authenticator),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) =>
                AppLock(clock: () => now, child: child!),
            home: Scaffold(body: TextField(focusNode: focusNode)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(find.byType(TextField).hitTestable(), findsOneWidget);
      expect(focusNode.hasFocus, isTrue);

      now = now.add(const Duration(seconds: 5));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(locked, findsNothing);
      expect(focusNode.hasFocus, isTrue);
      debugDefaultTargetPlatformOverride = null;
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
