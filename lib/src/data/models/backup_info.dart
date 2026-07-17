/// Metadata about the current Google Drive backup, shown when the user expands
/// the backup/restore settings tiles.
class BackupInfo {
  /// The signed-in Google account, or null if Drive couldn't be reached.
  final String? accountEmail;

  /// When the backup on Drive was last written. Null means no backup exists yet.
  final DateTime? lastBackupAt;

  const BackupInfo({this.accountEmail, this.lastBackupAt});

  bool get hasBackup => lastBackupAt != null;

  /// Whether we managed to authenticate with Drive at all.
  bool get isConnected => accountEmail != null;
}
