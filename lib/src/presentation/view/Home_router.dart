import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/view/analytics_page.dart';
import 'package:my_budget/src/presentation/view/goals_page.dart';
import 'package:my_budget/src/presentation/view/home_page.dart';
import 'package:my_budget/src/presentation/view/settings_page.dart';
import 'package:my_budget/src/presentation/view/transactions_page.dart';
import 'package:my_budget/src/presentation/viewmodel/page_notifier.dart';
import 'package:my_budget/src/providers/auto_capture_provider.dart';
import 'package:my_budget/src/utils/custom_nav_bar.dart';
import 'package:my_budget/src/utils/header_section.dart';

class HomeRouter extends ConsumerWidget {
  const HomeRouter({super.key});

  final pages = const [
    HomePage(),
    GoalsPage(),
    TransactionsPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps auto-capture listening for the app's whole lifetime rather than only
    // while the settings page happens to be built. Listened to, not watched, so
    // an import doesn't rebuild the router.
    ref.listen(autoCaptureProvider, (_, __) {});

    final currentIndex = ref.watch(pageIndexProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF090B2D),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(),

            CustomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(pageIndexProvider.notifier).changePage(index);
              },
            ),

            Expanded(
              child: IndexedStack(index: currentIndex, children: pages),
            ),
          ],
        ),
      ),
    );
  }
}
