# Roadmap

Goal: build the full v1 feature set first, then prepare and ship Monthly Expenses to Google Play, the App Store, and desktop stores. Behavior is defined in `docs/PRODUCT_RULES.md`; items cite its rule IDs. Group related items into larger PRs; CI must pass. Tick items in the same PR that completes them.

## Phase 0 — Tooling (done)
- [x] `CLAUDE.md`, `.claude/` settings, format hook, `/verify` and `/release` skills, `build-doctor` agent
- [x] Dependabot, release-signing scaffolding (`android/key.properties`, `ios/ExportOptions.plist`)
- [x] CI (checks + Android and iOS builds) green on GitHub
- [x] Repo public, with a `main` ruleset (PR + 3 required checks, no force pushes or deletion)
- [x] `release-android.yml` manual run without secrets (debug artifacts, nothing published)
- [x] GitHub Pages serving `docs/privacy-policy.md` at https://oasis-forge.github.io/monthly-expense-app/privacy-policy
- [x] Upgrade `fl_chart` 0.69 → 1.2 and `intl` → 0.20 (Dependabot PRs #2, #3)

## Phase 1 — Foundations (done)
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
- [x] Platform folders: keep `web/ windows/ linux/ macos/`. Desktop is a v1 target; web comes after v1 (decided 13 September 2026).

## Phase 2 — Features (in dependency order)
- [x] **Desktop:** Windows and Linux use `sqflite_common_ffi` with the database in the app support folder; macOS uses the sqflite plugin. Desktop builds run in CI on pushes to `main`. Editing a transaction offers a delete button, since a mouse can't swipe.
- [x] **Settings:** `SettingsProvider` on `shared_preferences` for currency (CUR-1–CUR-3), theme mode, and first day of month (PER-2, PER-3). Replaces the hard-coded `$` in `home_screen.dart`, `stats_screen.dart`, and `add_transaction_screen.dart`. First day of week (PER-4) moves to Insights, where the calendar uses it.
- [x] **Delete, undo, trash:** swipe delete with an Undo snackbar, a trash screen with restore, and a 30-day purge (DEL-2–DEL-4).
- [x] **Categories:** a screen to add, rename, reorder, change the icon of, and archive categories (CAT-3–CAT-5).
- [x] **Accounts and transfers:** accounts screen, account picker, transfers (schema step), account balances, and the carried-forward balance on Home (ACC-1–ACC-5, BAL-2, BAL-3).
- [x] **Faster entry:** keypad with `+` and `−`, smart defaults, "Save & add another", recent categories, date arrows both ways, duplicate, and the upcoming marker (ADD-2–ADD-8).
- [x] **Search and filters** (SRCH-1–SRCH-3).
- [x] **Budgets** (schema step): per-category and overall monthly budgets with per-day allowance and warnings; progress on Stats, over-budget marker on Home (BUD-1–BUD-6).
- [x] **Recurring** (schema step): rules, an Upcoming list that waits for a tap by default, and idempotent posting on app start (RCR-1–RCR-7).
- [x] **Backup, restore, export:** JSON backup of every table, Replace or Merge restore with an automatic safety backup, CSV export of the current view, and the backup reminder (BAK-1–BAK-7). Comes after the last schema step so the format covers every table.
- [x] **Insights:** calendar month view with daily totals and the first day of week setting (PER-4), a 6–12 month income vs. expense trend, and the category chart for any period (INS-1–INS-3).
- [x] **App lock:** the device's biometrics or screen lock through `local_auth` on Android, iOS, macOS, and Windows, with no app PIN (LOCK-1–LOCK-3). Linux has no app lock.
- [x] **First run:** Home empty state with one "Add your first transaction" action (RUN-1).

## Phase 3 — Store readiness (after Phase 2)
- [x] Display name "Monthly Expenses" on every platform: the Android label, the iOS and macOS bundle names, the Windows version info and window title, and the Linux window title.
- [x] Launcher icons (`flutter_launcher_icons`) and splash screen (`flutter_native_splash`), drawn by `tool/render_app_icons_test.dart`.
- [x] Store IDs, permanent after the first upload and free of personal names: `com.monthlyexpenses.app` on Google Play, the App Store, the Mac App Store, and the Microsoft Store; `io.github.monthly_expenses.MonthlyExpenses` on Flathub, verified through the `monthly-expenses` GitHub organization.
- [x] Privacy policy published at https://oasis-forge.github.io/monthly-expense-app/privacy-policy.
- [x] Update the privacy policy for accounts, backup and restore, CSV export, and app lock.
- [x] Android release build declares no `INTERNET` permission (RUN-2), so the Play data safety form can say no data is collected. `release-android.yml` fails if it ever does.
- [x] Desktop packaging: macOS sandbox entitlements, a Windows MSIX, and a Flatpak for Flathub, built by `release-desktop.yml`, with app icons and names for each. Mac App Store signing moves to Phase 4.

## Phase 4 — Notes, languages, widget, PDF report (before release)
Decided 13 September 2026: these ship in v1. Languages come first. After that, every PR that adds English messages also adds the other five languages (machine translation, LANG-6).
- [x] **Languages:** Turkish, Arabic, French, Spanish, and German, machine-translated from today's strings; language setting with System default (LANG-1); locale formats with machine-readable exports (LANG-3); case- and accent-insensitive search (LANG-4); right-to-left layout for Arabic (LANG-5); a CI check for missing messages and mismatched placeholders (LANG-2); overflow tests in every language (LANG-6). Add the translation step to `CLAUDE.md`.
- [x] **Notes** (schema step): notes with an optional due date, amount, and category; open and done lists whose filters and counts match the screen; "Record as transaction"; due notes in Home notices and on the calendar; local reminders that respect app lock; Undo and trash; backup and merge (NOTE-1–NOTE-8). Reminders use inexact alarms, so Google Play needs no exact-alarm permission, and are rescheduled after a reboot or a restore. The same setup can later serve recurring reminders.
- [x] **PDF report:** built on the device with embedded fonts for all six languages; preview, then share, save, or print; period, custom range, or year, with privacy options (PDF-1–PDF-6). Check that the PDF packages add no `INTERNET` permission (RUN-2).
- [x] **Home-screen widget:** an Android app widget and an iOS WidgetKit extension, fed by the provider after every change, with amounts hidden under app lock (WID-1–WID-6). The iOS extension needs an App Group and its own provisioning profile: update `release-ios.yml` and `docs/RELEASING.md`. The app sends finished strings and the days ahead on which they change, so neither widget reads the database or computes anything. Driven by hand on Android; the iOS half is only compiled by CI until there's a device to run it on.
- [x] **Import a CSV** (IMP-1–IMP-8): so someone arriving from another tracker can bring their history with them instead of starting empty. It reads our own export exactly, and for a foreign file it matches the columns by their headers and shows what it understood before writing anything; a file it can't make sense of is refused with a reason rather than half-imported. Unknown categories and accounts are mapped on that preview rather than created (IMP-7), and a row already in the app is skipped (IMP-8). Decided 14 September 2026, and it comes before the first-run page so "Import a CSV" can sit next to "Restore a backup" there.
  - Our competitor notes record the reference app exporting PDF/Excel and a local `.db`, not CSV, so **a real sample file is still wanted**: the generic matching is built and tested, but the reference app's own column names can only be added to the alias list once we've seen them. Until then a file of theirs is read on its merits like any other, and its columns can be corrected by hand on the preview.
- [ ] **First-run setup and walkthrough:** a setup page for language and currency with "Restore a backup" and "Import a CSV" (IMP-1), then a skippable walkthrough of up to four pages that Settings can replay (RUN-1, RUN-3–RUN-5). It replaces today's first-run welcome, and comes last so the walkthrough shows finished features.
- [ ] **Attach a per-architecture APK to the release instead of the universal one.** `flutter build apk --release` bundles `arm64-v8a`, `armeabi-v7a` and `x86_64` into one 71 MB file; measured on v1.5.0, each slice alone is 23–27 MB, and 95% of the file is native code built three times over. Play is unaffected — `release-android.yml` already ships an AAB and delivers only the matching slice — so this is only about the sideload build: attach `arm64-v8a` (25 MB) to the draft Release and build it in the `/release` skill, keeping the universal one only if a test device ever needs it. Under 30 MB it can also be sent straight to a phone.
- [ ] **Drop `cupertino_icons`** from `pubspec.yaml`: 258 KB of font in every build, and nothing in `lib/` references `CupertinoIcons` (the app's only Cupertino use is `GlobalCupertinoLocalizations`, which comes from `flutter_localizations`). It is the leftover default from `flutter create`.
- [x] Update the privacy policy for notes, the widget, and the PDF report.

## Phase 5 — Release
- [ ] Finish the one-time setup in `docs/RELEASING.md`.
- [ ] Exercise `release-ios.yml` and `claude.yml` once their secrets exist.
- [ ] Google Play: new personal developer accounts must run a closed test (at least 12 testers for 14 days) before production access. Confirm the current rule in Play Console and plan for the wait.
- [x] Every merged PR is a release: CI requires a SemVer bump and changelog entry, and `release-android.yml` tags the merge and attaches the APK to a draft GitHub Release. `v1.0.0` is the first.
- [ ] Play internal testing + TestFlight from a release, once the signing secrets exist.
- [ ] Store listings in all six languages (screenshots, description, privacy policy URL, Play data safety form, App Store privacy labels), then promote to production.
- [ ] Desktop releases: Mac App Store, Microsoft Store, and Snap Store or Flathub.

## After v1
Web version (needs a storage layer other than sqflite), receipt photo attachments, recurring notifications, subcategories, multiple currencies, desktop widgets.
