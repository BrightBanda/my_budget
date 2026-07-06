// lib/src/utils/transactions_page/filter_dropdown.dart
import 'package:flutter/material.dart';

class FilterDropdown<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onChanged;

  const FilterDropdown({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      color: const Color(0xFF121238),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => options.map((option) {
        final isSelected = option == value;
        return PopupMenuItem<T>(
          value: option,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check, size: 16, color: Colors.greenAccent)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(
                optionLabel(option),
                style: TextStyle(
                  color: isSelected ? Colors.greenAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF121238),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              optionLabel(value),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
