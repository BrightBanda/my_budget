import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/view/home_page.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_filter_chip.dart';
import 'package:my_budget/src/utils/transactions_page/transaction_list.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF09091F),

      body: Column(
        children: [
          const SizedBox(height: 20),

          //const TransactionsHeader(),
          const SizedBox(height: 20),

          //const TransactionFiltersRow(),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12),
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
                      MaterialPageRoute(builder: (builder) => HomePage()),
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
