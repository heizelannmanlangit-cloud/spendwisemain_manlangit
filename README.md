# SpendWise — Personal Expense Tracker

Lab 05 — Mobile Applications Development
Local Data Persistence with Hive (Flutter)

## What this app does

SpendWise is a personal daily expense tracker that stores all data
locally on the device using the Hive database. It implements:

- **Exercise 1** — Full CRUD (Create, Read, Update, Delete) of expenses,
  category filter chips, a summary card, and persistence across app
  restarts.
- **Exercise 2** — A monthly budget feature: set a budget, see a
  progress bar comparing spending vs. budget, and get an orange
  SnackBar warning when you cross 80%.
- **Exercise 3** — Export the current month's expenses to a plain-text
  file (`spendwise_YYYY_MM.txt`) saved to the app's documents
  directory using `path_provider`.

## How to run it

### 1. Prerequisites
- Flutter SDK 3.0 or higher (`flutter --version` to check)
- Android Studio with an emulator OR a physical Android device with
  USB debugging enabled

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Run the build_runner (generates expense.g.dart)
The generated file is already committed, but if you ever modify
`lib/models/expense.dart`, regenerate the adapter with:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Launch the app
```bash
flutter run
```
Choose your Android emulator or device when prompted.

### 5. Verify Exercise 3 (Export)
After tapping the download icon in the app bar:
- Open Android Studio → **Device File Explorer**
- Navigate to `/data/data/com.example.spendwise/app_flutter/`
- You should see `spendwise_YYYY_MM.txt` — open it to see the report.

## How to test data persistence (Exercise 1 verification)

1. Add at least 5 expenses across at least 3 different categories:
   - "Jollibee Chickenjoy" — ₱175 — Food
   - "Grab Ride" — ₱85 — Transport
   - "Globe Load" — ₱50 — Utilities
   - "SM Sneakers" — ₱350 — Shopping
   - "GCash Transfer" — ₱200 — Other
2. Fully kill the app (swipe it out of recent apps, not just background).
3. Reopen the app.
4. All 5 expenses should still appear in the list.

## Project structure

```
lib/
├── main.dart                          # App entry, Hive init, runApp
├── models/
│   ├── expense.dart                   # Expense model + ExpenseCategory enum
│   └── expense.g.dart                 # Generated TypeAdapters (do not edit)
├── services/
│   ├── expense_service.dart           # CRUD wrapper around the Hive box
│   └── export_service.dart            # Exercise 3 — monthly export
├── screens/
│   ├── home_screen.dart               # Dashboard, summary card, list, budget
│   ├── add_expense_screen.dart        # Form to create a new expense
│   └── edit_expense_screen.dart       # Form to edit an existing expense
└── widgets/
    └── expense_tile.dart              # Swipe-to-delete list tile
```

## Quick tests
```bash
flutter test          # runs the widget smoke test
flutter analyze       # static analysis (should be clean)
```
