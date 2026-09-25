import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/backup.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/services/attachment_service.dart';
import 'package:monthly_expense_app/services/backup_service.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  final now = DateTime(2026, 9, 16, 10);

  late Directory dir;
  late AttachmentService attachments;
  late FakeAttachmentFiles files;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('attachments');
    final made = testAttachments(dir);
    attachments = made.service;
    files = made.files;
  });

  tearDown(() => dir.delete(recursive: true));

  Future<File> aPhoto() =>
      File('${dir.path}/picked.jpg').writeAsBytes(const [9, 9, 9]);

  /// A provider holding [tx], with the test's attachment folder.
  Future<TransactionProvider> providerWith(ExpenseTransaction tx) async {
    final provider = TransactionProvider(
      db: FakeDB(transactions: [tx]),
      clock: () => now,
      attachments: attachments,
    );
    await provider.load();
    return provider;
  }

  group('photos (ATT-2, ATT-3)', () {
    test('a picked photo is copied in, and the picker copy goes', () async {
      final picked = await aPhoto();
      files.toPick = picked.path;

      final name = await attachments.addPhoto(PhotoSource.camera);

      expect(name, 'file1.jpg');
      expect(await attachments.exists(name!), isTrue);
      expect(await attachments.read(name), [9, 9, 9]);
      expect(await picked.exists(), isFalse);
      expect(files.picked, [PhotoSource.camera]);
    });

    test('on the desktop, the user\'s own file stays where it was', () async {
      final picked = await aPhoto();
      final desktop = AttachmentService(
        files: files,
        newName: () => 'desk1',
        galleryGivesCopy: false,
      );
      files.toPick = picked.path;

      final name = await desktop.addPhoto(PhotoSource.gallery);

      expect(await desktop.read(name!), [9, 9, 9]);
      expect(await picked.exists(), isTrue);
    });

    test('on a phone, the gallery picker\'s copy goes', () async {
      final picked = await aPhoto();
      final phone = AttachmentService(
        files: files,
        newName: () => 'phone1',
        galleryGivesCopy: true,
      );
      files.toPick = picked.path;

      await phone.addPhoto(PhotoSource.gallery);

      expect(await picked.exists(), isFalse);
    });

    test('backing out of the picker attaches nothing', () async {
      expect(await attachments.addPhoto(PhotoSource.gallery), isNull);
      expect(dir.listSync(), isEmpty);
    });

    test('a stored photo is downscaled on the way in', () {
      expect(AttachmentService.photoMaxSide, 1600.0);
    });
  });

  group('voice notes (ATT-4)', () {
    test('recording writes a file and returns its name', () async {
      expect(await attachments.startRecording(), isTrue);

      final name = await attachments.stopRecording();

      expect(name, 'file1.m4a');
      expect(await attachments.exists(name!), isTrue);
    });

    test('a refused microphone records nothing', () async {
      files.micAllowed = false;

      expect(await attachments.startRecording(), isFalse);
      expect(await attachments.stopRecording(), isNull);
      expect(dir.listSync(), isEmpty);
    });

    test('cancelling throws the part-recorded file away', () async {
      await attachments.startRecording();

      await attachments.cancelRecording();

      expect(files.cancelled, isTrue);
      expect(dir.listSync(), isEmpty);
    });

    test('a voice note stops at a minute', () {
      expect(AttachmentService.voiceLimit, const Duration(seconds: 60));
    });
  });

  group('files (ATT-5, ATT-7)', () {
    test('deleting nothing, or a file already gone, is fine', () async {
      await attachments.delete(null);
      await attachments.delete('gone.jpg');
    });

    test('deleteAll removes what it is given and skips the rest', () async {
      files.toPick = (await aPhoto()).path;
      final name = await attachments.addPhoto(PhotoSource.gallery);

      await attachments.deleteAll([name, null, 'gone.m4a']);

      expect(await attachments.exists(name!), isFalse);
    });

    test('written bytes read back and count towards the total', () async {
      await attachments.write('note.m4a', const [1, 2, 3, 4]);

      expect(await attachments.read('note.m4a'), [1, 2, 3, 4]);
      expect(await attachments.totalBytes(), 4);
    });

    test('path refuses a name that would resolve outside the folder '
        '(ATT-2, data-integrity#10)', () async {
      for (final name in ['a/b.jpg', '..\\x.jpg', '..']) {
        await expectLater(attachments.path(name), throwsArgumentError);
      }
    });
  });

  group('the provider clears up files (ATT-5)', () {
    test('emptying old trash deletes the attachments with it', () async {
      final old = testTx('a', expense, 10, now)
          .copyWith(photoFile: 'file1.jpg', voiceFile: 'file2.m4a')
          .copyWith(deletedAt: now.subtract(const Duration(days: 40)));
      await attachments.write('file1.jpg', const [1]);
      await attachments.write('file2.m4a', const [2]);

      await providerWith(old);

      expect(await attachments.exists('file1.jpg'), isFalse);
      expect(await attachments.exists('file2.m4a'), isFalse);
    });

    test('trash inside the 30 days keeps its attachments', () async {
      final recent = testTx('a', expense, 10, now)
          .copyWith(photoFile: 'file1.jpg')
          .copyWith(deletedAt: now.subtract(const Duration(days: 3)));
      await attachments.write('file1.jpg', const [1]);

      await providerWith(recent);

      expect(await attachments.exists('file1.jpg'), isTrue);
    });

    test('replacing a photo deletes the one it replaced', () async {
      final tx = testTx('a', expense, 10, now).copyWith(photoFile: 'file1.jpg');
      await attachments.write('file1.jpg', const [1]);
      await attachments.write('file2.jpg', const [2]);
      final provider = await providerWith(tx);

      await provider.updateTransaction(tx.copyWith(photoFile: 'file2.jpg'));

      expect(await attachments.exists('file1.jpg'), isFalse);
      expect(await attachments.exists('file2.jpg'), isTrue);
      expect(provider.transactions.single.photoFile, 'file2.jpg');
    });

    test('an edit that keeps the photo keeps the file', () async {
      final tx = testTx('a', expense, 10, now).copyWith(photoFile: 'file1.jpg');
      await attachments.write('file1.jpg', const [1]);
      final provider = await providerWith(tx);

      await provider.updateTransaction(tx.copyWith(title: 'Lunch'));

      expect(await attachments.exists('file1.jpg'), isTrue);
    });
  });

  group('backups carry the files (ATT-6)', () {
    late FakeBackupFiles saved;

    BackupService serviceFor(FakeDB db) {
      saved = FakeBackupFiles();
      return testBackupService(db, files: saved, attachments: attachments);
    }

    ExpenseTransaction withPhoto(String? name) =>
        testTx('a', expense, 10, now).copyWith(photoFile: name);

    test('a backup with an attachment is a zip that carries it', () async {
      await attachments.write('file1.jpg', const [7, 7, 7]);
      final service = serviceFor(
        FakeDB(transactions: [withPhoto('file1.jpg')]),
      );

      expect(await service.saveBackup(await testSettings()), isTrue);

      expect(saved.saved.keys.single, endsWith('.zip'));
      final read = await service.read(saved.saved.values.single);
      expect(read.files, {
        'file1.jpg': [7, 7, 7],
      });
      expect(read.transactionCount, 1);
    });

    test('a backup without attachments stays a JSON file', () async {
      final service = serviceFor(FakeDB(transactions: [withPhoto(null)]));

      await service.saveBackup(await testSettings());

      expect(saved.saved.keys.single, endsWith('.json'));
      final read = await service.read(saved.saved.values.single);
      expect(read.files, isEmpty);
    });

    test('a file that has gone is left out, not refused (ATT-7)', () async {
      final service = serviceFor(FakeDB(transactions: [withPhoto('gone.jpg')]));

      await service.saveBackup(await testSettings());

      final read = await service.read(saved.saved.values.single);
      expect(read.files, isEmpty);
      expect(read.transactionCount, 1);
    });

    test('restoring a zip writes its files back', () async {
      await attachments.write('file1.jpg', const [7, 7, 7]);
      final service = serviceFor(
        FakeDB(transactions: [withPhoto('file1.jpg')]),
      );
      await service.saveBackup(await testSettings());
      await attachments.delete('file1.jpg');

      await service.restore(
        await service.read(saved.saved.values.single),
        RestoreMode.replace,
        await testSettings(),
      );

      expect(await attachments.read('file1.jpg'), [7, 7, 7]);
    });
  });

  group('playback goes through to the player (ATT-4)', () {
    test('play, then pause, and the stream says which', () async {
      final heard = <bool>[];
      attachments.playing.listen(heard.add);

      await attachments.play('note.m4a');
      await attachments.pausePlaying();
      await Future<void>.delayed(Duration.zero);

      expect(files.played, [await attachments.path('note.m4a')]);
      expect(heard, [true, false]);
    });
  });
}
