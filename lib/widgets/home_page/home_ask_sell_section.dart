import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ForUMHUB/pages/create_post_page.dart';
import 'package:ForUMHUB/pages/sell_item_page.dart';

class HomeAskSellSection extends StatelessWidget {
  const HomeAskSellSection({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService _userService = UserService();
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              StreamBuilder<Map<String, dynamic>?>(
                stream: userId != null ? _userService.getUserDataStream(userId) : Stream.value(null),
                builder: (context, snapshot) {
                  final photo = snapshot.data?['photoUrl'];
                  return Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
                    child: ClipOval(
                      child: photo != null ? Image.network(photo, fit: BoxFit.cover) : const Icon(Icons.person, color: Colors.grey),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'What do you want to ask or sell?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniButton(context, Icons.sell_outlined, 'Sell', Colors.grey[600]!, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SellItemPage()));
              }),
              const SizedBox(width: 12),
              _buildMiniButton(context, Icons.chat_bubble_outline, 'Ask', Colors.grey[600]!, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage()));
              }),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB8C00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
