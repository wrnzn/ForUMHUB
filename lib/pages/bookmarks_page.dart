import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';
import 'package:ForUMHUB/widgets/market_page/market_product_card.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostService _postService = PostService();
  final MarketService _marketService = MarketService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('My Bookmarks', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: brandOrange,
          indicatorColor: brandOrange,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Posts'), Tab(text: 'Market')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBookmarkedPosts(), _buildBookmarkedProducts()],
      ),
    );
  }

  Widget _buildBookmarkedPosts() {
    return StreamBuilder<List<Post>>(
      stream: userId.isNotEmpty ? _postService.getBookmarkedPosts(userId) : Stream.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) return _buildEmptyState('No saved posts');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return HomePostCardFixed(
              postId: post.id, title: post.title, author: post.authorName, authorId: post.authorId,
              authorPhotoUrl: post.authorPhotoUrl, course: post.course ?? 'General', category: post.category,
              timestamp: post.formattedTimestamp, description: post.description,
              upvotes: post.upvotes, bookmarks: post.bookmarks, commentCount: post.commentCount,
              postImages: post.avatarUrls,
            );
          },
        );
      },
    );
  }

  Widget _buildBookmarkedProducts() {
    return StreamBuilder<List<Product>>(
      stream: userId.isNotEmpty ? _marketService.getBookmarkedProducts(userId) : Stream.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data ?? [];
        if (products.isEmpty) return _buildEmptyState('No saved items');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) => MarketProductCard(product: products[index], onLike: () {}),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey[200]), const SizedBox(height: 16), Text(message, style: const TextStyle(color: Colors.grey))]));
  }
}
