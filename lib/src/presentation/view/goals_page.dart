import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/providers/goal_selection_provider.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/utils/add_button.dart';
import 'package:my_budget/src/utils/add_funds_dialog.dart';
import 'package:my_budget/src/utils/add_goal_sheet.dart';
import 'package:my_budget/src/utils/add_transaction_sheet.dart';
import 'package:my_budget/src/utils/app_dialog.dart';
import 'package:my_budget/src/utils/cards/deduction_card.dart';
import 'package:my_budget/src/utils/cards/goal_card.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    final selectedIds = ref.watch(goalSelectionProvider);

    final selecting = selectedIds.isNotEmpty;

    bool allSelected = false;

    goals.whenData((items) {
      allSelected = items.isNotEmpty && selectedIds.length == items.length;
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D26),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            selecting
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          ref.read(goalSelectionProvider.notifier).clear();
                        },
                      ),

                      Text(
                        "${selectedIds.length} selected",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),
                      //select/disselect button
                      TextButton(
                        onPressed: () {
                          goals.whenData((items) {
                            ref
                                .read(goalSelectionProvider.notifier)
                                .toggleAll(items.map((e) => e.id).toList());
                          });
                        },
                        child: Text(
                          allSelected ? "Deselect All" : "Select All",
                        ),
                      ),

                      //delete icon
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (builder) => AppDialog(
                              title: "Delete Goals",
                              message:
                                  "Are you sure you want to permanently delete the selected goal(s)",
                              confirmBackgroundColor: Colors.red,
                              titleColor: Colors.red,
                              messageColor: Colors.red,
                              onConfirm: () async {
                                await ref
                                    .read(goalsProvider.notifier)
                                    .deleteGoals(selectedIds.toList());

                                ref
                                    .read(goalSelectionProvider.notifier)
                                    .clear();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Text(
                        "Savings Goals",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

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
                        },
                      ),
                    ],
                  ),

            const SizedBox(height: 20),

            goals.when(
              data: (items) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    child: ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final goal = items[index];

                        final isSelected = selectedIds.contains(goal.id);

                        final isSelecting = selectedIds.isNotEmpty;

                        return GoalCard(
                          title: goal.title,
                          currentAmount: goal.currentAmount,
                          targetAmount: goal.targetAmount,
                          daysLeft: goal.daysLeft,
                          dueDate: goal.dueDate.toString().split(' ')[0],

                          selected: isSelected,

                          onLongPress: isSelecting
                              ? null
                              : () {
                                  ref
                                      .read(goalSelectionProvider.notifier)
                                      .toggle(goal.id);
                                },

                          onTap: isSelecting
                              ? () {
                                  ref
                                      .read(goalSelectionProvider.notifier)
                                      .toggle(goal.id);
                                }
                              : null,

                          onAddFunds: () async {
                            final result = await showAddFundsDialog(context);

                            if (result == null) return;

                            ref
                                .read(goalsProvider.notifier)
                                .addFunds(
                                  goal.id,
                                  result.amount,
                                  deductFromBalance: result.deductFromBalance,
                                );

                            print(
                              'Amount: ${result.amount}, '
                              'Deduct: ${result.deductFromBalance}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
              error: (error, stackTrace) {
                throw Exception(error);
              },
              loading: () => const CircularProgressIndicator(),
            ),

            const SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }
}
