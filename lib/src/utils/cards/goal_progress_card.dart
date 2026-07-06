import 'package:flutter/material.dart';

class GoalProgressCard extends StatelessWidget {
  final String title;
  final double progress;

  const GoalProgressCard({
    super.key,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress,
            borderRadius: BorderRadius.circular(10),
            minHeight: 10,
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
