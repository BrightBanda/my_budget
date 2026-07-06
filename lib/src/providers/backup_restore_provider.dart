import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/viewmodel/backup_restore_notifier.dart';

final backupRestoreProvider =
    AsyncNotifierProvider<BackupRestoreNotifier, void>(
      BackupRestoreNotifier.new,
    );
