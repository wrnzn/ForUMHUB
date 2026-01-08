import 'package:flutter/material.dart';

class NavTab extends StatelessWidget {
  final String label;
  final int index;
  final int selectedTab;
  final Function(int) onTap;

  const NavTab({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
