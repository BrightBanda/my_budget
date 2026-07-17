import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/backup_restore_provider.dart';

/// "Backup Data" tile. Collapsed it's a plain row; expanded it offers a direct
/// backup and a switch-account backup. Expansion is transient view state, so it
/// lives here; every action delegates to the backup/restore notifier.
class BackupSettingsTile extends ConsumerStatefulWidget {
  const BackupSettingsTile({super.key});

  @override
  ConsumerState<BackupSettingsTile> createState() => _BackupSettingsTileState();
}

class _BackupSettingsTileState extends ConsumerState<BackupSettingsTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(backupRestoreProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF17173B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup_outlined, color: Colors.white),
            title: const Text(
              "Backup Data",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Save data to Google Drive",
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
                      _ExpandedAction(
                        icon: Icons.cloud_upload_outlined,
                        label: "Back up now",
                        onTap: () => notifier.backup(),
                      ),
                      _ExpandedAction(
                        icon: Icons.switch_account_outlined,
                        label: "Use another account",
                        onTap: () => notifier.backupWithNewAccount(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ExpandedAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExpandedAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }
}
