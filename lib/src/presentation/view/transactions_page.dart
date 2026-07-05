import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/view/home_page.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';
import 'package:my_budget/src/providers/transaction_selection_provider.dart';
import 'package:my_budget/src/utils/app_dialog.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_filter_chip.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_list.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(transactionSelectionProvider);
    final transactions = ref.watch(transactionsProvider);

    final selecting = selectedIds.isNotEmpty;

    bool allSelected = false;

    transactions.whenData((items) {
      allSelected = items.isNotEmpty && selectedIds.length == items.length;
    });

    return Scaffold(
      backgroundColor: const Color(0xFF09091F),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            child: selecting
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          ref
                              .read(transactionSelectionProvider.notifier)
                              .clear();
                        },
                      ),

                      Text(
                        "${selectedIds.length} selected",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: () {
                          transactions.whenData((items) {
                            ref
                                .read(transactionSelectionProvider.notifier)
                                .toggleAll(items.map((e) => e.id).toList());
                          });
                        },
                        child: Text(
                          allSelected ? 'Deselect All' : 'Select All',
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (builder) => AppDialog(
                              title: "Delete Goals",
                              message:
                                  "Are you sure you want to permanently delete the selected transaction(s)",
                              confirmBackgroundColor: Colors.red,
                              titleColor: Colors.red,
                              messageColor: Colors.red,
                              onConfirm: () async {
                                final ids = selectedIds.toList();

                                for (final id in ids) {
                                  await ref
                                      .read(transactionsProvider.notifier)
                                      .deleteTransaction(id);
                                }

                                ref
                                    .read(transactionSelectionProvider.notifier)
                                    .clear();
                              },
                            ),
                          );

                          ref
                              .read(transactionSelectionProvider.notifier)
                              .clear();
                        },
                      ),
                    ],
                  )
                : const SizedBox(),
          ),

          const SizedBox(height: 20),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 12,
              children: [
                TransactionFilterChip(
                  label: "Bank",
                  selected: true,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                    );
                  },
                ),
                TransactionFilterChip(
                  label: "Airtel Money",
                  selected: false,
                  onTap: () {},
                ),
                TransactionFilterChip(
                  label: "TNM Mpamba",
                  selected: false,
                  onTap: () {},
                ),
                TransactionFilterChip(
                  label: "Cash",
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF121238),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TransactionsList(),
            ),
          ),
        ],
      ),
    );
  }
}
