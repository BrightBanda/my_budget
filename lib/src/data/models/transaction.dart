import 'package:flutter/material.dart';

/// Standard set of payment providers used across the app —
/// keep this in sync with `providerFilterOptions` in transaction_filters_provider.dart.
class TransactionProvider {
  static const bank = 'Bank';
  static const airtelMoney = 'Airtel Money';
  static const tnmMpamba = 'TNM Mpamba';
  static const cash = 'Cash';
}

class BudgetTransaction {
  final String id;
  final double amount;
  final String title;
  final DateTime date;
  final String type;
  final String category;
  final String provider; // e.g. 'Bank', 'Airtel Money', 'TNM Mpamba', 'Cash'

  BudgetTransaction({
    required this.amount,
    required this.date,
    required this.title,
    required this.type,
    required this.category,
    required this.id,
    this.provider = TransactionProvider.cash, // safe default for old rows
  });

  factory BudgetTransaction.fromMap(Map<String, dynamic> map) {
    return BudgetTransaction(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      // Fallback keeps old rows (inserted before this column existed) from crashing.
      provider: map['provider'] as String? ?? TransactionProvider.cash,
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
      'provider': provider,
    };
  }

  BudgetTransaction copyWith({
    String? id,
    double? amount,
    String? title,
    DateTime? date,
    String? type,
    String? category,
    String? provider,
  }) {
    return BudgetTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      provider: provider ?? this.provider,
    );
  }
}

extension TransactionUI on BudgetTransaction {
  bool get isIncome => type == 'income';

  Color get amountColor => isIncome ? Colors.greenAccent : Colors.redAccent;
}
