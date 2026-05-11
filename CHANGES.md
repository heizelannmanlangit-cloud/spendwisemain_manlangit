# Changes from the original `spendwise-main.zip`

This file documents the three fixes applied to bring the project in
line with the Lab 05 specification. Keep it for your own reference;
delete it before submitting if your instructor wants a clean tree.

## 1. `lib/services/export_service.dart` — rewritten

**Problem:** The original file imported `dart:html` and used
`html.Blob` / `html.AnchorElement` to trigger a browser download.
This is web-only code; it will **not compile or run on Android/iOS**,
which is what the lab grades you on. The lab explicitly says the file
must be saved on the device using `path_provider`, and tells you to
verify it at `/data/data/com.example.spendwise/app_flutter/`.

**Fix:** Replaced with the spec-compliant version that:
- Imports `dart:io` and `package:path_provider/path_provider.dart`.
- Calls `getApplicationDocumentsDirectory()` to get the documents path.
- Writes the report with `File(...).writeAsString(...)`.
- Returns the real `file.path` (not a fake "Downloads/..." string).
- Uses `e.categoryName` (returns "Food", "Transport", ...) instead of
  `e.category.name` (returns "food", "transport", ...) so the report
  matches the format shown in the lab manual.

## 2. `test/widget_test.dart` — replaced

**Problem:** The original was the unmodified Flutter counter template.
It looked for `find.text('0')` and tapped `Icons.add` as if SpendWise
were a counter app. `flutter test` would have failed immediately,
which can cost points and looks bad in code review.

**Fix:** Replaced with a real smoke test that:
- Initializes Hive in a temp directory with `Hive.init('.')`.
- Registers both adapters (with `isAdapterRegistered` guards so it is
  safe to re-run).
- Opens the same boxes `main.dart` opens.
- Mocks `path_provider` so it doesn't blow up in the test harness.
- Pumps `SpendWiseApp` and asserts the HomeScreen renders correctly
  (title visible, "Add Expense" FAB visible, empty-state message).

## 3. `README.md` — rewritten

**Problem:** The original was the default Flutter `flutter create`
README, which says nothing about SpendWise, how to run it, or how to
verify the lab requirements.

**Fix:** Wrote a clear README describing what the app does, how to
run it, how to verify Exercise 1 persistence, and how to find the
exported file from Exercise 3.

## What was already correct in your friend's code

- `pubspec.yaml` — all dependencies are correct, including
  `path_provider`.
- `lib/main.dart` — Hive init, adapter registration, and box opening
  are all done in the right order.
- `lib/models/expense.dart` and `expense.g.dart` — model and generated
  adapter are correct.
- `lib/services/expense_service.dart` — all four CRUD methods plus
  helpers (`getTotalExpenses`, `getMonthlyTotal`) and `listenable`.
- `lib/screens/home_screen.dart` — summary card with progress bar,
  filter chips, FAB, budget dialog, 80% SnackBar warning — all there.
- `lib/screens/add_expense_screen.dart` and `edit_expense_screen.dart`
  — both forms with validation, date picker, category dropdown.
- `lib/widgets/expense_tile.dart` — `Dismissible` with red swipe
  background and confirmation dialog.

Your friend did the heavy lifting; you just need the three fixes above
to pass the rubric.
