import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/auto_capture_state.dart';
import 'package:my_budget/src/data/services/google_auth_service.dart';
import 'package:my_budget/src/presentation/viewmodel/backup_restore_notifier.dart';
import 'package:my_budget/src/providers/auto_capture_provider.dart';
import 'package:my_budget/src/providers/backup_restore_provider.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/loading_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AutoCaptureState>>(autoCaptureProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (state) {
          // Only speak up for a sync that actually landed something new. The
          // timestamp separates two imports that happened to have equal counts.
          if (state.lastImportedCount == 0) return;
          if (state.lastSyncAt == previous?.value?.lastSyncAt) return;

          final count = state.lastImportedCount;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text(
                "Auto-added $count ${count == 1 ? 'transaction' : 'transactions'}.",
              ),
            ),
          );
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Auto-capture failed: $error"),
            ),
          );
        },
      );
    });

    final autoCapture =
        ref.watch(autoCaptureProvider).value ?? const AutoCaptureState();

    ref.listen<AsyncValue<void>>(backupRestoreProvider, (previous, next) {
      final notifier = ref.read(backupRestoreProvider.notifier);

      // Guard Clause: Ignore state emissions if no backup/restore action is running
      if (notifier.operation == BackupOperation.idle) return;

      if (next.isLoading) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LoadingDialog(
            message: notifier.operation == BackupOperation.backup
                ? "Backing up your data..."
                : "Restoring your data...",
          ),
        );
        return;
      }

      if (previous?.isLoading == true) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                notifier.operation == BackupOperation.backup
                    ? "Backup completed successfully."
                    : "Restore completed successfully.",
              ),
            ),
          );
          notifier.resetOperation();
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(error.toString()),
            ),
          );
          notifier.resetOperation();
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            _SettingsTile(
              icon: Icons.backup_outlined,
              title: "Backup Data",
              subtitle: "Save data to Google Drive",
              onTap: () async {
                final user = await GoogleAuthService().signIn();
                if (user == null) return;

                await ref.read(backupRestoreProvider.notifier).backup();
              },
            ),

            _SettingsTile(
              icon: Icons.restore,
              title: "Restore Backup",
              subtitle: "Restore data from Google Drive",
              onTap: () async {
                final user = await GoogleAuthService().signIn();
                if (user == null) return;

                await ref.read(backupRestoreProvider.notifier).restore();
              },
            ),

            _SettingsTile(
              icon: autoCapture.isListenerEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              title: "Auto-Capture Transactions",
              subtitle: autoCapture.isListenerEnabled
                  ? "Reading Airtel Money & Mpamba alerts"
                  : "Tap to allow notification access",
              iconColor: autoCapture.isListenerEnabled
                  ? AppColors.primary
                  : Colors.white,
              onTap: autoCapture.isListenerEnabled
                  ? () => ref.read(autoCaptureProvider.notifier).syncNow()
                  : () => ref
                        .read(autoCaptureProvider.notifier)
                        .requestListenerPermission(),
            ),

            _SettingsTile(
              icon: Icons.currency_exchange,
              title: "Currency",
              subtitle: "MWK",
              onTap: () {},
            ),

            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: "Theme",
              subtitle: "Dark",
              onTap: () {},
            ),

            _SettingsTile(
              icon: Icons.delete_outline,
              title: "Clear All Data",
              subtitle: "Delete all transactions and goals",
              iconColor: Colors.red,
              onTap: () {},
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF17173B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Text(
                    "BUDGETEER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF17173B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
