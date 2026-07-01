import 'package:flutter/material.dart';

class DeductionCard extends StatelessWidget {
  final String title;
  final String frequency;
  final double amount;

  const DeductionCard({
    super.key,
    required this.title,
    required this.frequency,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17173B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.pink.withOpacity(.2),
            child: const Icon(Icons.home, color: Colors.pink),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(frequency, style: const TextStyle(color: Colors.blue)),
              ],
            ),
          ),

          Text(
            "-MWK ${amount.toInt()}",
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
