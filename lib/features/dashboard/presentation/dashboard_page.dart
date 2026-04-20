import 'package:FlowPhi/core/custom_appbar.dart';
import 'package:FlowPhi/features/auth/data/auth_repository.dart';
import 'package:FlowPhi/features/auth/presentation/login_page.dart';
import 'package:FlowPhi/features/dashboard/presentation/providers/current_month_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme styl = Theme.of(context).textTheme;
    // ColorScheme colr = Theme.of(context).colorScheme;

    final selectedMonth = ref.watch(selectedMonthProvider);
    final currentMonth = DateFormat.yMMM().format(selectedMonth);

    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          IconButton(
            onPressed: () async {
              final authRepository = AuthRepository();

              await authRepository.logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentMonth, style: styl.headlineSmall),
            const SizedBox(height: 20),
            _SummaryCard(
              title: 'Monthly Income',
              amount: 0,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _SummaryCard(title: 'Total Expenses', amount: 0, color: Colors.red),
            const SizedBox(height: 12),
            _SummaryCard(
              title: 'Current Balance',
              amount: 0,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text('Recent Expenses', style: styl.titleLarge),
            const SizedBox(height: 12),
            const Expanded(child: Center(child: Text('No expenses Yet!'))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme styl = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.account_balance_wallet, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: styl.titleMedium,
        ),
      ),
    );
  }
}
