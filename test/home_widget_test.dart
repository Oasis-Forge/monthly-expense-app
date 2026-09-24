import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/period.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/widget_summary.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/services/home_widget_payload.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';
import 'package:monthly_expense_app/services/home_widget_updater.dart';

import 'helpers.dart';

/// Keeps what it was handed instead of talking to the platform.
class FakeHomeWidgetService implements HomeWidgetService {
  final List<Map<String, Object?>> updates = [];
  var listening = false;

  Map<String, Object?> get last => updates.last;

  @override
  Future<void> update(Map<String, Object?> payload) async =>
      updates.add(payload);

  @override
  Future<void> listenForTaps() async => listening = true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15, 10);

  Future<AppLocalizations> l10nFor(String code) async {
    // buildHomeWidgetPayload names the period, which the updater prepares
    // for; on its own it needs the date symbols loaded first.
    await initializeDateFormatting(code);
    return AppLocalizations.delegate.load(Locale(code));
  }

  WidgetSummary entry({
    DateTime? from,
    Money income = const Money(200000),
    Money expense = const Money(30000),
    Money balance = const Money(170000),
    bool balanceIsNet = false,
    Money? budgetLeft,
  }) => WidgetSummary(
    from: from ?? DateTime(2026, 9, 15),
    period: Period.containing(DateTime(2026, 9, 15)),
    income: income,
    expense: expense,
    balance: balance,
    balanceIsNet: balanceIsNet,
    budgetLeft: budgetLeft,
  );

  Future<Map<String, Object?>> payload({
    List<WidgetSummary>? timeline,
    String code = 'en',
    bool hideAmounts = false,
  }) async {
    final l10n = await l10nFor(code);
    return buildHomeWidgetPayload(
      timeline: timeline ?? [entry()],
      l10n: l10n,
      currency: NumberFormat.simpleCurrency(
        locale: l10n.localeName,
        name: 'USD',
      ),
      hideAmounts: hideAmounts,
    );
  }

  List<Map<String, Object?>> entriesOf(Map<String, Object?> json) =>
      (json['entries']! as List).cast<Map<String, Object?>>();

  Map<String, Object?> labelsOf(Map<String, Object?> json) =>
      json['labels']! as Map<String, Object?>;

  group('the widget payload (WID-5, WID-6)', () {
    test('carries the formatted numbers and the app language', () async {
      final json = await payload();

      expect(json['version'], homeWidgetPayloadVersion);
      expect(json['rtl'], isFalse);
      expect(json['title'], 'Monthly Expenses');
      expect(labelsOf(json)['income'], 'Income');
      expect(labelsOf(json)['balance'], 'Balance');
      expect(labelsOf(json)['addExpense'], 'Add expense');

      final first = entriesOf(json).single;
      expect(first['period'], 'September 2026');
      expect(first['income'], r'$200');
      expect(first['expense'], r'$30');
      expect(first['balance'], r'$170');
      expect(first.containsKey('budgetLeft'), isFalse);
    });

    test('Arabic reads right to left and is translated', () async {
      final json = await payload(code: 'ar');

      expect(json['rtl'], isTrue);
      expect(labelsOf(json)['income'], 'الدخل');
      expect(labelsOf(json)['addExpense'], 'إضافة مصروف');
      expect(entriesOf(json).single['period'], contains('سبتمبر'));
    });

    test('every language builds a payload with all its labels', () async {
      for (final code in ['en', 'tr', 'ar', 'fr', 'es', 'de']) {
        final labels = labelsOf(await payload(code: code));
        for (final key in [
          'income',
          'expense',
          'balance',
          'budgetLeft',
          'addExpense',
          'addIncome',
          'hidden',
        ]) {
          expect(labels[key], isNotEmpty, reason: '$code has no $key');
        }
      }
    });

    test('the balance is labelled Net when carry-forward is off', () async {
      final json = await payload(timeline: [entry(balanceIsNet: true)]);
      expect(labelsOf(json)['balance'], 'This period');
    });

    test('a budget adds what is left, and says when it is over', () async {
      final under = await payload(
        timeline: [entry(budgetLeft: const Money(70000))],
      );
      expect(entriesOf(under).single['budgetLeft'], r'$70');
      expect(entriesOf(under).single['overBudget'], isFalse);

      final over = await payload(
        timeline: [entry(budgetLeft: const Money(-20000))],
      );
      expect(entriesOf(over).single['overBudget'], isTrue);
    });

    test('the days ahead travel as their own entries', () async {
      final json = await payload(
        timeline: [
          entry(),
          entry(from: DateTime(2026, 10), expense: const Money(0)),
        ],
      );

      final entries = entriesOf(json);
      expect(entries.length, 2);
      expect(entries[1]['from'], DateTime(2026, 10).millisecondsSinceEpoch);
    });

    test('hidden means no amounts are sent at all (WID-4)', () async {
      final json = await payload(hideAmounts: true);

      expect(json['hideAmounts'], isTrue);
      expect(entriesOf(json), isEmpty);
      // The labels still travel, so the widget can say why it is blank.
      expect(labelsOf(json)['hidden'], isNotEmpty);
      // And nothing anywhere in the payload looks like an amount.
      expect(json.toString(), isNot(contains(r'$')));
    });
  });

  group('the updater (WID-5)', () {
    late FakeHomeWidgetService service;
    late SettingsProvider settings;
    late TransactionProvider transactions;
    late HomeWidgetUpdater updater;

    Future<void> start({
      List<ExpenseTransaction> rows = const [],
      Map<String, Object> prefs = const {},
    }) async {
      SharedPreferences.setMockInitialValues(prefs);
      settings = SettingsProvider(
        await SharedPreferences.getInstance(),
        deviceLocale: 'en_US',
        clock: () => today,
      );
      transactions = TransactionProvider(
        db: FakeDB(transactions: rows),
        clock: () => today,
      );
      service = FakeHomeWidgetService();
      updater = HomeWidgetUpdater(
        service: service,
        transactions: transactions,
        settings: settings,
      )..start();
      await transactions.load();
      await pumpEventQueue();
    }

    tearDown(() => updater.dispose());

    test('pushes the numbers once the data is loaded', () async {
      await start(rows: [testTx('a', expense, 30, DateTime(2026, 9, 3))]);

      expect(service.updates, isNotEmpty);
      final entries = entriesOf(service.last);
      expect(entries.first['expense'], r'$30');
    });

    test('nothing is pushed before the first load', () async {
      SharedPreferences.setMockInitialValues({});
      final idle = FakeHomeWidgetService();
      final provider = TransactionProvider(db: FakeDB(), clock: () => today);
      HomeWidgetUpdater(
        service: idle,
        transactions: provider,
        settings: SettingsProvider(
          await SharedPreferences.getInstance(),
          deviceLocale: 'en_US',
          clock: () => today,
        ),
      ).start();
      await pumpEventQueue();

      expect(idle.updates, isEmpty);
    });

    test('a saved transaction reaches the widget', () async {
      await start();
      final before = service.updates.length;

      await transactions.addTransaction(
        testTx('new', income, 500, DateTime(2026, 9, 4)),
      );
      await pumpEventQueue();

      expect(service.updates.length, greaterThan(before));
      expect(entriesOf(service.last).first['income'], r'$500');
    });

    test('a settings change reaches it too', () async {
      await start();

      await settings.setCurrencyCode('EUR');
      await pumpEventQueue();

      expect(entriesOf(service.last).first['balance'], contains('€'));
    });

    test('one change makes one push, however many notifications', () async {
      await start();
      final before = service.updates.length;

      // Two changes in the same turn, as one save easily raises.
      transactions
        ..previousPeriod()
        ..nextPeriod();
      await pumpEventQueue();

      expect(service.updates.length, before + 1);
    });

    test('app lock hides the amounts, the setting brings them back', () async {
      await start(rows: [testTx('a', expense, 30, DateTime(2026, 9, 3))]);

      await settings.setAppLock(true);
      await pumpEventQueue();
      expect(service.last['hideAmounts'], isTrue);
      expect(entriesOf(service.last), isEmpty);

      await settings.setShowWidgetAmounts(true);
      await pumpEventQueue();
      expect(service.last['hideAmounts'], isFalse);
      expect(entriesOf(service.last).first['expense'], r'$30');
    });

    test('it stops pushing once disposed', () async {
      await start();
      updater.dispose();
      final after = service.updates.length;

      await transactions.addTransaction(
        testTx('new', income, 500, DateTime(2026, 9, 4)),
      );
      await pumpEventQueue();

      expect(service.updates.length, after);
    });
  });

  group('the platform edge', () {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final channel = DeviceHomeWidgetService.channel;
    late List<MethodCall> calls;

    void answer(Object? Function(MethodCall) handler) {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return handler(call);
      });
    }

    setUp(() {
      calls = [];
      tappedWidgetAction.value = null;
      answer((_) => null);
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      tappedWidgetAction.value = null;
    });

    test('the payload crosses as one JSON string', () async {
      await DeviceHomeWidgetService().update(await payload());

      expect(calls.single.method, 'update');
      final sent =
          jsonDecode(calls.single.arguments as String) as Map<String, Object?>;
      expect(sent['title'], 'Monthly Expenses');
      expect((sent['entries']! as List), hasLength(1));
    });

    test('a platform that has no widget is left alone (WID-1)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await DeviceHomeWidgetService().update(await payload());
      expect(calls, isEmpty);
    });

    test('a refused update is not worth failing the change over', () async {
      answer((_) => throw PlatformException(code: 'no_widget'));
      // Doesn't throw.
      await DeviceHomeWidgetService().update(await payload());
      expect(calls, hasLength(1));
    });

    test('the tap that launched the app is picked up', () async {
      answer((call) => call.method == 'launchAction' ? 'add_income' : null);

      await DeviceHomeWidgetService().listenForTaps();
      expect(tappedWidgetAction.value, HomeWidgetAction.addIncome);
    });

    test('a tap while running arrives on the channel', () async {
      final service = DeviceHomeWidgetService();
      await service.listenForTaps();
      expect(tappedWidgetAction.value, isNull);

      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('tapped', 'add_expense'),
        ),
        (_) {},
      );

      expect(tappedWidgetAction.value, HomeWidgetAction.addExpense);
    });
  });

  group('widget actions (WID-3)', () {
    test('each one is recognised by the name the platform sends', () {
      expect(
        HomeWidgetAction.parse('add_expense'),
        HomeWidgetAction.addExpense,
      );
      expect(HomeWidgetAction.parse('add_income'), HomeWidgetAction.addIncome);
      expect(HomeWidgetAction.parse('open_home'), HomeWidgetAction.openHome);
    });

    test('anything else is nothing to act on', () {
      expect(HomeWidgetAction.parse('delete_everything'), isNull);
      expect(HomeWidgetAction.parse(null), isNull);
    });
  });
}
