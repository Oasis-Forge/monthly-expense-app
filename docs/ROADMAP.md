# Roadmap

Goal: ship Monthly Expenses to Google Play and the App Store. One PR per item or small group; CI must pass. Tick items in the same PR that completes them.

## Phase 0 — Tooling
- [x] `CLAUDE.md`, `.claude/` settings, format hook, `/verify` and `/release` skills, `build-doctor` agent
- [x] Dependabot, release-signing scaffolding (`android/key.properties`, `ios/ExportOptions.plist`)
- [x] CI (checks + Android and iOS builds) green on GitHub
- [x] Repo public, with a `main` ruleset (PR + 3 required checks, no force pushes or deletion)
- [ ] `release-android.yml` manual run without secrets (debug artifacts, nothing published)
- [ ] GitHub Pages serving `docs/privacy-policy.md`
- [ ] `release-ios.yml` and `claude.yml` exercised once their secrets exist

## Phase 1 — Correctness, testability, tests
- [ ] `ExpenseTransaction.copyWith` can't clear `note` (`note ?? this.note`): editing a note to empty keeps the old text. Add a `clearNote` flag or sentinel. (`lib/models/transaction.dart`)
- [ ] DB writes are fire-and-forget: `_submit` doesn't await the provider (`lib/screens/add_transaction_screen.dart`), and the provider changes state before writing, with no error handling (`lib/providers/transaction_provider.dart`). Await, roll back on failure, show a SnackBar.
- [ ] Swipe-to-delete has no undo (`_TransactionTile` in `lib/screens/home_screen.dart`). Add a SnackBar undo that re-inserts.
- [ ] `transactionsForSelectedMonth` is recomputed 4+ times per build. Cache per month; invalidate on mutation or month change.
- [ ] Inject `DBHelper` into `TransactionProvider` (default `DBHelper.instance`) so tests can use an in-memory FFI database.
- [ ] Add an `onUpgrade` migration scaffold to `DBHelper` (ordered list of version steps).
- [ ] Lints in `analysis_options.yaml`: `unawaited_futures`, `prefer_single_quotes`, `prefer_const_constructors`, `always_declare_return_types`.
- [ ] Tests: model `toMap`/`fromMap` round-trip; provider totals, by-category, grouping, month navigation; widget tests for add, edit, delete + undo, and the stats empty state.

## Phase 2 — Store readiness
- [ ] Display name "Monthly Expenses": `android:label` in `android/app/src/main/AndroidManifest.xml` and `CFBundleDisplayName` in `ios/Runner/Info.plist`.
- [ ] Launcher icons (`flutter_launcher_icons`) and splash screen (`flutter_native_splash`).
- [ ] Finalize bundle IDs before the first upload — they're permanent afterwards. Today: Android `com.markkalash.monthly_expense_app`, iOS `com.markkalash.monthlyExpenseApp`.
- [ ] Privacy policy: fill in `docs/privacy-policy.md`, publish it with GitHub Pages, and link it from both store listings. Update it whenever a feature touches user data (backup/CSV).
- [ ] Optional: remove `web/ windows/ linux/ macos/` (sqflite has no web support; desktop isn't a target).
- [ ] Upgrade `fl_chart` 0.69 → 1.x and `intl` (via Dependabot PRs).

## Phase 3 — Features (in dependency order)
- [ ] **Settings:** `SettingsProvider` on `shared_preferences` (already a dependency) for currency, theme mode, and first day of the month. Replaces the hard-coded `$` in `home_screen.dart`, `stats_screen.dart`, and `add_transaction_screen.dart`.
- [ ] **Backup & CSV:** JSON backup/restore that records the schema version; CSV export (`csv`, `share_plus`, `file_picker`). Ship before any schema change so users can protect their data.
- [ ] **Budgets (schema v2):** `budgets` table; per-category progress bars on Stats; over-budget marker on Home.
- [ ] **Recurring + trends (schema v3):** `recurring_rules` table; create due occurrences idempotently on app start; 6–12 month income vs. expense `BarChart` on Stats.

## Phase 4 — Release
- [ ] Finish the one-time setup in `docs/RELEASING.md`.
- [ ] `/release minor` → tag `v1.0.0` → Play internal testing + TestFlight.
- [ ] Store listings (screenshots, description, privacy policy URL, Play data safety form, App Store privacy labels), then promote to production.
