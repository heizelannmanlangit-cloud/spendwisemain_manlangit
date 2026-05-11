import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/export_service.dart'; // Exercise 3 Import
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExpenseCategory? _selectedCategory;

  String _label(ExpenseCategory? cat) {
    if (cat == null) return 'All';
    switch (cat) {
      case ExpenseCategory.food:          return 'Food';
      case ExpenseCategory.transport:     return 'Transport';
      case ExpenseCategory.shopping:      return 'Shopping';
      case ExpenseCategory.utilities:     return 'Utilities';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.other:         return 'Other';
    }
  }

  // --- EXERCISE 2: Set Budget Dialog ---
  void _showBudgetDialog() {
    final settingsBox = Hive.box('settings');
    final controller = TextEditingController(
      text: settingsBox.get('monthly_budget')?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Monthly Budget"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Budget Amount (₱)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double? val = double.tryParse(controller.text);
              if (val != null) {
                // Save a budget value (Stored in 'settings' box)
                await settingsBox.put('monthly_budget', val);
                Navigator.pop(context);
                setState(() {}); 
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // EXERCISE 2: Budget Button
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: _showBudgetDialog,
          ),
          // EXERCISE 3: Export Button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final path = await ExportService.exportCurrentMonth();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Exported to: $path"), backgroundColor: Colors.green),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'SpendWise',
              applicationVersion: '1.0.0',
              children: [const Text('A personal expense tracker built with Hive.')],
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: ExpenseService.listenable,
        builder: (context, box, _) {
          // --- EXERCISE 2 HINT CODE LOGIC ---
          final settingsBox = Hive.box('settings');
          final double budget = (settingsBox.get('monthly_budget') ?? 0.0) as double;
          final double totalSpent = box.values.fold(0.0, (s, e) => s + e.amount);
          final double percentage = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;

          if (percentage >= 0.8 && budget > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("⚠️ Budget Alert: You've used ${(percentage * 100).toStringAsFixed(0)}% of your monthly budget!"),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ));
            });
          }

          final List<Expense> expenses = _selectedCategory == null
              ? ExpenseService.getAllExpenses()
              : ExpenseService.getExpensesByCategory(_selectedCategory!);

          expenses.sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              _buildSummaryCard(totalSpent, box.length, percentage, budget),
              _buildFilterChips(),
              Expanded(child: _buildExpenseList(expenses)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildSummaryCard(double total, int count, double percentage, double budget) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total Spending', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text('$count expense${count == 1 ? '' : 's'}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ]),
                Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            const SizedBox(height: 15),
            // EXERCISE 2: Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.black12,
                color: percentage >= 0.8 ? Colors.red : Colors.indigo,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Budget: ₱${budget.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12)),
                Text("${(percentage * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = [null, ...ExpenseCategory.values];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(_label(cat)),
            selected: _selectedCategory == cat,
            onSelected: (_) => setState(() => _selectedCategory = cat),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No expenses yet!', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap the button below to add your first expense.', style: TextStyle(color: Colors.grey[400])),
        ]),
      );
    }
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, i) {
        final expense = expenses[i];
        final int key = expense.key as int;
        return ExpenseTile(
          expense: expense,
          onDelete: () => ExpenseService.deleteExpense(key),
          onEdit: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense, expenseKey: key))),
        );
      },
    );
  }
}