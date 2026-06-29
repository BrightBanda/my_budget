import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';
import 'package:my_budget/src/utils/app_dialog.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_card.dart';

class TransactionsList extends ConsumerWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, stack) => Center(child: Text(error.toString())),

      data: (items) {
        return ListView.builder(
          itemCount: items.length,
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
    );
  }
}
