import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// docs/privacy-policy.md is prose, not code, so nothing else checks that it
/// still matches how the full-screen ad actually behaves. It is also what
/// the linked policy page publishes verbatim, so a wrong claim here goes
/// live as soon as the change merges.
void main() {
  final policy = File('docs/privacy-policy.md').readAsStringSync();
  final settings = File('lib/providers/settings_provider.dart')
      .readAsStringSync();
  final ads = File('lib/providers/ads_provider.dart').readAsStringSync();

  group('the privacy policy (ADS-6, ADS-12, ADS-17, Decision 40)', () {
    test('never claims a daily cap on the full-screen ad', () {
      // ADS-12 / Decision 40: earning ten things resets the count to zero
      // (SettingsProvider.spendAdActivity), so ten more can earn another the
      // same day. "The user chose no ceiling on purpose."
      expect(policy, isNot(contains('once a day')));
      expect(policy, isNot(contains('a day at most')));
      // spendAdActivity is what actually removes any daily ceiling: it zeros
      // the count rather than remembering that today already had one.
      expect(settings, contains('Future<void> spendAdActivity()'));
      expect(settings, contains('_adActivity = 0;'));
    });

    test('describes the full-screen ad as earned by use, not a cap', () {
      expect(
        policy,
        contains(
          'but only after ten things done in the app that day '
          '(an entry saved or a screen opened)',
        ),
      );
      expect(
        policy,
        contains(
          'a **full-screen ad** once you have done ten things in the app '
          'that day',
        ),
      );
    });

    test('does not promise device transfer carries records on Android 11 '
        'and below (BAK-8)', () {
      // allowBackup="false" turns off device-to-device transfer along with
      // cloud backup on Android 11 and below, so the policy must not claim
      // the transfer always brings the records -- only a user-saved backup
      // does on those phones.
      expect(
        policy,
        isNot(
          contains(
            "Moving to a new phone with Android's transfer "
            'still brings it with you.',
          ),
        ),
      );
      expect(policy, contains('Android 12 and later'));
    });

    test('tells iOS users about the tracking prompt the app asks, and that '
        'saying no still shows ads (ADS-17)', () {
      // DeviceAdService.start asks it on iOS, after the consent flow and
      // before the SDK starts, so the published policy has to say so.
      final adService = File('lib/services/ad_service.dart').readAsStringSync();
      expect(adService, contains('await _askAboutTracking();'));

      expect(
        policy,
        contains(
          "whether ads may be chosen using your device's advertising "
          'identifier',
        ),
      );
      expect(
        policy,
        contains(
          'Saying no to either still shows ads, just not personalised ones',
        ),
      );
      // The promise about the user's own records stands either way (ADS-7).
      expect(policy, contains('**Nothing you record leaves your device.**'));
    });

    test('exempts only the full-screen ad from the first session', () {
      // AdsProvider._startAdsIfReady gates a banner on setup, the
      // walkthrough, consent and purchase only — never on a first session —
      // while SettingsProvider.adActivityEarned is the one check that reads
      // !_firstSession, and it guards only the full-screen ad.
      expect(ads, isNot(contains('_firstSession')));
      expect(settings, contains('!_firstSession'));

      expect(
        policy,
        contains(
          'the full-screen ad is never requested during your first '
          'session with the app',
        ),
      );
      expect(
        policy,
        isNot(contains('none is requested at all during your first session')),
      );
    });
  });
}
