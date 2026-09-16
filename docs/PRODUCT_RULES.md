# Product rules

_13 September 2026._

This file defines how Monthly Expenses behaves: the calculations, defaults, and edge cases behind each screen. Each section says what the competitor does (see `docs/research/competitor-analysis.md`), what we take from it, and our rule. We learn from their app; we don't copy its rules.

- Rule IDs (`MONEY-1`) are stable. Tests and PRs reference them.
- "Not verified" marks competitor behavior we saw only partly.
- Every rule keeps the product principles in `CLAUDE.md`: no ads, no tracking, no account, and data leaves the device only when the user exports it.

## 1. Data foundations

**Today:** `amount` is a `REAL` (floating point), `category` stores the display name, `title` is required, and deleting removes the row.

**Learn:** rounding errors, category renames, translations, undo, trash, and backup merge all depend on getting these right before any user data exists.

- **MONEY-1** Amounts are stored as integers in thousandths of a unit (`12.50` → `12500`), so sums never drift. This fits every ISO currency (0, 2, or 3 decimals), and changing the currency never rescales stored values.
- **MONEY-2** Amounts are always positive; the transaction type carries the sign. Zero is rejected.
- **CAT-1** Transactions reference a category by a stable ID. Default category names are translatable labels, and renaming a category changes every transaction that uses it.
- **DATE-1** A transaction has a local calendar date and an optional time. It belongs to the period of the date the user picked, whatever time zone the phone is in later.
- **DEL-1** Deleting sets `deleted_at`; it doesn't remove the row. Undo, trash, and backup merge build on this.
- **REC-1** Every record has `created_at` and `updated_at`.
- **REC-2** Every record ID is a UUID v4, so records from a backup never collide with records on the device. Built-in defaults (the default categories and the Cash account) use fixed IDs instead, so the same default matches across devices when backups merge.

## 2. Periods

**They do:** month navigation plus settings for first day of the week, month, and year, and a default period. How those settings move totals and budgets: not verified.

**Learn:** people paid on the 25th think in "25th to 24th" months. The setting only helps if every screen uses it the same way.

- **PER-1** A period runs from its start date up to, but not including, the next start date. One function computes periods; Home, Stats, Budgets, and Calendar all use it.
- **PER-2** First day of month is 1–28 or "last day of month", so a start day never falls outside a short month.
- **PER-3** When the start day isn't 1, the period label shows both dates ("25 Aug – 24 Sep"), never just a month name.
- **PER-4** First day of week follows the device locale until the user changes it.

## 3. Adding a transaction

**They do:** the calculator keypad opens on the amount; a basic expense is about 4 taps; after Save the form stays open and keeps the category and payment method; recent categories; copy; note suggestions; time; receipt photos; line items.

**Learn:** speed matters most. Each extra field (payment method, line items) slows the common case.

- **ADD-1** Only amount and category are required. Title and note are optional. A list row shows the title, else the note, else the category name.
- **ADD-2** The keypad supports `+` and `−` (`12.5+3`), shows the result live, and saves the result.
- **ADD-3** A new transaction defaults to today, the chosen type, the last category used for that type, and the last account used.
- **ADD-4** "Save & add another" keeps the type, category, account, and date, clears the amount, title, and note, and focuses the amount.
- **ADD-5** Recent categories show the last 5 used for the chosen type.
- **ADD-6** The date arrows move one day back or forward; tapping the date opens a picker.
- **ADD-7** Duplicate copies everything except the ID and sets the date to today.
- **ADD-8** Future dates are allowed. The row is marked as upcoming until its date arrives (BAL-4).

## 4. Categories

**They do:** 61 expense and 7 income categories with icons, custom categories, and subcategories (off by default).

**Learn:** a long default list slows every entry, and most users never trim it.

- **CAT-2** About 15 defaults: 10 expense and 5 income.
- **CAT-3** Users can add, rename, reorder, change the icon of, and archive categories.
- **CAT-4** A category that has transactions can't be deleted, only archived. An archived category is hidden from pickers and still shows in history and reports.
- **CAT-5** No subcategories in v1.

## 5. Balances

**They do:** income, expense, and balance for the period, an optional carried-forward "previous balance", and an optional running balance on each row. Whether the carried-forward balance covers one account or all accounts: not verified.

**Learn:** the carried-forward balance answers "how much do I have?", not just "how did this month go?".

