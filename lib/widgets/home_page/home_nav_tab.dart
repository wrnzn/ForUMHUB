import 'package:flutter/material.dart';

class HomeNavTab extends StatelessWidget {
  final String label;
  final int index;
  final int selectedTab;
  final Function(int) onTap;

  const HomeNavTab({
    super.key,
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
