# Monthly Expenses: a plan to compete

Written 2026-09-21 from the roadmap, the product rules and a skim of the screens, not from using the
app for a month. It proposes what to build next so the app stands beside the popular trackers, and
it keeps one test for every item: does it stay easy? `docs/ROADMAP.md` and `docs/PRODUCT_RULES.md`
remain the source of truth; this file says what to add and in which order.

## How to work this plan (read first)

- One theme per PR, branch from a freshly pulled `main`. **Every merged PR is a release**: CI wants a
  SemVer bump above `main` and a line under `Unreleased` in `CHANGELOG.md` written for users. The
  first branch should also merge `origin/chore/kit-update` (the kit refresh waiting there, no PR of
  its own).
- Rules first. Every feature starts as rules in `docs/PRODUCT_RULES.md`, in the file's own pattern
  (a section with "They do" and "Learn", then numbered rule IDs), and the roadmap item cites them.
  Then strings in all 21 languages (`tool/add_messages.dart` adds one message to every ARB; read its
  header), then tests, then the screen.
- Nothing that works today moves behind a payment (PAY-4), no new network calls in the free app
  (RUN-2), and no new setting unless the feature is useless without one. Settings has fourteen rows;
  aim to keep it there.
- Mechanical passes (21-language strings, changelog, golden updates) go to Sonnet; rules, schema
  steps and anything touching money stay on the strong model.

## What the app is today

An offline, no-account tracker with a lot of depth: accounts and transfers, budgets with a per-day
allowance, recurring rules, notes, calendar and trend insights, a PDF report, CSV import and export,
backup and restore, photo and voice attachments, app lock, a home-screen widget with add buttons,
21 languages including right-to-left, ads with a one-time "Remove ads", and a Plus tier planned
around Drive backup and, later, a bank connection. Home opens on today with a week strip, a summary
that collapses to the balance, a budgets card and the day's entries. Version 1.23.0, on Play's
internal track, with the closed test running since 18 September 2026.

It already does more than most free trackers. What it lacks is not features but the few numbers and
touches that make people say "this one gets me": a colour per category, one hero number, a
comparison with last month, and entries that arrive by themselves.

## Phase A: polish (small PRs, mostly no schema)

**A1. A colour per category.** Categories have an icon and no colour. Add a `color` column (schema
step) filled from a fixed palette of 16 by the category's index, changeable in the category editor
from that palette only. Rows draw the icon in a tinted circle, and the category chart uses the same
colours, so the list and the chart agree at a glance. Rule under section 4; tests for the migration
and for the chart taking the category's colour.

**A2. Numbers that line up.** Tabular figures on every amount (`FontFeature.tabularFigures`), one
sign and colour convention across Home, Insights, Accounts and the PDF, and the balance rolling to
its new value when an entry is saved. No new strings.

**A3. Haptics.** A light tick on keypad keys, a medium one on save, a selection tick at the
swipe-to-delete threshold. It follows the phone's vibration setting; no toggle. Cannot be verified on
the emulator: say so in the PR.

**A4. The phone's own colours, and pure black.** On Android 12+ default to the wallpaper palette
(`dynamic_color`) with today's purple as the fallback, and add a "Black background" choice for OLED
screens. Both live inside the existing Theme row as choices, not as new rows.

**A5. One action in every empty state.** Home has it (RUN-1) and Notes grew it later. Recurring is
the only other list that can be empty, and it gets the same shape from one shared widget. Budgets
and Accounts cannot be empty at all — Budgets lists every expense category whether or not it
carries a limit, and ACC-2 guarantees a Cash account — so neither gets one. The trend with a single
period says a trend needs more than one and offers nothing, because only time fills it. Rules
EMPTY-1 to EMPTY-4.

**A6. Accessibility pass.** Largely already paid for: `test/languages_test.dart` holds seventeen
screens at 1.3x text in all twenty-one languages, every icon button already carries a tooltip, and
the amount colours moved into one file in 1.23.0. What was added is contrast cover for the two new
themes — true black, and a wallpaper palette — and the check that colour alone never separates
income from expense, since the two inks are all but the same brightness and the sign is what
carries the meaning. Rules A11Y-1 to A11Y-4.

## Phase B: the numbers people open the app for

**B1. Left to spend.** The collapsed summary's hero line. With an overall budget (BUD-1): "Left to
spend X · Y a day", using the per-day allowance BUD-3 already computes. Without one: "Spent X · Y a
day so far" and one tap, "Set a monthly budget", that opens the overall budget with last period's
spending prefilled. This is the single most valuable change in the file: it is the number people
check three times a day, and it needs no new data. Rules touch BAL-6, BAL-7 and section 7.