- **BAL-1** Period net = income − expense within the period. Transfers are excluded.
- **BAL-2** Carried forward = account opening balances + the sum of every net before the period start.
- **BAL-3** Closing balance = carried forward + period net. Showing the carried-forward balance is a setting, on by default.
- **BAL-4** A future-dated transaction counts nowhere until its date arrives: not in totals, balances, charts, or budgets. It shows in the list as upcoming and starts counting on its date.
- **BAL-5** Deleted (trashed) transactions count nowhere: totals, charts, budgets, search, or export.

## 6. Accounts and transfers

**They do:** accounts have only a name, and the default account carries the app's name. Transfers are a quick action. Payment methods (bank, card, cash) are a separate concept.

**Learn:** "account" and "payment method" overlap and confuse; one concept is enough.

- **ACC-1** One concept: an account has a name, a type (cash, bank, card, other), an opening balance, and an opening date. Every transaction belongs to exactly one account.
- **ACC-2** The default account is "Cash" and can be renamed.
- **ACC-3** A transfer is one record with from and to accounts. It changes both account balances and is never income or expense.
- **ACC-4** Account balance = opening balance (from its opening date) + income − expense − transfers out + transfers in, up to today (BAL-4). Transactions dated before the opening date still count, so the opening balance should be the balance on that date before them.
- **ACC-5** An account with history can be archived, not deleted.

## 7. Budgets

**They do:** per-category budgets (weekly, monthly, yearly) showing budget, spent, remaining, and a per-day allowance, plus "import from last month". The allowance formula: not verified.

**Learn:** the per-day allowance is the most actionable number. The import button exists because budgets don't carry over.

- **BUD-1** Monthly budgets per category, plus an optional overall budget, aligned to the period (PER-1).
- **BUD-2** Spent = the category's expenses in the period (BAL-4 applies). Remaining = limit − spent.
- **BUD-3** Per-day allowance = remaining ÷ days left in the period, including today. It shows only for the current period and never goes negative; when over, show the amount over instead.
- **BUD-4** At 80% of the limit the budget shows a warning; at 100% it shows over budget.
- **BUD-5** A budget repeats every period until the user changes or removes it. A change applies from the current period onward; past periods keep their limits.
- **BUD-6** Past periods show the final result; future periods show the limit only.

## 8. Recurring transactions

**They do:** daily to yearly repeats; ends never, after N times, or on a date; pause; an "add automatically" setting on by default; a list of upcoming dates. When occurrences post, whether missed ones catch up, and what editing a rule does: not verified.

**Learn:** automatic posting suits fixed amounts (rent) but creates wrong entries for amounts that vary (electricity).

- **RCR-1** A rule has an amount, category, account, title, note, frequency (day, week, month, or year) with an interval ("every 2 weeks"), a start date, and an end: never, after N times, or on a date.
- **RCR-2** Each rule chooses confirm or auto-post. Confirm is the default: due items wait in Upcoming, where one tap posts them and the amount can be edited first.
- **RCR-3** A monthly rule anchored on the 29th–31st uses the last day in shorter months and returns to its anchor afterwards (31 Jan → 28 Feb → 31 Mar).
- **RCR-4** On app start, every due occurrence up to today is posted or queued exactly once. Each occurrence is keyed by rule ID and date, so reopening the app or merging a backup never duplicates it.
- **RCR-5** Editing a rule changes future occurrences only. Deleting a rule keeps the transactions it already posted.
- **RCR-6** Occurrences due while a rule is paused are skipped, not caught up on resume.
- **RCR-7** Upcoming shows the next 30 days. Notifications come later.

## 9. Delete, undo, and trash

**They do:** a confirmation dialog, then the item goes to a trash.

**Learn:** undo is faster than a confirmation dialog and just as safe.

- **DEL-2** Delete needs no confirmation. A snackbar offers Undo for about 5 seconds.
- **DEL-3** Deleted items stay in the trash for 30 days, then get purged on app start.
- **DEL-4** Restore keeps the original ID, date, and category. If the category was archived in the meantime, the transaction still restores.

## 10. Search and filters

**They do:** keyword search, filters by category, payment method, and type, sorting, and search scoped to notes or amount. Search reliability: not verified.

- **SRCH-1** Search matches the title, note, category name, account name, and amount (`12.5` finds `12.50`). It ignores case and accents and updates as the user types.
- **SRCH-2** Filters (type, category, account, date range) combine with AND. Search covers all time unless a date range is set.
- **SRCH-3** Results show the count and the income and expense totals of the matches. Upcoming matches are listed but not counted in the totals (BAL-4).

## 11. Backup, restore, and export

