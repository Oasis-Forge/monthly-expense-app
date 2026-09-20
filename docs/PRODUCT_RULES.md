# Product rules

_13 September 2026._

This file defines how Monthly Expenses behaves: the calculations, defaults, and edge cases behind each screen. Each section says what the competitor does (see `docs/research/competitor-analysis.md`), what we take from it, and our rule. We learn from their app; we don't copy its rules.

- Rule IDs (`MONEY-1`) are stable. Tests and PRs reference them.
- "Not verified" marks competitor behavior we saw only partly.
- Every rule keeps the product principles in `CLAUDE.md`: no account, and the app's own data leaves the device only when the user exports it. Banner ads arrive with section 22; they bring the network with them, but never carry anything the user typed.

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
- **ADD-3** A new transaction defaults to the day Home is showing (DAY-9), the chosen type, the last category used for that type, and the last account used — or the account Home is showing, when it is showing one (ACC-9).
- **ADD-4** "Save & add another" keeps the type, category, account, and date, clears the amount, title, and note, and focuses the amount.
- **ADD-5** Recent categories show the last 5 used for the chosen type.
- **ADD-6** The date arrows move one day back or forward; tapping the date opens a picker.
- **ADD-7** Duplicate copies everything except the ID and sets the date to today.
- **ADD-8** Future dates are allowed. The row is marked as upcoming until its date arrives (BAL-4).
- **ADD-9** Leaving a form with unsaved edits asks first. Back closes the keypad if it is open, and the next Back — like the toolbar's arrow — asks "Discard changes?", with Keep editing and Discard. A form nothing has been typed into leaves without a word, and saving, "Save & add another" and deleting leave as they always did. It covers the transaction form and the transfer form.

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
- **BAL-6** The summary card on Home collapses to a single line — the balance, in its colour — and opens again on a tap. It keeps the way it was last left, on this device: it is a view of Home rather than a record, so a backup doesn't carry it.
- **BAL-7** Scrolling the day list collapses the card, and coming back to the top opens it again, so the entries have the screen while they are being read. Scrolling never opens a card that was closed by hand, and never changes what was chosen. The card is a header inside the day list's own scroll, pinned above the entries: the room it gives up is taken from the scroll, never from the list's height, so the entries move with the finger and never further.

## 6. Accounts and transfers

**They do:** accounts have only a name, and the default account carries the app's name. Transfers are a quick action. Payment methods (bank, card, cash) are a separate concept.

**Learn:** "account" and "payment method" overlap and confuse; one concept is enough.

- **ACC-1** One concept: an account has a name, a type (cash, bank, card, other), an opening balance, and an opening date. Every transaction belongs to exactly one account.
- **ACC-2** The default account is "Cash" and can be renamed.
- **ACC-3** A transfer is one record with from and to accounts. It changes both account balances and is never income or expense.
- **ACC-4** Account balance = opening balance (from its opening date) + income − expense − transfers out + transfers in, up to today (BAL-4). Transactions dated before the opening date still count, so the opening balance should be the balance on that date before them.
- **ACC-5** An account with history can be archived, not deleted.
- **ACC-6** The app can be pointed at one account instead of every one. It is one choice, shared by every screen that follows it, and **any screen that follows it has to say which account it is showing** — a filtered figure that looks like the whole of the money is worse than no filter at all. Home says it on the summary card, whose label names the chosen account in place of "Balance" or "Net" in both of the card's states (BAL-6), with the switch in the room already kept opposite the card's chevron, since the toolbar has no space for a third action (NAV-6) — and on the card's one line as well, but there only while one account is showing, since that is the state a scroll leaves Home in and the way back should never be behind opening the card first; Insights says it with a named button under the period. **With only one account the control is not shown at all**, on any screen: there is nothing to switch to, and an empty choice only raises a question with no answer. Archived accounts are not offered (ACC-5), and one archived or removed after it was chosen reads as every account again rather than leaving a screen empty with no way back. The choice is how this device is set up to look rather than a record, so it survives a relaunch and a backup doesn't carry it (BAL-6).
- **ACC-7** It reaches the screens that are about *this period's money*: Home — the summary card, the day list, and each day's own income and expense — and all three views of Insights (INS-1–INS-3), so a chart and the total above it are never about different money. It reaches four things not at all:
  - **Budgets**, on the card and in Insights. A budget is a limit on a category, across every account (BUD-1), so measuring one account against it reports a limit nobody set: on a card with no groceries on it, "0% used" of a grocery budget that is in fact more than half gone. Budgets always count every account.
  - **The home-screen widget** (WID-1). It is not a screen, and a tile that quietly showed one account would be read as the whole of the money every time.
  - **Search** (SRCH-2) and **the PDF report** (PDF-1), which each have an account filter of their own and would otherwise filter twice.
  - **The CSV export** (BAK-5). An export is a record of the period, and a partial file that looks complete is worse than an extra step; export what you mean explicitly from Search.
- **ACC-8** With one account showing, carried forward and closing are that account's own (ACC-4): its opening balance, its income and expense, and the transfers into and out of it. A transfer is still neither income nor expense (BAL-1) and still counts nowhere until its date arrives (BAL-4) — it moves the balance alone, and only here, because across every account it nets to zero.
- **ACC-9** A new entry started while Home shows one account begins on that account, ahead of the last account used (ADD-3). With every account showing, the last one used wins as before.

## 7. Budgets

**They do:** per-category budgets (weekly, monthly, yearly) showing budget, spent, remaining, and a per-day allowance, plus "import from last month". The allowance formula: not verified.

**Learn:** the per-day allowance is the most actionable number. The import button exists because budgets don't carry over.

- **BUD-1** Monthly budgets per category, plus an optional overall budget, aligned to the period (PER-1).
- **BUD-2** Spent = the category's expenses in the period (BAL-4 applies). Remaining = limit − spent.
- **BUD-3** Per-day allowance = remaining ÷ days left in the period, including today. It shows only for the current period and never goes negative; when over, show the amount over instead.
- **BUD-4** At 80% of the limit the budget shows a warning; at 100% it shows over budget.
- **BUD-5** A budget repeats every period until the user changes or removes it. A change applies from the current period onward; past periods keep their limits.
- **BUD-6** Past periods show the final result; future periods show the limit only.
- **BUD-7** Whenever the selected period has budgets, Home shows them in one card at the top of the day list, so opening it scrolls with the days instead of squeezing them. It starts closed, as one line: the share of the budget used (the overall budget's when there is one, otherwise the category budgets' spending against their limits combined) and how many budgets are over, in the colour of the worst of them (BUD-4). A future period's line says how many budgets are set (BUD-6). It replaces the over-budget notice Home used to show: the line says how many are over, in red.
- **BUD-8** Opened, the card shows each budget more simply than Insights: its name, what's spent of the limit with the share used, and its bar. What's left per day or how much is over stays in Insights (BUD-3), where the card's "Spending by category" button leads: the tab with the budgets above the spending by category.
- **BUD-9** Scrolling the day list folds the budgets card away, and it opens again when the list comes to rest at the top, exactly as it was left (BUD-7). Only the user's own dragging folds it, never a correction the list makes to its own position. The card is the width of the summary card above it, so Home reads as one column.

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

