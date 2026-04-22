import 'package:flow_phi/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flow_phi/features/expense/data/drift/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddExpenseDialog({super.key, this.expense});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController categoryController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.expense?.title ?? '');
    amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    categoryController = TextEditingController(
      text: widget.expense?.category ?? '',
    );
    selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefix: Text('\$ '),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date: ${DateFormat.yMd().format(selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final db = ref.read(databaseProvider);
            final amount = double.tryParse(amountController.text) ?? 0;

            if (titleController.text.isEmpty || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields correctly'),
                ),
              );
              return;
            }

            if (widget.expense == null) {
              await db
                  .into(db.expenses)
                  .insert(
                    ExpensesCompanion(
                      title: drift.Value(titleController.text),
                      amount: drift.Value(amount),
                      category: drift.Value(categoryController.text),
                      date: drift.Value(selectedDate),
                    ),
                  );
            } else {
              await db
                  .update(db.expenses)
                  .replace(
                    widget.expense!.copyWith(
                      title: titleController.text,
                      amount: amount,
                      category: categoryController.text,
                      date: selectedDate,
                    ),
                  );
            }

            if (context.mounted) {
              Navigator.pop(context);
              ref.invalidate(allExpensesForPeriodProvider);
              ref.invalidate(expensesByPeriodProvider);
              ref.invalidate(balanceProvider);
              ref.invalidate(sortedExpensesForPeriodProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.expense == null
                        ? 'Expense added successfully'
                        : 'Expense updated successfully',
                  ),
                ),
              );
            }
          },
          child: Text(widget.expense == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
