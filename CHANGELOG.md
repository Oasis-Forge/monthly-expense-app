# Changelog

Notable changes per release. Versions follow [Semantic Versioning](https://semver.org) and match `pubspec.yaml`. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

## [1.28.0] - 2026-09-25

### Added
- A Privacy policy row in Settings opens the published policy in the browser; Google Play and the App Store require it inside the app. The app itself still fetches nothing (RUN-2).

### Fixed
- A paying user got the ads back when the store listed no product (offline, a Play hiccup): what the account owns is now always asked (PAY-5).
- Left open past midnight, Home stayed on yesterday, so the morning's entries got the wrong day; it now moves on to today (DAY-1).
- An entry made today no longer leaves tonight's empty-day reminder scheduled, and posted or skipped due entries stop being announced (NUDGE-4).
- The empty-day reminder no longer switches itself off for people who record every day (NUDGE-5).

## [1.27.4] - 2026-09-25

### Fixed
- CSV import read this app's own export of a three-decimal amount as thousands: 12.345 KWD came back as 12,345 (IMP-2). Other files still read 1,234 as one thousand two hundred thirty-four.
- Merge let a later phone's untouched built-in defaults undo edits to them, such as a renamed Cash account or its opening balance. An edited record now beats an untouched one (BAK-3).
- On the desktop, attaching a photo deleted the original file; it now stays where it was (ATT-3).

## [1.27.3] - 2026-09-25

### Fixed
- Release builds opened with an empty Home: the resource shrinker dropped the notification icon, so notifications failed to start on every launch and stopped the data from loading. The icon is now kept, and a reminder that cannot be scheduled no longer stops loading or saving (NOTE-6, NUDGE-1).

## [1.27.2] - 2026-09-25

### Fixed
- In Arabic and Urdu, the import preview carried an amount's plus or minus to the far side of the row, away from the figures it belonged to.
- The Insights calendar and trend chart ran the currency into the number, showing `Rp1,2 rb` beside a total of `Rp 1.235` on the same screen.
- The PDF report signed its amounts differently from every screen in the app.
- Currencies written as a letter and a sign together, such as `R$`, were given a space between symbol and number that they should not have.
- On the Recurring screen, the row for something due kept the currency symbol on the opposite side from the rows beneath it.

## [1.27.1] - 2026-09-24

### Fixed
- In Arabic the currency symbol sat on the wrong side of the amount, in English order rather than Arabic. In Urdu and Indonesian the currency ran straight into the number: `Rs3,347,380` where it should read `Rs 3,347,380`.
- The Recurring screen no longer contradicts itself: nothing is called "next" while something is already overdue. Its three lists now start at the same left edge and each row carries its category's colour, and the Skip and Post buttons have moved out from under the date, which had left the row looking like a staircase.

## [1.27.0] - 2026-09-24

### Fixed
- Reminders now actually arrive. Both the note reminder and the daily "nothing recorded today" nudge were being scheduled and then silently dropped on every Android phone, because the app was missing an Android setting reminders need in order to fire. Reminders now also survive a restart of the phone, and show the app's own icon instead of a blank outline.

### Changed
- The app now asks whether you want the daily reminder before it asks Android for notification permission, so saying no costs you nothing. It also now tells you plainly that your phone may deliver a reminder a few minutes late.

## [1.26.0] - 2026-09-24

### Added
- The Theme setting has a fourth choice, Black: dark with a true black background, for OLED screens.
- On Android 12 and later, the app takes its colours from your phone's wallpaper, with no setting to turn on. Where the phone offers no palette, the app's own purple is used. The colours that carry meaning stay put: income stays green, expense stays red, and category colours stay themselves.
- On Android, when Google Play has a newer version waiting, the app offers it after you save an entry: the update downloads in the background while you keep working, and a Restart button finishes it. At most once a day, and it never blocks the app.

### Changed
- The Recurring screen, when it has no rules yet, now says what the screen is for and offers the button that adds the first one. The Notes empty screen moved to the same shape.
- The trend now says when it needs more than one period, instead of drawing a line through a single one.

## [1.25.0] - 2026-09-24

### Added
- Long-pressing the app's icon now offers the three things you are most likely to want: add expense, add income, transfer. They are worded in whatever language the app is set to.
- Once you have been using the app for a while, it asks — once, through the store's own sheet — whether you would rate it. It never asks before you have fifteen entries and a week behind you, never twice for the same version, and never on top of anything else.

## [1.24.0] - 2026-09-24

### Added
- The spending chart now says how the month compares with the one before it: a line under the total saying how much more or less you have spent than last month, and, on each category, the share it has risen or fallen by. A category you had nothing in last month is marked "new" rather than given a percentage. Your first month has nothing to compare itself with and shows neither.

## [1.23.1] - 2026-09-24

### Fixed
- Russian counted wrongly at twenty-one. Because of the way plural rules work in Russian, numbers ending in 1 — 21, 31, 41 — were shown the wording meant for a single item: twenty-one search results read as "1 результат", and a repeating entry set to every 21 days described itself as "every day". Every counted message in the app now reads correctly at those numbers, in all twenty-one languages.

## [1.23.0] - 2026-09-24

### Added
- The Recurring screen now opens with what your repeating expenses come to in a month — a weekly, monthly or yearly rule all worked out as a monthly figure — and which one falls next, in days.
- The Accounts screen now ends with what all your accounts come to together.
- The app answers your finger: the keypad ticks under each key, saving gives one firmer knock, and a swipe tells you the moment letting go would delete the row. It follows your phone's own vibration setting and adds nothing to switch on.

### Changed
- Amounts no longer carry `.00` when there is nothing after the point: a round figure now reads $930 rather than $930.00, while $12.50 is unchanged.
- Amounts are now set in figures of one width, so a column of them lines up and a figure that changes no longer nudges the text beside it.
- Money in and money out have new colours, chosen to stay readable on a light and a dark background alike — the old red was hard to read at night. A balance, a net or an account is now left plain unless it is below zero.
- The number at the top of Home counts to its new value when an entry is saved, rather than cutting to it.

## [1.22.0] - 2026-09-22

### Added
- Every category now has a colour of its own, one of sixteen you pick in the category editor. The spending chart, the list beside it and every row that shows a category all use it, so a category is recognised before it is read — and it keeps that colour whether or not it was your biggest expense this month.
- The top of Home now leads with the number you open the app for. With a monthly budget it is what is left to spend and what that comes to a day; without one it is what you have spent so far and what that has come to a day, with a way to set a budget that starts from what you spent last month.

### Fixed
- If you had bought "Remove ads", the app could still start the ad service for a moment when it launched, and the first time it could ask you to agree to ads you were never going to see. It now waits to hear from the store before anything starts.

## [1.21.0] - 2026-09-20

### Changed
- The full-screen ad is earned by using the app rather than by the clock. Ten things done in a day — an entry saved, or a screen opened — and the next natural break shows one, after which the count starts again. A quiet day passes without any, and nothing at all appears during the session that installs the app.

## [1.20.0] - 2026-09-20

### Changed
- The full-screen ad no longer waits three days after you install the app. Ten recorded entries is the only thing it waits for now.

## [1.19.0] - 2026-09-20

### Added
- Reminders. The app can tell you when a repeating entry was due and is still waiting, and, if you ask it to, nudge you on a day you have recorded nothing at all. One reminder a day at most, never between ten at night and eight in the morning, and the nudge stops itself if three go unanswered.

### Changed
- Android no longer backs this app up to Google Drive on its own. Reinstalling the app now starts you with nothing, and the way to carry your data over is a backup you saved yourself. Moving to a new phone still brings it with you.

## [1.18.0] - 2026-09-20

### Changed
- A full-screen ad can now appear once a day, and only where something has just finished: leaving Insights, or after a report, an export or an import. It never interrupts an entry, never appears in the app's first three days, and never keeps you waiting for it.

## [1.17.4] - 2026-09-20

### Changed
- Nothing you can see in the app: a roadmap note, recording that 1.17.2 reached Play's internal testing and that signing and uploading from CI is not planned any more.

## [1.17.3] - 2026-09-20

### Changed
- Nothing you can see in the app: releases are built and uploaded by hand now, so nothing is tagged, built or published automatically when a change lands.

## [1.17.2] - 2026-09-20

### Added
- Home can show one account instead of all of them. Tap the wallet on the summary card and pick it: the totals, the day list and each day's own income and expense are that account's alone, and the card's label says which one you are looking at. The choice is still there next time you open the app.
- With one account showing, a new entry starts on it, so recording a card payment from your card's Home no longer means changing the account every time.

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
