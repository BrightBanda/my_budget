import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/utils/add_button.dart';
import 'package:my_budget/src/utils/app_colors.dart';
import 'package:my_budget/src/utils/balance_summary_card.dart';
import 'package:my_budget/src/utils/goal_card.dart';
import 'package:my_budget/src/utils/statistics_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("MYGOAL", style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.appBar,
        foregroundColor: Colors.white,
        actions: [AddButton(title: "+ Add")],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        margin: EdgeInsets.only(bottom: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            spacing: 10,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 6,
                  children: [
                    ElevatedButton(onPressed: () {}, child: Text("Dashboard")),
                    ElevatedButton(onPressed: () {}, child: Text("Goals")),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("BudgetTransactions"),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Analytics")),
                  ],
                ),
              ),

              BalanceCard(),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatsCard(
                    title: "Savings rate",
                    value: "59%",
                    subtitle: "subtitle",
                  ),
                  StatsCard(
                    title: "Savings rate",
                    value: "59%",
                    subtitle: "subtitle",
                  ),
                  StatsCard(
                    title: "Savings rate",
                    value: "59%",
                    subtitle: "subtitle",
                  ),
                  StatsCard(
                    title: "Savings rate",
                    value: "59%",
                    subtitle: "subtitle",
                  ),
                ],
              ),

              Column(
                children: const [
                  GoalCard(
                    title: "New Laptop",
                    remainingDays: "187 days left",
                    currentAmount: "MWK 87,500",
                    targetAmount: "MWK 350,000",
                    progress: 0.25,
                    funded: "25% funded",
                  ),

                  SizedBox(height: 12),

                  GoalCard(
                    title: "Holiday Trip",
                    remainingDays: "95 days left",
                    currentAmount: "MWK 42,000",
                    targetAmount: "MWK 200,000",
                    progress: 0.90,
                    funded: "21% funded",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
