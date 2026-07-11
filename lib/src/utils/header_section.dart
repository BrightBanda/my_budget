import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/utils/add_button.dart';
import 'package:my_budget/src/utils/add_transaction_sheet.dart';

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            "BUDGETEER",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          AddButton(
            title: "+ ADD",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}
