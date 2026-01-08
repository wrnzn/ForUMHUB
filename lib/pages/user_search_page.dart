import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/user_search_service.dart';
import 'package:ForUMHUB/services/message_service.dart';
import 'package:ForUMHUB/services/user_service.dart'; // Added UserService
import 'package:ForUMHUB/models/chat_model.dart';
import 'package:ForUMHUB/pages/conversation_page.dart';
import 'package:ForUMHUB/pages/profile_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final UserSearchService _userSearchService = UserSearchService();
  final MessageService _messageService = MessageService();
  final UserService _userService = UserService(); // Initialize UserService
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startConversation(Map<String, dynamic> user) async {
    try {
      final chatId = await _messageService.getOrCreateChatId(user['userId'], otherUserName: user['name']);
      final chatItem = ChatItemModel(
        id: chatId, name: user['name'], lastMessage: '', time: '', unreadCount: 0, avatarUrl: user['avatarUrl'],
      );
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(chatPartner: chatItem)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Search Users', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Type a name...',
                prefixIcon: const Icon(Icons.search, color: brandOrange),
                filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _searchQuery.isEmpty ? _userSearchService.getAllUsers() : _userSearchService.searchUsers(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final users = snapshot.data ?? [];
                final Map<String, Map<String, dynamic>> uniqueUsers = {};
                for (var user in users) {
                  final name = user['name'];
                  if (!uniqueUsers.containsKey(name) || (user['avatarUrl'] != null && uniqueUsers[name]!['avatarUrl'] == null)) {
                    uniqueUsers[name] = user;
                  }
                }
                final filteredList = uniqueUsers.values.toList();

                if (filteredList.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => _buildUserTile(filteredList[index], brandOrange),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[100]!)),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: user['name']))),
        leading: StreamBuilder<Map<String, dynamic>?>(
          // FIXED: Fetching live user photo from Firestore
          stream: _userService.getUserDataStream(user['userId']),
          builder: (context, snapshot) {
            final photo = snapshot.data?['photoUrl'];
            return Container(
              width: 45, height: 45,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
              child: ClipOval(
                child: photo != null && photo.isNotEmpty
                  ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.person, color: Colors.grey[400])) 
                  : Icon(Icons.person, color: Colors.grey[400]),
              ),
            );
          },
        ),
        title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${user['course']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(
          icon: Icon(Icons.chat_bubble_outline_rounded, color: color),
          onPressed: () => _startConversation(user),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_search_rounded, size: 64, color: Colors.grey[200]), const SizedBox(height: 16), const Text('No users found', style: TextStyle(color: Colors.grey))]));
  }
}
