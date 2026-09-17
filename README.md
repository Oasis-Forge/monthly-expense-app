# Monthly Expense App

A simple Flutter app to track your monthly income and expenses, built around
what popular free trackers get right and what they get wrong.

## Features

- Add income and expense transactions with title, amount, category, date, and an optional note
- Month-by-month view with a running balance, total income, and total expense
- Transactions grouped by day
- Category breakdown with a pie chart (Stats screen)
- Edit or swipe-to-delete any transaction
- All data stored locally on-device (SQLite via `sqflite`) — no account or internet required

## Tech stack

- Flutter / Dart, Material 3
- `provider` for state management
- `sqflite` for local persistence
- `fl_chart` for the category pie chart
- `intl` for date and currency formatting

## Getting started

```bash
flutter pub get
flutter run
```

## Project structure

```
lib/
  models/        Transaction model and category definitions
  db/            SQLite database helper
  providers/     TransactionProvider (state + derived monthly stats)
  screens/       Home, Add/Edit transaction, and Stats screens
```
