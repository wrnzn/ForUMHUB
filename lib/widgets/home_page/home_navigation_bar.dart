import 'package:flutter/material.dart';

class HomeNavigationBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const HomeNavigationBar({super.key, required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavTab(context, 0, 'Campus', selectedTab == 0),
          _buildNavTab(context, 1, 'Courses', selectedTab == 1),
        ],
      ),
    );
  }

  Widget _buildNavTab(
    BuildContext context,
    int index,
    String label,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => onTabChanged(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
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
      ),
    );
  }
}
