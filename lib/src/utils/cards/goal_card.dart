import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final double currentAmount;
  final double targetAmount;
  final int daysLeft;
  final DateTime dueDate;
  final VoidCallback? onAddFunds;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GoalCard({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.daysLeft,
    required this.dueDate,
    this.onAddFunds,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentAmount / targetAmount;
    final remaining = targetAmount - currentAmount;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withValues(alpha: .2)
              : const Color(0xFF17173B),
          borderRadius: BorderRadius.circular(18),
          border: selected ? Border.all(color: Colors.blue) : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.laptop, color: Colors.white),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$daysLeft d left",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //due date
                Text(
                  "Due: " + DateFormat('dd MMM yyyy').format(dueDate),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Text(
                  "MWK ${currentAmount.mwk}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "of MWK ${targetAmount.mwk}",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${(progress * 100).toStringAsFixed(1)}% funded · need MWK ${remaining.mwk} more",
                style: const TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAddFunds,
                child: const Text(
                  "+ Add Funds",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
