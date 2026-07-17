import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/data/services/database_service.dart';
import 'package:my_budget/src/providers/database_service_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<BudgetTransaction>> {
  late final DatabaseService _db;

  @override
  Future<List<BudgetTransaction>> build() async {
    _db = ref.read(databaseServiceProvider);

    return _db.getTransactions();
  }

  Future<void> addTransaction(BudgetTransaction transaction) async {
    await _db.insertTransaction(transaction);

    refreshTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    refreshTransactions();
  }

  Future<void> refreshTransactions() async {
    final updated = await _db.getTransactions();

    state = AsyncData(updated);
  }

  Future<void> updateTransaction(BudgetTransaction transaction) async {
    await _db.updateTransaction(transaction);

    ref.invalidateSelf();
  }
}
