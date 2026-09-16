import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/services/attachment_service.dart';

import 'helpers.dart';

/// A one-pixel PNG, so the photo on the form has a real file to load.
final _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAE'
  'hQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  const expense = TransactionType.expense;
  final today = DateTime(2026, 9, 16);

  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;
  late Directory dir;
  late FakeAttachments attachments;

  final amountField = find.widgetWithText(TextFormField, 'Amount');

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('attachment_screen');
    final photo = File('${dir.path}/photo.jpg')..writeAsBytesSync(_pixel);
    attachments = FakeAttachments(filePath: photo.path);
    fake = FakeDB();
    provider = TransactionProvider(db: fake, attachments: attachments);
    await provider.load();
    settings = await testSettings();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> open(
    WidgetTester tester, {
    ExpenseTransaction? editing,
    ExpenseTransaction? template,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        AddTransactionScreen(editing: editing, template: template),
        attachments: attachments,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapInForm(WidgetTester tester, Finder finder) async {
    await revealInForm(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Taps without settling: while a recording runs, a tick a second means
  /// the tree never settles.
  Future<void> tapTicking(WidgetTester tester, Finder finder) async {
    await revealInForm(tester, finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> addPhoto(WidgetTester tester) async {
    await tapInForm(tester, find.widgetWithText(OutlinedButton, 'Add a photo'));
    // The sheet sits above the form, not inside its list.
    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();
  }

  Future<void> record(WidgetTester tester) => tapTicking(
    tester,
    find.widgetWithText(OutlinedButton, 'Record a voice note'),
  );

  Future<void> stopRecording(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pumpAndSettle();
  }

  Future<void> saveTransaction(WidgetTester tester) async {
    await revealInForm(tester, amountField);
    await tester.enterText(amountField, '12.50');
    await tapInForm(
      tester,
      find.widgetWithText(FilledButton, 'Add Transaction'),
    );
  }

  group('a photo on the form (ATT-1, ATT-2)', () {
    testWidgets('the camera and the photo library are both offered', (
      tester,
    ) async {
      await open(tester);

      await tapInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Add a photo'),
      );

      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose a photo'), findsOneWidget);
    });

    testWidgets('a photo is shown, then saved with the transaction', (
      tester,
    ) async {
      await open(tester);

      await addPhoto(tester);

      expect(attachments.picked, [PhotoSource.gallery]);
      expect(find.byType(Image), findsOneWidget);
      expect(attachments.stored.keys, ['file1.jpg']);

      await saveTransaction(tester);

      expect(provider.transactions.single.photoFile, 'file1.jpg');
    });

    testWidgets('backing out of the picker leaves the form alone', (
      tester,
    ) async {
      attachments.hasPhoto = false;
      await open(tester);

      await addPhoto(tester);

      expect(
        find.widgetWithText(OutlinedButton, 'Add a photo'),
        findsOneWidget,
      );
      expect(attachments.stored, isEmpty);
    });

    testWidgets('taking it off again deletes the file it took (ATT-5)', (
      tester,
    ) async {
      await open(tester);
      await addPhoto(tester);

      await tapInForm(tester, find.byTooltip('Remove photo'));

      expect(attachments.stored, isEmpty);
      expect(
        find.widgetWithText(OutlinedButton, 'Add a photo'),
        findsOneWidget,
      );
    });

    testWidgets('a duplicate starts without the original attachments', (
      tester,
    ) async {
      final original = testTx(
        'a',
        expense,
        10,
        today,
      ).copyWith(photoFile: 'file1.jpg', voiceFile: 'file2.m4a');

      await open(tester, template: original);

      await revealInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Add a photo'),
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Add a photo'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Record a voice note'),
        findsOneWidget,
      );
    });
  });

  group('a voice note on the form (ATT-4)', () {
    testWidgets('recording, then stopping, attaches it', (tester) async {
      await open(tester);

      await record(tester);
      expect(find.text('Recording, 60s left'), findsOneWidget);

      await stopRecording(tester);

      expect(find.text('Voice note'), findsOneWidget);
      expect(attachments.stored.keys, ['file1.m4a']);

      await saveTransaction(tester);

      expect(provider.transactions.single.voiceFile, 'file1.m4a');
    });

    testWidgets('the countdown runs down and stops it at a minute', (
      tester,
    ) async {
      await open(tester);
      await record(tester);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Recording, 59s left'), findsOneWidget);

      for (var second = 0; second < 60; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Stop'), findsNothing);
      expect(find.text('Voice note'), findsOneWidget);
    });

    testWidgets('a microphone that is off says so', (tester) async {
      attachments.micAllowed = false;
      await open(tester);

      await record(tester);

      expect(find.text('The microphone is off for this app.'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Record a voice note'),
        findsOneWidget,
      );
    });

    testWidgets('playing it turns the button into pause', (tester) async {
      await open(tester);
      await record(tester);
      await stopRecording(tester);

      await tapInForm(tester, find.byTooltip('Play'));

      expect(attachments.played, ['file1.m4a']);
      expect(find.byTooltip('Pause'), findsOneWidget);
    });

    testWidgets('a voice note whose file is gone says so (ATT-7)', (
      tester,
    ) async {
      final tx = testTx(
        'a',
        expense,
        10,
        today,
      ).copyWith(voiceFile: 'gone.m4a');
      fake.rows.add(tx);
      await provider.load();

      await open(tester, editing: tx);

      await revealInForm(tester, find.text('This voice note is missing.'));
      expect(find.text('This voice note is missing.'), findsOneWidget);
      expect(find.byTooltip('Play'), findsNothing);
    });
  });
}
