import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_phi/features/expense/data/drift/app_database.dart';
import 'package:flow_phi/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

class AddLoanDialog extends ConsumerStatefulWidget {
  final Loan? loan;

  const AddLoanDialog({super.key, this.loan});

  @override
  ConsumerState<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends ConsumerState<AddLoanDialog> {
  late TextEditingController personNameController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late DateTime loanDate;
  late DateTime dueDate;
  late bool reminderEnabled;
  int loanDays = 7;

  @override
  void initState() {
    super.initState();
    personNameController = TextEditingController(
      text: widget.loan?.personName ?? '',
    );
    amountController = TextEditingController(
      text: widget.loan?.amount.toString() ?? '',
    );
    notesController = TextEditingController(text: widget.loan?.notes ?? '');
    loanDate = widget.loan?.loanDate ?? DateTime.now();
    dueDate =
        widget.loan?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    reminderEnabled = widget.loan?.reminderEnabled ?? true;
  }

  @override
  void dispose() {
    personNameController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.loan == null ? 'Add Loan' : 'Edit Loan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: personNameController,
              decoration: const InputDecoration(
                labelText: 'Person Name',
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
            ListTile(
              title: Text('Loan Date: ${DateFormat.yMd().format(loanDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: loanDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => loanDate = date);
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Due Date: ${DateFormat.yMd().format(dueDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dueDate,
                  firstDate: loanDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => dueDate = date);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButton<int>(
              value: loanDays,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 3, child: Text('3 Days')),
                DropdownMenuItem(value: 5, child: Text('5 Days')),
                DropdownMenuItem(value: 7, child: Text('7 Days')),
                DropdownMenuItem(value: 14, child: Text('14 Days')),
                DropdownMenuItem(value: 30, child: Text('30 Days')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    loanDays = value;
                    dueDate = loanDate.add(Duration(days: value));
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Enable Reminder'),
              value: reminderEnabled,
              onChanged: (value) {
                setState(() => reminderEnabled = value ?? true);
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

            if (personNameController.text.isEmpty || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all required fields correctly'),
                ),
              );
              return;
            }

            if (widget.loan == null) {
              // Add new loan
              await db
                  .into(db.loans)
                  .insert(
                    LoansCompanion(
                      personName: drift.Value(personNameController.text),
                      amount: drift.Value(amount),
                      loanDate: drift.Value(loanDate),
                      dueDate: drift.Value(dueDate),
                      status: drift.Value('pending'),
                      notes: notesController.text.isNotEmpty
                          ? drift.Value(notesController.text)
                          : const drift.Value.absent(),
                      reminderEnabled: drift.Value(reminderEnabled),
                    ),
                  );
            } else {
              // Update existing loan
              await db
                  .update(db.loans)
                  .replace(
                    widget.loan!.copyWith(
                      personName: personNameController.text,
                      amount: amount,
                      loanDate: loanDate,
                      dueDate: dueDate,
                      notes: notesController.text.isNotEmpty
                          ? drift.Value(notesController.text)
                          : const drift.Value.absent(),
                      reminderEnabled: reminderEnabled,
                    ),
                  );
            }

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.loan == null
                        ? 'Loan added successfully'
                        : 'Loan updated successfully',
                  ),
                ),
              );
            }
          },
          child: Text(widget.loan == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
