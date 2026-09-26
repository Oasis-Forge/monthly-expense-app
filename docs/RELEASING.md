# Releasing

Releasing is by hand. Nothing on GitHub tags a commit, drafts a Release, or uploads to a store: the build that ships is made locally and uploaded to the store by the developer. The `version: x.y.z+N` line in `pubspec.yaml` is the source of truth: `x.y.z` is the version name, following [Semantic Versioning](https://semver.org) (major for breaking changes, minor for new features, patch for fixes and everything else), and `N` is the build number, which grows by one with every release because the stores require it to increase.

1. **On the branch**, bump the version with `/release [major|minor|patch]` in Claude Code, or by hand: edit `pubspec.yaml` and add a `## [x.y.z] - YYYY-MM-DD` entry to `CHANGELOG.md`. CI's `Format, analyze, test` check fails if the version isn't above the one on `main`, or has no changelog entry. Dependabot PRs are exempt and ride along with the next bump.
2. **Build it locally**: `/release --build`, or `flutter build appbundle --release` for Play and `flutter build apk --release` for a phone. The artifacts go to `dist/` (gitignored) as `monthly-expenses-X.Y.Z.aab` and `monthly-expenses-X.Y.Z.apk`, signed with the upload key through `android/key.properties`.
3. **Check the signer before every upload**: a release build without `android/key.properties` now fails fast (see below) rather than silently falling back to a debug key, but `keytool -printcert -jarfile dist/monthly-expenses-X.Y.Z.aab` showing your certificate, not `CN=Android Debug`, is still the final check — a debug-signed build made deliberately with `-PallowDebugSigning=true` would pass the build step but must never be uploaded. On Windows `keytool` may not be on PATH — call it as `"$JAVA_HOME/bin/keytool.exe"`, since a bare `keytool` prints nothing and reads as a pass.
4. **Upload it by hand** in Play Console, and paste `store/play/release-notes/X.Y.Z.txt` into the release notes box on each track it goes to.

The three workflows in the Actions tab build the same artifacts on GitHub's runners, started by hand and never on their own: **`build-android.yml`** (APK and App Bundle in the run's artifacts), **`build-desktop.yml`** (the Linux archive for Flathub and the Windows MSIX) and **`release-ios.yml`** (an unsigned compile check, or a signed IPA to TestFlight with `upload: true`). They are there for a clean build from a machine that isn't yours. Without the Android signing secrets below, a `build-android.yml` APK is signed with a throwaway debug key and can't update an installed copy.

## When a release is bad

Every merged PR is a release, so there will be a bad one. Decide none of this while it is happening.

1. **Stop the spread first.** In Play Console, halt the rollout on the track it is on. A version code that has been published can never be reused or re-uploaded, and an app cannot be rolled back to an earlier release: the only way out is a higher version going out.
2. **Fix forward, never backward.** `git revert` the merge and open a PR, and CI refuses it — the reverted tree's version is at or below `main`'s, which is exactly what the version check exists to catch. That is a stuck pipeline during the one hour it matters. If the fix *is* a revert, revert on a branch off a freshly pulled `main` **and** run `/release patch` on it, so the undo is itself a release with its own version and changelog entry.
3. **Don't rewrite `main`'s history to undo it.** The version check reads the version off `origin/main`, so rewriting the commit that raised it makes the next check compare against the wrong thing. Go forward instead.
4. **Say what happened in the changelog**, in the same user-facing words as everything else: what was wrong and what the new version does about it.
5. **Read the crash before guessing.** Play symbolicates with the deobfuscation mapping carried inside the uploaded bundle, so the stack traces in Play Console are readable. Keep the bundle you uploaded: it is the only copy, since nothing on GitHub builds it.

## GitHub secrets and variables

Add them in GitHub → Settings → Secrets and variables → Actions, or with `gh secret set NAME` (it prompts for the value).

