# Monthly Expense App

Flutter 3.47.4 / Dart 3.13.3 app for tracking monthly income and expenses. Targets Android, iOS, and desktop (macOS, Windows, Linux); web comes after v1. All data is local (sqflite); there is no backend.

## Commands (use the quiet forms)
- `flutter pub get > $null`
- `flutter analyze`
- `flutter test test/<file>_test.dart` while iterating; `flutter test -r failures-only` once at the end
- `dart format lib test` — rarely needed: a hook formats every edited `.dart` file
- `flutter` not on PATH? Use `D:\Desktop\projects\flutter_sdk\flutter\bin\flutter.bat` (`dart.bat` is next to it)
- `/verify` runs format check + analyze + tests and reports failures only
- `/coverage` lists untested lines in changed files; `/l10n-add` writes messages to all six ARB files; `/emulator` drives the phone as text; `/handoff` rewrites the resume note

## Architecture
- `lib/main.dart`: `MaterialApp` + providers for `SettingsProvider`, `TransactionProvider`, `BackupService`, and `Authenticator`; `AppLock` wraps every route through `MaterialApp.builder`
- `lib/models/`: `ExpenseTransaction` (toMap/fromMap, `copyWith` with a sentinel for clearing), `Transfer`, `Category`, `Account`, `Money` (integer thousandths), `evaluateAmount` (`12.5+3`), `Period` (month start day), `Budget` (limits versioned by the period they start in), `RecurringRule` + `RecurringOccurrence` (handled once per rule and date), `TransactionFilter`, `BackupData` + `planMerge` (backup file and merge), `buildCsv`, `DayTotals` + `PeriodTotals`
- `lib/db/db_helper.dart`: `DBHelper.instance` sqflite wrapper; tables `transactions`, `transfers`, `categories`, `accounts`, `budgets`, `recurring_rules`, `recurring_occurrences`; schema steps in `lib/db/migrations.dart`; whole-table export, replace, merge, and older-backup upgrade
- `lib/providers/transaction_provider.dart`: loaded data, selected `Period`, cached totals and balances, daily totals and trend, account balances, form defaults, write-first mutations with soft delete; `settings_provider.dart`: currency, theme, month and week start, carry-forward, backup reminder, app lock
- `lib/services/`: `BackupService` (create, read, restore, CSV) over `BackupFiles` (file dialogs, automatic backups); `Authenticator` over `local_auth`
- `lib/screens/form_fields.dart`: `AmountEntry` mixin + keypad and `DateField`, shared by the transaction and transfer forms; `period_selector.dart`, shared by Home and Insights
- `lib/l10n/`: `app_en.arb` plus `app_{tr,ar,fr,es,de}.arb` → generated `AppLocalizations` (`flutter gen-l10n`, committed); `languages.dart` for the language list and English fallback; `labels.dart` for category and period labels
- `lib/screens/`: `home_screen` (period selector, summary, notices, day list, swipe delete, first-run welcome), `add_transaction_screen` (add + edit), `insights_screen` (categories, calendar, trend), `backup_screen`, `app_lock`
- Flow: screen → `context.read/watch<TransactionProvider>()` → `DBHelper`

