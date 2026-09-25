import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/attachment_field.dart';
import 'package:monthly_expense_app/screens/backup_screen.dart';
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

    testWidgets(
      'leaving the form mid-recording asks first (ADD-9), then cancels it, '
      'not left running with no cap (ATT-4, ATT-5)',
      (tester) async {
        usePhoneScreen(tester);
        await tester.pumpWidget(
          testApp(
            provider,
            settings,
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
            attachments: attachments,
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await record(tester);
        expect(find.widgetWithText(FilledButton, 'Stop'), findsOneWidget);

        // Never pumpAndSettle here: the countdown ticks every second and the
        // tree would never settle while still recording.
        // The first Back only closes the keypad (ADD-9).
        await tester.pageBack();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(AddTransactionScreen), findsOneWidget);

        // The second Back asks, since a recording in progress counts as an
        // unsaved edit (ADD-9) — it must not be thrown away silently.
        await tester.pageBack();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Discard changes?'), findsOneWidget);
        expect(
          attachments.cancelled,
          isFalse,
          reason: 'still asking, so nothing has been thrown away yet',
        );

        await tester.tap(find.text('Discard'));
        // Two route-pop transitions run in sequence here (the dialog's, then
        // the form's), so this needs more than one beat to finish.
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        expect(find.byType(AddTransactionScreen), findsNothing);
        expect(
          attachments.cancelled,
          isTrue,
          reason:
              'a recording left running when the form closes should be '
              'cancelled, not left running with no cap (ATT-4)',
        );
      },
    );

    testWidgets(
      'Save mid-recording attaches the note just spoken instead of losing '
      'it (ATT-4, ATT-5)',
      (tester) async {
        await open(tester);
        // Enter the amount before recording starts, so nothing here needs
        // to settle while the countdown ticks.
        await revealInForm(tester, amountField);
        await tester.enterText(amountField, '12.50');

        await record(tester);
        expect(find.widgetWithText(FilledButton, 'Stop'), findsOneWidget);

        final saveButton = find.widgetWithText(FilledButton, 'Add Transaction');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pump();
        // Saving stops the recording itself; nothing left ticking now.
        await tester.pumpAndSettle();

        expect(attachments.cancelled, isFalse);
        expect(provider.transactions.single.voiceFile, 'file1.m4a');
      },
    );

    testWidgets(
      'stays mounted and keeps recording while scrolled far out of a lazy '
      'list, instead of the note being cancelled underneath it (ATT-4, '
      'review-data-2)',
      (tester) async {
        // A form's own list is too short in this test's default settings to
        // reliably scroll the field far enough past the cache extent to get
        // unmounted (the real bug needs a small phone, 1.3x text, or extra
        // rows showing to push it that far) — a purpose-built long list
        // isolates the mechanism (AutomaticKeepAliveClientMixin) instead.
        final key = GlobalKey<AttachmentFieldState>();
        bool? lastRecordingChanged;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Provider<AttachmentService>.value(
              value: attachments,
              child: Scaffold(
                body: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    if (index == 50) {
                      return AttachmentField(
                        key: key,
                        onPhotoChanged: (_) {},
                        onVoiceChanged: (_) {},
                        onRecordingChanged: (v) => lastRecordingChanged = v,
                      );
                    }
                    return SizedBox(height: 200, child: Text('item $index'));
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.byKey(key),
          500,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Record a voice note'),
        );
        await tester.pump();
        expect(find.widgetWithText(FilledButton, 'Stop'), findsOneWidget);

        // Scroll far away from index 50 (well beyond the sliver list's
        // cache extent), as the amount keypad opening shrinking the
        // viewport would in the real form.
        tester.state<ScrollableState>(scrollable).position.jumpTo(19000);
        await tester.pump();

        // Not cancelled, and the form was not told recording stopped:
        // AutomaticKeepAliveClientMixin kept the widget (and its countdown
        // Timer) alive instead of it being disposed underneath the user.
        expect(attachments.cancelled, isFalse);
        expect(lastRecordingChanged, isNot(false));

        // Scrolled back, it is still recording where it left off (Stop, not
        // "Record a voice note"), and Save can still reach it.
        tester.state<ScrollableState>(scrollable).position.jumpTo(0);
        await tester.scrollUntilVisible(
          find.byKey(key),
          500,
          scrollable: scrollable,
        );
        await tester.pump();
        expect(find.widgetWithText(FilledButton, 'Stop'), findsOneWidget);

        final name = await key.currentState!.finishRecording();
        expect(name, isNotNull);
        expect(attachments.cancelled, isFalse);
      },
    );

    testWidgets(
      'a throwing stop does not leave Save disabled for good, and shows the '
      'existing save-failed message (review-money-5)',
      (tester) async {
        await open(tester);
        await revealInForm(tester, amountField);
        await tester.enterText(amountField, '12.50');

        await record(tester);
        attachments.stopThrows = true;

        final saveButton = find.widgetWithText(FilledButton, 'Add Transaction');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(
          find.text("Couldn't save the transaction. Try again."),
          findsOneWidget,
        );
        expect(provider.transactions, isEmpty);

        // Save must not stay disabled for good (the recording state was
        // cleared even though stopping it threw): tapping it again saves.
        await tester.tap(saveButton);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(provider.transactions.length, 1);
      },
    );

    testWidgets(
      "'Save & add another' mid-recording attaches the note to the entry "
      'just saved, not the next one (ATT-4, ATT-5)',
      (tester) async {
        await open(tester);
        await revealInForm(tester, amountField);
        await tester.enterText(amountField, '12.50');

        await record(tester);

        final addAnother = find.widgetWithText(
          OutlinedButton,
          'Save & add another',
        );
        await tester.ensureVisible(addAnother);
        await tester.tap(addAnother);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(provider.transactions.single.voiceFile, 'file1.m4a');
        // The next, still-open entry starts with no voice note of its own.
        expect(
          find.widgetWithText(OutlinedButton, 'Record a voice note'),
          findsOneWidget,
        );

        // The form is a lazy list: the amount field scrolled out of view (and
        // out of the tree) while reaching the button below, so it needs
        // revealing again for the second entry.
        await revealInForm(tester, amountField);
        await tester.enterText(amountField, '5');
        await tapInForm(
          tester,
          find.widgetWithText(FilledButton, 'Add Transaction'),
        );

        expect(provider.transactions.last.voiceFile, isNull);
      },
    );

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

  group('the backup screen (ATT-6)', () {
    Future<void> openBackup(WidgetTester tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(
        testApp(
          provider,
          settings,
          const BackupScreen(),
          backup: testBackupService(fake, attachments: attachments),
          attachments: attachments,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says what the attachments add to a backup', (tester) async {
      attachments.stored['file1.jpg'] = List.filled(2 * 1024 * 1024, 0);

      await openBackup(tester);

      expect(find.text('Includes attachments, 2.0 MB'), findsOneWidget);
    });

    testWidgets('says nothing when there are none', (tester) async {
      await openBackup(tester);

      expect(find.textContaining('Includes attachments'), findsNothing);
    });
  });

  group('the rest of the field', () {
    testWidgets('the camera option takes a photo with it (ATT-2)', (
      tester,
    ) async {
      await open(tester);

      await tapInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Add a photo'),
      );
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();

      expect(attachments.picked, [PhotoSource.camera]);
    });

    testWidgets('away from a phone the picker opens straight away', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await open(tester);

      await tapInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Add a photo'),
      );

      expect(find.text('Take a photo'), findsNothing);
      expect(attachments.picked, [PhotoSource.gallery]);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('the photo opens full screen when tapped', (tester) async {
      await open(tester);
      await addPhoto(tester);

      await tapInForm(tester, find.byType(Image));

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('a voice note can be taken off again (ATT-5)', (tester) async {
      await open(tester);
      await record(tester);
      await stopRecording(tester);

      await tapInForm(tester, find.byTooltip('Remove voice note'));

      expect(attachments.stored, isEmpty);
      expect(
        find.widgetWithText(OutlinedButton, 'Record a voice note'),
        findsOneWidget,
      );
    });

    testWidgets('a playing note pauses again', (tester) async {
      await open(tester);
      await record(tester);
      await stopRecording(tester);
      await tapInForm(tester, find.byTooltip('Play'));

      await tapInForm(tester, find.byTooltip('Pause'));

      expect(find.byTooltip('Play'), findsOneWidget);
    });
  });
}
