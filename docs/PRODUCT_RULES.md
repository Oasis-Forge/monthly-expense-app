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
- **REC-2** Every record ID is a UUID v4, so records from a backup never collide with records on the device.

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
- **ACC-4** Account balance = opening balance + income − expense − transfers out + transfers in, counting from the opening date.
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
- **SRCH-3** Results show the count and the income and expense totals of the matches.

## 11. Backup, restore, and export

**They do:** backup as a raw database file or to Google Drive, PDF and Excel reports, a Google Drive prompt on first launch, and an "email statement automatically" setting that is on by default. What that setting sends: not verified.

**Learn:** a raw database file breaks across schema versions. Defaults that send data off the device conflict with our principles.

- **BAK-1** Backup is a JSON file recording the app version and schema version, saved or shared only when the user chooses to.
- **BAK-2** Restore offers Replace (the backup replaces all current data) or Merge (BAK-3). Before either, the app saves an automatic backup of the current data.
- **BAK-3** Merge matches every record by ID (REC-2). Records only in the backup are added. When both sides have a record, the one with the later `updated_at` wins, including deletions (DEL-1). Transactions, categories, accounts, budgets, and recurring rules all merge this way. The app then shows how many records were added, updated, and unchanged.
- **BAK-4** A backup from a newer schema is refused with a message to update the app. Older backups are migrated before Replace or Merge.
- **BAK-5** CSV export covers the current view (period and filters), with ISO dates and plain decimal amounts.
- **BAK-6** Nothing leaves the device without an explicit user action. No cloud sync, no scheduled email.
- **BAK-7** A backup reminder appears only after 20 transactions, then at most every 30 days since the last backup, and can be turned off. Never on first launch.

## 12. Currency and formatting

**They do:** only a number-format choice; no currency symbol.

- **CUR-1** One currency for the whole app in v1, chosen from a searchable ISO list and preselected from the device locale.
- **CUR-2** Amounts are formatted with `intl` for the device locale and the currency's decimals (JPY 0, USD 2, KWD 3).
- **CUR-3** Changing the currency changes labels only, never values. The app warns before applying it.

## 13. First run and trust

**They do:** open straight to Home with a Drive backup prompt and a banner ad; the default account uses the app's name.

- **RUN-1** The first launch opens Home with one clear "Add your first transaction" action. The currency is preselected and changeable in Settings. No prompts before first use.
- **RUN-2** The Android release build declares no `INTERNET` permission while the app has no feature that needs it, so the store listing can truthfully say "no data collected".

## Decisions (13 September 2026)
1. Title stays, as an optional field (ADD-1).
2. Future-dated transactions count only once their date arrives (BAL-4).
3. Recurring transactions wait for a tap by default (RCR-2).
4. Restore offers both Replace and Merge (BAK-2, BAK-3).
5. First day of month is in v1 (PER-2).
6. Accounts and transfers are in v1 (section 6).

## Roadmap impact
Schema v2, in Phase 1 before release, so no real user data needs migrating later:
- amounts as integers (MONEY-1)
- a categories table, referenced by ID (CAT-1)
- an optional title (ADD-1)
- `deleted_at`, `created_at`, and `updated_at` on every table (DEL-1, REC-1)
- an accounts table with a default "Cash" account, and an account on every transaction (ACC-1, ACC-2)
