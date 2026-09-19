# Changelog

Notable changes per release. Versions follow [Semantic Versioning](https://semver.org) and match `pubspec.yaml` and the `vX.Y.Z` git tags. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

## [1.17.1] - 2026-09-20

### Added
- The budgets card folds away while you scroll the list, and comes back at the top exactly as you left it.

### Changed
- The budgets card is the width of the summary card above it, so Home reads as one column.

### Fixed
- Scrolling Home no longer fights the list. The summary card used to take its room from the list itself, which pulled the entries upward faster than your finger and, when there was little to scroll, sprang the card open again — most visible with a budget set. The card is now part of the list's own scrolling.

## [1.17.0] - 2026-09-19

### Added
- Home opens on the current day, with a week of days above the list: tap a day to see it on its own, swipe sideways for other weeks, and a day carrying an entry shows a dot. Each day now shows its own income and expense beside its date.
- A three-dot menu on every transaction row, on Home, in Search and in the calendar, with Duplicate and Delete. Deleting from the menu asks first, and says the entry can be restored from the trash for 30 days.
- The summary card collapses to a single line with your balance, by a tap or while you scroll the list, and opens again at the top. It keeps the way you left it.

### Changed
- A new transaction or transfer starts on the day Home is showing, instead of always today. Tapping the chosen day again brings back the whole period's list.
- Leaving a form no longer loses what you typed: Back closes the keypad first, and then asks before anything is discarded.

### Fixed
- A deleted transfer can be got back. The trash now lists transfers beside transactions, and keeps them when the app restarts; before, only the Undo snackbar could bring one back.

## [1.16.0] - 2026-09-18

### Added
- A budgets card on Home: one line with how much of your budget is used and how many budgets are over. Tap it to see each budget's bar and share used, and open Insights for the details.

### Changed
- The budgets card replaces the "over its limit" notice on Home.
- Budget bars in Insights also show the share of each budget used.

## [1.15.1] - 2026-09-18

### Fixed
- Backing out of the Remove ads payment sheet no longer leaves the screen waiting for the store; the price comes back at once.
- In Arabic, the Arab currencies use their Arabic symbols (ر.س., د.إ., ج.م. and others) instead of Latin ones, and in Arabic and Urdu every amount keeps the same order on every screen.
- The banner ad sits on the bottom edge with no blank space around it, and "Remove ads" sits right above it.

## [1.15.0] - 2026-09-18

### Changed
- A new app icon: a budget ring around a small bar chart, on a deeper purple, on every platform, with splash screens to match.

### Fixed
- The trend chart no longer labels the top of its amount axis, where the label could sit on the gridline label just below it, and its axis labels stay on one line in every currency.

## [1.14.0] - 2026-09-18

### Added
- The ads are live: a banner at the bottom of Home and of Insights, served from the app's own ad account rather than Google's placeholder ads. "Remove ads" still takes every one of them away for good.

## [1.13.0] - 2026-09-18

### Fixed
- On Android, 1.12.0 closed as soon as it was opened. The part of the build that shrinks the app removed something Google's ad library needs at startup; it is kept now. Only the released version was affected, and it never reached a store.

### Changed
- The app's permanent store identity is now `com.oasisforge.monthlyexpenses`, under the Oasis Forge name that every future app will share. It is set before the first store upload, which is the last moment it can change.
- **If you installed an earlier test build, this one installs as a separate app** rather than updating it, because the identity is different. Make a backup in the old one (Settings → Backup & restore), install this one, and restore it there; then the old one can be removed.

## [1.12.0] - 2026-09-17

### Added
- Banner ads at the bottom of Home and Insights. They are the only reason the app uses the internet, and they never see anything you record — no amounts, titles, notes, categories, accounts or attachments.
- **Remove ads:** one payment hides every ad for good, on every device signed in to the same store account, with "Restore purchases" beside it. Nothing else changes, and every feature stays free with or without it.
- A Plus page that says what is coming — a bank connection that brings transactions in for you to confirm — with no price and no way to buy it until it works.
- **Settings → Privacy options**, where the law asks for it, to change your answer about personalised ads at any time.

### Changed
- The privacy policy now describes the ads in full: what Google receives in order to choose one, what it never receives, and that buying "Remove ads" stops the ad software from starting at all.
- The first-run walkthrough no longer says "no ads". It says what is true: no account, what you record stays on the phone, and the ads that pay for the app never see it.
- A slot reserves its height before it asks for an ad, sits outside the scrolling list and below the add button, shows nothing at all when empty, and loads nothing while the app is locked.

## [1.11.0] - 2026-09-17

### Added
- Fifteen more languages: Bengali, Chinese (Simplified), Dutch, Greek, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Thai, Urdu and Vietnamese. With the six it already had, the app now speaks 21, and picks yours from the phone's own settings unless you choose one.
- Urdu, like Arabic, reads right to left throughout — the drawer, lists, charts and the date arrows — while amounts and the keypad stay left to right.
- Importing a CSV recognises column names, and the words for income, expense and transfer, in all 21 languages.

### Changed
- The PDF report carries fonts for Hindi, Bengali and Thai as well, and leads with the one your language needs, so a Latin account name in a Hindi report still prints.
- In Chinese, Japanese and Korean the report isn't offered yet, and says why: the font for those scripts is 10 to 18 MB, which would more than double the app's download. A later version will offer it as a one-time download instead.

## [1.10.0] - 2026-09-17

### Added
- Tapping an expense or an income opens it to read rather than to edit: the amount and its kind, the category, account, date and note, any photo or voice note, and when it was added and last changed. A pencil opens the form you already know, with Duplicate and Delete beside it.

### Changed
- A tap on a row no longer drops you straight into the edit form, so nothing changes by accident while you are only looking. Transfers still open their own form.

## [1.9.0] - 2026-09-17

### Added
- The drawer now names every part of the app, in five groups: Add expense, Add income and Transfer; Budgets, Recurring and Notes; Spending by category, Calendar, Trend and Search; Accounts, Categories and Settings; both exports, Backup & restore and Trash. Accounts and Categories used to be reachable only through Settings, and the calendar and the trend only through Insights and then a tab.
- Add expense and Add income open the form already set to that kind, so recording one is two taps from anywhere.
- A settings button at the top right of the home screen.

### Changed
- The insights button has left the home screen's toolbar to make room for that settings button: the drawer names its three views separately, and tapping the month still opens the calendar for it.

## [1.8.1] - 2026-09-17

### Fixed
- The Linux build works again. A library the voice-note playback needs was missing from the build machine, so every Linux build since voice notes arrived had failed. Nothing in the app itself changed.

## [1.8.0] - 2026-09-17

### Added
- A navigation drawer holds everything that isn't Home — transfers, budgets, recurring, notes, insights, search, the exports, backup, settings and trash — grouped and named, in place of the three-dot menu.
- Tapping the month on the home screen opens the calendar for it.

### Changed
- "Restore a backup" and "Import a CSV" moved from the first setup page to the last page of the walkthrough, so setup only asks for your language and currency. Restoring says first that it brings back the language and currency saved in the backup.
- The app is a little smaller: an icon font nothing used has gone.
- The public documentation no longer names or links to the other app that was studied before this one was designed. The research and the reasoning stay; the name, the store link and its prices are gone.

## [1.7.1] - 2026-09-17

### Changed
- No change to the app itself. This release records decisions taken on 17 September 2026: banner ads in two places, fifteen more languages, a navigation drawer in place of the three-dot menu, tapping the month to open the calendar, and moving "Restore a backup" and "Import a CSV" off the setup page onto a last walkthrough page.
- Also recorded: removing the ads will be a one-time purchase, while Plus — shown as "coming soon" until it works — will be a yearly or monthly subscription that connects to your bank through an open-banking provider, with free notification reading on Android for banks no provider reaches. Either way, what arrives is a proposal you confirm.

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
