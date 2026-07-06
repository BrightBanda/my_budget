// lib/src/providers/analytics_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/analytics_overview.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

final analyticsDataProvider = Provider<AsyncValue<AnalyticsData>>((ref) {
  final txAsync = ref.watch(transactionsProvider);
  final goalsAsync = ref.watch(goalsProvider);

  if (txAsync.isLoading || goalsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (txAsync.hasError) {
    return AsyncValue.error(
      txAsync.error!,
      txAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(
      goalsAsync.error!,
      goalsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncValue.data(
    AnalyticsData.compute(txAsync.value ?? [], goalsAsync.value ?? []),
  );
});