**B2. This month against last.** In the Insights category chart each category shows its change
from the previous period ("+12%" or "−40"), and the chart's header says "Spent X, Y less than last
month". Pure arithmetic on existing data; tests in `insights_test.dart` for the change, for a
category with nothing last period, and for the first period ever.

**B3. The monthly review — built, then dropped on 24 September 2026.** Home already carries a
balance card, a budgets card, three notices, a rating ask and an update ask; the review card made a
ninth thing competing for the top of that screen, and it broke three existing tests by pushing the
backup reminder, the Budgets header and the day list out of reach — which is the screen saying it is
full. What it said was not new either: Insights already compares a period with the one before it
(INS-6) and the trend already puts the months side by side, permanently and with charts, rather than
once for a few seconds. Do not rebuild it. If "nobody opens Insights unprompted" turns out to be
worth answering, answer it inside Insights or in the notice row that already exists, not with a card
of its own.

**B4. Bills, and what everything adds up to.** The Recurring screen gets a header: "X a month in
bills", the monthly-normalised sum of recurring expenses, and "next: <name>, in 3 days". The Accounts
screen gets a total line across accounts. Both are missing today and both are one computation each.

## Phase C: getting found and rated

**C1. Ask for a rating at the right moment.** `in_app_review` after 15 saved entries and 7 days since
first run, once per version, never right after an error and never while the app is locked. The
decision is a pure function with a test; the prompt itself is the store's.

**C2. App shortcuts.** Long-press the icon: Add expense, Add income, Transfer (`quick_actions`), the
same three as the drawer's adding group. Android and iOS. Tiny, and the kind of thing reviews mention.

**C3. Store listing refresh.** Screenshots that show the hero number, the category colours and the
calendar; the first line of the description says offline, no account, free, because that is the
trust story (section 13). The screenshot tooling under `store/` exists. Not a code PR.

**C4. Keep what is planned, add no other monetisation.** Reminders (finish and tick), one
interstitial a day at a seam (ADS-11 to ADS-16), Plus with Drive backup. Nothing else goes on sale.

**C5. A newer version waiting.** Play's own flexible update flow at the seam after a save, once a
day, never blocking, and it outranks the rating ask. Android only: iOS has no equivalent and the
desktop builds make no network calls. Rules UPD-1 to UPD-5.

## Phase D: the flagship, entries the phone already knows about

Section 25's ALERT-1 to ALERT-7 are written and unscheduled. They are the feature no offline tracker
has, and they stay on the device. Android only, free, in three PRs:

**D1. Notification capture, minimal.** Android's notification-access screen, a picker of the apps to
read, and every notification from them becomes a proposal in a review list: amount is the first number
in the account currency's format, merchant is the notification's title, date is when it arrived,
category is the last one used for that merchant or none. The user confirms, edits or discards;
nothing is guessed (ALERT-5). Duplicates reuse the import check (IMP-8, BANK-4). Play Console needs the
notification-listener declaration and the listing the sentence ALERT-7 asks for; SMS permission is
never requested. Tests: the parser on a dozen real notification wordings in the top languages, and
the review flow.

**D2. It learns from corrections.** A small table of merchant to category and account, written when
the user corrects a proposal, so the second coffee is one tap. Rule ALERT-5 already promises it.

**D3. The review line on Home.** "3 to review" above the day list while proposals wait, gone when
they are handled. It is the only place the feature shows on Home.

## Not now, on purpose

Cloud sync and shared wallets (a server and accounts, against the no-account promise), receipt OCR
(model size and accuracy, and photos already attach), split transactions, tags, per-account
currencies, savings goals, streaks or badges, and an assistant. Each adds a screen, a setting or a
promise the app cannot keep offline. The answer to "what about X" is the review list and Plus.

## Suggested order

| # | PR | Version | Shipped |
|---|---|---|---|
| 1 | A1 category colours, with the kit-update merge | minor | 1.22.0 |
| 2 | B1 left to spend | minor | 1.22.0 |
| 3 | A2 numbers and A3 haptics | minor | 1.23.0 |
| 4 | B4 bills and totals | minor | 1.23.0 |
| 5 | B2 this month against last | minor | 1.24.0 |
| 6 | C1 rating prompt and C2 shortcuts | minor | 1.25.0 |
| 7 | A4 dynamic colour and black | minor | 1.26.0 |
| 8 | A5 empty states and A6 accessibility | minor | 1.26.0 |
| 9 | C5 the update offer | minor | 1.26.0 |
| 10 | D1, D2, D3 in order | minor each | — |

C3 fits after PR 5, when the screenshots have something new to show. The roadmap's own open items
(the closed test on Play, the interstitial, reminders, Drive backup, the desktop and Apple stores)
keep their place; this list slots between them. Reorder after a week of real use if the hero number
or the review list turns out not to be what people want.
