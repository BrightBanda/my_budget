import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/viewmodel/transaction_selection_notifier.dart';

final transactionSelectionProvider =
    NotifierProvider<TransactionSelectionNotifier, Set<String>>(
      TransactionSelectionNotifier.new,
    );
