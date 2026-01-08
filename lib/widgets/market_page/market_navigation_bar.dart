import 'package:flutter/material.dart';
import 'package:ForUMHUB/pages/home_page.dart';
import 'package:ForUMHUB/pages/campus_page.dart';
import 'package:ForUMHUB/pages/courses_page.dart';

class MarketNavigationBar extends StatefulWidget {
  const MarketNavigationBar({super.key});

  @override
  State<MarketNavigationBar> createState() => _MarketNavigationBarState();
}

class _MarketNavigationBarState extends State<MarketNavigationBar> {
  int _selectedTab = 2; // Market is selected by default

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavTab(
            context,
            0,
            'Home',
            _selectedTab == 0,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          _buildNavTab(
            context,
            1,
            'Campus',
            _selectedTab == 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CampusPage()),
              );
            },
          ),
          _buildNavTab(context, 2, 'Market', _selectedTab == 2, onTap: () {}),
          _buildNavTab(
            context,
            3,
            'Courses',
            _selectedTab == 3,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoursesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(
    BuildContext context,
    int index,
    String label,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
