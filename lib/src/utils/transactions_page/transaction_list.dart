import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';
import 'package:my_budget/src/providers/transaction_selection_provider.dart';
import 'package:my_budget/src/providers/transaction_filters_provider.dart';
import 'package:my_budget/src/utils/app_dialog.dart';
import 'package:my_budget/src/utils/cards/transaction_card.dart';

class TransactionsList extends ConsumerWidget {
  final bool isMainList;
  final int itemCount;

  const TransactionsList({
    super.key,
    this.isMainList = true,
    this.itemCount = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = isMainList
        ? ref.watch(filteredTransactionsProvider)
        : ref.watch(transactionsProvider);

    final selectedIds = ref.watch(transactionSelectionProvider);

    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
      data: (items) {
        final displayCount = isMainList
            ? items.length
            : (itemCount > items.length ? items.length : itemCount);

        if (displayCount == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No transactions match these filters',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final transaction = items[index];
            final isSelected = selectedIds.contains(transaction.id);
            final isSelecting = selectedIds.isNotEmpty;

            return TransactionCard(
              transaction: transaction,
              selected: isSelected,
              onLongPress: isSelecting
                  ? null
                  : () {
                      ref
                          .read(transactionSelectionProvider.notifier)
                          .toggle(transaction.id);
                    },
              onTap: isSelecting
                  ? () {
                      ref
                          .read(transactionSelectionProvider.notifier)
                          .toggle(transaction.id);
                    }
                  : () {},
              onDeletePressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AppDialog(
                    titleColor: Colors.red,
                    messageColor: Colors.red,
                    confirmBackgroundColor: Colors.red,
                    title: "Delete Transaction",
                    message:
                        "Are you sure you want to permanently delete this transaction?",
                    onConfirm: () {
                      ref
                          .read(transactionsProvider.notifier)
                          .deleteTransaction(transaction.id);
                    },
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
