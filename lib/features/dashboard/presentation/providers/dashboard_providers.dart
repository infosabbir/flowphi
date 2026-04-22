import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flow_phi/features/expense/data/drift/app_database.dart';
import 'package:drift/drift.dart' as drift;

// Period filter provider
enum PeriodFilter { daily, weekly, monthly }

enum ExpenseSortOption { dateNewest, dateOldest, amountHigh, amountLow }

final periodFilterProvider = StateProvider<PeriodFilter>((ref) {
  return PeriodFilter.monthly;
});

final expenseSortProvider = StateProvider<ExpenseSortOption>((ref) {
  return ExpenseSortOption.dateNewest;
});

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Get date range based on period filter
DateTime _getStartDate(DateTime date, PeriodFilter period) {
  switch (period) {
    case PeriodFilter.daily:
      return DateTime(date.year, date.month, date.day);
    case PeriodFilter.weekly:
      final dayOfWeek = date.weekday;
      return date.subtract(Duration(days: dayOfWeek - 1));
    case PeriodFilter.monthly:
      return DateTime(date.year, date.month, 1);
  }
}

DateTime _getEndDate(DateTime date, PeriodFilter period) {
  switch (period) {
    case PeriodFilter.daily:
      return date.add(const Duration(days: 1));
    case PeriodFilter.weekly:
      return date.add(Duration(days: 7 - (date.weekday - 1)));
    case PeriodFilter.monthly:
      return date.month == 12
          ? DateTime(date.year + 1, 1, 1)
          : DateTime(date.year, date.month + 1, 1);
  }
}

// Income expenses for period
final incomeByPeriodProvider = FutureProvider.autoDispose<double>((ref) async {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(periodFilterProvider);
  final now = DateTime.now();

  final startDate = _getStartDate(now, period);
  final endDate = _getEndDate(now, period);

  final query = db.select(db.income)
    ..where(
      (tbl) =>
          tbl.date.isBiggerOrEqualValue(startDate) &
          tbl.date.isSmallerThanValue(endDate),
    );

  final incomes = await query.get();
  return incomes.fold<double>(0, (sum, income) => sum + income.amount);
});

// Expenses for period
final expensesByPeriodProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(periodFilterProvider);
  final now = DateTime.now();

  final startDate = _getStartDate(now, period);
  final endDate = _getEndDate(now, period);

  final query = db.select(db.expenses)
    ..where(
      (tbl) =>
          tbl.date.isBiggerOrEqualValue(startDate) &
          tbl.date.isSmallerThanValue(endDate),
    );

  final expenses = await query.get();
  return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
});

// Active loans (not returned)
final activeLoansProvider = FutureProvider.autoDispose<List<Loan>>((ref) async {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.loans)
    ..where((tbl) => tbl.status.equals('pending'));
  return await query.get();
});

// All income for period
final allIncomeForPeriodProvider = FutureProvider.autoDispose<List<IncomeData>>(
  (ref) async {
    final db = ref.watch(databaseProvider);
    final period = ref.watch(periodFilterProvider);
    final now = DateTime.now();

    final startDate = _getStartDate(now, period);
    final endDate = _getEndDate(now, period);

    final query = db.select(db.income)
      ..where(
        (tbl) =>
            tbl.date.isBiggerOrEqualValue(startDate) &
            tbl.date.isSmallerThanValue(endDate),
      )
      ..orderBy([
        (tbl) => drift.OrderingTerm(
          expression: tbl.date,
          mode: drift.OrderingMode.desc,
        ),
      ]);

    return await query.get();
  },
);

// Calculate balance
final balanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final income = await ref.watch(incomeByPeriodProvider.future);
  final expenses = await ref.watch(expensesByPeriodProvider.future);

  return income - expenses;
});

// All expenses for period (for summary/sorting)
final allExpensesForPeriodProvider = FutureProvider.autoDispose<List<Expense>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(periodFilterProvider);
  final now = DateTime.now();

  final startDate = _getStartDate(now, period);
  final endDate = _getEndDate(now, period);

  final query = db.select(db.expenses)
    ..where(
      (tbl) =>
          tbl.date.isBiggerOrEqualValue(startDate) &
          tbl.date.isSmallerThanValue(endDate),
    )
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.date,
        mode: drift.OrderingMode.desc,
      ),
    ]);

  return await query.get();
});

final sortedExpensesForPeriodProvider =
    FutureProvider.autoDispose<List<Expense>>((ref) async {
      final expenses = await ref.watch(allExpensesForPeriodProvider.future);
      final sortOption = ref.watch(expenseSortProvider);
      final sortedExpenses = [...expenses];

      switch (sortOption) {
        case ExpenseSortOption.dateNewest:
          sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
        case ExpenseSortOption.dateOldest:
          sortedExpenses.sort((a, b) => a.date.compareTo(b.date));
        case ExpenseSortOption.amountHigh:
          sortedExpenses.sort((a, b) => b.amount.compareTo(a.amount));
        case ExpenseSortOption.amountLow:
          sortedExpenses.sort((a, b) => a.amount.compareTo(b.amount));
      }

      return sortedExpenses;
    });

// Delete income
final deleteIncomeProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  await (db.delete(db.income)..where((tbl) => tbl.id.equals(id))).go();
});

// Delete loan
final deleteLoanProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  await (db.delete(db.loans)..where((tbl) => tbl.id.equals(id))).go();
});

// Mark loan as completed
final completeLoanProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  final loan = await (db.select(
    db.loans,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  if (loan != null) {
    await db.update(db.loans).replace(loan.copyWith(status: 'returned'));
  }
});
