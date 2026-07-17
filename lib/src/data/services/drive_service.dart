import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:my_budget/src/data/models/backup_info.dart';
import 'package:my_budget/src/data/services/database_service.dart';

class DriveService {
  static const _backupFileName = 'budget.db';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', drive.DriveApi.driveAppdataScope],
  );

  /// The account currently backing up, if any. Null until the user signs in.
  String? get currentAccountEmail => _googleSignIn.currentUser?.email;

  Future<drive.DriveApi?> _driveApi() async {
    GoogleSignInAccount? account = _googleSignIn.currentUser;

    account ??= await _googleSignIn.signIn();

    if (account == null) return null;

    final client = await _googleSignIn.authenticatedClient();

    if (client == null) return null;

    return drive.DriveApi(client);
  }

  /// Reads the backup's account and last-modified time without downloading it.
  /// If the user isn't signed in this triggers the sign-in prompt, since reading
  /// Drive requires authentication either way.
  Future<BackupInfo> getBackupInfo() async {
    final api = await _driveApi();

    if (api == null) return const BackupInfo();

    final files = await api.files.list(
      spaces: "appDataFolder",
      q: "name='$_backupFileName' and trashed=false",
      $fields: "files(id,name,modifiedTime)",
    );

    final backup = (files.files != null && files.files!.isNotEmpty)
        ? files.files!.first
        : null;

    return BackupInfo(
      accountEmail: currentAccountEmail,
      lastBackupAt: backup?.modifiedTime?.toLocal(),
    );
  }

  /// Signs out first so the next backup shows the account picker, letting the user
  /// back up to a different Google account.
  Future<void> backupWithNewAccount(DatabaseService databaseService) async {
    await _googleSignIn.signOut();

    await backupDatabase(databaseService);
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<void> backupDatabase(DatabaseService databaseService) async {
    print("========== BACKUP STARTED ==========");

    final api = await _driveApi();

    if (api == null) {
      print("❌ Failed to authenticate with Google Drive.");
      throw Exception("Could not authenticate.");
    }

    print("✅ Google Drive authenticated.");

    final path = await databaseService.databasePath();

    print("Database path: $path");

    final dbFile = File(path);

    if (!await dbFile.exists()) {
      print("❌ Database file does not exist.");
      throw Exception("Database file not found.");
    }

    print("Database size: ${await dbFile.length()} bytes");

    final media = drive.Media(dbFile.openRead(), await dbFile.length());

    print("Searching for existing backup...");

    final files = await api.files.list(
      spaces: "appDataFolder",
      q: "name='budget.db' and trashed=false",
      $fields: "files(id,name)",
    );

    if (files.files != null && files.files!.isNotEmpty) {
      final existing = files.files!.first;

      print("Existing backup found.");
      print("File ID: ${existing.id}");

      await api.files.update(drive.File(), existing.id!, uploadMedia: media);

      print("✅ Backup updated successfully.");
    } else {
      print("No previous backup found. Creating one...");

      final metadata = drive.File()
        ..name = "budget.db"
        ..parents = ["appDataFolder"];

      final created = await api.files.create(metadata, uploadMedia: media);

      print("✅ Backup created successfully.");
      print("File ID: ${created.id}");
      print("File Name: ${created.name}");
    }

    print("========== BACKUP FINISHED ==========");
  }

  Future<bool> restoreDatabase(DatabaseService databaseService) async {
    print("========== RESTORE STARTED ==========");

    final api = await _driveApi();

    if (api == null) {
      throw Exception("Could not authenticate.");
    }

    print("✅ Authenticated");

    final files = await api.files.list(
      spaces: "appDataFolder",
      q: "name='budget.db' and trashed=false",
      $fields: "files(id,name)",
    );

    if (files.files == null || files.files!.isEmpty) {
      print("❌ No backup found.");
      return false;
    }

    final backup = files.files!.first;

    print("Backup found:");
    print(backup.name);
    print(backup.id);

    final media =
        await api.files.get(
              backup.id!,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final path = await databaseService.databasePath();

    print("Local database path:");
    print(path);

    //-------------------------------------------------
    // VERY IMPORTANT
    //-------------------------------------------------

    await databaseService.close();

    final file = File(path);

    final sink = file.openWrite();

    await media.stream.pipe(sink);

    await sink.flush();
    await sink.close();

    await databaseService.reopen();

    print("✅ Database restored successfully.");

    print("========== RESTORE COMPLETE ==========");

    return true;
  }
}