| Name | Kind | Used by | Value |
|---|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | secret | `claude.yml` | Output of `claude setup-token` (or use `ANTHROPIC_API_KEY` and change the workflow input) |
| `ANDROID_KEYSTORE_BASE64` | secret | `build-android.yml` | Base64 of `upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | secret | `build-android.yml` | Keystore password |
| `ANDROID_KEY_ALIAS` | secret | `build-android.yml` | Key alias, e.g. `upload` |
| `ANDROID_KEY_PASSWORD` | secret | `build-android.yml` | Key password |
| `IOS_DIST_CERT_P12_BASE64` | secret | `release-ios.yml` | Base64 of the Apple Distribution certificate (`.p12`) |
| `IOS_DIST_CERT_PASSWORD` | secret | `release-ios.yml` | Password of the `.p12` |
| `APPSTORE_ISSUER_ID` | secret | `release-ios.yml` | App Store Connect API issuer ID |
| `APPSTORE_KEY_ID` | secret | `release-ios.yml` | App Store Connect API key ID |
| `APPSTORE_PRIVATE_KEY` | secret | `release-ios.yml` | Full contents of the `.p8` API key |
| `APPLE_TEAM_ID` | variable | `release-ios.yml` | 10-character Apple team ID |
| `IOS_PROFILE_NAME` | variable (optional) | `release-ios.yml` | Provisioning profile name; defaults to `Monthly Expenses App Store` |
| `MSIX_IDENTITY_NAME` | variable | `build-desktop.yml` | Partner Center → Product identity → Package/Identity/Name |
| `MSIX_PUBLISHER` | variable | `build-desktop.yml` | Partner Center → Product identity → Package/Identity/Publisher (`CN=…`). Without it, CI builds a test-signed MSIX only |
| `MSIX_PUBLISHER_DISPLAY_NAME` | variable | `build-desktop.yml` | Partner Center → Product identity → Package/Properties/PublisherDisplayName |

No store credentials are needed here: every upload to Play, TestFlight, Partner Center and Flathub is done by hand.

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
5. **Upload every AAB by hand** in Play Console → Testing → Internal testing. Build it with `flutter build appbundle --release` (after step 3).

Without `android/key.properties`, an Android release build (including `flutter run --release`) now fails fast with a clear error instead of silently producing a debug-signed AAB/APK that Play Console would reject; pass `-PallowDebugSigning=true` (or set `ORG_GRADLE_PROJECT_allowDebugSigning=true`) for a local debug-signed test build without a keystore.

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
- **Nothing publishes itself:** no workflow tags a commit, creates a GitHub Release or uploads to a store. The draft releases from before 20 September 2026 (v1.12.0 to v1.17.2) stay drafts, so their APKs stay private.
- **Fork PRs:** in Settings → Actions → General → "Approval for running fork pull request workflows", choose "Require approval for all external contributors".
- **Commit emails are public.** To hide yours on future commits, use your noreply address from GitHub → Settings → Emails: `git config user.email "<id>+haskalach@users.noreply.github.com"`.
- **License:** with no `LICENSE` file the code is "all rights reserved". People can view and fork it on GitHub but have no right to reuse it. Add a license only if you want to allow reuse.

### Protect `main`

Go to Settings → Rules → Rulesets → New branch ruleset, target `main`, and set:
- Require a pull request before merging.
- Require status checks to pass: `Format, analyze, test`, `Android build (release)`, `iOS build (unsigned)`. Run CI on one PR first so the check names show up in the picker.
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

Building for Windows needs the ATL component for MSVC (Visual Studio Installer → Individual components → "C++ ATL for latest v143 build tools"); `flutter_local_notifications_windows` (note reminders, NOTE-6) needs it to compile. `ci.yml` and `build-desktop.yml` install it on the runner before building.

1. In Partner Center, reserve the name "Monthly Expenses".
2. Under Product identity, copy Package/Identity/Name, Package/Identity/Publisher, and Package/Properties/PublisherDisplayName into the `MSIX_IDENTITY_NAME`, `MSIX_PUBLISHER`, and `MSIX_PUBLISHER_DISPLAY_NAME` variables.
3. Run `build-desktop.yml`, download the MSIX from the run, and upload it in a Partner Center submission. The Store signs it.
4. For a local test install, `dart run msix:create` builds a test-signed package in `build/windows/x64/runner/Release/`.

The package declares no capabilities, so it requests no internet access.

## One-time setup: Linux (Flathub)

Flathub checks that the publisher controls the app ID's domain. `io.github.monthly_expenses.MonthlyExpenses` is verified through a GitHub organization, so no personal name or domain appears in it.

1. Create the GitHub organization `monthly-expenses`. If the name is taken, pick another and change the ID in `linux/CMakeLists.txt`, `linux/flatpak/`, and `build-desktop.yml` before the first submission.
2. Flathub needs permission to redistribute the app. With no `LICENSE` file the code is all rights reserved, so add a license (or terms that allow redistribution) and update `project_license` in the metainfo file.
3. Add screenshots and a `<release>` entry to `linux/flatpak/io.github.monthly_expenses.MonthlyExpenses.metainfo.xml`.
4. Run `build-desktop.yml` and download the Linux archive from the run. Flathub fetches the tarball from a public URL, so put it somewhere it can reach — a GitHub Release published by hand is the simplest. Copy the archive's sha256 from the run summary into the manifest's `sha256`, and that URL into its `url`.
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

### Store listing graphics

`integration_test/store_screenshots_test.dart` renders the Play listing graphics on the emulator from the real screens with sample data: six captioned phone screenshots (1080×1920) and a feature graphic (1024×500) for each of the 23 listing languages, and the 512×512 store icon. Android draws the text and emoji itself, so they look as they do on a phone.

```
adb shell rm -rf /sdcard/Download/store-screenshots
flutter test integration_test/store_screenshots_test.dart -d emulator-5554
adb pull /sdcard/Download/store-screenshots/<code> store/play/graphics
```

Clear the folder first: the test runner uninstalls the app when it finishes, and a new install can't overwrite files the old one wrote. `--dart-define=ONLY=en-US,ar` renders only those languages. The captions and listing titles live in the test file; the store icon and feature graphics use the app icon's painter from `tool/render_app_icons_test.dart`. The pull puts one language's folder in place, replacing the old files; pull each language you rendered. Everything for the listing (text, graphics, the Data safety files, and the scripts that made them) lives in `store/`, which `.gitignore` keeps out of the public repository; `store/play/README.txt` says what is where.

### What to tell the stores

Both forms have to match `docs/privacy-policy.md`, which is the wording to copy from (ADS-6).

**Play Console → Data safety.** Data is *collected* (by the ad SDK) and *shared* (with Google). It is encrypted in transit, since the SDK only talks to Google over HTTPS. Users can't turn the collection off inside the app, and there is no way to request deletion of something we never hold. Every type below is collected and shared, required, not processed ephemerally, and used for **advertising or marketing**, **analytics**, and **fraud prevention, security and compliance**, as in Google's [data disclosure for the Mobile Ads SDK](https://developers.google.com/admob/android/privacy/play-data-disclosure):

| Category | Answer |
| --- | --- |
| Location → Approximate location | Worked out from the IP address by the ad network, never requested from the device. |
| App activity → App interactions | Whether an ad was shown, and whether it was tapped. |
| App info and performance → Diagnostics | How the SDK and its ads perform, such as how long an ad took to load. |
| Device or other IDs | The advertising ID and the app set ID. Buying "Remove ads" stops it, which the form has no way to express. |
| Financial info | **Not collected.** Everything the user records stays on the device (ADS-7). |
| Personal info, messages, photos, contacts, calendar, files | **Not collected.** |

Also declare the ads themselves under **Ads** in the store listing, and answer the **Families policy** questions: the app is not directed at children.

**App Store Connect → App Privacy.** Declare, all under "Data Used to Track You" as well as "Data Linked to You" only if Google's own guidance says so for your configuration:

- **Identifiers → Device ID** — Third-Party Advertising, Developer's Advertising or Marketing.
- **Usage Data → Advertising Data** — Third-Party Advertising.
- **Diagnostics → Crash/Performance Data** — only if you enable anything of the sort; today the app has none of its own.
- Everything the user records: **not collected**.

The iOS app asks App Tracking Transparency itself, right after the consent form and before the ad SDK starts (ADS-17), which is what makes declaring "Data Used to Track You" honest. Its prompt shows `NSUserTrackingUsageDescription` from `Info.plist`; keep that wording honest about what refusing does (nothing, except less-relevant ads). App Review checks the prompt appears, so test it on a fresh install: finish setup and the walkthrough, answer the consent form if one shows, and the ATT prompt should follow. It does not come back once answered; delete the app to see it again.
