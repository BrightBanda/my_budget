// lib/src/utils/analytics/analytics_models.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/utils/analytics/chart_data.dart';

class AnalyticsOverview {
  final double income;
  final double expenses;
  final double balance;
  final double savingsRate; // 0.0 - 1.0

  const AnalyticsOverview({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.savingsRate,
  });
}

class InsightData {
  final double expenseChangePercent; // vs last month, negative = spent less
  final String? topCategory;
  final double topCategoryPercent;
  final int goalsCompletedThisYear;
  final double dailyAverageSpending;

  const InsightData({
    required this.expenseChangePercent,
    required this.topCategory,
    required this.topCategoryPercent,
    required this.goalsCompletedThisYear,
    required this.dailyAverageSpending,
  });
}

class GoalProgress {
  final String title;
  final double progress; // 0.0 - 1.0

  const GoalProgress({required this.title, required this.progress});
}

class AnalyticsData {
  final AnalyticsOverview overview;
  final Map<String, double> expenseCategories;
  final ({List<double> income, List<double> expense, List<String> labels})
  incomeVsExpense;
  final List<double> weeklySpending;
  final ({List<FlSpot> spots, List<String> labels}) monthlyTrend;
  final List<GoalProgress> goals;
  final InsightData insights;

  const AnalyticsData({
    required this.overview,
    required this.expenseCategories,
    required this.incomeVsExpense,
    required this.weeklySpending,
    required this.monthlyTrend,
    required this.goals,
    required this.insights,
  });

  factory AnalyticsData.compute(
    List<BudgetTransaction> tx,
    List<SavingGoal> goals,
  ) {
    final now = DateTime.now();

    bool inMonth(BudgetTransaction t, DateTime m) =>
        t.date.year == m.year && t.date.month == m.month;

    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final thisMonthTx = tx.where((t) => inMonth(t, thisMonth));
    final lastMonthTx = tx.where((t) => inMonth(t, lastMonth));

    final monthIncome = thisMonthTx
        .where((t) => t.type == 'income')
        .fold(0.0, (s, t) => s + t.amount);
    final monthExpense = thisMonthTx
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);
    final lastMonthExpense = lastMonthTx
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);

    final balance = monthIncome - monthExpense;
    final savingsRate = monthIncome > 0
        ? (balance / monthIncome).clamp(0.0, 1.0)
        : 0.0;

    final overview = AnalyticsOverview(
      income: monthIncome,
      expenses: monthExpense,
      balance: balance,
      savingsRate: savingsRate,
    );

    // ---- insights ----
    final expenseChangePercent = lastMonthExpense > 0
        ? ((monthExpense - lastMonthExpense) / lastMonthExpense) * 100
        : 0.0;

    final categories = ChartData.expenseByCategory(thisMonthTx.toList());
    String? topCategory;
    double topCategoryPercent = 0;
    if (categories.isNotEmpty && monthExpense > 0) {
      final top = categories.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      topCategory = top.key;
      topCategoryPercent = (top.value / monthExpense) * 100;
    }

    final daysSoFarThisMonth = now.day;
    final dailyAverage = daysSoFarThisMonth > 0
        ? monthExpense / daysSoFarThisMonth
        : 0.0;

    final completedThisYear = goals.where((g) {
      final done = g.currentAmount >= g.targetAmount;
      return done; // add a completedAt/date field to scope strictly to "this year" if you track it
    }).length;

    final insights = InsightData(
      expenseChangePercent: expenseChangePercent,
      topCategory: topCategory,
      topCategoryPercent: topCategoryPercent,
      goalsCompletedThisYear: completedThisYear,
      dailyAverageSpending: dailyAverage,
    );

    final goalProgress = goals.map((g) {
      final progress = g.targetAmount > 0
          ? (g.currentAmount / g.targetAmount).clamp(0.0, 1.0)
          : 0.0;
      return GoalProgress(title: g.title, progress: progress);
    }).toList();

    return AnalyticsData(
      overview: overview,
      expenseCategories: ChartData.expenseByCategory(tx),
      incomeVsExpense: ChartData.monthlyIncomeVsExpense(tx),
      weeklySpending: ChartData.weeklySpending(tx),
      monthlyTrend: ChartData.monthlySpendingTrend(tx),
      goals: goalProgress,
      insights: insights,
    );
  }
}
