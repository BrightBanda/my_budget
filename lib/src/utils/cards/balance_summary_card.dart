import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/analytics/total_monthly_expense_provider.dart';
import 'package:my_budget/src/providers/analytics/total_monthly_income_provider.dart';
import 'package:my_budget/src/providers/currency_formatter_provider.dart';

class BalanceCard extends ConsumerWidget {
  final String balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyFormatterProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 21, 170, 101),
            Color.fromARGB(255, 15, 151, 115),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TOTAL BALANCE",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "${balance}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(
                Icon(Icons.trending_up, color: Colors.white),
                "Monthly Income",
                currency.format(ref.watch(monthlyIncomeProvider)),
              ),
              _statItem(
                Icon(Icons.trending_down, color: Colors.white),
                "Monthly Expenses",
                currency.format(ref.watch(monthlyExpenseProvider)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(Icon iconData, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconData,
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
