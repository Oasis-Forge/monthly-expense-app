# Changelog

Notable changes per release. Versions follow [Semantic Versioning](https://semver.org) and match `pubspec.yaml` and the `vX.Y.Z` git tags. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

## [1.3.0] - 2026-09-14

### Added
- A PDF report of your spending, from the Home menu, Insights, or Search: the period, dates you pick, or a whole year, and one account or all of them.
- The report opens with income, expense, net, and the balances either side, then spending and income by category with each share and budget, a trend, and the entries day by day, with anything dated ahead listed apart.
- Before creating it you can leave out the transaction list, the titles and notes, or the account names, so a report can be shared without the whole picture.
- The report is built on your device with no internet connection, shown to you first, and shared, saved, or printed only if you then choose to.
- It follows the app's language and formats, reads right to left in Arabic, and comes on A4 or US Letter with numbered pages.

### Fixed
- Turning app lock on now hides the text of note reminders that were already scheduled, instead of waiting for the next launch.
- Undoing the deletion of a transaction recorded from a note marks that note done and linked again.

## [1.2.0] - 2026-09-14

### Added
- Notes: text with an optional due date, amount, and category; open notes list overdue first, Done notes collapse below, and search combines with Open, Done, and due-date filters.
- "Record as transaction" fills the add form from a note's amount, category, and text, marks the note done, and links the two; deleting that transaction reopens the note.
- A reminder notification at a chosen time on a note's due date, asking for notification permission only the first time one is set; with app lock on, the notification names only the app, and tapping it opens the note through the lock.
- Open notes due in the selected period show a Home notice, and the Insights calendar marks the days they're due.

## [1.1.0] - 2026-09-13

### Added
- Turkish, Arabic, French, Spanish, and German, with a language setting that follows the device by default.
- Arabic reads right to left, while amounts and the keypad stay left to right.
- Search ignores case and accents in every language, including the Turkish ı and İ and Arabic vowel marks.

### Changed
- Language, theme, and the first day of the month and week open their choices in a dialog, so long names always fit.

### Fixed
- With large text, the budget rows in Insights and the due rows in Recurring no longer overflow.

## [1.0.1] - 2026-09-13

No changes to the app.

### Changed
- Plan: notes, Turkish, Arabic, French, Spanish, and German, a home-screen widget, a PDF report, and a first-run setup page with a walkthrough now come before the first store release.

## [1.0.0] - 2026-09-13

First release. All data stays on the device; no account, ads, or tracking.

### Added
- Income and expenses with categories, accounts, and transfers between accounts.
- Monthly periods with a chosen first day, balances carried forward, and daily totals.
- Faster entry: amount keypad with + and −, recent categories, save and add another, duplicate.
- Search and filters, budgets with over-budget notices, and recurring transactions.
- Insights: spending by category, a calendar, and trends.
- Backup and restore (merge or replace) with automatic backups, and CSV export.
- App lock with the device's biometrics or screen lock.
- Trash with undo; deleted items are removed after 30 days.
- Settings for currency, theme, first day of the month, and first day of the week.
- Runs on Android, iOS, macOS, Windows, and Linux.
