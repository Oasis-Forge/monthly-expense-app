# Releasing

Every PR merged to `main` is a release. The `version: x.y.z+N` line in `pubspec.yaml` is the source of truth: `x.y.z` is the version name, following [Semantic Versioning](https://semver.org) (major for breaking changes, minor for new features, patch for fixes and everything else), and `N` is the build number, which grows by one with every release because the stores require it to increase.

1. **Before merging**, bump the version on the branch with `/release [major|minor|patch]` in Claude Code, or by hand: edit `pubspec.yaml` and add a `## [x.y.z] - YYYY-MM-DD` entry to `CHANGELOG.md`. CI's `Format, analyze, test` check fails if the version isn't above the latest `vX.Y.Z` tag or has no changelog entry. Dependabot PRs are exempt and ship with the next release.
2. **On merge**, `release-android.yml` builds the release APK and AAB, tags the merge commit `vX.Y.Z`, and attaches `monthly-expenses-X.Y.Z.apk` to a draft GitHub Release with the changelog entry as notes. With the signing and Play secrets, it also uploads the AAB to Play **internal testing** as a draft. A merge whose version is already tagged releases nothing.

Without the Android signing secrets, each APK is signed with a throwaway debug key and can't update an installed copy: back up in the app, uninstall, install the new APK, and restore. Add the secrets below to get APKs that update in place.

Tags pushed by CI don't start other workflows, so iOS and desktop builds are manual. In the Actions tab, run **`release-ios.yml`** (signed IPA to TestFlight; for an unsigned compile check, set `upload: false`) or **`release-desktop.yml`** with the release tag as the ref, or run `gh workflow run release-desktop.yml --ref vX.Y.Z`. Both check that the tag matches `pubspec.yaml`.

## GitHub secrets and variables

Add them in GitHub → Settings → Secrets and variables → Actions, or with `gh secret set NAME` (it prompts for the value).

| Name | Kind | Used by | Value |
|---|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | secret | `claude.yml` | Output of `claude setup-token` (or use `ANTHROPIC_API_KEY` and change the workflow input) |
| `ANDROID_KEYSTORE_BASE64` | secret | `release-android.yml` | Base64 of `upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | secret | `release-android.yml` | Keystore password |
| `ANDROID_KEY_ALIAS` | secret | `release-android.yml` | Key alias, e.g. `upload` |
| `ANDROID_KEY_PASSWORD` | secret | `release-android.yml` | Key password |
| `PLAY_SERVICE_ACCOUNT_JSON` | secret | `release-android.yml` | Google Cloud service-account JSON key with Play Console release access |
| `IOS_DIST_CERT_P12_BASE64` | secret | `release-ios.yml` | Base64 of the Apple Distribution certificate (`.p12`) |
| `IOS_DIST_CERT_PASSWORD` | secret | `release-ios.yml` | Password of the `.p12` |
| `APPSTORE_ISSUER_ID` | secret | `release-ios.yml` | App Store Connect API issuer ID |
| `APPSTORE_KEY_ID` | secret | `release-ios.yml` | App Store Connect API key ID |
| `APPSTORE_PRIVATE_KEY` | secret | `release-ios.yml` | Full contents of the `.p8` API key |
| `APPLE_TEAM_ID` | variable | `release-ios.yml` | 10-character Apple team ID |
| `IOS_PROFILE_NAME` | variable (optional) | `release-ios.yml` | Provisioning profile name; defaults to `Monthly Expenses App Store` |
| `MSIX_IDENTITY_NAME` | variable | `release-desktop.yml` | Partner Center → Product identity → Package/Identity/Name |
| `MSIX_PUBLISHER` | variable | `release-desktop.yml` | Partner Center → Product identity → Package/Identity/Publisher (`CN=…`). Without it, CI builds a test-signed MSIX only |
| `MSIX_PUBLISHER_DISPLAY_NAME` | variable | `release-desktop.yml` | Partner Center → Product identity → Package/Properties/PublisherDisplayName |

## One-time setup: Android

1. Create the upload keystore, and back it up together with its passwords. Losing it means asking Google for an upload-key reset.
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Base64 it into the clipboard for `ANDROID_KEYSTORE_BASE64` (PowerShell):
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
   ```
3. Optional, for signed local builds: copy the keystore to `android/app/upload-keystore.jks` and create `android/key.properties` (both are gitignored):
   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
4. In Play Console, create the app with package `com.oasisforge.monthlyexpenses` and keep Play App Signing enabled.
5. **Upload the first AAB by hand** in Play Console → Testing → Internal testing. The API can't create an app's first release. Build it with `flutter build appbundle` (after step 3), or download it from a `release-android.yml` run that had the secrets.
6. In Google Cloud, create a service account and a JSON key. In Play Console → Users and permissions, invite the service account with release permissions for this app. Save the JSON as `PLAY_SERVICE_ACCOUNT_JSON`.

## One-time setup: iOS

1. Enroll in the Apple Developer Program.
2. Register the App ID `com.oasisforge.monthlyexpenses`, and create the app record in App Store Connect.
3. Create an Apple Distribution certificate. Without a Mac, use OpenSSL (ships with Git for Windows):
   ```bash
   openssl genrsa -out dist.key 2048
   openssl req -new -key dist.key -out dist.csr -subj "/emailAddress=you@example.com/CN=Your Name/C=US"
   ```
   Upload `dist.csr` at developer.apple.com → Certificates → Apple Distribution, then download `distribution.cer` and convert it:
   ```bash
   openssl x509 -inform DER -in distribution.cer -out dist.pem
   openssl pkcs12 -export -legacy -inkey dist.key -in dist.pem -out dist.p12
   ```
   Base64 `dist.p12` into `IOS_DIST_CERT_P12_BASE64`, and put its export password in `IOS_DIST_CERT_PASSWORD`.
4. Create an **App Store** provisioning profile for the App ID named `Monthly Expenses App Store`, or set `IOS_PROFILE_NAME` to your profile's name.
   The home-screen widget is a second target, so it needs its own of both (WID-1):
   - Register the App Group `group.com.oasisforge.monthlyexpenses`, and enable the App Groups capability on **both** App IDs, ticking that group. Without it the widget shows nothing — it reads the app's numbers through the group and has no other way in.
   - Register the App ID `com.oasisforge.monthlyexpenses.MonthlyExpensesWidget` for the extension.
   - Create a second **App Store** profile for it named `Monthly Expenses Widget App Store`, or set `IOS_WIDGET_PROFILE_NAME`. `release-ios.yml` installs both and maps each to its target.
5. In App Store Connect → Users and Access → Integrations, create an API key with the App Manager role. Fill in `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID` and `APPSTORE_PRIVATE_KEY`.
6. Set the `APPLE_TEAM_ID` variable. This enables iOS on tag pushes.
7. Test it: run `release-ios.yml` manually with `upload: true` before tagging a real release.

## One-time setup: Claude GitHub Action

Run `/install-github-app` from a `claude` terminal. Or install the Claude GitHub app on the repo yourself and add `CLAUDE_CODE_OAUTH_TOKEN`. Then comment `@claude <request>` on an issue or PR. Only `haskalach` can trigger it, and each run is capped at 15 turns on Sonnet.

## Public repository

The repo is public, so GitHub-hosted runners (macOS included) cost nothing. CI therefore compiles iOS and Android on every PR.

- **Secrets stay safe:** GitHub masks secret values in logs, and the workflows never print them. CI uses `pull_request`, not `pull_request_target`, so PRs from forks run without secrets. `claude.yml` only runs for `haskalach`.
- **Release APKs:** `release-android.yml` creates the GitHub Release as a **draft**, so nobody can download the APK until you publish it. Leave it as a draft if you only want store distribution.
- **Fork PRs:** in Settings → Actions → General → "Approval for running fork pull request workflows", choose "Require approval for all external contributors".
- **Commit emails are public.** To hide yours on future commits, use your noreply address from GitHub → Settings → Emails: `git config user.email "<id>+haskalach@users.noreply.github.com"`.
- **License:** with no `LICENSE` file the code is "all rights reserved". People can view and fork it on GitHub but have no right to reuse it. Add a license only if you want to allow reuse.

### Protect `main`

Go to Settings → Rules → Rulesets → New branch ruleset, target `main`, and set:
- Require a pull request before merging.
- Require status checks to pass: `Format, analyze, test`, `Android build (debug)`, `iOS build (unsigned)`. Run CI on one PR first so the check names show up in the picker.
- Block force pushes.
- Bypass list: Repository admin.

### Host the privacy policy

Both stores require a public privacy policy URL.
1. In Settings → Pages, choose Deploy from a branch → `main` / `/docs`.
2. The policy is then live at `https://oasis-forge.github.io/monthly-expense-app/privacy-policy`. Its contact is the GitHub Issues page, so no email address is published.

Every file in `docs/` gets published, which is fine because the repo is public anyway.

## App icon and splash screen

`tool/render_app_icons_test.dart` draws the icon, a calendar page with a bar chart on the app's purple, into `assets/icon/`. After changing it, run these in order and commit `assets/icon/` with the generated platform files:
```bash
flutter test tool/render_app_icons_test.dart
```
```bash
dart run flutter_launcher_icons
```
```bash
dart run flutter_native_splash:create
```

## One-time setup: Windows (Microsoft Store)

Building for Windows needs the ATL component for MSVC (Visual Studio Installer → Individual components → "C++ ATL for latest v143 build tools"); `flutter_local_notifications_windows` (note reminders, NOTE-6) needs it to compile. `ci.yml` and `release-desktop.yml` install it on the runner before building.

1. In Partner Center, reserve the name "Monthly Expenses".
2. Under Product identity, copy Package/Identity/Name, Package/Identity/Publisher, and Package/Properties/PublisherDisplayName into the `MSIX_IDENTITY_NAME`, `MSIX_PUBLISHER`, and `MSIX_PUBLISHER_DISPLAY_NAME` variables.
3. Run `release-desktop.yml` on the release tag, download the MSIX from the run, and upload it in a Partner Center submission. The Store signs it.
4. For a local test install, `dart run msix:create` builds a test-signed package in `build/windows/x64/runner/Release/`.

The package declares no capabilities, so it requests no internet access.

## One-time setup: Linux (Flathub)

Flathub checks that the publisher controls the app ID's domain. `io.github.monthly_expenses.MonthlyExpenses` is verified through a GitHub organization, so no personal name or domain appears in it.

1. Create the GitHub organization `monthly-expenses`. If the name is taken, pick another and change the ID in `linux/CMakeLists.txt`, `linux/flatpak/`, and `release-desktop.yml` before the first submission.
2. Flathub needs permission to redistribute the app. With no `LICENSE` file the code is all rights reserved, so add a license (or terms that allow redistribution) and update `project_license` in the metainfo file.
3. Add screenshots and a `<release>` entry to `linux/flatpak/io.github.monthly_expenses.MonthlyExpenses.metainfo.xml`.
4. Run `release-desktop.yml` on the release tag and publish the draft GitHub Release. Copy the archive's sha256 from the `release-desktop.yml` run summary into the manifest's `sha256`, and the tag into its `url`.
5. Submit the manifest by following Flathub's submission guide (a pull request to `flathub/flathub`). Once it's accepted, verify the app through the organization in Flathub's developer portal.
6. For each later release, update `url` and `sha256` in the app's Flathub repository.

The repository lives in the `Oasis-Forge` organization, so store listings don't show a personal account. It moved there from a personal account; GitHub redirects the old repository URLs but not the GitHub Pages site, so the privacy policy URL for the store listings is `https://oasis-forge.github.io/monthly-expense-app/privacy-policy`.

## Mac App Store (Phase 4)

The macOS app is sandboxed and can read or write only the files people pick. Signing and a release workflow come with the desktop releases. They need macOS enabled for the App ID `com.oasisforge.monthlyexpenses`, Mac App Distribution and Mac Installer Distribution certificates, and a Mac App Store provisioning profile.

## Ads and the one purchase

### Filling in the live AdMob IDs

The live IDs went in with 1.14.0 (18 September 2026). If they ever change — a new AdMob app, a replaced unit — change them in **three** places at once — the SDK reads the app ID from the platform files before Dart runs, so all three have to agree, and `test/ads_config_test.dart` fails if they drift apart:

1. `lib/services/ads_config.dart` — `liveAppIdAndroid`, `liveAppIdIos`, and the four banner unit IDs (`liveBannerHomeAndroid`, `liveBannerInsightsAndroid`, `liveBannerHomeIos`, `liveBannerInsightsIos`). Either fill in every one for a platform or none: the test fails on a half-filled set, because a release would otherwise ask for an ad with an empty unit ID.
2. `android/app/src/main/AndroidManifest.xml` — the `com.google.android.gms.ads.APPLICATION_ID` meta-data.
3. `ios/Runner/Info.plist` — `GADApplicationIdentifier`.

None of these is a secret: they ship inside every binary, so they belong in the repository rather than in a GitHub secret.

**Only release builds serve them** (ADS-10). Debug and profile builds use the test units, because AdMob suspends accounts for impressions and clicks on their own live ads. To check a real fill once, set `AdsConfig.liveAdsEverywhere` to `true`, look, and set it back — and don't tap the ad.

**Seeing the consent form from outside Europe.** The form only appears where the law asks for it, so from anywhere else it can't be checked. A debug build run with `--dart-define=CONSENT_TEST_REGION=eea` behaves as if it were in the EEA, and `CONSENT_TEST_REGION=us` as if it were in a regulated US state; it also forgets the last answer at each launch, so the form shows every time. A release build ignores the setting. Emulators need nothing else; a physical phone must also be registered under AdMob → Settings → Test devices.

### Before the iOS release

Add Google's **`SKAdNetworkItems`** to `ios/Runner/Info.plist`, from [AdMob's iOS guide](https://developers.google.com/admob/ios/ios14#skadnetwork). It is a long list of network identifiers that Google keeps up to date; without it, iOS ad attribution under SKAdNetwork doesn't work and the ads earn less. It affects nothing on Android, which is why it isn't in yet.

### The "Remove ads" product

`PurchaseService.removeAdsId` is the product ID, and **changing it after the first release orphans what people have already bought**. Create it as a **non-consumable / one-time** in-app product with that exact ID in both consoles:

- Play Console → Monetise → In-app products. Then add testers to a licence-test list, or use the internal testing track; a purchase can't be tested from a locally built APK.
- App Store Connect → the app → In-App Purchases → Non-Consumable. Test with a Sandbox Apple Account.

Until the product exists in a console, the screen says there is nothing to sell and offers no button (PAY-3) — which is also what a device with no store answers, so that path is worth leaving in place.

### What to tell the stores

Both forms have to match `docs/privacy-policy.md`, which is the wording to copy from (ADS-6).

**Play Console → Data safety.** Data is *collected* (by the ad SDK) and *shared* (with Google), it is **not** encrypted in transit by us because we send nothing ourselves, and there is no way to request deletion of something we never hold:

| Category | Answer |
| --- | --- |
| Device or other IDs | Collected and shared, for **advertising or marketing** and **fraud prevention**. Not optional (buying "Remove ads" stops it, which the form has no way to express). |
| Approximate location | Collected and shared, for advertising — derived from the IP address by the ad network, never requested from the device. |
| App info and performance | Diagnostics, collected and shared, for advertising and fraud prevention. |
| Financial info | **Not collected.** Everything the user records stays on the device (ADS-7). |
| Personal info, messages, photos, contacts, calendar, files | **Not collected.** |

Also declare the ads themselves under **Ads** in the store listing, and answer the **Families policy** questions: the app is not directed at children.

**App Store Connect → App Privacy.** Declare, all under "Data Used to Track You" as well as "Data Linked to You" only if Google's own guidance says so for your configuration:

- **Identifiers → Device ID** — Third-Party Advertising, Developer's Advertising or Marketing.
- **Usage Data → Advertising Data** — Third-Party Advertising.
- **Diagnostics → Crash/Performance Data** — only if you enable anything of the sort; today the app has none of its own.
- Everything the user records: **not collected**.

Because the app shows ads and may ask for tracking, `NSUserTrackingUsageDescription` is in `Info.plist`; keep its wording honest about what refusing does (nothing, except less-relevant ads).
