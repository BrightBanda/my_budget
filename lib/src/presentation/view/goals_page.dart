import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/utils/add_button.dart';
import 'package:my_budget/src/utils/add_goal_sheet.dart';
import 'package:my_budget/src/utils/add_transaction_sheet.dart';
import 'package:my_budget/src/utils/cards/deduction_card.dart';
import 'package:my_budget/src/utils/cards/goal_card.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D26),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Savings Goals",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                AddButton(
                  title: "+ New Goal",
                  width: 120,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddGoalSheet(),
                    );
                    final goal = SavingGoal(
                      id: DateTime.now().toIso8601String(),
                      title: "new goal",
                      currentAmount: 200,
                      targetAmount: 1000,
                      dueDate: DateTime.now(),
                      createdAt: DateTime.now(),
                    );
                    //ref.read(goalsProvider.notifier).addGoal(goal);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            //goals list
            goals.when(
              data: (items) {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final goal = items[index];
                        return GoalCard(
                          title: goal.title,
                          currentAmount: goal.currentAmount,
                          targetAmount: goal.targetAmount,
                          daysLeft: goal.daysLeft,
                          dueDate: goal.dueDate.toIso8601String(),
                        );
                      },
                    ),
                  ),
                );
              },
              error: (error, stackTrace) {
                throw Exception(error);
              },
              loading: () => CircularProgressIndicator(),
            ),

            // const GoalCard(
            //   title: "New Laptop",
            //   currentAmount: 87500,
            //   targetAmount: 350000,
            //   daysLeft: 183,
            //   dueDate: "Dec 2026",
            // ),
            const SizedBox(height: 16),

            // const GoalCard(
            //   title: "Holiday Trip",
            //   currentAmount: 42000,
            //   targetAmount: 200000,
            //   daysLeft: 91,
            //   dueDate: "Sep 2026",
            // ),
            const SizedBox(height: 30),

            const Text(
              "Scheduled Deductions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // const DeductionCard(
            //   title: "House Rent",
            //   frequency: "Monthly",
            //   amount: 45000,
            // ),

            // const SizedBox(height: 12),

            // const DeductionCard(
            //   title: "Weekly Groceries",
            //   frequency: "Weekly",
            //   amount: 10000,
            // ),
          ],
        ),
      ),
    );
  }
}