- **DEL-2** Swiping a row away needs no confirmation: a snackbar offers Undo for about 5 seconds. Delete chosen from a row's menu asks first (ROW-3), since a tap in a menu is easy to land by mistake. Either way the entry goes to the trash and the same Undo snackbar appears.
- **DEL-3** Deleted items stay in the trash for 30 days, then get purged on app start.
- **DEL-4** Restore keeps the original ID, date, and category. If the category was archived in the meantime, the transaction still restores.
- **DEL-5** The trash holds everything that was deleted — transfers as well as transactions — most recently deleted first, each restored by the same button (DEL-4). A deleted transfer survives the next launch: it waits out its 30 days in the database like anything else (DEL-3), and the app reads it back rather than forgetting it.

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
- **BAK-8** The phone's own automatic backup is refused: `android:allowBackup="false"`, and `dataExtractionRules` excludes every domain from cloud backup. Android would otherwise copy the database and the settings to the user's Google Drive by itself — a copy of every entry that nobody asked for, and one that would be handed to whoever next installs the app under that account. Moving to a new phone still carries them, because that is the user taking their own data with them rather than a copy kept somewhere. A reinstall therefore starts empty, and the way back is the backup the app makes when asked (BAK-1, BAK-6).

## 12. Currency and formatting

**They do:** only a number-format choice; no currency symbol.

- **CUR-1** One currency for the whole app in v1, chosen from a searchable ISO list and preselected from the device locale.
- **CUR-2** Amounts are formatted with `intl` for the device locale and the currency's decimals (JPY 0, USD 2, KWD 3).
- **CUR-3** Changing the currency changes labels only, never values. The app warns before applying it.

## 13. First run and trust

**They do:** open straight to Home with a Drive backup prompt and a banner ad; the default account uses the app's name.

**Learn:** the first launch settles what the device can't tell us for sure — the language and the currency — on one screen, and it has to come first, because the language chosen there is the language everything after it is read in. Then the app explains itself, without delaying the first entry. Asking for an account, permissions, or cloud backup up front costs trust.

- **RUN-1** After setup (RUN-3) and the walkthrough (RUN-4), an empty Home shows one clear "Add your first transaction" action.
- **RUN-2** The Android release build asks for `INTERNET` only so the ad slots in section 22 can fill. No other feature touches the network, and the store listing declares what the ad network collects and nothing more (ADS-6).
- **RUN-3** The first launch opens one setup page: the language (LANG-1) and the currency (CUR-1), both preselected from the device locale, so most people only tap Continue. Picking a language switches the page at once, and it is the language the walkthrough that follows is read in. The page asks for nothing else: no account, no permissions, no cloud backup, and nothing about files. Continue opens the walkthrough.
- **RUN-4** The walkthrough follows setup, in the language just chosen: four pages on quick entry, planning (budgets, recurring, notes), insights and reports, and what stays on the device, then a fifth page for people arriving from somewhere else — "Restore a backup", which restores with Replace (BAK-2), and "Import a CSV" (IMP-1). They belong here, not on the setup page, which asks only what the app itself needs. A restored backup brings the language and currency it was saved with, overriding what setup just set, because it is the user's own earlier choice; the app says so before restoring. Every page has Skip, and the last one opens Home. The walkthrough runs right to left in Arabic and Urdu (LANG-5), respects the device's reduce-motion setting, and can be replayed from Settings — where the fifth page is left out, since Backup & restore is a tap away by then.
- **RUN-5** Setup shows until it's finished. The walkthrough shows once, even when skipped. An app update on a device that already has data skips both and keeps the current settings.

## 14. Insights

**They do:** a calendar view and charts. How periods and future-dated entries affect them: not verified.

**Learn:** a calendar and a trend only help if they use the same periods and counting rules as Home.

- **INS-1** The calendar shows the selected period as a month grid with each day's expense and income. Weeks start on the first day of the week (PER-4). Upcoming days show their amounts faintly, because they don't count yet (BAL-4). Tapping a day lists its transactions and transfers.
- **INS-2** The trend shows income and expense for the last 6 or 12 periods, ending with the selected one. Only entries that count are included (BAL-4), and the averages leave out periods that haven't started.
- **INS-3** The category chart works for any period and shows expense or income, with budget progress for expense (BUD-2).
- **INS-4** Tapping the period label on Home opens Insights on the calendar for that period (INS-1). The arrows beside it still move between periods (PER-1), and inside Insights the label does nothing, since the calendar is already there.
- **INS-5** The trend's amount axis labels only its gridlines, each on one line. The top of the axis, which is rarely a round amount, gets no label of its own, so no two labels overlap in any currency.

## 15. App lock

**They do:** not verified.

**Learn:** an expense app holds private data, but a forgotten app PIN would lock people out of their own records.

- **LOCK-1** App lock is off by default. It uses the device's own biometrics or screen lock (fingerprint, face, PIN, pattern, or password), so the app never stores a PIN. Turning it on or off asks for authentication first.
- **LOCK-2** With app lock on, the app asks at launch and again after at least a minute in the background, and hides its content until unlocked.
- **LOCK-3** If the device no longer has biometrics or a screen lock, app lock turns itself off instead of locking the data away.

## 16. Languages

**They do:** their own strings carry 20 languages besides English — Arabic, Bengali, Chinese (Simplified), Dutch, French, German, Greek, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Turkish, Urdu, and Vietnamese, with Portuguese only partly done — read from the app's own resources on 17 September 2026; the "16" noted earlier came from its picker. Translation quality, right-to-left layout, and number formats in those languages: not verified.

**Learn:** a translated app only feels native when numbers, dates, plurals, search, and layout direction are right too. A cut-off label or a half-translated screen looks broken.

