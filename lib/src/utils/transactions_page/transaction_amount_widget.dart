import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/currency_formatter_provider.dart';

class TransactionAmountWidget extends ConsumerWidget {
  final double amount;
  final bool isIncome;

  const TransactionAmountWidget({
    super.key,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyFormatterProvider);

    return Text(
      currency.formatSigned(amount, isIncome: isIncome),
      style: TextStyle(
        color: isIncome ? const Color(0xFF00D084) : const Color(0xFFFF0055),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
