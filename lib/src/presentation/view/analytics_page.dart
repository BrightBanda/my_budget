import 'package:flutter/material.dart';

import 'package:my_budget/src/utils/analytics/analytics_section.dart';
import 'package:my_budget/src/utils/analytics/expense_pie_chart.dart';
import 'package:my_budget/src/utils/analytics/income_expense_chart.dart';
import 'package:my_budget/src/utils/analytics/monthly_line_chart.dart';
import 'package:my_budget/src/utils/analytics/weekly_spendings_chart.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/cards/goal_progress_card.dart';
import 'package:my_budget/src/utils/cards/insight_card.dart';
import 'package:my_budget/src/utils/cards/overview_card.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    //----------------------------------------
    // MOCK DATA
    //----------------------------------------

    final lineData = [
      const FlSpot(1, 1200),
      const FlSpot(2, 1700),
      const FlSpot(3, 900),
      const FlSpot(4, 2400),
      const FlSpot(5, 1800),
      const FlSpot(6, 2800),
      const FlSpot(7, 2100),
    ];

    final expenseCategories = {
      "Food": 47.0,
      "Transport": 18.0,
      "Bills": 16.0,
      "Shopping": 12.0,
      "Entertainment": 18.0,
      "Other": 4.0,
    };

    final income = [4000.0, 4500.0, 5200.0, 5000.0, 6000.0, 5800.0];

    final expense = [2800.0, 3200.0, 3600.0, 3900.0, 4100.0, 4300.0];

    final weeklySpending = [400.0, 900.0, 700.0, 1200.0, 1800.0, 1600.0, 850.0];

    //----------------------------------------

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
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

              //----------------------------------------------------
              // OVERVIEW
              //----------------------------------------------------
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,

                crossAxisCount: 2,

                crossAxisSpacing: 14,
                mainAxisSpacing: 14,

                childAspectRatio: 1.15,

                children: const [
                  OverviewCard(
                    title: "Income",
                    value: "MWK 540,000",
                    subtitle: "This month",
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),

                  OverviewCard(
                    title: "Expenses",
                    value: "MWK 312,000",
                    subtitle: "This month",
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),

                  OverviewCard(
                    title: "Balance",
                    value: "MWK 228,000",
                    subtitle: "Current",
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue,
                  ),

                  OverviewCard(
                    title: "Savings",
                    value: "42%",
                    subtitle: "Savings Rate",
                    icon: Icons.savings,
                    iconColor: Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              //----------------------------------------------------
              // MONTHLY TREND
              //----------------------------------------------------
              AnalyticsSection(
                title: "Monthly Spending Trend",
                child: MonthlyLineChart(spots: lineData),
              ),

              //----------------------------------------------------
              // PIE CHART
              //----------------------------------------------------
              AnalyticsSection(
                title: "Expense Categories",
                child: ExpensePieChart(categories: expenseCategories),
              ),

              //----------------------------------------------------
              // BAR CHART
              //----------------------------------------------------
              AnalyticsSection(
                title: "Income vs Expense",

                child: IncomeExpenseChart(income: income, expense: expense),
              ),

              //----------------------------------------------------
              // WEEKLY CHART
              //----------------------------------------------------
              AnalyticsSection(
                title: "Weekly Spending",

                child: WeeklySpendingChart(spending: weeklySpending),
              ),

              //----------------------------------------------------
              // GOALS
              //----------------------------------------------------
              AnalyticsSection(
                title: "Savings Goals",

                child: const Column(
                  children: [
                    GoalProgressCard(title: "Emergency Fund", progress: .82),

                    GoalProgressCard(title: "Vacation", progress: .61),

                    GoalProgressCard(title: "Laptop", progress: .37),
                  ],
                ),
              ),

              //----------------------------------------------------
              // INSIGHTS
              //----------------------------------------------------
              AnalyticsSection(
                title: "Insights",

                child: const Column(
                  children: [
                    InsightCard(
                      icon: Icons.trending_down,
                      title: "Lower Spending",
                      description: "You spent 18% less than last month.",
                    ),

                    InsightCard(
                      icon: Icons.restaurant,
                      title: "Highest Category",
                      description: "Food accounts for 42% of your expenses.",
                    ),

                    InsightCard(
                      icon: Icons.flag,
                      title: "Goals",
                      description: "You completed 2 savings goals this year.",
                    ),

                    InsightCard(
                      icon: Icons.bar_chart,
                      title: "Daily Average",
                      description: "Average daily spending is MWK 4,250.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
