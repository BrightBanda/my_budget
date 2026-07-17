import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/analytics_overview.dart';
import 'package:my_budget/src/providers/analytics/analytics_data_provider.dart';
//import 'package:my_budget/src/utils/analytics/analytics_models.dart'; // <-- AnalyticsData lives here

import 'package:my_budget/src/utils/analytics/analytics_section.dart';
import 'package:my_budget/src/utils/analytics/expense_pie_chart.dart';
import 'package:my_budget/src/utils/analytics/income_expense_chart.dart';
import 'package:my_budget/src/utils/analytics/monthly_line_chart.dart';
import 'package:my_budget/src/utils/analytics/weekly_spendings_chart.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/cards/goal_progress_card.dart';
import 'package:my_budget/src/utils/cards/insight_card.dart';
import 'package:my_budget/src/utils/cards/overview_card.dart';
import 'package:my_budget/src/providers/currency_formatter_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: analyticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load analytics: $err',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (data) => _AnalyticsContent(data: data),
        ),
      ),
    );
  }
}

class _AnalyticsContent extends ConsumerWidget {
  final AnalyticsData data; // was: dynamic — this was the bug

  const _AnalyticsContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyFormatterProvider);
    final overview = data.overview;
    final insights = data.insights;

    final hasWeeklySpending = data.weeklySpending.any((v) => v > 0);
    final hasIncomeVsExpense =
        data.incomeVsExpense.income.any((v) => v > 0) ||
        data.incomeVsExpense.expense.any((v) => v > 0);
    final hasMonthlyTrend = data.monthlyTrend.spots.any((s) => s.y != 0);
    final hasCategories = data.expenseCategories.isNotEmpty;
    final hasGoals = data.goals.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Analytics",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // ------------------------------------------------------
          // OVERVIEW
          // ------------------------------------------------------
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              OverviewCard(
                title: "Income",
                value: overview.income,
                subtitle: "This month",
                icon: Icons.arrow_downward,
                iconColor: Colors.green,
              ),
              OverviewCard(
                title: "Expenses",
                value: overview.expenses,
                subtitle: "This month",
                icon: Icons.arrow_upward,
                iconColor: Colors.red,
              ),
              OverviewCard(
                title: "Balance",
                value: overview.balance,
                subtitle: "Current",
                icon: Icons.account_balance_wallet,
                iconColor: Colors.blue,
              ),
              OverviewCard(
                title: "Savings",
                value: (overview.savingsRate * 100),
                subtitle: "Savings Rate",
                icon: Icons.savings,
                iconColor: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ------------------------------------------------------
          // MONTHLY TREND
          // ------------------------------------------------------
          AnalyticsSection(
            title: "Monthly Spending Trend",
            child: hasMonthlyTrend
                ? MonthlyLineChart(
                    spots: data.monthlyTrend.spots,
                    labels: data.monthlyTrend.labels,
                  )
                : const _EmptyState(message: "No spending history yet"),
          ),

          // ------------------------------------------------------
          // PIE CHART
          // ------------------------------------------------------
          AnalyticsSection(
            title: "Expense Categories",
            child: hasCategories
                ? ExpensePieChart(categories: data.expenseCategories)
                : const _EmptyState(message: "No expenses recorded yet"),
          ),

          // ------------------------------------------------------
          // BAR CHART
          // ------------------------------------------------------
          AnalyticsSection(
            title: "Income vs Expense",
            child: hasIncomeVsExpense
                ? IncomeExpenseChart(
                    income: data.incomeVsExpense.income,
                    expense: data.incomeVsExpense.expense,
                    labels: data.incomeVsExpense.labels,
                  )
                : const _EmptyState(message: "No transactions recorded yet"),
          ),

          // ------------------------------------------------------
          // WEEKLY CHART
          // ------------------------------------------------------
          AnalyticsSection(
            title: "Weekly Spending",
            child: hasWeeklySpending
                ? WeeklySpendingChart(spending: data.weeklySpending)
                : const _EmptyState(message: "No spending recorded this week"),
          ),

          // ------------------------------------------------------
          // GOALS
          // ------------------------------------------------------
          AnalyticsSection(
            title: "Savings Goals",
            child: hasGoals
                ? Column(
                    children: data.goals
                        .map<Widget>(
                          (g) => GoalProgressCard(
                            title: g.title,
                            progress: g.progress,
                          ),
                        )
                        .toList(),
                  )
                : const _EmptyState(message: "No savings goals yet"),
          ),

          // ------------------------------------------------------
          // INSIGHTS
          // ------------------------------------------------------
          AnalyticsSection(
            title: "Insights",
            child: Column(
              children: [
                InsightCard(
                  icon: insights.expenseChangePercent <= 0
                      ? Icons.trending_down
                      : Icons.trending_up,
                  title: insights.expenseChangePercent <= 0
                      ? "Lower Spending"
                      : "Higher Spending",
                  description:
                      "You spent ${insights.expenseChangePercent.abs().toStringAsFixed(0)}% "
                      "${insights.expenseChangePercent <= 0 ? 'less' : 'more'} than last month.",
                ),
                if (insights.topCategory != null)
                  InsightCard(
                    icon: Icons.restaurant,
                    title: "Highest Category",
                    description:
                        "${insights.topCategory} accounts for "
                        "${insights.topCategoryPercent.toStringAsFixed(0)}% of your expenses.",
                  ),
                InsightCard(
                  icon: Icons.flag,
                  title: "Goals",
                  description:
                      "You completed ${insights.goalsCompletedThisYear} savings goal"
                      "${insights.goalsCompletedThisYear == 1 ? '' : 's'} this year.",
                ),
                InsightCard(
                  icon: Icons.bar_chart,
                  title: "Daily Average",
                  description:
                      "Average daily spending is    ${currency.format(insights.dailyAverageSpending)}",
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}
