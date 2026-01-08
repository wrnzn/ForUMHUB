import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/nav_tab.dart';

class NavigationBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const NavigationBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavTab(
            label: 'Home',
            index: 0,
            selectedTab: selectedTab,
            onTap: onTabChanged,
          ),
          NavTab(
            label: 'Campus',
            index: 1,
            selectedTab: selectedTab,
            onTap: onTabChanged,
          ),
          NavTab(
            label: 'Market',
            index: 2,
            selectedTab: selectedTab,
            onTap: onTabChanged,
          ),
          NavTab(
            label: 'Courses',
            index: 3,
            selectedTab: selectedTab,
            onTap: onTabChanged,
          ),
        ],
      ),
    );
  }
}
