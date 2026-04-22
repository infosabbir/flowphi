import 'package:flow_phi/core/custom_appbar.dart';
import 'package:flow_phi/features/auth/data/auth_repository.dart';
import 'package:flow_phi/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flow_phi/features/dashboard/presentation/widgets/add_transaction_sheet.dart';
import 'package:flow_phi/features/dashboard/presentation/widgets/add_income_dialog.dart';
import 'package:flow_phi/features/dashboard/presentation/widgets/add_loan_dialog.dart';
import 'package:flow_phi/features/dashboard/presentation/widgets/period_selector.dart';
import 'package:flow_phi/features/dashboard/presentation/widgets/summary_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final incomeAsync = ref.watch(incomeByPeriodProvider);
    final expensesAsync = ref.watch(expensesByPeriodProvider);
    final balanceAsync = ref.watch(balanceProvider);
    final loansAsync = ref.watch(activeLoansProvider);
    final expensesListAsync = ref.watch(sortedExpensesForPeriodProvider);
    final incomeListAsync = ref.watch(allIncomeForPeriodProvider);
    final selectedExpenseSort = ref.watch(expenseSortProvider);

    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          IconButton(
            onPressed: () async {
              final authRepository = AuthRepository();
              await authRepository.logout();
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Dashboard',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Period Selector
              const PeriodSelector(),
              const SizedBox(height: 24),

              // Summary Cards
              incomeAsync.when(
                data: (income) => expensesAsync.when(
                  data: (expenses) => balanceAsync.when(
                    data: (balance) => Column(
                      children: [
                        SummaryCard(
                          title: 'Income',
                          amount: '\$${income.toStringAsFixed(2)}',
                          color: Colors.green,
                          icon: Icons.trending_up,
                        ),
                        const SizedBox(height: 12),
                        SummaryCard(
                          title: 'Expenses',
                          amount: '\$${expenses.toStringAsFixed(2)}',
                          color: Colors.red,
                          icon: Icons.trending_down,
                        ),
                        const SizedBox(height: 12),
                        SummaryCard(
                          title: 'Balance',
                          amount: '\$${balance.toStringAsFixed(2)}',
                          color: balance >= 0 ? Colors.blue : Colors.orange,
                          icon: Icons.account_balance_wallet,
                        ),
                      ],
                    ),
                    loading: () => const _LoadingCards(),
                    error: (err, stack) => Text('Error loading balance: $err'),
                  ),
                  loading: () => const _LoadingCards(),
                  error: (err, stack) => Text('Error loading expenses: $err'),
                ),
                loading: () => const _LoadingCards(),
                error: (err, stack) => Text('Error loading income: $err'),
              ),

              const SizedBox(height: 28),

              // Income Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Income',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              incomeListAsync.when(
                data: (incomeList) {
                  if (incomeList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        'No income added',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: incomeList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final income = incomeList[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(income.title),
                          subtitle: Text(income.category),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              Text(
                                '\$${income.amount.toStringAsFixed(2)}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Edit'),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AddIncomeDialog(income: income),
                                      ).then((_) {
                                        ref.invalidate(
                                          allIncomeForPeriodProvider,
                                        );
                                        ref.invalidate(incomeByPeriodProvider);
                                        ref.invalidate(balanceProvider);
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Income?'),
                                          content: const Text(
                                            'Are you sure you want to delete this income?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final db = ref.read(
                                                  databaseProvider,
                                                );
                                                final currentContext = context;
                                                await (db.delete(db.income)
                                                      ..where(
                                                        (tbl) => tbl.id.equals(
                                                          income.id,
                                                        ),
                                                      ))
                                                    .go();
                                                if (currentContext.mounted) {
                                                  Navigator.pop(currentContext);
                                                  ref.invalidate(
                                                    allIncomeForPeriodProvider,
                                                  );
                                                  ref.invalidate(
                                                    incomeByPeriodProvider,
                                                  );
                                                  ref.invalidate(
                                                    balanceProvider,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    currentContext,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Income deleted successfully',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading income: $err'),
              ),

              const SizedBox(height: 28),

              // Lend Money Section
              Text(
                'Active Loans',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              loansAsync.when(
                data: (loans) {
                  if (loans.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        'No active loans',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: loans.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final loan = loans[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lent to ${loan.personName}',
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${loan.amount.toStringAsFixed(2)}',
                                          style: textTheme.headlineSmall
                                              ?.copyWith(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (loan.reminderEnabled)
                                    const Icon(
                                      Icons.notifications_active,
                                      color: Colors.amber,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getDaysRemaining(loan.dueDate),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AddLoanDialog(loan: loan),
                                      ).then((_) {
                                        ref.invalidate(activeLoansProvider);
                                      });
                                    },
                                    child: const Text('Edit'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final db = ref.read(databaseProvider);
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      await db
                                          .update(db.loans)
                                          .replace(
                                            loan.copyWith(status: 'returned'),
                                          );
                                      ref.invalidate(activeLoansProvider);
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Loan marked as returned',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Complete'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Loan?'),
                                          content: const Text(
                                            'Are you sure you want to delete this loan?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final db = ref.read(
                                                  databaseProvider,
                                                );
                                                final currentContext = context;
                                                await (db.delete(db.loans)
                                                      ..where(
                                                        (tbl) => tbl.id.equals(
                                                          loan.id,
                                                        ),
                                                      ))
                                                    .go();
                                                if (currentContext.mounted) {
                                                  Navigator.pop(currentContext);
                                                  ref.invalidate(
                                                    activeLoansProvider,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    currentContext,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Loan deleted successfully',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading loans: $err'),
              ),

              const SizedBox(height: 28),

              // Summary/Recent Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Summary',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      final sortOption = switch (value) {
                        'date_oldest' => ExpenseSortOption.dateOldest,
                        'amount_high' => ExpenseSortOption.amountHigh,
                        'amount_low' => ExpenseSortOption.amountLow,
                        _ => ExpenseSortOption.dateNewest,
                      };
                      ref.read(expenseSortProvider.notifier).state = sortOption;
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'date_newest',
                        child: _SortMenuLabel(
                          label: 'Newest First',
                          isSelected:
                              selectedExpenseSort ==
                              ExpenseSortOption.dateNewest,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'date_oldest',
                        child: _SortMenuLabel(
                          label: 'Oldest First',
                          isSelected:
                              selectedExpenseSort ==
                              ExpenseSortOption.dateOldest,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'amount_high',
                        child: _SortMenuLabel(
                          label: 'Amount: High to Low',
                          isSelected:
                              selectedExpenseSort ==
                              ExpenseSortOption.amountHigh,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'amount_low',
                        child: _SortMenuLabel(
                          label: 'Amount: Low to High',
                          isSelected:
                              selectedExpenseSort == ExpenseSortOption.amountLow,
                        ),
                      ),
                    ],
                    child: const Icon(Icons.sort),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              expensesListAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        'No expenses for this period',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.shopping_cart,
                              color: Colors.red,
                            ),
                          ),
                          title: Text(expense.title),
                          subtitle: Text(expense.category),
                          trailing: Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading expenses: $err'),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getDaysRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue by ${(-difference)} days';
    } else if (difference == 0) {
      return 'Due today';
    } else {
      return 'Due in $difference days';
    }
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

class _SortMenuLabel extends StatelessWidget {
  const _SortMenuLabel({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Text(label)),
        if (isSelected) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check, size: 18),
        ],
      ],
    );
  }
}
