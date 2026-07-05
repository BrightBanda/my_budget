import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/balance_provider.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/cards/statistics_card.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final balance = ref.watch(balanceProvider);
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Analytics",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            transactions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                e.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              data: (items) {
                double income = 0;
                double expense = 0;

                for (final t in items) {
                  if (t.type == 'income') {
                    income += t.amount;
                  } else {
                    expense += t.amount;
                  }
                }

                final savings = income - expense;

                final savingsRate = income == 0
                    ? 0
                    : ((savings / income) * 100);

                return Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        StatsCard(
                          title: "Income",
                          value: income.mwk,
                          subtitle: "Total income",
                        ),

                        StatsCard(
                          title: "Expenses",
                          value: expense.mwk,
                          subtitle: "Total spent",
                        ),

                        StatsCard(
                          title: "Balance",
                          value: balance.mwk,
                          subtitle: "Current balance",
                        ),

                        StatsCard(
                          title: "Savings Rate",
                          value: "${savingsRate.toStringAsFixed(1)}%",
                          subtitle: "Of income saved",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _AnalyticsCard(
                      title: "Summary",
                      child: Column(
                        children: [
                          _summaryRow("Total Transactions", "${items.length}"),
                          _summaryRow("Total Income", "MWK ${income.mwk}"),
                          _summaryRow("Total Expense", "MWK ${expense.mwk}"),
                          _summaryRow("Net Savings", "MWK ${savings.mwk}"),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            goals.when(
              data: (items) => _AnalyticsCard(
                title: "Goals Overview",
                child: Column(
                  children: [
                    _summaryRow("Total Goals", "${items.length}"),
                    _summaryRow(
                      "Active Goals",
                      "${items.where((g) => g.progress < 1).length}",
                    ),
                    _summaryRow(
                      "Completed Goals",
                      "${items.where((g) => g.progress >= 1).length}",
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnalyticsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17173B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