**They do:** backup as a raw database file or to Google Drive, PDF and Excel reports, a Google Drive prompt on first launch, and an "email statement automatically" setting that is on by default. What that setting sends: not verified.

**Learn:** a raw database file breaks across schema versions. Defaults that send data off the device conflict with our principles.

- **BAK-1** Backup records the app version and schema version as JSON, saved or shared only when the user chooses to; when there are attachments it is a zip holding that JSON and the files (ATT-6).
- **BAK-2** Restore offers Replace (the backup replaces all current data and settings) or Merge (BAK-3). Before either, the app saves an automatic backup of the current data. The device keeps the five most recent automatic backups, and any of them can be restored.
- **BAK-3** Merge matches every record by ID (REC-2). Records only in the backup are added. When both sides have a record, the one with the later `updated_at` wins, including deletions (DEL-1). Transactions, categories, accounts, budgets, and recurring rules all merge this way. Records that differ only in their timestamps count as unchanged. An occurrence handled on both sides keeps this device's record, and the backup's transaction for it is left out, so a recurring transaction never posts twice (RCR-4). Budget versions from the same period start go by the one saved last. Merge keeps this device's settings. The app then shows how many records were added, updated, and unchanged.
- **BAK-4** A backup from a newer schema is refused with a message to update the app. Older backups are migrated with the app's own schema steps before Replace or Merge.
- **BAK-5** CSV export covers the current view (period and filters), with ISO dates and plain decimal amounts. Text that a spreadsheet would run as a formula (starting with `=`, `+`, `-`, or `@`) gets a leading apostrophe.
- **BAK-6** Nothing leaves the device without an explicit user action. No cloud sync, no scheduled email.
- **BAK-7** A backup reminder appears only after 20 transactions, then at most every 30 days since the last backup, and can be turned off. Dismissing it also waits 30 days. Never within a day of first opening the app.

## 12. Currency and formatting

**They do:** only a number-format choice; no currency symbol.

- **CUR-1** One currency for the whole app in v1, chosen from a searchable ISO list and preselected from the device locale.
- **CUR-2** Amounts are formatted with `intl` for the device locale and the currency's decimals (JPY 0, USD 2, KWD 3).
- **CUR-3** Changing the currency changes labels only, never values. The app warns before applying it.

## 13. First run and trust

**They do:** open straight to Home with a Drive backup prompt and a banner ad; the default account uses the app's name.

**Learn:** the first launch should settle what the device can't tell us for sure, the language and the currency, on one screen, and explain the app without delaying the first entry. Asking for an account, permissions, or cloud backup up front costs trust.

- **RUN-1** After setup (RUN-3) and the walkthrough (RUN-4), an empty Home shows one clear "Add your first transaction" action.
- **RUN-2** The Android release build declares no `INTERNET` permission while the app has no feature that needs it, so the store listing can truthfully say "no data collected".
- **RUN-3** The first launch opens one setup page with the language (LANG-1) and the currency (CUR-1), both preselected from the device locale, so most people only tap Continue. Picking a language switches the page at once. The page asks for nothing else: no account, no permissions, no cloud backup. A secondary "Restore a backup" action restores a backup file with Replace (BAK-2), which brings its settings, and skips the walkthrough.
- **RUN-4** A walkthrough of up to four pages follows: quick entry, planning (budgets, recurring, notes), insights and reports, and privacy (data stays on the device, backups, app lock). Every page has Skip, and the last one opens Home. It runs right to left in Arabic (LANG-5), respects the device's reduce-motion setting, and can be replayed from Settings.
- **RUN-5** Setup shows until it's finished. The walkthrough shows once, even when skipped. An app update on a device that already has data skips both and keeps the current settings.

## 14. Insights

**They do:** a calendar view and charts. How periods and future-dated entries affect them: not verified.

**Learn:** a calendar and a trend only help if they use the same periods and counting rules as Home.

- **INS-1** The calendar shows the selected period as a month grid with each day's expense and income. Weeks start on the first day of the week (PER-4). Upcoming days show their amounts faintly, because they don't count yet (BAL-4). Tapping a day lists its transactions and transfers.
- **INS-2** The trend shows income and expense for the last 6 or 12 periods, ending with the selected one. Only entries that count are included (BAL-4), and the averages leave out periods that haven't started.
- **INS-3** The category chart works for any period and shows expense or income, with budget progress for expense (BUD-2).

## 15. App lock

**They do:** not verified.

**Learn:** an expense app holds private data, but a forgotten app PIN would lock people out of their own records.

