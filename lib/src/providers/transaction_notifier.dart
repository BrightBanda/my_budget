import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/presentation/viewmodel/home_page_viewmodel.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<BudgetTransaction>>(
      TransactionsNotifier.new,
    );
