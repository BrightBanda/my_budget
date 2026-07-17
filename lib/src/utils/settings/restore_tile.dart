import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_budget/src/data/models/backup_info.dart';
import 'package:my_budget/src/providers/backup_info_provider.dart';
import 'package:my_budget/src/providers/backup_restore_provider.dart';

/// "Restore Backup" tile. Expanding it loads the backup's account and date from
/// Drive (via [backupInfoProvider]) and offers the restore action. The provider is
/// only watched while expanded, so opening Settings never triggers a sign-in.
class RestoreSettingsTile extends ConsumerStatefulWidget {
  const RestoreSettingsTile({super.key});

  @override
  ConsumerState<RestoreSettingsTile> createState() =>
      _RestoreSettingsTileState();
}

class _RestoreSettingsTileState extends ConsumerState<RestoreSettingsTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF17173B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.white),
            title: const Text(
              "Restore Backup",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Restore data from Google Drive",
              style: TextStyle(color: Colors.white54),
            ),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.expand_more, color: Colors.white54),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      const Divider(color: Color(0xFF2A2A5A), height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                        child: _buildDetails(),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    // Watched only inside the expanded branch, so the fetch (and its sign-in) is
    // deferred until the user actually asks for it.
    final infoAsync = ref.watch(backupInfoProvider);

    return infoAsync.when(
      loading: () => const _DetailText("Checking Google Drive..."),
      error: (error, _) => _DetailText("Couldn't reach Drive: $error"),
      data: (info) => _details(info),
    );
  }

  Widget _details(BackupInfo info) {
    if (!info.isConnected) {
      return const _DetailText("Sign in to Google to view your backup.");
    }

    if (!info.hasBackup) {
      return _DetailText(
        "No backup found on ${info.accountEmail}.",
      );
    }

    final formattedDate = DateFormat(
      'EEE, d MMM yyyy • h:mm a',
    ).format(info.lastBackupAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: "Account", value: info.accountEmail!),
        const SizedBox(height: 8),
        _InfoRow(label: "Last backup", value: formattedDate),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.black,
            ),
            onPressed: () =>
                ref.read(backupRestoreProvider.notifier).restore(),
            icon: const Icon(Icons.restore),
            label: const Text("Restore this backup"),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: Colors.white54)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _DetailText extends StatelessWidget {
  final String text;

  const _DetailText(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(color: Colors.white54)),
    );
  }
}
