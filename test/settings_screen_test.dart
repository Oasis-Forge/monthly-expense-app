import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/accounts_screen.dart';
import 'package:monthly_expense_app/screens/backup_screen.dart';
import 'package:monthly_expense_app/screens/categories_screen.dart';
import 'package:monthly_expense_app/screens/remove_ads_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/trash_screen.dart';
import 'package:monthly_expense_app/services/authenticator.dart';
import 'package:monthly_expense_app/services/links.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';

import 'helpers.dart';

void main() {
  late SettingsProvider settings;
  late TransactionProvider provider;

  setUp(() async {
    settings = await testSettings();
    provider = TransactionProvider(
      db: FakeDB(),
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
  });

  Future<void> showSettings(
    WidgetTester tester, {
    Authenticator? authenticator,
    FakeAdService? ads,
    FakePurchases? purchases,
  }) async {
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const SettingsScreen(),
        authenticator: authenticator,
        ads: ads,
        purchases: purchases,
      ),
    );
    await tester.pump();
  }

  Future<void> chooseEuro(WidgetTester tester) async {
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'euro');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();
  }

  testWidgets('changing the currency asks first, then applies (CUR-3)', (
    tester,
  ) async {
    await showSettings(tester);
    expect(find.text('USD · US Dollar'), findsOneWidget);

    await chooseEuro(tester);
    expect(find.text('Change currency to EUR?'), findsOneWidget);
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    expect(settings.currencyCode, 'EUR');
    expect(find.text('EUR · Euro'), findsOneWidget);
  });

  testWidgets('changing the currency reaches the already-scheduled reminders '
      '(CUR-2, CUR-3, rules-23-26-34#9)', (tester) async {
    final reminders = FakeReminderService();
    provider = TransactionProvider(
      db: FakeDB(),
      clock: () => DateTime(2026, 9, 15),
      reminders: reminders,
    );
    await provider.load();

    await showSettings(tester);
    await chooseEuro(tester);
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    expect(reminders.lastCurrency?.currencySymbol, '€');
  });

  testWidgets('cancelling keeps the current currency', (tester) async {
    await showSettings(tester);

    await chooseEuro(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(settings.currencyCode, 'USD');
  });

  testWidgets('a device currency missing from the list is still offered', (
    tester,
  ) async {
    settings = await testSettings({'currency_code': 'XOF'});
    await showSettings(tester);
    expect(find.text('XOF'), findsOneWidget);

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    expect(find.widgetWithIcon(ListTile, Icons.check), findsOneWidget);
  });

  testWidgets('the theme can be switched to dark', (tester) async {
    await showSettings(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.dark);
  });

  testWidgets('the month start day moves the selected period (PER-2)', (
    tester,
  ) async {
    await showSettings(tester);

    await tester.tap(find.text('First day of the month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    expect(settings.startDay, 2);
    expect(provider.period.start, DateTime(2026, 9, 2));
  });

  testWidgets('the first day of the week follows the locale until chosen '
      '(PER-4)', (tester) async {
    await showSettings(tester);
    expect(find.text('Default (Sunday)'), findsOneWidget);

    await tester.tap(find.text('First day of the week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monday').last);
    await tester.pumpAndSettle();

    expect(settings.weekStartDay, 1);
  });

  testWidgets("the default week start follows the device's region, not just "
      'its language (PER-4, rules-1-5#5)', (tester) async {
    // A phone set to English (UK) defaults to Monday, though the app's
    // own language-only locale ('en') defaults to Sunday.
    tester.platformDispatcher.localesTestValue = [const Locale('en', 'GB')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await showSettings(tester);

    expect(find.text('Default (Monday)'), findsOneWidget);
  });

  testWidgets('carrying the balance forward can be turned off (BAL-3)', (
    tester,
  ) async {
    await showSettings(tester);

    await tester.tap(find.text('Carry balance forward'));
    await tester.pumpAndSettle();

    expect(settings.showCarriedForward, isFalse);
  });

  testWidgets('app lock turns on only after authenticating (LOCK-1)', (
    tester,
  ) async {
    final authenticator = FakeAuthenticator(result: AuthResult.failed);
    await showSettings(tester, authenticator: authenticator);

    await tester.tap(find.text('App lock'));
    await tester.pumpAndSettle();
    expect(settings.appLock, isFalse);
    expect(
      find.text("Couldn't confirm it's you. App lock wasn't changed."),
      findsOneWidget,
    );

    authenticator.result = AuthResult.success;
    await tester.tap(find.text('App lock'));
    await tester.pumpAndSettle();
    expect(settings.appLock, isTrue);
    expect(authenticator.requests, 2);
  });

  testWidgets('turning app lock on re-words the reminders already scheduled '
      'for notes (NOTE-6, LOCK-2)', (tester) async {
    // Fixed, and before the note's reminder: otherwise, as real
    // wall-clock time moves past this fixture's date, the reminder looks
    // like one that already passed (NOTE-6) rather than the future one
    // this test means to keep scheduled.
    final reminders = FakeReminderService(now: () => DateTime(2026, 9, 15));
    provider = TransactionProvider(
      db: FakeDB(
        notes: [
          testNote(
            'a',
            'Remind me',
            dueDate: DateTime(2026, 9, 20),
            reminderAt: DateTime(2026, 9, 20, 9),
          ),
        ],
      ),
      clock: () => DateTime(2026, 9, 15),
      reminders: reminders,
    );
    await provider.load();
    expect(reminders.scheduled['a'], false);

    await showSettings(tester, authenticator: FakeAuthenticator());
    await tester.tap(find.text('App lock'));
    await tester.pumpAndSettle();

    expect(settings.appLock, isTrue);
    expect(reminders.scheduled['a'], true);
  });

  testWidgets('without a screen lock, app lock can only be turned off '
      '(LOCK-3)', (tester) async {
    final authenticator = FakeAuthenticator(available: false);
    await showSettings(tester, authenticator: authenticator);

    expect(
      find.text('Set up a screen lock on this device to use app lock'),
      findsOneWidget,
    );
    SwitchListTile appLockTile() => tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'App lock'),
    );
    expect(appLockTile().onChanged, isNull);

    await settings.setAppLock(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('App lock'));
    await tester.pumpAndSettle();

    expect(settings.appLock, isFalse);
  });

  testWidgets('showing widget amounts is only offered under app lock '
      '(WID-4)', (tester) async {
    await showSettings(tester, authenticator: FakeAuthenticator());
    SwitchListTile widgetTile() => tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Show amounts on the widget'),
    );

    // Nothing hides them while app lock is off, so there's nothing to say.
    expect(widgetTile().onChanged, isNull);
    expect(settings.showWidgetAmounts, isFalse);

    await settings.setAppLock(true);
    await tester.pumpAndSettle();
    expect(widgetTile().onChanged, isNotNull);

    await tester.tap(find.text('Show amounts on the widget'));
    await tester.pumpAndSettle();
    expect(settings.showWidgetAmounts, isTrue);
  });

  testWidgets('Accounts, Categories, Backup, and Trash open their screens', (
    tester,
  ) async {
    await showSettings(tester);

    for (final (label, screen) in [
      ('Accounts', AccountsScreen),
      ('Categories', CategoriesScreen),
      ('Backup & restore', BackupScreen),
      ('Trash', TrashScreen),
    ]) {
      // The list is longer than the screen, and the last rows aren't built
      // until they're scrolled to.
      await tester.scrollUntilVisible(find.text(label), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget, reason: label);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the privacy policy opens in the browser, not in the app', (
    tester,
  ) async {
    final opened = <Uri>[];
    final before = openInBrowser;
    openInBrowser = (url) async {
      opened.add(url);
      return true;
    };
    addTearDown(() => openInBrowser = before);
    await showSettings(tester);

    await tester.scrollUntilVisible(find.text('Privacy policy'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(opened, [privacyPolicyUrl]);
    expect(privacyPolicyUrl.scheme, 'https');
  });

  testWidgets('choosing a language applies at once (LANG-1)', (tester) async {
    await showSettings(tester);

    expect(find.text('System default'), findsOneWidget);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(settings.languageCode, 'de');
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('Sprache'), findsOneWidget);
  });

  group('the ads rows (PAY-7, ADS-5)', () {
    /// Both rows are at the very bottom of a list longer than the screen.
    Future<void> scrollTo(WidgetTester tester, String label) async {
      await tester.scrollUntilVisible(find.text(label), 200);
      await tester.pumpAndSettle();
    }

    testWidgets('Remove ads is one quiet row, and it opens the screen', (
      tester,
    ) async {
      await showSettings(tester);

      await scrollTo(tester, 'Remove ads');
      // PAY-7: one row, with no price shouted from the list.
      expect(find.text('Remove ads'), findsOneWidget);
      await tester.tap(find.text('Remove ads'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveAdsScreen), findsOneWidget);
    });

    testWidgets('once bought, the row says so (PAY-1)', (tester) async {
      await showSettings(
        tester,
        purchases: FakePurchases(stage: PurchaseStage.owned),
      );

      await scrollTo(tester, 'Remove ads');

      expect(find.text('Ads are off. Thank you.'), findsOneWidget);
    });

    testWidgets('no Privacy options row unless the law asks (ADS-5)', (
      tester,
    ) async {
      await showSettings(tester, ads: FakeAdService(canStart: true));

      await scrollTo(tester, 'Remove ads');

      expect(find.text('Privacy options'), findsNothing);
    });

    testWidgets('where it is asked for, it reopens the consent form (ADS-5)', (
      tester,
    ) async {
      final ads = FakeAdService(canStart: true, privacyOptionsRequired: true);

      await showSettings(tester, ads: ads);
      await scrollTo(tester, 'Privacy options');
      await tester.tap(find.text('Privacy options'));
      await tester.pumpAndSettle();

      expect(ads.privacyOptionsShown, 1);
    });
  });
}
