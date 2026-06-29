import 'package:flutter/material.dart';

class TransactionIcon extends StatelessWidget {
  final String type;
  final String category;

  const TransactionIcon({
    super.key,
    required this.type,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B4A),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Icon(
        type == 'income' ? Icons.trending_up : Icons.shopping_bag_outlined,
        color: type == 'income'
            ? const Color(0xFF00D084)
            : const Color(0xFFFFB800),
      ),
    );
  }
}
