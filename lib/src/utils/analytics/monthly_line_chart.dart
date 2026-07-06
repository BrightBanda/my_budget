import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String>? labels; // e.g. ['Jan','Feb',...] or week numbers

  const MonthlyLineChart({super.key, required this.spots, this.labels});

  double get _minY {
    if (spots.isEmpty) return 0;
    final min = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    return min * 0.9 < 0
        ? min * 1.1
        : 0; // keep 0 baseline unless values go negative
  }

  double get _maxY {
    if (spots.isEmpty) return 10;
    final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    const lineColor = Color(0xFF4A90D9);

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: _minY,
          maxY: _maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (_maxY - _minY) / 4,
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
                reservedSize: 42,
                interval: (_maxY - _minY) / 4,
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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  final text = (labels != null && i >= 0 && i < labels!.length)
                      ? labels![i]
                      : i.toString();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(2),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: lineColor.withOpacity(0.3), strokeWidth: 2),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                );
              }).toList();
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: lineColor,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withOpacity(0.25),
                    lineColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
