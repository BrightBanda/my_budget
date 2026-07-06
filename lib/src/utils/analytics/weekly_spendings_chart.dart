import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklySpendingChart extends StatelessWidget {
  final List<double> spending;
  final List<String> labels;

  WeeklySpendingChart({super.key, required this.spending, List<String>? labels})
    : labels =
          labels ?? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  double get _maxY {
    if (spending.isEmpty) return 10;
    final max = spending.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFFFF9F43);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: _maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _maxY / 4,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: _maxY / 4,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  final text = (i >= 0 && i < labels.length) ? labels[i] : '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toStringAsFixed(2),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(
            spending.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: spending[i],
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC371), barColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
