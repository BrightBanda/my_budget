import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Dashboard', Icons.dashboard_outlined),
      ('Goals', Icons.track_changes_outlined),
      ('Transactions', Icons.list_alt_outlined),
      ('Analytics', Icons.analytics),
      ("Settings", Icons.settings),
    ];

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(113, 30, 35, 80)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 14,
          children: List.generate(items.length, (index) {
            final selected = currentIndex == index;

            return InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index].$2,
                        size: 18,
                        color: selected ? const Color(0xFF00E59B) : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        items[index].$1,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF00E59B)
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 2,
                    width: selected ? 80 : 0,
                    color: const Color(0xFF00E59B),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
