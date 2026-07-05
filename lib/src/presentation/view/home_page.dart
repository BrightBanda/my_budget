import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/viewmodel/page_notifier.dart';
import 'package:my_budget/src/providers/balance_provider.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/app_dialog.dart';
import 'package:my_budget/src/utils/cards/balance_summary_card.dart';
import 'package:my_budget/src/utils/cards/goal_list_card.dart';
import 'package:my_budget/src/utils/label.dart';
import 'package:my_budget/src/utils/cards/statistics_card.dart';
import 'package:my_budget/src/utils/cards/transaction_card.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final goals = ref.watch(goalsProvider);
    final int maxRecentItemCount = 2;
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        margin: EdgeInsets.only(bottom: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            spacing: 10,
            children: [
              //balance summary sheet
              BalanceCard(balance: ref.watch(balanceProvider).mwk),

              //summary
              Label(text: "Summary", fontSize: 16, fontWeight: FontWeight.w700),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatsCard(
                    title: "Savings rate",
                    value: "59%",
                    subtitle: "of income saved",
                  ),
                  StatsCard(
                    title: "AVG/Day",
                    value: "MK 8500",
                    subtitle: "daily spend",
                  ),
                  StatsCard(
                    title: "Transactions",
                    value: "120",
                    subtitle: "total recorded",
                  ),
                  StatsCard(
                    title: "Goals",
                    value: "2",
                    subtitle: "0 completed",
                  ),
                ],
              ),
              Label(text: "Goals", fontSize: 16, fontWeight: FontWeight.w700),
              // Column(
              //   children: const [
              //     GoalListCard(
              //       title: "New Laptop",
              //       remainingDays: "187 days left",
              //       currentAmount: "MWK 87,500",
              //       targetAmount: "MWK 350,000",
              //       progress: 0.25,
              //       funded: "25% funded",
              //     ),

              //     SizedBox(height: 12),

              //     GoalListCard(
              //       title: "Holiday Trip",
              //       remainingDays: "95 days left",
              //       currentAmount: "MWK 42,000",
              //       targetAmount: "MWK 200,000",
              //       progress: 0.90,
              //       funded: "21% funded",
              //     ),
              //   ],
              // ),
              goals.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Text(
                      "No goals yet",
                      style: TextStyle(color: Colors.white54),
                    );
                  }
                  final int length = 2;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length < 2 ? items.length : length,
                    itemBuilder: (context, index) {
                      final goal = items[index];

                      return GoalListCard(
                        title: goal.title,
                        remainingDays: goal.dueDate.toString(),
                        currentAmount: goal.currentAmount,
                        targetAmount: goal.targetAmount,
                        progress: goal.progress,
                        funded:
                            "${(goal.progress * 100).toStringAsFixed(0)}% funded",
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text(error.toString())),
              ),

              //recent transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Label(
                    text: "Recent activity",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(width: 70),
                  GestureDetector(
                    onTap: () =>
                        ref.read(pageIndexProvider.notifier).changePage(2),
                    child: Text(
                      "See all",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121238),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: transactions.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (error, stack) =>
                      Center(child: Text(error.toString())),

                  data: (items) {
                    return ListView.builder(
                      shrinkWrap: true,

                      itemCount: items.length < maxRecentItemCount
                          ? items.length
                          : maxRecentItemCount,

                      itemBuilder: (context, index) {
                        final transaction = items[index];
                        return TransactionCard(
                          transaction: transaction,
                          onDeletePressed: () {
                            showDialog(
                              context: context,
                              builder: (builder) => AppDialog(
                                titleColor: Colors.red,
                                messageColor: Colors.red,
                                confirmBackgroundColor: Colors.red,
                                title: "Delete transaction",
                                message:
                                    "are you sure you want to permanantly delete this transaction?",
                                onConfirm: () => ref
                                    .read(transactionsProvider.notifier)
                                    .deleteTransaction(transaction.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