- **LANG-1** The app is in 21 languages, the set the competitor covers: English, Arabic, Bengali, Chinese (Simplified), Dutch, French, German, Greek, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Turkish, Urdu, and Vietnamese. It follows the device language and falls back to English. Setup (RUN-3) and Settings list them all, each in its own language, and Settings also offers "System default". A change applies at once, without a restart.
- **LANG-2** Every user-facing text comes from the ARB files: screens, notices, errors, default category and account names (CAT-1), the widget, and the PDF report. CI fails when a language is missing a message, or when its placeholders, plurals, or selects differ from English. Plurals and variable parts use ICU messages, never pieced-together strings.
- **LANG-3** Dates, numbers, and amounts follow the chosen language's format (CUR-2), and the first day of the week keeps following PER-4. CSV exports and backups always use ISO dates and plain decimals with a `.`, whatever the language (BAK-5), so the files read the same everywhere.
- **LANG-4** Search ignores case and accents in every language, including the Turkish dotted and dotless i: `istanbul` finds "İstanbul" and `cafe` finds "Café" (section 10).
- **LANG-5** In Arabic and Urdu the layout runs right to left: navigation, the drawer (NAV-3), lists, swipe actions, charts, and the date arrows (ADD-6), whose "earlier" arrow points right. Amounts and keypad expressions (ADD-2) stay left to right inside right-to-left text. Each amount is one left-to-right piece, sign and currency symbol included, so it reads the same on every screen; in Arabic the Arab currencies use their Arabic symbols (ر.س., د.إ., ج.م. and the rest) instead of intl's Latin ones.
- **LANG-6** Translations are machine-made: a change that adds or edits English messages adds every other language in the same PR, with no separate review step, and `/l10n-add` writes them in one go. Widget tests render the main screens, the add form, setup, and the walkthrough in every language, on a phone-size screen at 1.3× text size, and fail on overflow.

## 17. PDF report

**They do:** PDF and Excel reports. Their contents and options: not verified.

**Learn:** people send a report to a partner, an accountant, or a landlord, so it has to make sense without the app, look right in every language, and leave the device only when the user sends it (BAK-6).

- **PDF-1** "Export PDF" in the Home, Insights, and Search menus creates a report for the selected period, a custom date range, or a whole year, optionally for one account. From Search, the current filters apply, as with CSV (BAK-5).
- **PDF-2** The report opens with a summary: income, expense, net, and the opening and closing balance (BAL-2, BAL-3). Then come spending by category with amounts, shares, and budget progress (BUD-2); a trend by day, or by period for ranges longer than two periods (INS-2); and the transactions grouped by day, with transfers marked. Entries that don't count yet appear in a separate Upcoming list, outside the totals (BAL-4).
- **PDF-3** Before creating it, the user can leave out the transaction list, titles and notes, or account names. The header shows the app name, the range (PER-3), the currency, and when the report was created. No watermark, no promotion.
- **PDF-4** The report is built on the device without a network connection and previewed, then shared, saved, or printed only when the user chooses (BAK-6, RUN-2).
- **PDF-5** It uses the app language and formats (LANG-3), runs right to left in Arabic and Urdu (LANG-5), and embeds faces for every language it can be made in: Roboto for Latin, Greek and Cyrillic, Noto Sans Arabic for Arabic and Urdu, and Noto Sans Devanagari, Bengali and Thai for those three. The face for the app's language leads and the rest follow it as fallbacks, so a Latin account name in a Hindi report still prints. Pages are A4, or US Letter in regions that use it, with page numbers and table headers repeated on every page.
- **PDF-6** A year with thousands of transactions builds without freezing the app, shows progress, and can be cancelled.
- **PDF-7** In Chinese, Japanese and Korean there is no report yet. The smallest faces the PDF library can read are 9.6–17.8 MB each, no single file covers all three, and carrying them would more than double what a user downloads — for a report, in three of twenty-one languages. The screen says so in the app's language instead of printing empty boxes, and once the app has internet at all (RUN-2, ADS-6) a later version will offer the face as a one-time download.

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

**They do:** a notes tab that works as a dated to-do list. Each note is text with a date, a time, and a done checkbox. The tab has period filters, search, Completed and Pending filters, counts, and a PDF of the list. Notes don't link to transactions and have no reminders, and a confirmed delete removes them for good. In testing on version 295, the counts went stale, search ignored the Pending filter, and the PDF quietly kept an earlier search. Whether backups include notes: not verified.

**Learn:** people use notes for money to-dos, like "pay the water bill on the 5th". Their value is the due date and turning the note into a transaction once it's paid. A list whose counts and filters disagree with the screen can't be trusted.

- **NOTE-1** A note has text (required, several lines allowed) and, optionally, a due date, an amount, and a category. It is open or done. Notes follow the record rules: UUID, timestamps, and soft delete (REC-1, REC-2, DEL-1).
- **NOTE-2** The Notes screen lists open notes first: overdue, then by due date, then notes without a date by last edit. Done notes collapse into a Done section below. An empty list explains what notes are for, with one "Add a note" action.
- **NOTE-3** Search (LANG-4) and the Open, Done, and due-date filters combine. The screen always shows which are on, with one tap to clear them, and every count comes from the list on screen.
- **NOTE-4** "Record as transaction" opens the add form with the note's amount, category, and text as the title, dated today; ADD-3 fills the rest. Saving marks the note done and links the two, and each shows the other. Deleting that transaction reopens the note.
- **NOTE-5** Open notes due in the selected period appear in the Home notices, next to the recurring one, and the Insights calendar marks their days (INS-1).
- **NOTE-6** A due date can have a reminder at a chosen time, sent as a local notification from the device. The app asks for notification permission only when the user first sets a reminder, and everything else works if it's refused. Android may deliver it a few minutes late. With app lock on, the notification says only that a note is due, and tapping it opens the note through the lock (LOCK-2).
- **NOTE-7** Deleting a note works like deleting a transaction: Undo, then the trash, then a purge after 30 days (DEL-2–DEL-4).
- **NOTE-8** Backups include notes, and restore merges them by ID like every other record (BAK-1, BAK-3). CSV and PDF exports leave notes out.

## 20. Importing a CSV

**They do:** the reference app exports PDF and Excel reports and keeps a local `.db` backup it can put back. There is no documented CSV export, and no way to bring data in from anywhere else.

**Learn:** the cost of switching trackers is the history you'd leave behind. Reading a plain CSV is the one import that works no matter which app someone is coming from — but only if it is honest about what it understood, because a silent mis-mapping puts wrong numbers in the one place a person needs to trust.