- **LOCK-1** App lock is off by default. It uses the device's own biometrics or screen lock (fingerprint, face, PIN, pattern, or password), so the app never stores a PIN. Turning it on or off asks for authentication first.
- **LOCK-2** With app lock on, the app asks at launch and again after at least a minute in the background, and hides its content until unlocked.
- **LOCK-3** If the device no longer has biometrics or a screen lock, app lock turns itself off instead of locking the data away.

## 16. Languages

**They do:** 16 languages. Translation quality, right-to-left layout, and number formats in those languages: not verified.

**Learn:** a translated app only feels native when numbers, dates, plurals, search, and layout direction are right too. A cut-off label or a half-translated screen looks broken.

- **LANG-1** The app is in English, Turkish, Arabic, French, Spanish, and German. It follows the device language and falls back to English. The setup page (RUN-3) and Settings list the six languages, each in its own language, and Settings also offers "System default". A change applies at once, without a restart.
- **LANG-2** Every user-facing text comes from the ARB files: screens, notices, errors, default category and account names (CAT-1), the widget, and the PDF report. CI fails when a language is missing a message, or when its placeholders, plurals, or selects differ from English. Plurals and variable parts use ICU messages, never pieced-together strings.
- **LANG-3** Dates, numbers, and amounts follow the chosen language's format (CUR-2), and the first day of the week keeps following PER-4. CSV exports and backups always use ISO dates and plain decimals with a `.`, whatever the language (BAK-5), so the files read the same everywhere.
- **LANG-4** Search ignores case and accents in every language, including the Turkish dotted and dotless i: `istanbul` finds "İstanbul" and `cafe` finds "Café" (section 10).
- **LANG-5** In Arabic the layout runs right to left: navigation, lists, swipe actions, charts, and the date arrows (ADD-6), whose "earlier" arrow points right. Amounts and keypad expressions (ADD-2) stay left to right inside Arabic text.
- **LANG-6** Translations are machine-made: a change that adds or edits English messages adds the other five languages in the same PR, with no separate review step. Widget tests render the main screens, the add form, setup, and the walkthrough in all six languages, on a phone-size screen at 1.3× text size, and fail on overflow.

## 17. PDF report

**They do:** PDF and Excel reports. Their contents and options: not verified.

**Learn:** people send a report to a partner, an accountant, or a landlord, so it has to make sense without the app, look right in every language, and leave the device only when the user sends it (BAK-6).

- **PDF-1** "Export PDF" in the Home, Insights, and Search menus creates a report for the selected period, a custom date range, or a whole year, optionally for one account. From Search, the current filters apply, as with CSV (BAK-5).
- **PDF-2** The report opens with a summary: income, expense, net, and the opening and closing balance (BAL-2, BAL-3). Then come spending by category with amounts, shares, and budget progress (BUD-2); a trend by day, or by period for ranges longer than two periods (INS-2); and the transactions grouped by day, with transfers marked. Entries that don't count yet appear in a separate Upcoming list, outside the totals (BAL-4).
- **PDF-3** Before creating it, the user can leave out the transaction list, titles and notes, or account names. The header shows the app name, the range (PER-3), the currency, and when the report was created. No watermark, no promotion.
- **PDF-4** The report is built on the device without a network connection and previewed, then shared, saved, or printed only when the user chooses (BAK-6, RUN-2).
- **PDF-5** It uses the app language and formats (LANG-3), runs right to left in Arabic, and embeds fonts that cover all six languages. Pages are A4, or US Letter in regions that use it, with page numbers and table headers repeated on every page.
- **PDF-6** A year with thousands of transactions builds without freezing the app, shows progress, and can be cancelled.

## 18. Home-screen widget

**They do:** in-app dashboard sections that can be turned on or off. A home-screen widget: not verified.

**Learn:** a widget is the quickest way to log a purchase and to see what's left this month. It also puts money on a screen anyone can glance at, so it must respect app lock.

- **WID-1** Android and iOS offer a small widget (the period's expense, or the budget left when an overall budget exists, with an Add expense button) and a medium one (the period's income, expense, balance, and budget left, with Add expense and Add income buttons). Desktop has no widget. On iOS a small widget can have only one tap target, so there the whole small widget is its Add expense button and Home is reached from the medium one.
- **WID-2** The widget always shows the current period (PER-1) and counts only entries that count (BAL-4), whatever period the app showed last.
- **WID-3** Add opens the add form on the keypad with the usual defaults (ADD-3), and tapping the numbers opens Home on the current period. With app lock on, both go through the lock first (LOCK-2).
- **WID-4** With app lock on, the widget hides amounts and shows only its buttons, unless the user turns on "Show amounts on the widget" in Settings.
- **WID-5** The widget refreshes after every change in the app and at midnight, when a new day can start a period or make upcoming entries count. It never uses the network, and the app shares only the numbers the widget shows, never the database.
- **WID-6** It follows the app language, the currency format, and the device's light or dark theme, and stays readable at its smallest size.

