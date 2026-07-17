import 'package:flutter/material.dart';
import 'package:my_budget/src/utils/skeleton/shimmer.dart';

/// The initial loading state of the dashboard: a shimmering stand-in laid out to
/// match the real content (balance card, summary grid, recent list) so the switch
/// to real data doesn't jump.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            const SkeletonBox(height: 150, radius: 20),
            const SizedBox(height: 20),

            // "Summary" heading
            const SkeletonBox(width: 110, height: 18),
            const SizedBox(height: 14),

            // 2x2 summary grid
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 90, radius: 16)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 90, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 90, radius: 16)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 90, radius: 16)),
              ],
            ),

            const SizedBox(height: 24),

            // Recent list heading
            const SkeletonBox(width: 140, height: 18),
            const SizedBox(height: 14),

            ...List.generate(3, (_) => const _SkeletonRow()),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SkeletonBox(width: 46, height: 46, radius: 23),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 70, height: 16),
        ],
      ),
    );
  }
}