## Conventions
- Product principles: no account required; the user's own records (amounts, titles, notes, attachments) leave the device only through user-initiated export/backup, and the ad SDK is never given them (ADS-7). Banner ads and the `INTERNET` permission arrive with Phase 4's ads item; until then the app makes no network calls at all, and there is still no analytics or crash reporting.
- State lives in providers; screens stay presentational. Don't add another state library.
- Schema change = append a step to `DBHelper.schemaMigrations` (the version follows) and test it in `test/db_helper_test.dart`; never edit a merged step or `_createVersion1`.
- Every model/provider change gets a test. DB tests use `sqflite_common_ffi` (copy the setup in `test/widget_test.dart`); widget and write-failure tests use `FakeDB`, `testApp`, and `testTx` from `test/helpers.dart`, with `FakeBackupFiles` and `FakeAuthenticator` standing in for file dialogs and `local_auth`.
- Feature order: model → migration → provider → screen → test → analyze.
- One branch per feature, PR to `main`; CI (`.github/workflows/ci.yml`) must pass.
- Every merged PR is a release: bump the version on the branch with `/release [major|minor|patch]` (SemVer `x.y.z+N` plus a `CHANGELOG.md` entry; CI checks it), and the merge tags `vX.Y.Z` and attaches the APK to a draft GitHub Release. `/release` also builds the same version locally into `dist/monthly-expenses-X.Y.Z.apk` (gitignored); rebuild it after any app change on the branch.
- Before a branch is merged: check coverage of the changed files (`/coverage`) and add tests for gaps, then run the app (`flutter run`, or `/emulator` to drive it) so the user can test it by hand.

## Token rules
- Don't open `android/ ios/ linux/ macos/ windows/ web/` unless the task is platform-specific.
- Grep with a `path`, then read line ranges. Never read `pubspec.lock` or `ios/Runner.xcodeproj/project.pbxproj` whole; grep them.
- Don't spawn subagents for tasks touching fewer than ~5 files, except routine work (next rule). Use the `build-doctor` agent for long Gradle/Xcode logs.
- Routine work goes to a Sonnet subagent (`Agent` with `model: sonnet`), whatever its size: link and URL fixes, doc, roadmap, and changelog edits, and releases (`/release`, version bump, local APK). Decide the change in the main session, then hand it over with the exact files, lines, and wording so the subagent doesn't re-read the project; check the result with `git diff --stat`, not by re-reading files. Features, bug fixes, tests, and emulator runs stay with the main model.
- Don't summarize diffs back; state the result in 1–3 lines.

## Read on demand only
- `docs/ROADMAP.md`: phased plan and known bugs — read when planning or picking up work.
- `docs/RELEASING.md`: signing, secrets, store release steps.
- `docs/PRODUCT_RULES.md`: behavior rules with IDs (`BUD-3`) — read the relevant section before implementing or testing a feature; cite rule IDs in tests and PRs.

## Gotchas
- The repo is public: never commit secrets or personal data, and never print secrets in workflows.
- The project path contains spaces: quote it in shell commands.
- Targets: Android, iOS, and desktop (macOS, Windows, Linux; desktop CI builds run only on pushes to `main`). Windows and Linux use `sqflite_common_ffi`, set up in `main.dart`, with the database in the app support folder. Web comes after v1: sqflite has no web implementation.
- Release signing reads `android/key.properties` (gitignored); without it, release builds are debug-signed.
- Store IDs are permanent after the first upload and carry no personal names: `com.monthlyexpenses.app` (Android, iOS, macOS, Windows) and `io.github.monthly_expenses.MonthlyExpenses` (Linux and Flathub). Run the app with `adb shell am start -n com.monthlyexpenses.app/.MainActivity`.
- Icons and splash screens come from `tool/render_app_icons_test.dart`: run it with `flutter test`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, and commit the generated platform files.
- App lock uses `local_auth`: Android's `MainActivity` is a `FlutterFragmentActivity` with an AppCompat launch theme, and iOS needs `NSFaceIDUsageDescription`. Backups on macOS need the user-selected files entitlement.
- Six languages: every message added or changed in `app_en.arb` gets machine translations in `app_tr.arb`, `app_ar.arb`, `app_fr.arb`, `app_es.arb`, and `app_de.arb` in the same change (LANG-6), written with `/l10n-add` rather than by hand, then run `flutter gen-l10n` and commit the generated `app_localizations*.dart`. `test/l10n_test.dart` fails on missing messages or placeholders; `test/languages_test.dart` on overflow at 1.3× text or right-to-left mistakes. Use directional padding and alignment (`EdgeInsetsDirectional`, `AlignmentDirectional`), and keep amounts left to right.