## 19. Notes

**They do:** a NoteBook tab that works as a dated to-do list. Each note is text with a date, a time, and a done checkbox. The tab has period filters, search, Completed and Pending filters, counts, and a PDF of the list. Notes don't link to transactions and have no reminders, and a confirmed delete removes them for good. In testing on version 295, the counts went stale, search ignored the Pending filter, and the PDF quietly kept an earlier search. Whether backups include notes: not verified.

**Learn:** people use notes for money to-dos, like "pay the water bill on the 5th". Their value is the due date and turning the note into a transaction once it's paid. A list whose counts and filters disagree with the screen can't be trusted.

- **NOTE-1** A note has text (required, several lines allowed) and, optionally, a due date, an amount, and a category. It is open or done. Notes follow the record rules: UUID, timestamps, and soft delete (REC-1, REC-2, DEL-1).
- **NOTE-2** The Notes screen lists open notes first: overdue, then by due date, then notes without a date by last edit. Done notes collapse into a Done section below. An empty list explains what notes are for, with one "Add a note" action.
- **NOTE-3** Search (LANG-4) and the Open, Done, and due-date filters combine. The screen always shows which are on, with one tap to clear them, and every count comes from the list on screen.
- **NOTE-4** "Record as transaction" opens the add form with the note's amount, category, and text as the title, dated today; ADD-3 fills the rest. Saving marks the note done and links the two, and each shows the other. Deleting that transaction reopens the note.
- **NOTE-5** Open notes due in the selected period appear in the Home notices, next to the recurring and budget ones, and the Insights calendar marks their days (INS-1).
- **NOTE-6** A due date can have a reminder at a chosen time, sent as a local notification from the device. The app asks for notification permission only when the user first sets a reminder, and everything else works if it's refused. Android may deliver it a few minutes late. With app lock on, the notification says only that a note is due, and tapping it opens the note through the lock (LOCK-2).
- **NOTE-7** Deleting a note works like deleting a transaction: Undo, then the trash, then a purge after 30 days (DEL-2–DEL-4).
- **NOTE-8** Backups include notes, and restore merges them by ID like every other record (BAK-1, BAK-3). CSV and PDF exports leave notes out.

## 20. Importing a CSV

**They do:** the reference app exports PDF and Excel reports and keeps a local `.db` backup it can put back. There is no documented CSV export, and no way to bring data in from anywhere else.

**Learn:** the cost of switching trackers is the history you'd leave behind. Reading a plain CSV is the one import that works no matter which app someone is coming from — but only if it is honest about what it understood, because a silent mis-mapping puts wrong numbers in the one place a person needs to trust.