- **IMP-1** "Import a CSV" sits with Backup & restore, and next to "Restore a backup" on the first-run page (RUN-3). It reads a file the user picks and only adds records; it never replaces or deletes what is already there, and it is not how a backup is restored (BAK-2).
- **IMP-2** A CSV this app wrote reads back exactly, columns and all (BAK-5), including transfers.
- **IMP-3** For a file from another app, columns are matched by their headers — date, amount, type, category, account, title, note — ignoring case, spaces and accents (LANG-4) and allowing for the usual alternative names. A column that can't be matched with confidence is left out rather than guessed at, and the user can correct any match before importing. The alternative names are matched in every app language (LANG-1).
- **IMP-4** A file needs a date and an amount to be importable. Without them, nothing is written: the app says the file can't be imported and names what it couldn't find, so the user knows whether to fix the file or give up (this is the whole point of IMP-5's preview).
- **IMP-5** Before anything is written the user sees what the app understood: which column became which field, how many rows will import, how many will be skipped and why, and the first few rows as they were read. Importing happens only on confirmation.
- **IMP-6** Imported rows follow the record rules like any other (REC-1, REC-2, DEL-1), so an import can be undone from the trash. Amounts and dates are read the way exports are written — ISO dates, plain decimals — and a row whose amount or date can't be read is skipped and counted, not rounded or guessed.
- **IMP-7** A category or account named in the file that this app doesn't have is chosen once on the preview screen, from those that exist, defaulting to Other and the default account. Importing never creates categories or accounts, so a file from an app with dozens of them can't flood a list this app keeps deliberately short (section 5).
- **IMP-8** A row matching one already in the app on date, amount, type, and title is taken as already imported and skipped; the preview says how many. A foreign CSV has no IDs, so this stands in for BAK-3's merge, and it is the one place the import decides something for itself — the preview says so plainly.

## 21. Attachments

**They do:** not covered by the competitor study.

**Learn:** a photo of the receipt and a few spoken words are what people reach for when typing at the till is too slow. They are also the heaviest thing this app will hold, so these rules are mostly about where the files live, what a backup does with them, and what happens when one goes missing.

- **ATT-1** A transaction can carry one photo and one voice note, both optional. Transfers and notes carry neither.
- **ATT-2** The photo is taken with the camera or picked with the system photo picker; the voice note is recorded in the app. Files are copied into the app's own storage, named after the record, and never written to a shared folder or the device gallery. Picking asks for no gallery permission, and the camera is the system camera app, so Android asks for no camera permission of its own; iOS asks with `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`. The recorder asks for `RECORD_AUDIO` on Android and `NSMicrophoneUsageDescription` on iOS, only when first used, and refusing it leaves the rest of the form working.
- **ATT-3** A photo is downscaled on import to at most 1600 px on its long side and saved as JPEG, which keeps a receipt readable at roughly 200 KB. The original in the gallery is untouched.
- **ATT-4** A voice note stops at 60 seconds, with the time left shown while recording. It plays back in place, and recording again replaces it.
- **ATT-5** Attachments live and die with their transaction (REC-1, REC-2, DEL-1): a transaction in the trash keeps its files, emptying the trash deletes them, and restoring brings them back. Replacing an attachment deletes the file it replaced.
- **ATT-6** A backup with attachments is a zip holding the same JSON and the files (BAK-1); without them it stays a plain JSON file. Restore accepts either, so backups written before this feature still restore. Merge treats a file as part of its record: whichever side wins on `updated_at` brings its attachment (BAK-3). The app says how large a backup will be before writing it.
- **ATT-7** A record whose file is missing after a restore says so on the entry, and stays editable. Never a broken image or a silent gap.
- **ATT-8** Nothing about an attachment leaves the device (BAK-6, RUN-2): no upload, no transcription service, no gallery write, and nothing handed to the ad network that brought the `INTERNET` permission (ADS-7). There is no speech-to-text. CSV export and the PDF report are unchanged and carry no files.

## 22. Ads

**They do:** a banner on most screens from the first launch, through a third-party ad network, with the advertising ID and ad attribution; the ads are removed by a subscription or a one-off lifetime price, and a rewarded video buys seven ad-free days.

**Learn:** ads pay for a free app, but a banner that covers a row, moves a button under a finger, or interrupts an entry is what makes a free app feel cheap, and the money only comes if people keep the app. Ads also change what the app collects, so the listing and the policy have to say so plainly.

- **ADS-1** Two shapes and no others: a banner in a slot the layout reserves — the bottom of Home and the bottom of Insights — and one full-screen ad a day at a seam (ADS-11). No pop-ups, no rewarded video, no ad dressed as a row in a list, none on opening or resuming the app, and nothing on the add and edit forms, the walkthrough, setup, dialogs, the home-screen widget, or the PDF report.
- **ADS-2** A slot keeps its height whether or not an ad fills it, so nothing shifts under a finger, and an empty slot shows nothing at all: no frame, no placeholder.
- **ADS-3** A slot sits outside the scrolling content, above the system navigation bar, and never overlaps the keypad, the add button, or a list row. Content ends above it; nothing hides behind it. The slot is a standard anchored banner tall and the ad fills it, so it sits on the bottom edge with no blank band around it, with the "Remove ads" link (PAY-7) just above.
- **ADS-4** No ad is requested until the walkthrough and setup are finished (RUN-3, RUN-4) and consent has been answered (ADS-5), so the first minutes of the app belong to the app.
- **ADS-5** Where the law asks for it (the EEA, the UK, and Switzerland), the ad network's consent form appears before the first request, and Settings keeps a "Privacy options" row to change the answer later. Refusing means non-personalised ads, never a nag screen or a feature withheld.
- **ADS-6** What the ad SDK collects — the advertising ID, coarse device and app data, and the ad requests themselves — is declared in the Play data-safety form, the App Store privacy labels, and `docs/privacy-policy.md`, in the same plain words as the rest of the policy.
- **ADS-7** The ad SDK is handed nothing from the app: no amounts, titles, notes, categories, accounts, attachments, or search terms, and no keywords derived from them. The user's records still leave the device only through an export or a backup they asked for (BAK-6).
- **ADS-8** One switch hides every slot, and "Remove ads" (PAY-1) is what flips it, so an ad-free build and a paid ad-free app are the same code path. No feature is ever withheld from someone who keeps the ads (PAY-4).
- **ADS-9** No ad loads while the app is locked (LOCK-2), and none appears in a store screenshot.
- **ADS-10** Only a release build asks with the real ad units; every other build asks with Google's test units. AdMob forbids impressions and clicks on your own live ads, and a development build that served them would put the account at risk, so this is not a convenience but the condition of having an account at all. The app ID and the unit IDs are not secrets — they ship inside the binary — so they live in the repository, in `lib/services/ads_config.dart` and, because the SDK reads it before Dart runs, in the Android manifest and `Info.plist` as well. A release built before the real IDs are filled in requests nothing rather than asking with a placeholder.
- **ADS-11** The full-screen ad appears only at a seam: the moment a self-contained job has ended and the user is on their way out of it, never inside one. There are four — leaving Insights for Home, and after a PDF report, a CSV export, or a finished import — and no screen adds a fifth without a rule. Never after a restore: someone putting their records back is not an audience. Never over an Undo still on screen (DEL-2), and never over entry, a dialog, the keypad, setup or the walkthrough (ADS-1).
- **ADS-12** At most one a day, counted by the device's own day, and none until the app has been used: not before ten transactions, and never within three days of first opening it. The first days decide whether the app is kept at all.
- **ADS-13** Never a wait. The ad is fetched before the seam is reached, and a seam that finds none ready passes in silence — no spinner, no pause, nothing held back for it. The day's one showing is spent when an ad is actually on screen, not when one was asked for, so a fetch that fails costs the user nothing and the next seam may still try.
- **ADS-14** It is never a back button. The user reaches a seam by finishing something, the screen it belonged to is already gone when the ad appears, and dismissing it leaves them exactly where they were going — never one tap short of it, and never somewhere else. An ad that catches a tap meant for the app is a click nobody made, and AdMob counts those against the account.
- **ADS-15** Everything that governs a banner governs this one: nothing before setup, the walkthrough and consent (ADS-4, ADS-5), nothing once the ads are bought away (ADS-8, PAY-1), nothing while the app is locked (ADS-9, LOCK-2), and the SDK is handed nothing the user typed (ADS-7).
- **ADS-16** Its own ad unit, so AdMob reports it apart from the banners, kept in `lib/services/ads_config.dart` with the rest (ADS-10). A build whose interstitial unit is still blank shows none rather than asking with a placeholder.

## 23. Getting around

**They do:** a bottom tab bar for home, calendar and notes, a drawer behind the toolbar's menu button, an overflow menu, and Add income, Add expense and Transfer as buttons on Home.

**Learn:** our three-dot menu is where everything that isn't Home ended up — Transfer, Budgets, Recurring, Notes, the exports, Backup, Settings, Trash. It is one small target that says nothing about what is behind it, and people don't open it. A named list they can see beats a menu they have to guess at. A drawer that only names half the app has the same fault one layer down, so every destination is in it, and the ones people reach for most — adding, and each view of the insights — are rows of their own rather than a screen to land on and then navigate.

- **NAV-1** Every destination that isn't Home lives in a navigation drawer, opened from the toolbar's menu button or an edge swipe: Add expense, Add income, Transfer, Budgets, Recurring, Notes, Spending by category, Calendar, Trend, Search, Accounts, Categories, Settings, Export CSV, Export PDF, Backup & restore, and Trash. A row goes where it says: the three views of Insights are named one by one and each opens on its own (INS-1–INS-3), and Add expense and Add income open the form already on that type. The three-dot overflow goes.
- **NAV-2** The drawer is grouped under headings: adding (Add expense, Add income, Transfer), planning (Budgets, Recurring, Notes), looking back (Spending by category, Calendar, Trend, Search), managing (Accounts, Categories, Settings), and data (Export CSV, Export PDF, Backup & restore, Trash). Every row has an icon and a translated label (LANG-2), and the list scrolls on a phone.
- **NAV-3** The drawer opens from the leading edge: the left in left-to-right languages, the right in Arabic and Urdu (LANG-5). Choosing a destination closes it, and Back closes it before it leaves the screen.
- **NAV-4** Home keeps its own quick paths — the period selector (INS-4), the day strip under it (DAY-1), Search and Settings in the toolbar, and the add button — so the everyday round never goes through the drawer.
- **NAV-5** The drawer is for going somewhere and nothing else: no settings toggles, no account area, no ads (ADS-1).
- **NAV-6** The toolbar carries two actions, Search and Settings, with Settings at the trailing edge. A third would squeeze the app's name, which is the same untranslated words in every language (LANG-6); Insights lost its toolbar icon to the gear and is named three times in the drawer instead.
- **NAV-7** Nothing is more than two taps from Home: open the drawer, choose the row. Accounts and Categories are among those rows as well as in Settings, and adding one is the button on the list itself.

## 24. Paying

**They do:** ads are removed by a monthly or yearly subscription, or by a one-off lifetime purchase, and a rewarded video buys seven ad-free days.

**Learn:** a subscription to *not* see something is resented, and a rewarded video turns the app into a slot machine, so ads are bought away once and for all. A bank connection is the opposite case: it costs us every month that someone uses it, so it has to be paid for every month too. What is sold must already work, and must work for the buyer's own bank.

- **PAY-1** "Remove ads" is a one-time purchase. It hides every ad slot (ADS-8) and changes nothing else. It follows the store account, so a new phone or a reinstall restores it.
- **PAY-2** Plus is a subscription, yearly with a monthly option, because the bank connection it buys (section 25) costs us for every month it runs. It hides the ads while it is active, and when it lapses the connection stops and the ads come back — unless "Remove ads" was bought, which is kept forever either way (PAY-1). Nothing else changes, and nothing recorded is ever taken away (BANK-8).
- **PAY-3** Until the bank connection actually works, Plus is shown as "coming soon", with no price and no way to buy it. Nothing is sold before it exists.
- **PAY-4** Nothing that works today ever moves behind a payment. Every feature in v1 — entry, budgets, recurring, notes, insights, reports, backup, import, attachments, the widget, app lock — stays free for everyone, with or without ads. Paying removes ads and adds what is new.
- **PAY-5** "Remove ads" needs no account and no server: the store's own receipt on the device decides it, "Restore purchases" sits beside the price, and the app asks the store what is owned at each launch, so a refund or a family-shared purchase takes effect without a reinstall. Plus is checked on the server the bank connection needs anyway, so a lapsed or refunded subscription actually stops the connection instead of being taken on trust.
- **PAY-6** Prices come from the store, in the buyer's own currency. They are never hard-coded, and they have nothing to do with the app's currency setting (CUR-1).
- **PAY-7** Selling is quiet: one row in Settings, and one small tap target on the ad slot itself. No interstitial upsell, no countdown, no trial that lapses into a charge, no repeated asking.
- **PAY-8** A purchase that fails or is left pending never charges twice and never leaves the app half-paid: the slots stay as they were until the store confirms. Backing out of the store's sheet, or a sheet that never opens, puts the price back at once, and backing out says nothing.
- **PAY-9** Plus is only offered where it can work. The screen asks which bank first, and when no provider reaches it, the app says so and sells nothing — it points at the free notification route (ALERT-1) and the CSV import (IMP-1) instead.
- **PAY-10** A subscription is cancelled in the store, never by asking us, and the app says where that is. It never dark-patterns: no "are you sure" chain, no offer wall on the way out, and the last day paid for is honoured.

## 25. Automatic entry

**They do:** nothing of the sort; every entry is typed in by hand.

**Learn:** the entries people miss are the ones their bank already knows about. A real connection catches all of them, including the ones no notification ever mentions, but it exists only where a provider reaches that bank, and it costs money every month. Reading the phone's own notifications is free and reaches banks no provider does, but it sees only what the bank chooses to announce. Both are worth having, as long as neither writes to the ledger unread.

### The bank connection (Plus)

- **BANK-1** Plus connects to the bank through a licensed open-banking provider. The user signs in on the provider's or the bank's own screen: the app never sees a bank password, and neither do we.
- **BANK-2** Transactions arrive whole — date, amount, merchant, account — and the user matches each bank account to an account in the app once, when the connection is made (ACC-1).
- **BANK-3** An arriving transaction is still a proposal. It waits in a review list where the user confirms it, changes its category, or discards it, and nothing reaches the ledger unread (as with IMP-5 and RCR-2). Once a merchant has been filed the same way a few times, the app may suggest the category by itself, but never the amount, the date, or the account.
- **BANK-4** A proposal that matches something already entered by hand, by amount, day, and account, is offered as a merge rather than added beside it (IMP-8).
- **BANK-5** This is the one place the app's data leaves the device. The screen that starts a connection says in plain words what the provider receives and keeps, the privacy policy says the same, and none of it is ever shown to an ad network (ADS-7). Without Plus, the app still sends nothing anywhere.
- **BANK-6** Disconnecting stops the flow at once, asks the provider to revoke its access, and deletes what our side holds for that connection. Everything already recorded stays, because it is the user's data (DEL-1).
- **BANK-7** A connection that breaks — a consent that expired, a bank that changed its sign-in, a provider outage — says so on Home and offers to reconnect. It never fails quietly, and it never invents entries for the days it missed.
- **BANK-8** When Plus lapses, the connection stops and the review list is cleared, but every transaction already recorded stays and stays editable.

### Reading notifications (free, Android)

- **ALERT-1** Where no provider reaches the bank, the app can read notifications from apps the user picks — the bank's own app, or the messaging app when the bank texts instead. It is free, needs no purchase, and is Android only: on iOS no app may read another's notifications.
- **ALERT-2** It goes through Android's own notification-access screen, names exactly which apps will be read, and is one tap to turn off. Notifications from every other app are ignored and never stored.
- **ALERT-3** Everything is parsed on the device. No notification text, bank name, amount, or merchant leaves the phone (BAK-6, ADS-7).
- **ALERT-4** Every reading is a proposal, reviewed exactly like a connected bank's (BANK-3), with the same duplicate check (BANK-4).
- **ALERT-5** A wording the app can't read confidently is kept as its own text, for the user to complete or throw away; nothing is guessed. A correction teaches the shape for that app on that phone, and is never uploaded or shared between users.
- **ALERT-6** The app is honest about the limit: this route sees only what the bank chooses to announce, so no notification means no entry. A bank that has said nothing for two weeks prompts a look at its alert settings rather than silence.
- **ALERT-7** The Play listing declares notification access and what it is for, and `docs/privacy-policy.md` says in plain words what is read, what is kept, and that it stays on the phone.

## 26. Looking at one entry

**They do:** a tap on a row opens the entry in the form it was typed into, every field live; there is nothing between reading what you recorded and changing it.

**Learn:** most taps on a row are to look, not to change — what was that $42 on Tuesday? A form answers that badly: the fields are small, the keypad is waiting, and a stray tap edits real data. So a tap opens a page that reads like a record, and editing is a button on it. The form stays exactly as it was; this is not the form with its fields locked, which would be the worst of both.

- **DET-1** Tapping a transaction anywhere — Home, Search, the calendar, or a note's link — opens its details, laid out to be read: nothing on the page is a field, and nothing on it can be typed into.
- **DET-2** The details lead with the amount in the colour of its kind and signed as the lists sign it, under the category's icon and over what it was for. A date still ahead is marked "Upcoming", because it is not in the period's totals yet (ADD-8, BAL-4).
- **DET-3** The record follows as labelled lines: category, account, the full date, and the note when there is one. The pencil in the toolbar opens the same form as always (section 3), with Duplicate (ADD-7) and Delete (DEL-2) beside it.
- **DET-4** A photo shows as a thumbnail that opens full screen, and a voice note plays and pauses from here (ATT-1, ATT-4). Replacing or removing either is the form's job, so those controls are not on this page, and a file that has gone says so (ATT-7).
- **DET-5** The foot of the page says when the entry was added, and when it was last changed if that was a later day — saving sets both moments apart, so the same date twice would say nothing.
- **DET-6** The page follows the record rather than a copy of it: an edit, an undo, or a change made elsewhere shows at once, and if the entry is deleted — here or anywhere else — the page closes itself.

- **DET-7** Transfers keep opening their own form for now (ACC-3); if they get a details page it follows this section.

## 27. The day on Home

**They do:** the month's days run one after another down Home, newest first, and the current day is wherever it happens to fall in that list.

**Learn:** a new entry is nearly always today's, so Home should already be there. A week of days across the top says which day is which, keeps today in sight without scrolling, and turns "record yesterday's taxi" into two taps rather than a date picker. The month doesn't go away: it is the same list, one tap back.

- **DAY-1** Home opens on today: the strip chooses it and the list shows that day alone. Adding an entry is then always on the day it belongs to.
- **DAY-2** The strip sits under the period selector: seven days, the weekday over the date, ordered by the first day of the week (PER-4) and the locale's direction (LANG-5). Today keeps a mark of its own even when another day is chosen. The strip is on every Home there is, the first-run welcome included, so the day a first entry lands on is never a surprise.
- **DAY-3** Swiping the strip moves a week at a time. Choosing a day outside the shown period moves the period to the one that contains it, whatever day that period starts on (PER-1, PER-2).
- **DAY-4** A day carrying any entry shows a dot under its date, so a week's activity reads at a glance.
- **DAY-5** Tapping the chosen day again clears it: the list goes back to every day in the period, newest first.
- **DAY-6** The choice follows the period: a period holding today opens on today, and any other period opens with no day chosen and shows all of its days. Looking back over history stays a month at a time.
- **DAY-7** The chosen day shows its entries under its date, with its own income and expense beside it; a day holding nothing says so rather than showing an empty screen. Every day in the whole-period list carries that same total.
- **DAY-8** The summary card and the budgets card stay on the period (BAL-3, BUD-7): the strip changes which entries are listed, not what the period means.
- **DAY-9** A new entry opened while a day is chosen starts on that day, at the current time; with no day chosen it starts on today. A duplicate and a recorded note are still dated today (ADD-7, NOTE-4).

## 28. A row's own actions

**They do:** a swipe deletes a row, and everything else waits until the entry is opened.

**Learn:** a swipe is quick once you know it is there, but nothing on the row says so, and a row has only one swipe to give. A button that names its actions is findable by anyone, and it gives deleting the moment of thought a swipe doesn't need: a swipe is deliberate, a tap in a menu is easy to land by mistake.

- **ROW-1** Every transaction row in a list — Home's day list, Search results, and the calendar's day list — carries a three-dot button at its trailing edge, beside the amount. It opens a menu of Duplicate and Delete, and opening it never opens the entry.
- **ROW-2** Duplicate opens the add form prefilled from the row, exactly as it does from the details page: everything but the ID and the attachments, dated today (ADD-7). Nothing is written until the form is saved, and it is called Duplicate in both places, because it is one action.
- **ROW-3** Delete from the menu asks "Delete this transaction?" and says where the entry goes, before anything happens. Confirming moves it to the trash with the usual Undo (DEL-2, DEL-3); Cancel leaves the row alone, and a delete that fails says so and keeps it.
- **ROW-4** The row's other ways in are unchanged: a tap opens the details page (DET-1), and a swipe still deletes with Undo and no question (DEL-2). Transfer rows keep the swipe alone until they have a details page of their own (DET-7).

## 29. Reminders

**They do:** neither app ever speaks first. Recurring rules have an upcoming list and the notes tab has dates and times, but nothing on the phone says anything; remembering is left entirely to the user.

**Learn:** a list only reaches someone who has already opened the app, which is exactly the person who did not need reminding. But a reminder that arrives whether or not it is needed teaches people to swipe it away, and then the one that mattered is swiped away with it. So the app speaks only when it knows something — a rule the user wrote is due and unhandled, or a day is ending with nothing in it — and it stops on its own when it turns out not to be wanted.

- **NUDGE-1** Two reminders and no others: a recurring entry that was due and has not been handled, and a day that is ending with nothing recorded. Both are local notifications from the device's own notification system, as a note's reminder already is (NOTE-6). Nothing is sent anywhere, and nothing leaves the phone (BAK-6, ADS-7).
- **NUDGE-2** The due one is specific: it names what was due and for how much, in the words of the rule the user wrote (section 8), and it appears only while that occurrence is still unhandled. Several due on the same day are one notification, not one each. Tapping it opens the upcoming list, and nothing is ever recorded from a notification — a proposal is confirmed by a person, exactly as a bank's is (BANK-3, ALERT-4).
- **NUDGE-3** The empty day is asked for, never assumed. It is off until the user turns it on, and the app offers it once — after they have recorded on three separate days, so it reaches someone who has shown they want the habit rather than someone still deciding. Declined, it is never offered again, and the switch stays in Settings for whenever they want it.
- **NUDGE-4** It fires only on a day that really is empty, at a time the user chose, nine in the evening until they change it. A day with anything recorded in it is a day the app says nothing, however long ago they last opened it.
- **NUDGE-5** It goes quiet by itself: three in a row that are neither opened nor followed by an entry that day, and it stops, with Settings saying why and one tap to start it again. A reminder people swipe away has already stopped working, and it is better for it to admit that than to keep teaching them that the app is worth ignoring.
- **NUDGE-6** At most one a day, whatever is waiting, and never between ten at night and eight in the morning by the device's own clock. A day with something due is not also told that it is empty.
- **NUDGE-7** Permission is asked when the user first turns a reminder on, never at first run, and everything else works if it is refused (NOTE-6). A refusal is not asked about again; Settings says the phone is not allowing them and how to change that.
- **NUDGE-8** With app lock on a reminder names nothing: it says only that the app has something waiting, and tapping it opens through the lock (LOCK-2, NOTE-6).
- **NUDGE-9** Inexact alarms, so Play is never asked for the exact-alarm permission and Android may deliver a few minutes late. Reminders are rescheduled after a reboot and after a restore, as a note's are (NOTE-6).
- **NUDGE-10** Android and iOS only. The desktop builds schedule nothing, and Settings does not offer what they cannot do.

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

## Decisions (17 September 2026)

13. Setup stays the first screen, because the language picked there is the language the walkthrough is read in — considered turning the order around on 17 September 2026 and decided against it the same day. What does move is the pair of actions for people arriving from elsewhere: "Restore a backup" and "Import a CSV" leave the setup page for a fifth walkthrough page, so setup asks only what the app itself needs (RUN-3, RUN-4).
14. Banner ads ship in v1, with a real ad network, which ends "no ads, ever" (section 22). They bring the `INTERNET` permission with them (RUN-2), so the Play data-safety form, the App Store labels, the privacy policy, the walkthrough's privacy page, and the store listing all change in the same release. Nothing the user typed is ever handed to the network (ADS-7).
15. The app matches the competitor's languages: 21 in all, adding Bengali, Chinese (Simplified), Dutch, Greek, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Thai, Urdu, and Vietnamese to the six it has (LANG-1). Urdu makes right to left a two-language case (LANG-5), and the PDF report needs fonts covering the new scripts (PDF-5).
16. The three-dot menu becomes a navigation drawer (section 23), because nothing in it was being found.
17. Tapping the period label on Home opens the calendar for that period (INS-4).
18. Ads can be bought away: "Remove ads" is a one-time purchase, not a subscription and not a rewarded video (PAY-1). Every feature stays free with or without it (PAY-4).
19. Plus is a subscription — yearly, with a monthly option — because what it buys costs us every month (PAY-2). It hides the ads while it runs, and it is shown as "coming soon" with no price until the connection works (PAY-3).
20. What Plus sells is a real bank connection through a licensed open-banking provider, not notification scraping: transactions arrive whole, so nothing is missed (BANK-1, BANK-2). It brings a server, a provider contract, per-user fees, and the one place where the app's data leaves the device (BANK-5), all of which the privacy policy and the store listings must say plainly. Which market comes first is not decided: the first task is a coverage check of the banks that matter against what the providers actually reach and charge.
21. Reading bank notifications stays, but free and outside Plus: it is the answer for banks and countries no provider reaches, Android only, parsed on the device, and honest about seeing only what the bank announces (ALERT-1–ALERT-7).
22. A tap on a transaction opens it to read, not to edit (section 26). The form is one button away and unchanged; a read-only copy of the form was rejected as the worst of both. Transfers are unchanged for now (DET-7).
23. The report ships fonts for 18 of the 21 languages; Chinese, Japanese and Korean wait for a face that can be downloaded (PDF-7). Measured against the alternative: Noto Sans SC is 17.8 MB, JP 9.6 MB and KR 10.4 MB, where Devanagari, Bengali and Thai together are 0.86 MB.
24. The slots go in the `Scaffold`'s bottom bar rather than at the end of the body, which is what makes ADS-3 true by construction: the list scrolls above them, the add button lifts over them, and the system navigation bar is below. The height is the anchored adaptive one, asked for before any ad is requested and the same for a given width, so an arriving ad can never shift what is under a finger (ADS-2).
25. Development builds serve Google's test units, release builds the real ones (ADS-10). Decided 17 September 2026 after the accounts were ready: the choice was never between test and live IDs but between risking the AdMob account and not, since AdMob suspends accounts over self-clicks. One constant, `AdsConfig.liveAdsEverywhere`, turns it off for a deliberate check of a real fill.
26. The Android release check turns around rather than going away. It used to fail if the APK asked for `INTERNET`; it now fails if the APK does *not* ask for it, and also if any of the permissions that would let the app read the user's life — location, contacts, calendar, messages, call history, sensors, all-files, package queries — has crept in through a plugin update (ADS-7, RUN-2).

## Decisions (18 September 2026)

27. The store identity becomes `com.oasisforge.monthlyexpenses`, in the Oasis Forge namespace every future app will share, replacing `com.monthlyexpenses.app`. Decided the morning of the first Play upload, which is the last moment a package name can change; the old one was never uploaded anywhere. Users see it only in the store URL, so this is for the studio's order, not for them. The store *title* is "Monthly Expense Tracker", for search, while the name under the icon stays "Monthly Expenses", which fits without being cut off.

28. Home gets a budgets card (BUD-7, BUD-8), decided in the roadmap review. Budgets were a tab away in Insights, and Home only mentioned them once one was already over; now how the month is going is on the first screen, one line until it is opened. It replaces the over-budget notice, whose news the card's red line carries, and stays slim: the per-day detail is one tap away in Insights.

## Decisions (19 September 2026)

29. Home opens on today, with a week of days above the list to move between them (section 27, DAY-1–DAY-9). Home named the month but never the day, so an entry that is nearly always today's began life in a list of the whole month, and reaching another day meant scrolling or the calendar. The month list stays one tap away (DAY-5), and each day now carries its own total (DAY-7).

30. A transaction row gets a three-dot menu of its own — Duplicate and Delete — in every list that shows one (section 28, ROW-1–ROW-4), and Delete from it asks before it acts, which is the one place DEL-2's "no confirmation" now bends: the gesture keeps its speed, the menu tap gets a moment of thought. A form also stops losing what was typed into it: Back closes the keypad, and the next one asks (ADD-9). Both came out of using the app by hand.

31. Home's summary card can be one line (BAL-6), and scrolling the day list collapses it (BAL-7): on a phone the fixed header — period, day strip, summary, notices — was eating the list it sits above. The strip itself is now on every Home, the welcome included (DAY-2). And the trash finally holds transfers (DEL-5): deleting one offered Undo and nothing else, so a transfer deleted a minute earlier was already beyond recovery, and one deleted before a relaunch was forgotten entirely. Found by asking what the trash was tested for.

32. The summary card moved inside the day list's scroll, as a pinned header (BAL-7). Sitting above the scroll view, collapsing it resized the list's viewport: measured, the entries lurched upward at twice the speed of the finger, and on a list with less than about 142px of slack the offset was corrected back below the threshold and the card sprang open again — which is why it seemed to work with the budgets card open and not with it closed, that card being worth about 144px. Inside the scroll there is nothing to resize and no state to oscillate. The budgets card folds on scroll the same way (BUD-9).

## Decisions (20 September 2026)

33. Home can show one account instead of every one (ACC-6–ACC-9). Accounts existed and every transaction belonged to one (ACC-1), but Home could only ever total all of them, so "how much is on the card this month" meant Search. The switch went on the summary card rather than the toolbar, which has no room for a third action (NAV-6), and the card's label names the chosen account in place of "Balance" so a filtered figure cannot be mistaken for the whole of the money — including when the card is its one line (BAL-6).

34. The filter is the app's, not Home's, and every screen that follows it names it (ACC-6, ACC-7). It was built for Home alone, and driving it on the phone showed why that was wrong twice over: Insights was already following Home's choice, because it reads the same period totals — silently, with nothing on screen saying so, which is exactly the misreading the rule now forbids. Budgets were following it too, and there the number was simply false: with a card selected the card read "0% used" of a food budget that was 60% gone. Budgets now always count every account, and Insights names the account it is showing. A new entry started while one account is showing begins on that account (ACC-9), ahead of ADD-3's "last account used" — a filtered screen is a stronger signal of where the money went than whatever was typed last.

35. One account's carried-forward and closing figures take in its transfers (ACC-8). Across every account a transfer nets to zero, which is why BAL-1 leaves it out of income and expense entirely; within one account it is money arriving or leaving, exactly as ACC-4 already counts it, so leaving it out would have shown a balance that disagreed with the Accounts screen.


36. A full-screen ad, once a day, at a seam (ADS-11–ADS-16). ADS-1 had banned interstitials outright, and the ban was right about what it feared: an ad inside the entry loop would cost more in ratings than it could ever earn. It also left the app with the format that pays least, at a fraction of an interstitial's rate, which is a strange way to fund a free app. The reversal keeps the fear and drops the ban — the ad may appear only where a job has just ended and nothing is half-finished, at most once in a day, never before three days and ten entries have passed, and never at the price of a wait (ADS-13). App-open ads were refused for the very reason the ban existed: they land between tapping the icon and typing an amount, which is the whole of what the app promises. Ads dressed as rows in the day list were refused because that list is the user's own money.

37. Android's own automatic backup is refused (BAK-8). It came up while answering what a second person on the same phone would see. The purchase turned out to be safe — nothing about it is cached, and `restorePurchases()` asks the store at every launch, so a different Google account is offered the price again — but `android:allowBackup` had never been set, and its default is on. Android was quietly copying the database and the settings to the user's Drive, and putting them back for whoever next installed the app under that account. "Nothing you record leaves your device" is the first line of the privacy policy and it was not quite true. Device-to-device transfer is left alone: carrying your own data to a new phone is not the same as a copy kept somewhere else. The cost is that a reinstall now starts empty, which is what the app's own backup is for.

38. The app may speak first, twice and no more (NUDGE-1–NUDGE-10). Recurring reminders were dropped on 18 September 2026, and RCR-7 left notifications for later; both are reversed, because the entries people miss are exactly the ones an upcoming list never reaches — it is read by whoever already opened the app. The due-entry reminder is safe to give freely: it fires only for a rule the user wrote, on the day it was due, and it proposes rather than records. The empty-day nudge is the one that could become a nag, so it is the one that has to be asked for (NUDGE-3), fires only on a day that really is empty (NUDGE-4), and stops itself after three that are ignored (NUDGE-5). Budget thresholds and a period wrap-up were offered and left out: each is another message in twenty-one languages, and neither is something the user asked to be told. Nothing new goes on the phone for this — notes have had local notifications since NOTE-6, with the permission, the inexact alarms and the rescheduling already in place.
## Roadmap impact
These schema changes land in Phase 1 of `docs/ROADMAP.md`, before any feature work and long before release:
- amounts as integers (MONEY-1)
- a categories table, referenced by ID (CAT-1)
- an optional title (ADD-1)
- `deleted_at`, `created_at`, and `updated_at` on every table (DEL-1, REC-1)
- an accounts table with a default "Cash" account, and an account on every transaction (ACC-1, ACC-2)
