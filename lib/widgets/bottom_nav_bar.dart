import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final ValueChanged<int>? onTabChanged;
  final int activeTab;
  final int notificationCount; // Added
  final int messageCount; // Added

  const BottomNavBar({
    super.key,
    this.onTabChanged,
    this.activeTab = 0,
    this.notificationCount = 0,
    this.messageCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildItem(context, 0, Icons.home_rounded, activeTab == 0, brandOrange),
                _buildItem(context, 1, Icons.shopping_bag_rounded, activeTab == 1, brandOrange),
                const SizedBox(width: 60),
                _buildItem(context, 3, Icons.notifications_rounded, activeTab == 3, brandOrange, count: notificationCount),
                _buildItem(context, 4, Icons.chat_bubble_rounded, activeTab == 4, brandOrange, count: messageCount),
              ],
            ),
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => onTabChanged?.call(2),
              child: Container(
                width: 65, height: 65,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFB8C00), Color(0xFFF4511E)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: const Color(0xFFFB8C00).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, bool isActive, Color color, {int count = 0}) {
    return GestureDetector(
      onTap: () => onTabChanged?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 28, color: isActive ? color : Colors.grey[400]),
          if (count > 0)
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
