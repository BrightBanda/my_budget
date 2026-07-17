import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/view/analytics_page.dart';
import 'package:my_budget/src/presentation/view/goals_page.dart';
import 'package:my_budget/src/presentation/view/home_page.dart';
import 'package:my_budget/src/presentation/view/settings_page.dart';
import 'package:my_budget/src/presentation/view/transactions_page.dart';
import 'package:my_budget/src/presentation/viewmodel/page_notifier.dart';
import 'package:my_budget/src/providers/app_boot_provider.dart';
import 'package:my_budget/src/providers/auto_capture_provider.dart';
import 'package:my_budget/src/providers/pending_prefill_provider.dart';
import 'package:my_budget/src/utils/add_transaction_sheet.dart';
import 'package:my_budget/src/utils/custom_nav_bar.dart';
import 'package:my_budget/src/utils/header_section.dart';
import 'package:my_budget/src/utils/skeleton/dashboard_skeleton.dart';

class HomeRouter extends ConsumerStatefulWidget {
  const HomeRouter({super.key});

  @override
  ConsumerState<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends ConsumerState<HomeRouter> {
  static const _pages = [
    HomePage(),
    GoalsPage(),
    TransactionsPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  // Drives the directional page slide. Swipe is disabled — the nav bar owns navigation.
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps auto-capture listening for the app's whole lifetime rather than only
    // while the settings page happens to be built.
    ref.listen(autoCaptureProvider, (_, __) {});

    // A tapped detection notification lands here: open the add-transaction sheet
    // pre-filled, then clear so it fires exactly once.
    ref.listen(pendingPrefillProvider, (_, detected) {
      if (detected == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddTransactionSheet(prefill: detected),
        );
      });

      ref.read(pendingPrefillProvider.notifier).clear();
    });

    // Slide the page whenever the nav index changes, in the direction of travel.
    ref.listen<int>(pageIndexProvider, (_, next) {
      if (!_controller.hasClients) return;

      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    });

    final currentIndex = ref.watch(pageIndexProvider);
    final isBooting = ref.watch(appBootProvider);

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
              // First launch shows shimmering placeholders; then it cross-fades to
              // the real pages once the warm-up finishes.
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isBooting
                    ? const DashboardSkeleton()
                    : PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _pages,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
