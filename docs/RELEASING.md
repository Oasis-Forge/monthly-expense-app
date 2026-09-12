# Releasing

Releases are tag-driven. The `version: x.y.z+N` line in `pubspec.yaml` is the source of truth: `x.y.z` is the store version name, and `N` is the build number, which must increase with every store upload. Use `/release` in Claude Code, or bump the version manually, commit, and push a `vX.Y.Z` tag.

Pushing a tag runs:
- **`release-android.yml`:** builds a signed AAB and APK, attaches the APK to a GitHub Release, and uploads the AAB to Play **internal testing** as a draft. Without signing secrets it builds with debug keys, uploads the files as workflow artifacts, and publishes nothing.
- **`release-ios.yml`:** builds a signed IPA and uploads it to TestFlight. Tag runs are skipped until the `APPLE_TEAM_ID` variable exists. For an unsigned compile check, run it manually with `upload: false`.

Both workflows fail if the tag doesn't match `pubspec.yaml`. Each also has a **Run workflow** button in the Actions tab.

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
4. In Play Console, create the app with package `com.markkalash.monthly_expense_app` and keep Play App Signing enabled.
5. **Upload the first AAB by hand** in Play Console → Testing → Internal testing. The API can't create an app's first release. Build it with `flutter build appbundle` (after step 3), or download it from a `release-android.yml` run that had the secrets.
6. In Google Cloud, create a service account and a JSON key. In Play Console → Users and permissions, invite the service account with release permissions for this app. Save the JSON as `PLAY_SERVICE_ACCOUNT_JSON`.

## One-time setup: iOS

1. Enroll in the Apple Developer Program.
2. Register the App ID `com.markkalash.monthlyExpenseApp`, and create the app record in App Store Connect.
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
- Bypass list: Repository admin, so `/release` can push its version-bump commit to `main`.

### Host the privacy policy

Both stores require a public privacy policy URL.
1. In Settings → Pages, choose Deploy from a branch → `main` / `/docs`.
2. The policy is then live at `https://haskalach.github.io/monthly-expense-app/privacy-policy`. Its contact is the GitHub Issues page, so no email address is published.

Every file in `docs/` gets published, which is fine because the repo is public anyway.
