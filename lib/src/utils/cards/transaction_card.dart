import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_amount_widget.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_icon.dart';

class TransactionCard extends ConsumerWidget {
  final BudgetTransaction transaction;
  final void Function()? onDeletePressed;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDeletePressed,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = transaction.type == 'income';

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withValues(alpha: .2)
              : const Color(0xFF17173B),
          borderRadius: BorderRadius.circular(16),
          border: selected ? Border.all(color: Colors.blue) : null,
        ),
        child: Row(
          children: [
            TransactionIcon(
              type: transaction.type,
              category: transaction.category,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    transaction.category,
                    style: const TextStyle(color: Color(0xFF7272A6)),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    transaction.date.toIso8601String().split('T').first,
                    style: const TextStyle(
                      color: Color(0xFF7272A6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            TransactionAmountWidget(
              amount: transaction.amount,
              isIncome: income,
            ),
          ],
        ),
      ),
    );
  }
}
