import 'package:flutter/material.dart';
import 'package:ForUMHUB/pages/create_post_page.dart';
import 'package:ForUMHUB/pages/sell_item_page.dart';

class CreatePostDialog extends StatelessWidget {
  const CreatePostDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);
    const Color cardBg = Color(0xFFFFF3E0); // Soft beige background from screenshot

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What would you like to do?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                // 1. Create a Post Card
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Create a\nPost',
                    subtitle: 'Ask a question or share something in\nthe community',
                    icon: Icons.add_comment_rounded,
                    onTap: () => _navigate(context, const CreatePostPage()),
                    bgColor: cardBg,
                    iconColor: brandOrange,
                  ),
                ),
                const SizedBox(width: 12),
                // 2. Sell an Item Card
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Sell an Item',
                    subtitle: 'Post something for sale on the\nmarket',
                    icon: Icons.shopping_bag_rounded,
                    onTap: () => _navigate(context, const SellItemPage()),
                    bgColor: cardBg,
                    iconColor: brandOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor, iconColor.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
