# Roadmap

Goal: build the full v1 feature set first, then prepare and ship Monthly Expenses to Google Play and the App Store. Behavior is defined in `docs/PRODUCT_RULES.md`; items cite its rule IDs. One PR per item; CI must pass. Tick items in the same PR that completes them.

## Phase 0 — Tooling (done)
- [x] `CLAUDE.md`, `.claude/` settings, format hook, `/verify` and `/release` skills, `build-doctor` agent
- [x] Dependabot, release-signing scaffolding (`android/key.properties`, `ios/ExportOptions.plist`)
- [x] CI (checks + Android and iOS builds) green on GitHub
- [x] Repo public, with a `main` ruleset (PR + 3 required checks, no force pushes or deletion)
- [x] `release-android.yml` manual run without secrets (debug artifacts, nothing published)
- [x] GitHub Pages serving `docs/privacy-policy.md` at https://haskalach.github.io/monthly-expense-app/privacy-policy
- [x] Upgrade `fl_chart` 0.69 → 1.2 and `intl` → 0.20 (Dependabot PRs #2, #3)

## Phase 1 — Foundations
Groundwork every feature builds on. After this phase, only budgets, recurring rules, and transfers add tables.
- [x] Lints in `analysis_options.yaml`: `unawaited_futures`, `prefer_single_quotes`, `prefer_const_constructors`, `always_declare_return_types`.
- [x] Inject `DBHelper` into `TransactionProvider` (default `DBHelper.instance`) so tests use an in-memory FFI database.
- [x] Migration scaffold in `DBHelper`: an ordered list of version steps run by `onUpgrade`, with a test that upgrades a v1 database.
- [x] Reliable writes: `_submit` awaits the provider (`lib/screens/add_transaction_screen.dart`); the provider writes before changing state, rolls back on failure, and the screen shows a SnackBar (`lib/providers/transaction_provider.dart`).
- [x] `copyWith` can clear nullable fields (`note`, and `title` once optional); use a sentinel. (`lib/models/transaction.dart`)
- [x] Localization scaffolding: `flutter gen-l10n` with an English ARB file; move today's UI strings. Every later feature adds its strings there.
- [x] Schema step — records: integer amounts (MONEY-1, MONEY-2), optional title (ADD-1), `created_at` and `updated_at` (REC-1), soft delete with `deleted_at` (DEL-1). Existing rows migrate.
- [x] Schema step — categories table with ~15 curated defaults; transactions reference a category ID, and old names map to the new defaults (CAT-1, CAT-2).
- [x] Schema step — accounts table with a default "Cash" account; every transaction gets an account (ACC-1, ACC-2).
- [x] Period and balance engine: one period function (PER-1); period totals, carried-forward and closing balances, future-dated and deleted exclusions (BAL-1–BAL-5). Cache per period and invalidate on mutation or period change, replacing today's repeated `transactionsForSelectedMonth` work.
- [x] Tests: model round-trip, each migration step, period and balance rules, and widget tests for add, edit, and the stats empty state.
- [ ] Optional: remove `web/ windows/ linux/ macos/` (not targets; `flutter pub get` keeps rewriting their generated plugin files).

## Phase 2 — Features (in dependency order)
- [ ] **Settings:** `SettingsProvider` on `shared_preferences` for currency (CUR-1–CUR-3), theme mode, and first day of month and week (PER-2–PER-4). Replaces the hard-coded `$` in `home_screen.dart`, `stats_screen.dart`, and `add_transaction_screen.dart`.
- [ ] **Delete, undo, trash:** swipe delete with an Undo snackbar, a trash screen with restore, and a 30-day purge (DEL-2–DEL-4).
- [ ] **Categories:** a screen to add, rename, reorder, change the icon of, and archive categories (CAT-3–CAT-5).
- [ ] **Accounts and transfers:** accounts screen, account picker, transfers (schema step), account balances, and the carried-forward balance on Home (ACC-1–ACC-5, BAL-2, BAL-3).
- [ ] **Faster entry:** keypad with `+` and `−`, smart defaults, "Save & add another", recent categories, date arrows both ways, duplicate, and the upcoming marker (ADD-2–ADD-8).
- [ ] **Search and filters** (SRCH-1–SRCH-3).
- [ ] **Budgets** (schema step): per-category and overall monthly budgets with per-day allowance and warnings; progress on Stats, over-budget marker on Home (BUD-1–BUD-6).
- [ ] **Recurring** (schema step): rules, an Upcoming list that waits for a tap by default, and idempotent posting on app start (RCR-1–RCR-7).
- [ ] **Backup, restore, export:** JSON backup of every table, Replace or Merge restore with an automatic safety backup, CSV export of the current view, and the backup reminder (BAK-1–BAK-7). Comes after the last schema step so the format covers every table.
- [ ] **Insights:** calendar month view with daily totals, a 6–12 month income vs. expense trend, and the category chart for any period.
- [ ] **App lock:** optional PIN or biometric unlock (`local_auth`).
- [ ] **First run:** Home empty state with one "Add your first transaction" action (RUN-1).

## Phase 3 — Store readiness (after Phase 2)
- [ ] Display name "Monthly Expenses": `android:label` in `android/app/src/main/AndroidManifest.xml` and `CFBundleDisplayName` in `ios/Runner/Info.plist`.
- [ ] Launcher icons (`flutter_launcher_icons`) and splash screen (`flutter_native_splash`).
- [ ] Finalize bundle IDs before the first upload — they're permanent afterwards. Today: Android `com.markkalash.monthly_expense_app`, iOS `com.markkalash.monthlyExpenseApp`.
- [x] Privacy policy published at https://haskalach.github.io/monthly-expense-app/privacy-policy.
- [ ] Update the privacy policy for accounts, backup and restore, CSV export, and app lock; link it from both store listings.
- [ ] Android release build declares no `INTERNET` permission (RUN-2), so the Play data safety form can say no data is collected.

## Phase 4 — Release
- [ ] Finish the one-time setup in `docs/RELEASING.md`.
- [ ] Exercise `release-ios.yml` and `claude.yml` once their secrets exist.
- [ ] Google Play: new personal developer accounts must run a closed test (at least 12 testers for 14 days) before production access. Confirm the current rule in Play Console and plan for the wait.
- [ ] `/release minor` → tag `v1.0.0` → Play internal testing + TestFlight.
- [ ] Store listings (screenshots, description, privacy policy URL, Play data safety form, App Store privacy labels), then promote to production.

## After v1
Receipt photo attachments, PDF report, home-screen widget, recurring notifications, subcategories, multiple currencies, more languages.
