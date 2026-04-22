import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_phi/features/expense/data/drift/app_database.dart';
import 'package:flow_phi/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

class AddIncomeDialog extends ConsumerStatefulWidget {
  final IncomeData? income;

  const AddIncomeDialog({super.key, this.income});

  @override
  ConsumerState<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends ConsumerState<AddIncomeDialog> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController categoryController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.income?.title ?? '');
    amountController = TextEditingController(
      text: widget.income?.amount.toString() ?? '',
    );
    categoryController = TextEditingController(
      text: widget.income?.category ?? '',
    );
    selectedDate = widget.income?.date ?? DateTime.now();
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
      title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
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
              keyboardType: TextInputType.number,
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

            if (widget.income == null) {
              // Add new income
              await db
                  .into(db.income)
                  .insert(
                    IncomeCompanion(
                      title: drift.Value(titleController.text),
                      amount: drift.Value(amount),
                      category: drift.Value(categoryController.text),
                      date: drift.Value(selectedDate),
                    ),
                  );
            } else {
              // Update existing income
              await db
                  .update(db.income)
                  .replace(
                    widget.income!.copyWith(
                      title: titleController.text,
                      amount: amount,
                      category: categoryController.text,
                      date: selectedDate,
                    ),
                  );
            }

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.income == null
                        ? 'Income added successfully'
                        : 'Income updated successfully',
                  ),
                ),
              );
            }
          },
          child: Text(widget.income == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
