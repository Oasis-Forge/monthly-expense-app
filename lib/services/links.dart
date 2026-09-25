import 'package:url_launcher/url_launcher.dart';

/// The privacy policy, published with the app's pages. Google Play's User
/// Data policy and App Store guideline 5.1.1(i) both ask for it inside the
/// app, not only on the store listing.
final privacyPolicyUrl = Uri.parse(
  'https://oasis-forge.github.io/monthly-expense-app/privacy-policy',
);

/// Opens [url] in the device's own browser. The browser does the fetching,
/// so the app still makes no network call of its own (RUN-2). Tests replace
/// it.
Future<bool> Function(Uri url) openInBrowser = (url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);
