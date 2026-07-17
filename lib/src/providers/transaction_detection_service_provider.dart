import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/services/transaction_detection_service.dart';

final transactionDetectionServiceProvider = Provider<TransactionDetectionService>(
  (ref) => TransactionDetectionService(),
);
