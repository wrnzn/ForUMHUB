import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/chat_model.dart';
import 'package:ForUMHUB/widgets/chat/chat_search_bar.dart';
import 'package:ForUMHUB/pages/conversation_page.dart';
import 'package:ForUMHUB/pages/user_search_page.dart';
import 'package:ForUMHUB/services/chat_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatService.deleteSelfChats();
  }

  String _formatShortTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(timeStr);
      final Duration diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${(diff.inDays / 7).floor()}we';
    } catch (e) { return ''; }
  }

  void _openChat(ChatItemModel item) async {
    try {
      await FirebaseFirestore.instance.collection('chats').doc(item.id).update({'unreadCount': 0});
    } catch (e) { debugPrint('Error: $e'); }
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(chatPartner: item)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Messages', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black87), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserSearchPage()))),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), child: ChatSearchBar(onChanged: (q) => setState(() => _searchQuery = q))),
          Expanded(
            child: StreamBuilder<List<ChatItemModel>>(
              // Search is handled locally in _buildChatCard now for better accuracy
              stream: _chatService.getConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final chats = snapshot.data ?? [];
                if (chats.isEmpty) return _buildEmptyState();
                
                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final item = chats[index];
                      return _buildChatCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(ChatItemModel item) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseFirestore.instance.collection('chats').doc(item.id).snapshots().map((doc) => doc.data()),
      builder: (context, chatSnap) {
        if (!chatSnap.hasData) return const SizedBox();
        final chatData = chatSnap.data!;
        final participants = List<String>.from(chatData['participants'] ?? []);
        final partnerId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
        final lastSenderId = chatData['lastSenderId'] ?? '';

        return StreamBuilder<Map<String, dynamic>?>(
          stream: _userService.getUserDataStream(partnerId),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            
            final partnerName = userSnap.data?['name'] ?? 'User';
            final partnerPhoto = userSnap.data?['photoUrl'];
            
            // FIXED: Search check - only show if name matches the search query
            if (_searchQuery.isNotEmpty && !partnerName.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return const SizedBox();
            }

            final bool isUnreadForMe = (item.unreadCount > 0) && (lastSenderId != currentUserId);

            final updatedItem = ChatItemModel(
              id: item.id, name: partnerName, lastMessage: item.lastMessage,
              time: item.time, avatarUrl: partnerPhoto, unreadCount: item.unreadCount,
            );

            return AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: isUnreadForMe ? const Color(0xFFFB8C00).withOpacity(0.05) : Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          onTap: () => _openChat(updatedItem),
                          leading: _buildAvatar(partnerPhoto),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(partnerName, style: TextStyle(fontWeight: isUnreadForMe ? FontWeight.bold : FontWeight.w600, fontSize: 16))),
                              Text(_formatShortTime(item.time), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(item.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUnreadForMe ? Colors.black87 : Colors.grey[600], fontSize: 14, fontWeight: isUnreadForMe ? FontWeight.bold : FontWeight.normal))),
                                if (isUnreadForMe)
                                  Container(margin: const EdgeInsets.only(left: 8), width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFB8C00), shape: BoxShape.circle)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey))
            : const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[200]), const SizedBox(height: 16), const Text('No conversations yet', style: TextStyle(color: Colors.grey))]));
  }
}
