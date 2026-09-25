import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';

/// The Android notification-channel names reminder_service.dart passes to
/// AndroidNotificationDetails, and the app-lock prompt's own strings, come
/// from the ARB files rather than being left as English literals users see
/// in system settings whatever the app's language (LANG-2, NUDGE-11,
/// LOCK-1).
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
}
