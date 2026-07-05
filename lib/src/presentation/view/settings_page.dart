import 'package:flutter/material.dart';
import 'package:my_budget/src/utils/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              onTap: () {},
            ),

            _SettingsTile(
              icon: Icons.restore,
              title: "Restore Backup",
              subtitle: "Restore data from backup",
              onTap: () {},
            ),

            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "Manage reminders",
              onTap: () {},
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
                    "BudgetPal",
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
  final VoidCallback onTap;

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
