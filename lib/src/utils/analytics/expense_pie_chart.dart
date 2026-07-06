import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> categories;

  const ExpensePieChart({super.key, required this.categories});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? _touchedIndex;

  static const List<Color> _palette = [
    Color(0xFF4A90D9),
    Color(0xFFFF9F43),
    Color(0xFF2ECC71),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
    Color(0xFFF1C40F),
    Color(0xFFE67E22),
  ];

  double get _total => widget.categories.values.fold(0.0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    final entries = widget.categories.entries.toList();
    final total = _total;

    if (entries.isEmpty || total == 0) {
      return const SizedBox(
        height: 260,
        child: Center(child: Text('No expense data yet')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 55,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = null;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    final percent = (entry.value / total) * 100;
                    final isTouched = i == _touchedIndex;
                    final color = _palette[i % _palette.length];

                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percent.toStringAsFixed(0)}%',
                      radius: isTouched ? 60 : 50,
                      color: color,
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
              // Center label showing total
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    total.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            final entry = entries[i];
            final color = _palette[i % _palette.length];
            final percent = (entry.value / total) * 100;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.key} (${percent.toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