- **IMP-1** "Import a CSV" sits with Backup & restore, and next to "Restore a backup" on the first-run page (RUN-3). It reads a file the user picks and only adds records; it never replaces or deletes what is already there, and it is not how a backup is restored (BAK-2).
- **IMP-2** A CSV this app wrote reads back exactly, columns and all (BAK-5), including transfers.
- **IMP-3** For a file from another app, columns are matched by their headers — date, amount, type, category, account, title, note — ignoring case, spaces and accents (LANG-4) and allowing for the usual alternative names. A column that can't be matched with confidence is left out rather than guessed at, and the user can correct any match before importing.
- **IMP-4** A file needs a date and an amount to be importable. Without them, nothing is written: the app says the file can't be imported and names what it couldn't find, so the user knows whether to fix the file or give up (this is the whole point of IMP-5's preview).
- **IMP-5** Before anything is written the user sees what the app understood: which column became which field, how many rows will import, how many will be skipped and why, and the first few rows as they were read. Importing happens only on confirmation.
- **IMP-6** Imported rows follow the record rules like any other (REC-1, REC-2, DEL-1), so an import can be undone from the trash. Amounts and dates are read the way exports are written — ISO dates, plain decimals — and a row whose amount or date can't be read is skipped and counted, not rounded or guessed.
- **IMP-7** A category or account named in the file that this app doesn't have is chosen once on the preview screen, from those that exist, defaulting to Other and the default account. Importing never creates categories or accounts, so a file from an app with dozens of them can't flood a list this app keeps deliberately short (section 5).
- **IMP-8** A row matching one already in the app on date, amount, type, and title is taken as already imported and skipped; the preview says how many. A foreign CSV has no IDs, so this stands in for BAK-3's merge, and it is the one place the import decides something for itself — the preview says so plainly.

## 21. Attachments

**They do:** not covered by the competitor study.

**Learn:** a photo of the receipt and a few spoken words are what people reach for when typing at the till is too slow. They are also the heaviest thing this app will hold, so these rules are mostly about where the files live, what a backup does with them, and what happens when one goes missing.

- **ATT-1** A transaction can carry one photo and one voice note, both optional. Transfers and notes carry neither.
- **ATT-2** The photo is taken with the camera or picked with the system photo picker; the voice note is recorded in the app. Files are copied into the app's own storage, named after the record, and never written to a shared folder or the device gallery. Picking asks for no gallery permission; the camera asks for `CAMERA` and the recorder for `RECORD_AUDIO`, each only when first used, and refusing either leaves the rest of the form working.
- **ATT-3** A photo is downscaled on import to at most 1600 px on its long side and saved as JPEG, which keeps a receipt readable at roughly 200 KB. The original in the gallery is untouched.
- **ATT-4** A voice note stops at 60 seconds, with the time left shown while recording. It plays back in place, and recording again replaces it.
- **ATT-5** Attachments live and die with their transaction (REC-1, REC-2, DEL-1): a transaction in the trash keeps its files, emptying the trash deletes them, and restoring brings them back. Replacing an attachment deletes the file it replaced.
- **ATT-6** A backup with attachments is a zip holding the same JSON and the files (BAK-1); without them it stays a plain JSON file. Restore accepts either, so backups written before this feature still restore. Merge treats a file as part of its record: whichever side wins on `updated_at` brings its attachment (BAK-3). The app says how large a backup will be before writing it.
- **ATT-7** A record whose file is missing after a restore says so on the entry, and stays editable. Never a broken image or a silent gap.
- **ATT-8** Nothing about an attachment leaves the device (BAK-6, RUN-2): no upload, no transcription service, no gallery write, and no `INTERNET` permission. There is no speech-to-text. CSV export and the PDF report are unchanged and carry no files.

## Decisions (13 September 2026)
1. Title stays, as an optional field (ADD-1).
2. Future-dated transactions count only once their date arrives (BAL-4).
3. Recurring transactions wait for a tap by default (RCR-2).
4. Restore offers both Replace and Merge (BAK-2, BAK-3).
5. First day of month is in v1 (PER-2).
6. Accounts and transfers are in v1 (section 6).
7. Notes, five more languages (Turkish, Arabic, French, Spanish, German), a home-screen widget, and a PDF report ship in v1, before release (roadmap Phase 4).
8. Translations are machine-made, without a fluent-speaker review; CI checks and overflow tests guard them (LANG-2, LANG-6).
9. The first launch shows a setup page for language and currency, then a short walkthrough (RUN-3–RUN-5). This replaces "no prompts before first use".

## Decisions (14 September 2026)

10. Importing a CSV ships in v1, before the first-run page (section 20, roadmap Phase 4). It reads this app's own export exactly and makes a best effort at a foreign one, showing what it understood first and refusing a file it can't read rather than importing part of it. Accepting *any* CSV layout is the aim, not a promise: what can't be mapped is declined with a reason. Unknown categories and accounts are mapped on the preview, never created (IMP-7), and a row already in the app is skipped (IMP-8).

## Decisions (16 September 2026)

11. Attachments ship in v1, before the first-run page (section 21, roadmap Phase 4). A transaction carries one photo and one voice note; transfers and notes carry none. Voice notes stop at 60 seconds. Backups become a zip that carries the files, and plain JSON backups still restore (ATT-6).
12. The universal 71 MB release APK stays as it is. Play receives the AAB and builds each device's download from it, so only sideloading from the GitHub Release sees the size.

## Roadmap impact
These schema changes land in Phase 1 of `docs/ROADMAP.md`, before any feature work and long before release:
- amounts as integers (MONEY-1)
- a categories table, referenced by ID (CAT-1)
- an optional title (ADD-1)
- `deleted_at`, `created_at`, and `updated_at` on every table (DEL-1, REC-1)
- an accounts table with a default "Cash" account, and an account on every transaction (ACC-1, ACC-2)
