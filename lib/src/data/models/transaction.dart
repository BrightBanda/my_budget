import 'package:flutter/material.dart';

class BudgetTransaction {
  final String id;
  final double amount;
  final String title;
  final DateTime date;
  final String type;
  final String category;

  BudgetTransaction({
    required this.amount,
    required this.date,
    required this.title,
    required this.type,
    required this.category,
    required this.id,
  });

  factory BudgetTransaction.fromMap(Map<String, dynamic> map) {
    return BudgetTransaction(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

extension TransactionUI on BudgetTransaction {
  bool get isIncome => type == 'income';

  Color get amountColor => isIncome ? Colors.greenAccent : Colors.redAccent;
}
