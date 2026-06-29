import 'package:flutter/material.dart';

class TransactionAmountWidget extends StatelessWidget {
  final double amount;
  final bool isIncome;

  const TransactionAmountWidget({
    super.key,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${isIncome ? '+' : '-'}MWK ${amount.toStringAsFixed(0)}',
      style: TextStyle(
        color: isIncome ? const Color(0xFF00D084) : const Color(0xFFFF0055),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
