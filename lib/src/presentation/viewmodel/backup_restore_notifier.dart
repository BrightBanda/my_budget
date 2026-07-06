import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/balance_provider.dart';
import 'package:my_budget/src/providers/database_service_provider.dart';
import 'package:my_budget/src/providers/drive_service_provider.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

enum BackupOperation { idle, backup, restore }

class BackupRestoreNotifier extends AsyncNotifier<void> {
  BackupOperation operation = BackupOperation.idle;

  @override
  void build() {
    // Initialized synchronously to prevent initial AsyncLoading state
  }

  Future<void> backup() async {
    operation = BackupOperation.backup;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final drive = ref.read(driveServiceProvider);
      final database = ref.read(databaseServiceProvider);

      await drive.backupDatabase(database);
    });
  }

  Future<void> restore() async {
    operation = BackupOperation.restore;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final drive = ref.read(driveServiceProvider);
      final database = ref.read(databaseServiceProvider);

      final restored = await drive.restoreDatabase(database);

      if (!restored) {
        throw Exception("No backup found.");
      }

      await ref.read(transactionsProvider.notifier).refreshTransactions();
      await ref.read(goalsProvider.notifier).refreshGoals();

      ref.invalidate(balanceProvider);
    });
  }

  void resetOperation() {
    operation = BackupOperation.idle;
  }
}
