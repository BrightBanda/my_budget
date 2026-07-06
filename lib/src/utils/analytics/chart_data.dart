// lib/src/utils/analytics/chart_data.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:my_budget/src/data/models/transaction.dart';

class ChartData {
  static bool _isExpense(BudgetTransaction t) => t.type == 'expense';
  static bool _isIncome(BudgetTransaction t) => t.type == 'income';

  /// Raw totals per category (expenses only) — feeds the pie chart.
  static Map<String, double> expenseByCategory(List<BudgetTransaction> tx) {
    final map = <String, double>{};
    for (final t in tx.where(_isExpense)) {
      map.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return map;
  }

  /// Daily expense totals for the current week, Mon → Sun.
  static List<double> weeklySpending(
    List<BudgetTransaction> tx, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    return days.map((day) {
      return tx
          .where((t) => _isExpense(t) && _sameDay(t.date, day))
          .fold(0.0, (sum, t) => sum + t.amount);
    }).toList();
  }

  /// Income vs expense totals per month for the last [months] months.
  static ({List<double> income, List<double> expense, List<String> labels})
  monthlyIncomeVsExpense(List<BudgetTransaction> tx, {int months = 6}) {
    final buckets = _lastMonths(months);
    final income = <double>[];
    final expense = <double>[];
    final labels = <String>[];

    for (final bucket in buckets) {
      final inMonth = tx.where((t) => _sameMonth(t.date, bucket));
      income.add(inMonth.where(_isIncome).fold(0.0, (s, t) => s + t.amount));
      expense.add(inMonth.where(_isExpense).fold(0.0, (s, t) => s + t.amount));
      labels.add(_monthAbbr(bucket.month));
    }
    return (income: income, expense: expense, labels: labels);
  }

  /// Total expense per month for the last [months] months — feeds the line chart.
  static ({List<FlSpot> spots, List<String> labels}) monthlySpendingTrend(
    List<BudgetTransaction> tx, {
    int months = 6,
  }) {
    final buckets = _lastMonths(months);
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (var i = 0; i < buckets.length; i++) {
      final total = tx
          .where((t) => _isExpense(t) && _sameMonth(t.date, buckets[i]))
          .fold(0.0, (sum, t) => sum + t.amount);
      spots.add(FlSpot(i.toDouble(), total));
      labels.add(_monthAbbr(buckets[i].month));
    }
    return (spots: spots, labels: labels);
  }

  // ---- helpers ----

  static List<DateTime> _lastMonths(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
      (i) => DateTime(now.year, now.month - (count - 1 - i)),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static String _monthAbbr(int month) => _monthNames[month - 1];
}
