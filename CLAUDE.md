# Monthly Expense App

Flutter 3.47.4 / Dart 3.13.3 app for tracking monthly income and expenses. Targets Android, iOS, and desktop (macOS, Windows, Linux); web comes after v1. All data is local (sqflite); there is no backend.

## Commands (use the quiet forms)
- `flutter pub get > $null`
- `flutter analyze`
- `flutter test test/<file>_test.dart` while iterating; `flutter test -r failures-only` once at the end
- `dart format lib test` — rarely needed: a hook formats every edited `.dart` file
- `flutter` not on PATH? Use `D:\Desktop\projects\flutter_sdk\flutter\bin\flutter.bat` (`dart.bat` is next to it)
- `/verify` runs format check + analyze + tests and reports failures only

## Architecture
- `lib/main.dart`: `MaterialApp` + `ChangeNotifierProvider<TransactionProvider>`
- `lib/models/`: `ExpenseTransaction` (toMap/fromMap, `copyWith` with a sentinel for clearing), `Category`, `Account`, `Money` (integer thousandths), `Period` (month start day)
- `lib/db/db_helper.dart`: `DBHelper.instance` sqflite wrapper; tables `transactions`, `categories`, `accounts`; schema steps in `lib/db/migrations.dart`
- `lib/providers/transaction_provider.dart`: loaded data, selected `Period`, cached totals and balances, write-first mutations with soft delete
- `lib/l10n/`: `app_en.arb` → generated `AppLocalizations` (`flutter gen-l10n`, committed); `labels.dart` for category and period labels
- `lib/screens/`: `home_screen` (period selector, summary, day list, swipe delete), `add_transaction_screen` (add + edit), `stats_screen` (pie chart)
- Flow: screen → `context.read/watch<TransactionProvider>()` → `DBHelper`

## Conventions
- Product principles: no ads, no analytics/tracking SDKs or advertising ID, no account required; data leaves the device only through user-initiated export/backup.
- State lives in providers; screens stay presentational. Don't add another state library.
- Schema change = append a step to `DBHelper.schemaMigrations` (the version follows) and test it in `test/db_helper_test.dart`; never edit a merged step or `_createVersion1`.
- Every model/provider change gets a test. DB tests use `sqflite_common_ffi` (copy the setup in `test/widget_test.dart`); widget and write-failure tests use `FakeDB`, `testApp`, and `testTx` from `test/helpers.dart`.
- Feature order: model → migration → provider → screen → test → analyze.
- One branch per feature, PR to `main`; CI (`.github/workflows/ci.yml`) must pass.
- Before a branch is merged: check coverage of the changed files (`flutter test --coverage`) and add tests for gaps, then run the app (`flutter run`) so the user can test it by hand.

## Token rules
- Don't open `android/ ios/ linux/ macos/ windows/ web/` unless the task is platform-specific.
- Grep with a `path`, then read line ranges. Never read `pubspec.lock` or `ios/Runner.xcodeproj/project.pbxproj` whole; grep them.
- Don't spawn subagents for tasks touching fewer than ~5 files. Use the `build-doctor` agent for long Gradle/Xcode logs.
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
- The currency symbol is hard-coded `$` until settings land (ROADMAP Phase 2).
- Generated `lib/l10n/app_localizations*.dart` are committed; after editing `app_en.arb`, run `flutter gen-l10n` and commit the output.
