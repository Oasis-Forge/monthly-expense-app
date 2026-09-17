# Changelog

Notable changes per release. Versions follow [Semantic Versioning](https://semver.org) and match `pubspec.yaml` and the `vX.Y.Z` git tags. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

## [1.7.1] - 2026-09-17

### Changed
- No change to the app itself. This release records decisions taken on 17 September 2026: banner ads in two places, fifteen more languages, a navigation drawer in place of the three-dot menu, tapping the month to open the calendar, and the walkthrough coming before the setup page.

## [1.7.0] - 2026-09-17

### Added
- A first launch now opens a setup page for your language and currency, with "Restore a backup" and "Import a CSV" as the way in from another phone or another app.
- A four-page walkthrough after setup: quick entry, planning, insights and privacy. Every page can be skipped, and Settings can play it again.

### Changed
- Restoring a backup during setup brings its settings and goes straight to your data, skipping the walkthrough.

## [1.6.0] - 2026-09-16

### Added
- Attach a photo to a transaction, taken with the camera or chosen from your photos, and a voice note of up to a minute recorded in the app. Both stay on your device.

### Changed
- A backup that has attachments is now a zip holding the same data plus those files. Backups without attachments stay a plain JSON file, and both kinds restore.

## [1.5.1] - 2026-09-15

### Fixed
- The privacy policy, help, and bug tracker links point to the project's new home on GitHub; the old privacy policy address no longer opened.

## [1.5.0] - 2026-09-14

### Added
- Import a CSV, in Backup & restore: bring your history over from another tracker instead of starting empty. It only adds records, and never replaces or deletes what you already have.
- Before anything is added you see what the app made of the file: which column it read as the date, the amount, the type, the category, the account, the title, and the note — and you can change any of them.
- It says how many rows will be imported and how many were skipped, with a reason for each, and shows the first rows as it read them.
- Column names are matched in all six languages, and dates and amounts are read in the usual formats. A file with no date or amount column is refused with a reason instead of being half-imported.
- A category or account named in the file that the app hasn't got is chosen once on that page. Importing never creates categories or accounts.
- A row you already have — same date, amount, type, and title — is skipped, so importing the same file twice doesn't double anything.

## [1.4.0] - 2026-09-14

### Added
- A home-screen widget, in two sizes: a small one with this period's spending, or what's left of your budget when you've set an overall one, and a wider one with income, spending, the balance, and the budget left.
- Both have an Add expense button, and the wider one adds Add income; tapping the numbers opens the app on the current period.
- The widget always shows the current period, whatever the app was last left on, and keeps up as the day turns even if you don't open the app.
- It follows the app's language, currency, and your device's light or dark theme, and reads right to left in Arabic.
- With app lock on the widget shows only its buttons, and the amounts aren't given to it at all. A new setting, "Show amounts on the widget", puts them back.

## [1.3.1] - 2026-09-14

### Fixed
- In an Arabic report, anything written in Latin letters — the app's name, the currency, and any category, account, or title you typed that way — came out backwards. It reads forwards now.
- Amounts in an Arabic report no longer show a stray speck in front of the number.

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
