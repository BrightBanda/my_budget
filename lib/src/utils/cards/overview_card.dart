import 'package:flutter/material.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final double value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF20204A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: iconColor.withOpacity(.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),

          const Spacer(),

          Text(
            value.mwk,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),

          Text(subtitle, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}
