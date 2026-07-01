import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_amount_widget.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_icon.dart';

class TransactionCard extends ConsumerWidget {
  final BudgetTransaction transaction;
  final void Function()? onDeletePressed;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = transaction.type == 'income';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF242454))),
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

          TransactionAmountWidget(amount: transaction.amount, isIncome: income),
          SizedBox(width: 15),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            onPressed: onDeletePressed,
          ),
        ],
      ),
    );
  }
}
