# Competitor analysis: a widely installed free tracker (Android)

_Researched 13 September 2026, with a later look in the same month. The app is a free income-and-expense tracker with millions of installs; it is not named here._

**How:** we installed it from Google Play on an emulator and used it with made-up data, and we read its manifest metadata and its Play data-safety page. Everything below is described in our own words; nothing from it (assets, text, code) was copied, and it is not named or linked to anywhere in this repository.

**Not explored:** Google Drive backup, generating PDF/Excel files, the passcode/fingerprint lock, saving a recurring rule, subcategories in depth, purchases.

## At a glance

| Area | The other app | Monthly Expenses today | Our plan |
|---|---|---|---|
| Account / sign-in | None needed | None needed | Keep it that way |
| Ads & tracking | Banner ad on most screens from first launch; a third-party ad network; advertising ID and ad attribution; device IDs shared for ads/analytics | None | Two banner slots (Home, Insights), none before the walkthrough is done, and nothing about the user's money given to the network (section 22, decided 17 September 2026) |
| Price | Free with ads; ads removed by a monthly or yearly subscription, or a one-off lifetime price, and a rewarded video buys a week without them | Free | Free with two banners; one payment removes them for good (PAY-1), and a dearer Plus adds the bank connection when it exists (PAY-2). No subscription, no rewarded video |
| Adding a transaction | Calculator keypad, recent categories, payment method, notes autocomplete, receipt photo, line items; form resets after Save for fast repeat entry; duplicate | Title, amount, category dropdown, date, note | Keypad, recent categories, "Save & add another", duplicate |
| Date entry | Day arrows only moved forward (bug); calendar dialog works | Date picker | Arrows both ways + picker |
| Categories | ~61 expense + 7 income with icons, custom categories, optional subcategories | 10 expense + 6 income, fixed | ~15 curated defaults + custom |
| Accounts & transfers | Multiple accounts (name only), transfers, payment methods (bank/card/cash) | None | Named accounts with opening balance; transfers |
| Budgets | Per category, weekly/monthly/yearly, remaining + per-day allowance, copy last month | None | Per category/month with per-day allowance |
| Reports | Donut chart by category (with %), income/expense trend lines, payment-method chart, custom periods | Monthly pie chart | Trend chart, custom periods |
| Calendar view | Month grid with daily income/expense totals | None | Yes |
| Recurring & reminders | Repeat daily–yearly, end never/after N/on date, pause; upcoming list | None | Same, plus notifications later |
| Notes (checked on a later build) | A notes tab holding a dated to-do list (text, date, time, done checkbox) with period and status filters, search, counts, and a PDF of the list. No reminders or links to transactions; delete is permanent. Counts went stale and search ignored the status filter | A note field on each transaction | Notes with due dates, reminders, and "Record as transaction" (NOTE-1–NOTE-8) |
| Search & filters | Keyword search (unreliable in testing), filters by category/type/payment method, sort | None | Reliable text search + filters |
| Export & backup | PDF/Excel reports, local `.db` backup, Google Drive, scheduled email statements | None | CSV + JSON backup first, PDF later |
| Deleted items | Trash for deleted transactions | Swipe delete, no undo | Undo now, trash later |
| Security | PIN and fingerprint lock | None | Optional PIN/biometric |
| Currency | Number format only; no currency symbol or multi-currency | Hard-coded `$` | Currency picker (**better**) |
| Personalization | Dark mode toggle, first day of week/month/year, carry-forward balance, dashboard widgets toggles | Follows system theme | Theme toggle, first day of month/week, carry-forward balance |
| Languages | 20 besides English in its own strings, Portuguese only partly (its picker showed 16) | 6: English, Turkish, Arabic, French, Spanish, German | Match their set: 21 with English (LANG-1) |
| Getting around | Bottom tabs for home, calendar and notes, a drawer, and an overflow menu | A three-dot menu holding everything but Home | A grouped navigation drawer (NAV-1–NAV-5) |
| Reading the bank | Nothing: every entry is typed | Nothing | Plus connects to the bank through an open-banking provider, so nothing is missed (BANK-1); free notification reading on Android covers banks no provider reaches (ALERT-1). Both propose, and the user confirms |

## What they do well (worth matching)
- **Fast repeat entry:** the form stays open after saving, keeps the last category, and opens a calculator keypad on the amount.
- **Dashboard control:** users pick which home sections appear (recent transactions, category chart, budget, trend).
- **Calendar with daily totals:** the quickest way to spot heavy spending days.
- **Budgets with a per-day allowance:** turns a monthly limit into a daily number people can act on.
- **Carry-forward balance:** each month starts from the previous month's closing balance.
- **Core features are free:** only ad removal is paid, which sets user expectations for this category.

## Weak spots (our opening)
1. **Ads and tracking everywhere:** a persistent banner from the first screen, an ad network SDK, advertising-ID access, and device IDs shared with third parties. Its data-safety page offers no way to request data deletion. We take the ads and none of the rest: two slots, nothing before the walkthrough is finished, and the network told nothing about the user's money (ADS-1, ADS-4, ADS-7).
2. **No real currency support:** money always shows as bare numbers.
3. **Clutter:** about 68 default categories, two separate navigation drawers, and settings spread across menus.
4. **Rough edges:**
   - The date arrows can't go backward.
   - Search dropped keystrokes and didn't filter.
   - The default account shares the app's name.
   - Pressing Back from deep screens can exit the app.
5. **Thin accounts:** an account has only a name, with no opening balance, type or currency.

## Positioning
**"The expense tracker that respects you":** no account, nothing about your money leaving the device unless you export it, and the few ads it does show kept out of the way. It's open source, has the essentials done well, and a clean interface with fewer, better defaults.

Ads were decided on 17 September 2026 (section 22 of `docs/PRODUCT_RULES.md`), so "no ads" is no longer the line. What is left of it, and what the listing should say, is how few and how quiet they are — two banner slots, none of them interrupting, none before the walkthrough is done — and that the ad network is handed nothing about the user's records.

Every feature we add has to keep that promise, and the privacy policy is updated whenever one touches user data.

## Roadmap impact
`docs/ROADMAP.md` Phase 3 is re-ordered around this analysis:
1. Settings with a currency picker.
2. Faster entry.
3. Backup and CSV export.
4. Search.
5. Budgets.
6. Recurring transactions.
7. Insights: calendar, trends and carry-forward balance.
8. Accounts and transfers.
9. App lock and trash.

Phase 2 also gains localization scaffolding, so translations don't require touching every screen later.
