import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_android/local_auth_android.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/services/authenticator.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

/// The Android notification-channel names reminder_service.dart passes to
/// AndroidNotificationDetails, and the app-lock prompt's own strings, come
/// from the ARB files rather than being left as English literals users see
/// in system settings whatever the app's language (LANG-2, NUDGE-11,
/// LOCK-1).
///
/// These tests exercise the pure functions the services build their
/// notification/auth-message objects from, not only the ARB getters, so
/// reverting reminder_service.dart or authenticator.dart to an English
/// literal fails the suite (rules-14-19_10).
void main() {
  test('note, due-entry, and empty-day channel names follow the app language '
      '(LANG-2, NUDGE-11)', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.noteReminderChannelName, 'Note reminders');
    expect(en.dueEntryChannelName, 'Entries that fell due');
    expect(en.emptyDayChannelName, 'Days with nothing recorded');

    final fr = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(fr.noteReminderChannelName, isNot(en.noteReminderChannelName));
    expect(fr.dueEntryChannelName, isNot(en.dueEntryChannelName));
    expect(fr.emptyDayChannelName, isNot(en.emptyDayChannelName));
  });

  test(
    "the app-lock prompt's hint follows the app language (LANG-2, LOCK-1)",
    () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final fr = await AppLocalizations.delegate.load(const Locale('fr'));
      expect(en.appLockPromptHint, 'Confirm it\'s you');
      expect(fr.appLockPromptHint, isNot(en.appLockPromptHint));
    },
  );

  test('noteChannelName and channelNameFor build from the ARB getters, not an '
      'English literal (LANG-2, NUDGE-11, rules-14-19_10)', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final fr = await AppLocalizations.delegate.load(const Locale('fr'));

    expect(noteChannelName(en), en.noteReminderChannelName);
    expect(noteChannelName(fr), isNot(noteChannelName(en)));

    expect(channelNameFor(ReminderKind.dueEntry, en), en.dueEntryChannelName);
    expect(
      channelNameFor(ReminderKind.dueEntry, fr),
      isNot(channelNameFor(ReminderKind.dueEntry, en)),
    );
    expect(channelNameFor(ReminderKind.emptyDay, en), en.emptyDayChannelName);
    expect(
      channelNameFor(ReminderKind.emptyDay, fr),
      isNot(channelNameFor(ReminderKind.emptyDay, en)),
    );
  });

  test(
    'authMessagesFor builds the Android title and hint from what it was '
    'given, not an untranslated default (LANG-2, LOCK-1, rules-14-19_10)',
    () {
      final messages = authMessagesFor(
        'Confirmez que c\'est vous',
        hint: 'Indice',
        cancelButton: 'Annuler',
      );
      final android = messages.whereType<AndroidAuthMessages>().single;
      expect(android.signInTitle, 'Confirmez que c\'est vous');
      expect(android.signInHint, 'Indice');
      expect(android.cancelButton, 'Annuler');
    },
  );
}
