import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';
import 'package:ForUMHUB/widgets/market_page/market_product_card.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/models/chat_model.dart';
import 'package:ForUMHUB/pages/edit_profile_page.dart';
import 'package:ForUMHUB/pages/conversation_page.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String name; 
  final int initialTabIndex;

  const ProfilePage({
    super.key,
    required this.name,
    this.initialTabIndex = 0,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostService _postService = PostService();
  final MarketService _marketService = MarketService();
  final UserService _userService = UserService();
  final MessageService _messageService = MessageService();
  
  String? _profileUserId;
  String? _userCourse;
  String? _photoUrl;
  String? _userBio;
  bool _isLoading = true;
  bool _isMe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _loadProfileData();
  }

  String _formatCourse(String fullCourse) {
    return fullCourse
        .replaceAll('Bachelor of Science in ', '')
        .replaceAll('Bachelor of ', '')
        .replaceAll('Associate in ', '');
  }

  Future<void> _loadProfileData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final targetUserId = await _userService.getUserIdByName(widget.name);
    
    if (targetUserId != null) {
      if (mounted) setState(() { _profileUserId = targetUserId; _isMe = currentUserId == targetUserId; });
      final userData = await _userService.getUserData(targetUserId);
      if (mounted) {
        setState(() {
          _userCourse = userData?['course'] ?? 'No course';
          _photoUrl = userData?['photoUrl'];
          _userBio = userData?['bio'] ?? '';
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStartChat() async {
    if (_profileUserId == null) return;
    try {
      final chatId = await _messageService.getOrCreateChatId(_profileUserId!, otherUserName: widget.name);
      if (mounted) {
        final chatItem = ChatItemModel(
          id: chatId, name: widget.name, lastMessage: '', time: '', avatarUrl: _photoUrl, unreadCount: 0,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(chatPartner: chatItem)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chat Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (_isMe)
            IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFFFB8C00)), onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
              _loadProfileData();
            })
          else
            // Added Chat Button for other users
            IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFFB8C00)), onPressed: _handleStartChat),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                _buildProfileCircle(),
                const SizedBox(height: 12),
                Text(widget.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFB8C00).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(_formatCourse(_userCourse ?? ''), style: const TextStyle(color: Color(0xFFFB8C00), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 12),
                if (_userBio != null && _userBio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(_userBio!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
                  ),
                const SizedBox(height: 16),
                _buildStats(),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFFB8C00),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFFB8C00),
            tabs: const [Tab(text: 'Posts'), Tab(text: 'Market')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildUserPosts(), _buildUserMarket()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCircle() {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFB8C00), width: 3)),
      child: ClipOval(
        child: _photoUrl != null && _photoUrl!.isNotEmpty
            ? Image.network(_photoUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 60, color: Colors.grey))
            : const Icon(Icons.person, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _buildStats() {
    if (_profileUserId == null) return const SizedBox();
    return StreamBuilder<List<Post>>(
      stream: _postService.getPostsByUser(_profileUserId!),
      builder: (context, postSnapshot) {
        return StreamBuilder<List<Product>>(
          stream: _marketService.getProductsByUser(_profileUserId!),
          builder: (context, productSnapshot) {
            final postCount = postSnapshot.data?.length ?? 0;
            final marketCount = productSnapshot.data?.length ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatColumn('Posts', '$postCount'),
                _buildDivider(),
                _buildStatColumn('Market', '$marketCount'),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserPosts() {
    if (_profileUserId == null) return const SizedBox();
    return StreamBuilder<List<Post>>(
      stream: _postService.getPostsByUser(_profileUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) return const Center(child: Text('No posts yet.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HomePostCardFixed(
                postId: post.id, title: post.title, author: post.authorName, authorId: post.authorId,
                authorPhotoUrl: post.authorPhotoUrl, course: post.course ?? 'General', category: post.category,
                timestamp: post.formattedTimestamp, description: post.description,
                upvotes: post.upvotes, bookmarks: post.bookmarks, commentCount: post.commentCount,
                postImages: post.avatarUrls,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserMarket() {
    if (_profileUserId == null) return const SizedBox();
    return StreamBuilder<List<Product>>(
      stream: _marketService.getProductsByUser(_profileUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const Center(child: Text('No items for sale.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) => MarketProductCard(product: products[index], onLike: () {}),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))]);
  }

  Widget _buildDivider() => Container(height: 20, width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 20));
}
