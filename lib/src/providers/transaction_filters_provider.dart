// lib/src/providers/transaction_filters_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

enum DateFilter { today, thisWeek, thisMonth, all }

extension DateFilterLabel on DateFilter {
  String get label {
    switch (this) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.all:
        return 'All Time';
    }
  }
}

const providerFilterOptions = [
  'All',
  'Bank',
  'Airtel Money',
  'TNM Mpamba',
  'Cash',
];

final dateFilterProvider = StateProvider<DateFilter>((ref) => DateFilter.all);
final providerFilterProvider = StateProvider<String>((ref) => 'All');

final filteredTransactionsProvider =
    Provider<AsyncValue<List<BudgetTransaction>>>((ref) {
      final txAsync = ref.watch(transactionsProvider);
      final dateFilter = ref.watch(dateFilterProvider);
      final providerFilter = ref.watch(providerFilterProvider);
      return txAsync.whenData((items) {
        return items.where((t) {
          final matchesDate = _matchesDateFilter(t.date, dateFilter);
          final matchesProvider =
              providerFilter == 'All' || t.provider == providerFilter;
          return matchesDate && matchesProvider;
        }).toList();
      });
    });

bool _matchesDateFilter(DateTime date, DateFilter filter) {
  final now = DateTime.now();
  switch (filter) {
    case DateFilter.all:
      return true;
    case DateFilter.today:
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    case DateFilter.thisWeek:
      final monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final endOfWeek = monday.add(const Duration(days: 7));
      return !date.isBefore(monday) && date.isBefore(endOfWeek);
    case DateFilter.thisMonth:
      return date.year == now.year && date.month == now.month;
  }
}
