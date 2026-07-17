import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/backup_info.dart';
import 'package:my_budget/src/providers/drive_service_provider.dart';

/// Backup metadata for the restore tile. autoDispose so it's only fetched while the
/// tile is expanded — opening Settings must never trigger a Google sign-in on its own.
final backupInfoProvider = FutureProvider.autoDispose<BackupInfo>((ref) async {
  final drive = ref.read(driveServiceProvider);

  return drive.getBackupInfo();
});
