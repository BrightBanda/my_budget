import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
