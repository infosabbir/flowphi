import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_phi/features/dashboard/presentation/providers/dashboard_providers.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(periodFilterProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PeriodButton(
          label: 'Daily',
          isSelected: selectedPeriod == PeriodFilter.daily,
          onTap: () => ref.read(periodFilterProvider.notifier).state =
              PeriodFilter.daily,
        ),
        _PeriodButton(
          label: 'Weekly',
          isSelected: selectedPeriod == PeriodFilter.weekly,
          onTap: () => ref.read(periodFilterProvider.notifier).state =
              PeriodFilter.weekly,
        ),
        _PeriodButton(
          label: 'Monthly',
          isSelected: selectedPeriod == PeriodFilter.monthly,
          onTap: () => ref.read(periodFilterProvider.notifier).state =
              PeriodFilter.monthly,
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
